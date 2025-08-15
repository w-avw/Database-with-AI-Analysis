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
    const { items } = req.body;

    try {
        // Load the template
        const templatePath = path.resolve(__dirname, '../templates/template.docx');
        const content = fs.readFileSync(templatePath, 'binary');

        const zip = new PizZip(content);
        const doc = new Docxtemplater(zip, { paragraphLoop: true, linebreaks: true });

        // Replace placeholders with actual values
        doc.setData({
            items: items.join(", "),
            date: new Date().toLocaleDateString()
        });

        doc.render();

        // Generate buffer and send as download
        const buffer = doc.getZip().generate({ type: 'nodebuffer' });
        
        res.setHeader('Content-Disposition', 'attachment; filename=final.docx');
        res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document');
        res.send(buffer);

    } catch (error) {
        console.error('Error generating document:', error);
        res.status(500).send('Error generating document: ' + error.message);
    }
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => console.log(`Word Integration API running on port ${PORT}`));