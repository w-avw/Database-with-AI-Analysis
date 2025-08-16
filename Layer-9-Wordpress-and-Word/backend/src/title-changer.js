const fs = require('fs');
const path = require('path');
const createReport = require('docx-templates').default;

// File paths
const templatePath = path.join(__dirname, '../templates/RPM_PR-_3240_ESTACIÓN_BASE1_20250324_01_LAND_MOBILE_RADIO_NETWORK_FOR_NEW_JERSEY_TRANSIT(NJT).docm');
const outputPath = path.join(__dirname, '../output/edited_document.docm');

async function changeTitle(newTitle) {
    try {
        console.log(`📝 Changing title to: "${newTitle}"`);
        
        // Read the template
        const template = fs.readFileSync(templatePath);
        
        // Create report with new title
        const buffer = await createReport({
            template,
            data: { 
                TITLE: newTitle,
                // Add more data fields if needed
                PROTOCOLO: newTitle  // Alternative field name
            },
            cmdDelimiter: ['{', '}'],  // Use {TITLE} syntax
        });
        
        // Save the edited document
        fs.writeFileSync(outputPath, buffer);
        
        console.log('✅ Title changed successfully!');
        console.log('📊 File size:', fs.statSync(outputPath).size, 'bytes');
        
        return true;
        
    } catch (error) {
        console.error('❌ Error changing title:', error);
        
        // Try with different delimiter
        try {
            console.log('🔄 Trying with different delimiters...');
            const template = fs.readFileSync(templatePath);
            
            const buffer = await createReport({
                template,
                data: { 
                    TITLE: newTitle,
                    PROTOCOLO: newTitle
                },
                cmdDelimiter: ['{{', '}}'],  // Try {{TITLE}} syntax
            });
            
            fs.writeFileSync(outputPath, buffer);
            console.log('✅ Title changed with different delimiters!');
            return true;
            
        } catch (secondError) {
            console.error('❌ Both attempts failed:', secondError);
            
            // Fallback: just copy original
            fs.copyFileSync(templatePath, outputPath);
            return false;
        }
    }
}

// Test the function
if (require.main === module) {
    changeTitle('TEST TITLE CHANGE')
        .then(success => {
            console.log(success ? '✅ SUCCESS' : '❌ FAILED');
            process.exit(success ? 0 : 1);
        })
        .catch(error => {
            console.error('❌ FATAL ERROR:', error);
            process.exit(1);
        });
}

module.exports = { changeTitle };
