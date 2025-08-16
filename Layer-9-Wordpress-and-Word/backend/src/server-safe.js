const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');
const { changeTitle } = require('./title-changer');

const app = express();
const PORT = 3002;

// Enable CORS
app.use(cors({
    origin: '*',
    methods: ['GET', 'POST', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use(express.json());

// File paths
const templatePath = path.join(__dirname, '../templates/RPM_PR-_3240_ESTACIÓN_BASE1_20250324_01_LAND_MOBILE_RADIO_NETWORK_FOR_NEW_JERSEY_TRANSIT(NJT).docm');
const editedPath = path.join(__dirname, '../output/edited_document.docm');

// Memory storage
let currentEditedTitle = null;
const ORIGINAL_TITLE = "PROTOCOLO MANTENIMIENTO REMOTO ESTACIÓN BASE NEBULA";

// API Endpoints
app.get('/status', (req, res) => {
    try {
        const editedExists = fs.existsSync(editedPath);
        
        res.json({
            success: true,
            originalTitle: ORIGINAL_TITLE,
            currentTitle: currentEditedTitle || ORIGINAL_TITLE,
            isEdited: !!currentEditedTitle,
            editedFileExists: editedExists
        });
    } catch (error) {
        res.status(500).json({ 
            success: false, 
            message: 'Failed to get status', 
            error: error.message 
        });
    }
});

app.post('/edit', async (req, res) => {
    try {
        const newTitle = req.body.newTitle || req.body.newText;
        const section = req.body.section || 'title';
        
        if (!newTitle) {
            return res.status(400).json({ 
                success: false, 
                message: 'Missing newTitle or newText parameter' 
            });
        }

        console.log(`📝 Editing ${section} to: "${newTitle}"`);
        
        if (section === 'title') {
            const success = await changeTitle(newTitle);
            
            if (success) {
                currentEditedTitle = newTitle;
                
                res.json({ 
                    success: true, 
                    message: `Title updated to "${newTitle}"`,
                    originalTitle: ORIGINAL_TITLE,
                    newTitle: newTitle
                });
            } else {
                res.status(500).json({ 
                    success: false, 
                    message: 'Failed to edit document' 
                });
            }
        } else {
            res.status(400).json({ 
                success: false, 
                message: `Section "${section}" not supported yet` 
            });
        }
        
    } catch (error) {
        console.error('❌ Edit error:', error);
        res.status(500).json({ 
            success: false, 
            message: 'Server error during edit',
            error: error.message 
        });
    }
});

app.post('/remove', (req, res) => {
    try {
        // Copy original to restore
        fs.copyFileSync(templatePath, editedPath);
        currentEditedTitle = null;
        
        console.log('✅ Document reset to original');
        
        res.json({ 
            success: true, 
            message: 'Edit removed, original title restored',
            originalTitle: ORIGINAL_TITLE
        });
    } catch (error) {
        console.error('❌ Remove error:', error);
        res.status(500).json({ 
            success: false, 
            message: 'Failed to remove edit',
            error: error.message 
        });
    }
});

app.get('/export', (req, res) => {
    try {
        const filePath = fs.existsSync(editedPath) ? editedPath : templatePath;
        const filename = currentEditedTitle ? 'Edited_Document.docm' : 'Original_Document.docm';
        
        res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
        res.setHeader('Content-Type', 'application/vnd.ms-word.document.macroEnabled.12');
        res.setHeader('Content-Length', fs.statSync(filePath).size);
        
        console.log(`📥 Exporting: ${filename} (${fs.statSync(filePath).size} bytes)`);
        
        res.sendFile(path.resolve(filePath));
    } catch (error) {
        console.error('❌ Export error:', error);
        res.status(500).json({ 
            success: false, 
            message: 'Failed to export document', 
            error: error.message 
        });
    }
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Working Word Integration Server running on port ${PORT}`);
    console.log(`📁 Template: ${templatePath}`);
    console.log(`📁 Output: ${editedPath}`);
    console.log(`🌐 Public URL: https://didactic-space-succotash-4j5rv77xpp5fqg9p-3002.app.github.dev`);
});
