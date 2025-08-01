dotenv.config();

// 1. Import required modules
import express from 'express'; // Express framework for routing
import { Pool } from 'pg'; // PostgreSQL client
import dotenv from 'dotenv'; // Loads environment variables

// 2. Load environment variables from .env file
dotenv.config();

// 3. Create a new Express router instance
const router = express.Router();

// 4. Create a new PostgreSQL connection pool using environment variables
const pool = new Pool(); // Uses env vars for config

// 5. GET /api/calls - Fetch the latest 100 call records from the 'calls' table
router.get('/calls', async (req, res) => {
  // This endpoint returns the most recent 100 rows from the 'calls' table
  try {
    const result = await pool.query('SELECT * FROM calls ORDER BY id DESC LIMIT 100');
    res.json(result.rows); // Respond with the data as JSON
  } catch (err) {
    // If there's a database error, return a 500 error with details
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

// 6. GET /api/calls/:id - Fetch a single call record by its ID
router.get('/calls/:id', async (req, res) => {
  // This endpoint returns a single row from the 'calls' table by ID
  try {
    const { id } = req.params; // Extract the ID from the URL
    const result = await pool.query('SELECT * FROM calls WHERE id = $1', [id]);
    if (result.rows.length === 0) {
      // If no record is found, return a 404 error
      return res.status(404).json({ error: 'Not found' });
    }
    res.json(result.rows[0]); // Respond with the found record
  } catch (err) {
    // If there's a database error, return a 500 error with details
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

// 7. Export the router to be used in the main Express app
export default router;
