const fs = require('fs');
const PizZip = require('pizzip');
const Docxtemplater = require('docxtemplater');
const path = require('path');

const generateDocx = (items) => {
    const templatePath = path.resolve(__dirname, '../templates/template.docx');
    const content = fs.readFileSync(templatePath, 'binary');

    const zip = new PizZip(content);
    const doc = new Docxtemplater(zip, { paragraphLoop: true, linebreaks: true });

    doc.setData({
        items: items.join(", "),
        date: new Date().toLocaleDateString()
    });

    try {
        doc.render();
    } catch (error) {
        throw new Error('Error rendering document: ' + error.message);
    }

    const buffer = doc.getZip().generate({ type: 'nodebuffer' });
    return buffer;
};

module.exports = generateDocx;