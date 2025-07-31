import express from 'express';
import { connectToDatabase } from './db/connection.js';
import { configureGrafanaDatasource } from './grafana/datasource.js';
import { getChatGPTResponse } from './chatgpt/api.js';
import { logger } from './utils/logger.js';

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

const startServer = async () => {
    try {
        await connectToDatabase();
        logger.info('Database connected successfully.');

        configureGrafanaDatasource();
        logger.info('Grafana datasource configured.');

        app.listen(PORT, () => {
            logger.info(`Server is running on http://localhost:${PORT}`);
        });
    } catch (error) {
        logger.error('Error starting the server:', error);
    }
};

startServer();