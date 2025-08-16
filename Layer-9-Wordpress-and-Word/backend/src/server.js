const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');
const { TemplateHandler } = require('easy-template-x');

const app = express();
const PORT = 3002;

// Enable CORS
app.use(cors({ origin: '*' }));
app.use(express.json());

// File paths - using clean .docx format
const originalPath = path.resolve(process.cwd(), 'templates/original.docx');
const outputPath = path.resolve(process.cwd(), 'output/edited_document.docx');

// Memory storage
let currentTitle = null;
const ORIGINAL_TITLE = "PROTOCOLO MANTENIMIENTO REMOTO ESTACIÓN BASE NEBULA";

// Change title using easy-template-x with .docx - SIMPLE approach
async function changeTitle(newTitle) {
    try {
        console.log(`📝 Processing .docx title: "${newTitle}"`);
        
        // Read the original clean .docx file
        const originalBuffer = fs.readFileSync(originalPath);
        
        // First, replace the original title with {{TITLE}} placeholder in the binary content
        const originalString = originalBuffer.toString('binary');
        const templateString = originalString.replace(
            new RegExp(ORIGINAL_TITLE, 'g'), 
            '{{TITLE}}'
        );
        const templateBuffer = Buffer.from(templateString, 'binary');
        
        // Now use easy-template-x to replace {{TITLE}} with the new title
        const handler = new TemplateHandler();
        const doc = await handler.process(templateBuffer, { TITLE: newTitle });
        
        // Save the final document
        fs.writeFileSync(outputPath, doc);
        console.log('✅ .docx document processed successfully');
        return true;
        
    } catch (error) {
        console.error('❌ Processing error:', error);
        return false;
    }
}

// API Endpoints
app.post('/edit', async (req, res) => {
    const newTitle = req.body.newTitle || req.body.newText;
    
    if (!newTitle) {
        return res.status(400).json({ success: false, message: 'Missing title' });
    }
    
    const success = await changeTitle(newTitle);
    
    if (success) {
        currentTitle = newTitle;
        res.json({ 
            success: true, 
            message: `Title updated to "${newTitle}"`,
            newTitle: newTitle
        });
    } else {
        res.status(500).json({ success: false, message: 'Failed to update title' });
    }
});

app.post('/remove', async (req, res) => {
    const success = await changeTitle(ORIGINAL_TITLE);
    
    if (success) {
        currentTitle = null;
        res.json({ success: true, message: 'Title restored to original' });
    } else {
        res.status(500).json({ success: false, message: 'Failed to restore title' });
    }
});

app.get('/export', (req, res) => {
    const filename = currentTitle ? 'Edited_Document.docx' : 'Original_Document.docx';
    
    res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
    res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document');
    res.sendFile(path.resolve(outputPath));
});

app.get('/status', (req, res) => {
    res.json({
        success: true,
        originalTitle: ORIGINAL_TITLE,
        currentTitle: currentTitle || ORIGINAL_TITLE,
        isEdited: !!currentTitle,
        format: '.docx'
    });
});

// Initialize and start
console.log('🚀 Starting Clean .docx Server...');
console.log('📁 Original file:', originalPath);
console.log('📁 Output file:', outputPath);
app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Clean .docx Server running on port ${PORT}`);
    console.log(`🌐 URL: https://didactic-space-succotash-4j5rv77xpp5fqg9p-3002.app.github.dev`);
});