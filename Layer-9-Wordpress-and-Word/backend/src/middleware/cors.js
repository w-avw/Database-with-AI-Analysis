const cors = require('cors');

const corsOptions = {
    origin: 'https://your-wordpress-site.com', // Replace with your WordPress site URL
    methods: ['GET', 'POST'],
    allowedHeaders: ['Content-Type'],
};

module.exports = cors(corsOptions);