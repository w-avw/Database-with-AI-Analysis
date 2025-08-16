const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = 3002;

// Enable CORS
app.use(cors({ origin: '*' }));
app.use(express.json());

// File paths
const originalFile = '/workspaces/Universal-DB/Layer-9-Wordpress-and-Word/backend/templates/original.docx';
const outputFile = '/workspaces/Universal-DB/Layer-9-Wordpress-and-Word/backend/output/edited_document.docx';

// Memory storage
let currentTitle = null;
const ORIGINAL_TITLE = "PROTOCOLO MANTENIMIENTO REMOTO ESTACIÓN BASE NEBULA";

// Simple binary replacement function
function replaceInDocx(inputPath, outputPath, oldText, newText) {
    console.log(`📝 Replacing "${oldText}" with "${newText}"`);
    
    const content = fs.readFileSync(inputPath, 'binary');
    const newContent = content.replace(new RegExp(oldText, 'g'), newText);
    fs.writeFileSync(outputPath, newContent, 'binary');
    
    console.log(`✅ File processed successfully`);
    return true;
}

// API Endpoints
app.post('/edit', async (req, res) => {
    try {
        const newTitle = req.body.newTitle || req.body.newText;
        
        if (!newTitle) {
            return res.status(400).json({ success: false, message: 'Missing title' });
        }
        
        replaceInDocx(originalFile, outputFile, ORIGINAL_TITLE, newTitle);
        currentTitle = newTitle;
        
        res.json({ 
            success: true, 
            message: `Title updated to "${newTitle}"`,
            newTitle: newTitle
        });
    } catch (error) {
        console.error('❌ Error:', error);
        res.status(500).json({ success: false, message: 'Failed to update title' });
    }
});

app.post('/remove', async (req, res) => {
    try {
        replaceInDocx(originalFile, outputFile, currentTitle || ORIGINAL_TITLE, ORIGINAL_TITLE);
        currentTitle = null;
        
        res.json({ success: true, message: 'Title restored to original' });
    } catch (error) {
        console.error('❌ Error:', error);
        res.status(500).json({ success: false, message: 'Failed to restore title' });
    }
});

app.get('/export', (req, res) => {
    try {
        const filename = currentTitle ? 'Edited_Document.docx' : 'Original_Document.docx';
        
        res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
        res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document');
        res.sendFile(path.resolve(outputFile));
    } catch (error) {
        console.error('❌ Error:', error);
        res.status(500).json({ success: false, message: 'Failed to export' });
    }
});

app.get('/status', (req, res) => {
    res.json({
        success: true,
        originalTitle: ORIGINAL_TITLE,
        currentTitle: currentTitle || ORIGINAL_TITLE,
        isEdited: !!currentTitle,
        approach: 'simple-binary-replacement'
    });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Simple Working Server running on port ${PORT}`);
    console.log(`🌐 URL: https://didactic-space-succotash-4j5rv77xpp5fqg9p-3002.app.github.dev`);
    console.log(`📁 Template: ${originalFile}`);
    console.log(`📁 Output: ${outputFile}`);
});
