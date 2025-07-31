
import fs from 'fs';
import path from 'path';
import { Pool } from 'pg';
import readline from 'readline';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const pool = new Pool(); // Uses env vars for config

const DATA_DIR = path.join(__dirname, '../../data');
const PROCESSED_DIR = path.join(DATA_DIR, 'processed');

if (!fs.existsSync(PROCESSED_DIR)) {
  fs.mkdirSync(PROCESSED_DIR, { recursive: true });
}

async function importTxtFiles() {
  const files = fs.readdirSync(DATA_DIR).filter(f => f.endsWith('.txt'));
  if (files.length === 0) {
    console.log('🟡 No new .txt files to import.');
    return;
  }
  for (const file of files) {
    const filePath = path.join(DATA_DIR, file);
    try {
      const imported = await importSingleFile(filePath);
      if (imported) {
        fs.renameSync(filePath, path.join(PROCESSED_DIR, file));
        console.log(`✅ Imported and moved: ${file}`);
      } else {
        // File was duplicate, do not move
        console.log(`⚠️ Skipped (duplicate data): ${file}`);
      }
    } catch (err) {
      console.error(`❌ Error importing ${file}:`, err);
    }
  }
}

async function importSingleFile(filePath) {
  const rl = readline.createInterface({
    input: fs.createReadStream(filePath),
    crlfDelay: Infinity
  });

  let headers = [];
  let isFirstLine = true;
  let insertedAny = false;
  let duplicateCount = 0;
  let totalCount = 0;
  const client = await pool.connect();

  try {
    for await (const line of rl) {
      if (isFirstLine) {
        headers = line.split(';').map(h => h.trim().replace(/[^\w]/g, '_').toLowerCase());
        isFirstLine = false;
        continue;
      }
      if (!line.trim()) continue;
      totalCount++;
      const values = line.split(';').map(v => v.trim());
      // Assume first column is unique ID
      const idValue = values[0];
      const idCol = headers[0];
      const checkQuery = `SELECT 1 FROM calls WHERE ${idCol} = $1 LIMIT 1`;
      const checkRes = await client.query(checkQuery, [idValue]);
      if (checkRes.rows.length > 0) {
        duplicateCount++;
        continue; // Skip duplicate
      }
      const placeholders = values.map((_, i) => `$${i + 1}`).join(',');
      const query = `INSERT INTO calls (${headers.join(',')}) VALUES (${placeholders})`;
      await client.query(query, values);
      insertedAny = true;
    }
    if (duplicateCount === totalCount && totalCount > 0) {
      // All rows were duplicates
      return false;
    }
    return insertedAny;
  } catch (err) {
    console.error('❌ Error during file import:', err);
    throw err;
  } finally {
    client.release();
  }
}

export default importTxtFiles;
