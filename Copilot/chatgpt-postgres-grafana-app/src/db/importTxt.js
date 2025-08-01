// This file is responsible for importing text files into the database.
// It processes each .txt file found in the data directory.
// [ARCHIVED: Use PostgreSQL COPY for bulk import. See README.]

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


  // Hardcoded table and columns to match your DB schema
  const tableName = 'mydb'; // TODO: Replace with your actual table name
  // Example: adjust this array to match your table columns in order
  const dbColumns = [
    'ID', // e.g. id
    'Date', // e.g. name
    'Time',// ... add all columns in order as in your schema
    'Source type',
    'Source',
    'Source fleet',
    'Destination type',
    'Destination',
    'Destination fleet',
    'Service type',
    'Service type info',
    'AI security',
    'E2EE security',
    'Disconnection cause',
    'Duration (secs.)',
    'Time in queue (secs.)',
    'Priority',
    'Source location',
    'Cell reselection',
    'Status',
    'Voice recording',
    'Call forwarding',
    'Source NMS',
    'Network Controller',
    'UTC offset (minutes)',
    
  ];

  let headers = [];
  let isFirstLine = true;
  let insertedAny = false;
  let duplicateCount = 0;
  let totalCount = 0;
  const client = await pool.connect();

  try {
    for await (let line of rl) {
      line = line.trim();
      if (isFirstLine) {
        headers = line.split(';').map(h => h.trim());
        isFirstLine = false;
        continue;
      }
      if (!line) continue; // skip empty lines
      totalCount++;
      // Use ';' as the delimiter to match your data file, and convert empty fields to null
      const values = line.split(';').map(v => v.trim() === '' ? null : v.trim());
      if (values.length !== dbColumns.length) {
        console.error(`⚠️ Skipping line: expected ${dbColumns.length} columns, got ${values.length}. Line:`, line);
        continue; // skip instead of throwing
      }
      // Optionally check for duplicates if your schema requires
      // const idValue = values[0];
      // const idCol = dbColumns[0];
      // const checkQuery = `SELECT 1 FROM ${tableName} WHERE ${idCol} = $1 LIMIT 1`;
      // const checkRes = await client.query(checkQuery, [idValue]);
      // if (checkRes.rows.length > 0) {
      //   duplicateCount++;
      //   continue; // Skip duplicate
      // }
      const placeholders = values.map((_, i) => `$${i + 1}`).join(', ');
      const query = `INSERT INTO ${tableName} (${dbColumns.join(', ')}) VALUES (${placeholders})`;
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
