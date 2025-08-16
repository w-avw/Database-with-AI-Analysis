<div id="word-integration-panel" style="padding: 20px; border: 1px solid #ddd; margin: 20px 0;">
    <h3>Word Document Modifier</h3>
    
    <div style="margin-bottom: 20px;">
        <h4>Add Content</h4>
        <textarea id="addText" placeholder="Enter text to add at the beginning of the document" style="width: 100%; height: 100px;"></textarea>
        <br><br>
        <button id="addBtn" class="button button-primary">Add Content & Export</button>
    </div>
    
    <div style="margin-bottom: 20px;">
        <h4>Remove Short Paragraphs</h4>
        <p>This will remove paragraphs with 2 lines or less, or 100 characters or less.</p>
        <button id="removeBtn" class="button button-secondary">Remove Short Paragraphs & Export</button>
    </div>
    
    <div>
        <h4>Download Original</h4>
        <button id="originalBtn" class="button">Download Original Document</button>
    </div>
</div>

<script>
document.getElementById('addBtn').onclick = async () => {
    const text = document.getElementById('addText').value;
    if (!text.trim()) {
        alert('Please enter some text to add.');
        return;
    }
    
    try {
        const res = await fetch('http://localhost:3001/generate', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ action: 'add', text: text })
        });
        
        if (res.ok) {
            const blob = await res.blob();
            downloadFile(blob, 'document_with_added_content.docm');
            document.getElementById('addText').value = '';
        } else {
            alert('Error adding content to document');
        }
    } catch (error) {
        alert('Error connecting to server: ' + error.message);
    }
};

document.getElementById('removeBtn').onclick = async () => {
    if (!confirm('This will remove paragraphs with 2 lines or less, or 100 characters or less. Continue?')) {
        return;
    }
    
    try {
        const res = await fetch('http://localhost:3001/remove-paragraphs', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ maxLines: 2, maxCharacters: 100 })
        });
        
        if (res.ok) {
            const blob = await res.blob();
            downloadFile(blob, 'document_paragraphs_removed.docm');
        } else {
            alert('Error removing paragraphs from document');
        }
    } catch (error) {
        alert('Error connecting to server: ' + error.message);
    }
};

document.getElementById('originalBtn').onclick = async () => {
    try {
        const res = await fetch('http://localhost:3001/generate', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ action: 'original' })
        });
        
        if (res.ok) {
            const blob = await res.blob();
            downloadFile(blob, 'original_document.docm');
        } else {
            alert('Error downloading original document');
        }
    } catch (error) {
        alert('Error connecting to server: ' + error.message);
    }
};

function downloadFile(blob, filename) {
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    a.remove();
    window.URL.revokeObjectURL(url);
}
</script>