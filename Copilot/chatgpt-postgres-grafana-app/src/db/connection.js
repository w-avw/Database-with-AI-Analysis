import pkg from 'pg';
const { Pool } = pkg;

const pool = new Pool({
    user: process.env.PGUSER,
    host: process.env.PGHOST,
    database: process.env.PGDATABASE,
    password: process.env.PGPASSWORD,
    port: process.env.PGPORT,
});

export async function connectToDatabase() {
    try {
        await pool.connect();
        console.log('Connected to the PostgreSQL database successfully.');
    } catch (error) {
        console.error('Error connecting to the database:', error);
        throw error;
    }
}

export default pool;