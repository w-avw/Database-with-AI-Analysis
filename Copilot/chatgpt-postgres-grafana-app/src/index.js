
// 1. Load environment variables from .env file
import 'dotenv/config';

// 2. Import required modules
import express from 'express'; // Express framework
import { connectToDatabase } from './db/connection.js'; // DB connection util
import { setupGrafanaDatasource } from './grafana/datasource.js'; // Grafana integration stub
import { getChatGPTResponse } from './chatgpt/api.js'; // ChatGPT API util
import { logger } from './utils/logger.js'; // Logger util
import importTxtFiles from './db/importTxt.js'; // TXT import logic
import apiRouter from './api/index.js'; // API router


// 3. Create the Express app instance
const app = express();

// 4. Set the port from environment or default to 3000
const PORT = process.env.PORT || 3000;

// 5. Middleware to parse JSON request bodies
app.use(express.json());

// 6. Mount the API router under /api
app.use('/api', apiRouter);

// 7. Interval for scheduled TXT import (milliseconds)
const INTERVAL_MS = 15000; // 15 seconds

// 8. Function to start scheduled import of .txt files
const startScheduledImport = () => {
    setInterval(async () => {
        try {
            logger.info(`[${new Date().toISOString()}] Starting import...`);
            await importTxtFiles(); // Import new .txt files into DB
            logger.info(`[${new Date().toISOString()}] Import finished.`);
        } catch (err) {
            logger.error('Error during import:', err);
        }
    }, INTERVAL_MS);
};

// 9. Main function to start the server and services
const startServer = async () => {
    try {
        await connectToDatabase(); // Connect to PostgreSQL
        logger.info('Database connected successfully.');

        setupGrafanaDatasource(); // (Stub) Set up Grafana integration
        logger.info('Grafana datasource configured.');

        startScheduledImport(); // Start scheduled .txt import

        app.listen(PORT, () => {
            logger.info(`Server is running on http://localhost:${PORT}`);
        });
    } catch (error) {
        logger.error('Error starting the server:', error);
    }
};

// 10. Start the server
startServer();