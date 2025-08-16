const fs = require('fs');
const path = require('path');

// Simple binary string replacement that works for .docx files
function replaceInDocx(inputPath, outputPath, oldText, newText) {
    console.log(`Replacing "${oldText}" with "${newText}"`);
    
    // Read the file as binary
    const content = fs.readFileSync(inputPath, 'binary');
    
    // Simple replacement
    const newContent = content.replace(new RegExp(oldText, 'g'), newText);
    
    // Write the new file
    fs.writeFileSync(outputPath, newContent, 'binary');
    
    console.log(`✅ File processed: ${outputPath}`);
    return true;
}

// Test it
const inputFile = '/workspaces/Universal-DB/Layer-9-Wordpress-and-Word/backend/templates/original.docx';
const outputFile = '/workspaces/Universal-DB/Layer-9-Wordpress-and-Word/backend/output/test-simple.docx';
const originalTitle = "PROTOCOLO MANTENIMIENTO REMOTO ESTACIÓN BASE NEBULA";
const newTitle = "SIMPLE WORKING TITLE REPLACEMENT";

try {
    replaceInDocx(inputFile, outputFile, originalTitle, newTitle);
    console.log('✅ Success! Check the output file.');
} catch (error) {
    console.error('❌ Error:', error);
}
