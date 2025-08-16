const express = require('express');
const fs = require('fs');
const cors = require('cors');
const path = require('path');
const PizZip = require('pizzip');
const Docxtemplater = require('docxtemplater');

const app = express();
app.use(cors());
app.use(express.json());

app.post('/generate', (req, res) => {
    const { action, text } = req.body;

    try {
        // Load the .docm template
        const templatePath = path.resolve(__dirname, '../templates/RPM_PR-_3240_ESTACIÓN_BASE1_20250324_01_LAND_MOBILE_RADIO_NETWORK_FOR_NEW_JERSEY_TRANSIT(NJT).docm');
        const content = fs.readFileSync(templatePath, 'binary');

        const zip = new PizZip(content);

        if (action === 'add' && text) {
            // Add text at the beginning of the document by modifying document.xml
            const documentXml = zip.files['word/document.xml'].asText();
            
            // Create a new paragraph with the user's text
            const newParagraph = `<w:p><w:pPr><w:spacing w:before="240" w:after="240"/></w:pPr><w:r><w:rPr><w:b/></w:rPr><w:t>ADDED CONTENT: ${text}</w:t></w:r></w:p>`;
            
            // Insert after the opening body tag
            const modifiedXml = documentXml.replace(/<w:body[^>]*>/, `$&${newParagraph}`);
            
            // Update the document
            zip.file('word/document.xml', modifiedXml);
        }

        // Generate buffer and send as download
        const buffer = zip.generate({ type: 'nodebuffer' });
        
        res.setHeader('Content-Disposition', 'attachment; filename=modified_document.docm');
        res.setHeader('Content-Type', 'application/vnd.ms-word.document.macroEnabled.12');
        res.send(buffer);

    } catch (error) {
        console.error('Error generating document:', error);
        res.status(500).send('Error generating document: ' + error.message);
    }
});

// New endpoint for paragraph removal
app.post('/remove-paragraphs', (req, res) => {
    const { maxLines = 2, maxCharacters = 100 } = req.body;

    try {
        const templatePath = path.resolve(__dirname, '../templates/RPM_PR-_3240_ESTACIÓN_BASE1_20250324_01_LAND_MOBILE_RADIO_NETWORK_FOR_NEW_JERSEY_TRANSIT(NJT).docm');
        const content = fs.readFileSync(templatePath, 'binary');

        const zip = new PizZip(content);
        
        // Get the document.xml content
        const documentXml = zip.files['word/document.xml'].asText();
        
        // Basic paragraph removal logic - remove short paragraphs
        const modifiedXml = documentXml.replace(/<w:p[^>]*>.*?<\/w:p>/g, (match) => {
            // Count lines (approximated by line breaks)
            const lineCount = (match.match(/<w:br\/>/g) || []).length + 1;
            // Remove XML tags to count characters
            const textContent = match.replace(/<[^>]*>/g, '');
            
            if (lineCount <= maxLines || textContent.length <= maxCharacters) {
                return ''; // Remove the paragraph
            }
            return match; // Keep the paragraph
        });

        // Update the document
        zip.file('word/document.xml', modifiedXml);
        
        const buffer = zip.generate({ type: 'nodebuffer' });
        
        res.setHeader('Content-Disposition', 'attachment; filename=modified_document.docm');
        res.setHeader('Content-Type', 'application/vnd.ms-word.document.macroEnabled.12');
        res.send(buffer);

    } catch (error) {
        console.error('Error removing paragraphs:', error);
        res.status(500).send('Error removing paragraphs: ' + error.message);
    }
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => console.log(`Word Integration API running on port ${PORT}`));