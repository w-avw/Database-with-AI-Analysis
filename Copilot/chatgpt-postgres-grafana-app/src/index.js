import 'dotenv/config';
import express from 'express';
import { connectToDatabase } from './db/connection.js';
import { setupGrafanaDatasource } from './grafana/datasource.js';
import { getChatGPTResponse } from './chatgpt/api.js';
import { logger } from './utils/logger.js';
import importTxtFiles from './db/importTxt.js';

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

const INTERVAL_MS = 15000; // 15 seconds

const startScheduledImport = () => {
    setInterval(async () => {
        try {
            logger.info(`[${new Date().toISOString()}] Starting import...`);
            await importTxtFiles();
            logger.info(`[${new Date().toISOString()}] Import finished.`);
        } catch (err) {
            logger.error('Error during import:', err);
        }
    }, INTERVAL_MS);
};

const startServer = async () => {
    try {
        await connectToDatabase();
        logger.info('Database connected successfully.');

        setupGrafanaDatasource();
        logger.info('Grafana datasource configured.');

        startScheduledImport();

        app.listen(PORT, () => {
            logger.info(`Server is running on http://localhost:${PORT}`);
        });
    } catch (error) {
        logger.error('Error starting the server:', error);
    }
};

startServer();