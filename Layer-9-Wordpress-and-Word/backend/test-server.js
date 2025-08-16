const express = require('express');
const { TemplateHandler } = require('easy-template-x');

console.log('🚀 Starting test server...');

const app = express();
const PORT = 3002;

app.get('/test', (req, res) => {
    res.json({ status: 'working' });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`✅ Test server running on port ${PORT}`);
});
