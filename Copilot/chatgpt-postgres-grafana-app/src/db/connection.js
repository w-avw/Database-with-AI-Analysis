
// 1. Import the pg package for PostgreSQL
import pkg from 'pg';
const { Pool } = pkg;

// 2. Create a new PostgreSQL connection pool using environment variables
const pool = new Pool({
    user: process.env.PGUSER,      // DB username
    host: process.env.PGHOST,      // DB host
    database: process.env.PGDATABASE, // DB name
    password: process.env.PGPASSWORD, // DB password
    port: process.env.PGPORT,      // DB port
});

// 3. Function to test and establish a DB connection
export async function connectToDatabase() {
    try {
        await pool.connect(); // Try to connect
        console.log('Connected to the PostgreSQL database successfully.');
    } catch (error) {
        console.error('Error connecting to the database:', error);
        throw error; // Rethrow for caller to handle
    }
}

// 4. Export the pool for use in other modules
export default pool;