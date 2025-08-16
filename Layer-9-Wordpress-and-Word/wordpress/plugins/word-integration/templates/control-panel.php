<div id="word-integration-panel" style="padding: 20px; border: 1px solid #ddd; margin: 20px 0; background: #f9f9f9;">
    <h3>📄 Word Document Modifier</h3>
    
    <!-- Backend URL Configuration -->
    <div style="margin-bottom: 20px; padding: 10px; background: #fff; border: 1px solid #ccc;">
        <h4>🔧 Server Configuration</h4>
        <label for="backendUrl">Backend API URL:</label>
        <input type="text" id="backendUrl" value="http://localhost:3001" style="width: 100%; margin-top: 5px;" placeholder="e.g., https://your-backend-server.com">
        <small style="color: #666;">Change this to point to your Word processing backend server</small>
    </div>
    
    <div style="margin-bottom: 20px; padding: 10px; background: #fff; border: 1px solid #ccc;">
        <h4>➕ Add Content</h4>
        <textarea id="addText" placeholder="Enter text to add at the beginning of the document" style="width: 100%; height: 80px; margin-bottom: 10px;"></textarea>
        <button id="addBtn" class="button button-primary" style="margin-right: 10px;">Add Content & Export</button>
        <span id="addStatus" style="color: #666;"></span>
    </div>
    
    <div style="margin-bottom: 20px; padding: 10px; background: #fff; border: 1px solid #ccc;">
        <h4>➖ Remove Short Paragraphs</h4>
        <p style="margin: 5px 0; color: #666;">Remove paragraphs with:</p>
        <label style="display: block; margin: 5px 0;">
            Max Lines: <input type="number" id="maxLines" value="2" min="1" max="10" style="width: 60px;">
        </label>
        <label style="display: block; margin: 5px 0;">
            Max Characters: <input type="number" id="maxCharacters" value="100" min="1" max="500" style="width: 80px;">
        </label>
        <button id="removeBtn" class="button button-secondary" style="margin-right: 10px;">Remove Short Paragraphs & Export</button>
        <span id="removeStatus" style="color: #666;"></span>
    </div>
    
    <div style="padding: 10px; background: #fff; border: 1px solid #ccc;">
        <h4>📥 Download Original</h4>
        <button id="originalBtn" class="button" style="margin-right: 10px;">Download Original Document</button>
        <span id="originalStatus" style="color: #666;"></span>
    </div>
</div></div>

<!-- Status Messages -->
<div id="statusMessages" style="margin: 10px 0;"></div>

<script>
// Utility functions
function getBackendUrl() {
    return document.getElementById('backendUrl').value.trim() || 'http://localhost:3001';
}

function showStatus(elementId, message, isError = false) {
    const element = document.getElementById(elementId);
    element.textContent = message;
    element.style.color = isError ? '#dc3545' : '#28a745';
    setTimeout(() => { element.textContent = ''; }, 5000);
}

function showMessage(message, isError = false) {
    const container = document.getElementById('statusMessages');
    const div = document.createElement('div');
    div.style.cssText = `
        padding: 10px; 
        margin: 5px 0; 
        border-radius: 4px; 
        background: ${isError ? '#f8d7da' : '#d4edda'}; 
        color: ${isError ? '#721c24' : '#155724'}; 
        border: 1px solid ${isError ? '#f5c6cb' : '#c3e6cb'};
    `;
    div.textContent = message;
    container.appendChild(div);
    setTimeout(() => div.remove(), 5000);
}

// Add content functionality
document.getElementById('addBtn').onclick = async () => {
    const text = document.getElementById('addText').value;
    if (!text.trim()) {
        showMessage('Please enter some text to add.', true);
        return;
    }
    
    showStatus('addStatus', 'Processing...');
    
    try {
        const res = await fetch(`${getBackendUrl()}/generate`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ action: 'add', text: text })
        });
        
        if (res.ok) {
            const blob = await res.blob();
            downloadFile(blob, 'document_with_added_content.docm');
            document.getElementById('addText').value = '';
            showStatus('addStatus', 'Content added successfully!');
            showMessage('Document downloaded with added content!');
        } else {
            throw new Error(`Server error: ${res.status}`);
        }
    } catch (error) {
        showStatus('addStatus', 'Error occurred', true);
        showMessage('Error: ' + error.message, true);
    }
};

// Remove paragraphs functionality
document.getElementById('removeBtn').onclick = async () => {
    const maxLines = parseInt(document.getElementById('maxLines').value) || 2;
    const maxCharacters = parseInt(document.getElementById('maxCharacters').value) || 100;
    
    if (!confirm(`This will remove paragraphs with ${maxLines} lines or less, or ${maxCharacters} characters or less. Continue?`)) {
        return;
    }
    
    showStatus('removeStatus', 'Processing...');
    
    try {
        const res = await fetch(`${getBackendUrl()}/remove-paragraphs`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ maxLines, maxCharacters })
        });
        
        if (res.ok) {
            const blob = await res.blob();
            downloadFile(blob, 'document_paragraphs_removed.docm');
            showStatus('removeStatus', 'Paragraphs removed successfully!');
            showMessage('Document downloaded with paragraphs removed!');
        } else {
            throw new Error(`Server error: ${res.status}`);
        }
    } catch (error) {
        showStatus('removeStatus', 'Error occurred', true);
        showMessage('Error: ' + error.message, true);
    }
};

// Download original functionality
document.getElementById('originalBtn').onclick = async () => {
    showStatus('originalStatus', 'Downloading...');
    
    try {
        const res = await fetch(`${getBackendUrl()}/generate`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ action: 'original' })
        });
        
        if (res.ok) {
            const blob = await res.blob();
            downloadFile(blob, 'original_document.docm');
            showStatus('originalStatus', 'Downloaded successfully!');
            showMessage('Original document downloaded!');
        } else {
            throw new Error(`Server error: ${res.status}`);
        }
    } catch (error) {
        showStatus('originalStatus', 'Error occurred', true);
        showMessage('Error: ' + error.message, true);
    }
};

// File download utility
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

// Save backend URL to localStorage
document.getElementById('backendUrl').onchange = function() {
    localStorage.setItem('wordIntegrationBackendUrl', this.value);
};

// Load saved backend URL
document.addEventListener('DOMContentLoaded', function() {
    const savedUrl = localStorage.getItem('wordIntegrationBackendUrl');
    if (savedUrl) {
        document.getElementById('backendUrl').value = savedUrl;
    }
});
</script>