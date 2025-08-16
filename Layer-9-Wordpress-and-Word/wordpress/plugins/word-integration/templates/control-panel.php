<div id="word-integration-panel" style="padding: 20px; border: 1px solid #ddd; margin: 20px 0; background: #f9f9f9;">
    <h3>📄 Word Document Title Editor</h3>
    <p style="color: #666; margin-bottom: 20px;">Edit the first page title of your Word document template. Current title: <strong>"PROTOCOLO MANTENIMIENTO REMOTO ESTACIÓN BASE NEBULA"</strong></p>

    <!-- Current Status -->
    <div id="statusPanel" style="margin-bottom: 20px; padding: 10px; background: #fff; border: 1px solid #ccc;">
        <h4>📋 Current Status</h4>
        <div id="currentStatus" style="color: #666;">Loading status...</div>
        <button id="refreshStatus" class="button" style="margin-top: 10px;">🔄 Refresh Status</button>
    </div>
    
    <!-- Interactive Editor Bar -->
    <div id="editorBar" style="margin-bottom: 20px; padding: 15px; background: #fff; border: 1px solid #ccc; border-radius: 10px;">
        <h3>📝 Add your recommendation</h3>
        
        <!-- Dropdown to select section -->
        <label for="sectionSelect" style="display: block; margin-bottom: 5px; font-weight: bold;">Select section:</label>
        <select id="sectionSelect" style="width: 100%; padding: 8px; margin-bottom: 15px; border: 1px solid #ddd; border-radius: 4px;">
            <option value="title">Title (PROTOCOLO MANTENIMIENTO REMOTO ESTACIÓN BASE NEBULA)</option>
        </select>
        
        <!-- Input for new text -->
        <label for="newText" style="display: block; margin-bottom: 5px; font-weight: bold;">New text:</label>
        <input type="text" id="newText" placeholder="Enter your recommendation" style="width: 100%; padding: 8px; margin-bottom: 15px; border: 1px solid #ddd; border-radius: 4px;" maxlength="200">
        
        <!-- Submit button -->
        <button id="addSubmit" class="button button-primary" style="padding: 10px 20px;">� Apply Changes</button>
        <span id="addStatus" style="color: #666; margin-left: 10px;"></span>
    </div>
    
    <!-- Button 2: Remove Edit -->
    <div style="margin-bottom: 20px; padding: 10px; background: #fff; border: 1px solid #ccc;">
        <h4>🗑️ Button 2: Remove Edit</h4>
        <p style="color: #666; margin: 5px 0;">Restore the original title by removing any edits made:</p>
        <button id="removeBtn" class="button button-secondary" style="margin-right: 10px;">↶ Remove Edit (Restore Original)</button>
        <span id="removeStatus" style="color: #666;"></span>
    </div>
    
    <!-- Button 3: Export Document -->
    <div style="padding: 10px; background: #fff; border: 1px solid #ccc;">
        <h4>� Button 3: Export Document</h4>
        <p style="color: #666; margin: 5px 0;">Download the document with your changes (saves as a copy, doesn't overwrite template):</p>
        <button id="exportBtn" class="button button-success" style="margin-right: 10px; background: #28a745; border-color: #28a745; color: white;">📥 Export Document</button>
        <span id="exportStatus" style="color: #666;"></span>
    </div>
</div>

<!-- Status Messages -->
<div id="statusMessages" style="margin: 10px 0;"></div>

<script>
// Utility functions
function getBackendUrl() {
    return 'https://didactic-space-succotash-4j5rv77xpp5fqg9p-3002.app.github.dev';
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

// Load and display current status
async function loadStatus() {
    try {
        const res = await fetch(`${getBackendUrl()}/status`);
        const data = await res.json();
        
        if (data.success) {
            const statusDiv = document.getElementById('currentStatus');
            statusDiv.innerHTML = `
                <strong>Original Title:</strong> "${data.originalTitle}"<br>
                <strong>Current Title:</strong> "${data.currentTitle}"<br>
                <strong>Status:</strong> ${data.isEdited ? '✏️ Modified' : '📄 Original'}<br>
                <strong>Edited File:</strong> ${data.editedFileExists ? '✅ Exists' : '❌ Not created'}
            `;
            statusDiv.style.color = '#333';
        } else {
            throw new Error(data.message);
        }
    } catch (error) {
        document.getElementById('currentStatus').innerHTML = `❌ Error loading status: ${error.message}`;
        document.getElementById('currentStatus').style.color = '#dc3545';
    }
}

// Interactive Editor Bar functionality
document.getElementById('addSubmit').onclick = async () => {
    const section = document.getElementById('sectionSelect').value;
    const newText = document.getElementById('newText').value.trim();
    
    if (!newText) {
        showMessage('Please enter your recommendation text.', true);
        return;
    }
    
    showStatus('addStatus', 'Applying changes...');
    
    try {
        const res = await fetch(`${getBackendUrl()}/edit`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ section: section, newText: newText })
        });
        
        const data = await res.json();
        
        if (data.success) {
            document.getElementById('newText').value = '';
            showStatus('addStatus', 'Changes applied successfully!');
            showMessage(`${section} updated to: "${newText}"`);
            loadStatus(); // Refresh status
        } else {
            throw new Error(data.message);
        }
    } catch (error) {
        showStatus('addStatus', 'Error occurred', true);
        showMessage('Error: ' + error.message, true);
    }
};

// Button 2: Remove edit functionality
document.getElementById('removeBtn').onclick = async () => {
    if (!confirm('This will restore the original title. Are you sure?')) {
        return;
    }
    
    showStatus('removeStatus', 'Removing edit...');
    
    try {
        const res = await fetch(`${getBackendUrl()}/remove`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'}
        });
        
        const data = await res.json();
        
        if (data.success) {
            showStatus('removeStatus', 'Edit removed successfully!');
            showMessage(`Title restored to original: "${data.originalTitle}"`);
            loadStatus(); // Refresh status
        } else {
            throw new Error(data.message);
        }
    } catch (error) {
        showStatus('removeStatus', 'Error occurred', true);
        showMessage('Error: ' + error.message, true);
    }
};

// Button 3: Export document functionality (Preview Mode Compatible + Fallback)
document.getElementById('exportBtn').onclick = async () => {
    showStatus('exportStatus', 'Starting download...');
    
    try {
        // Method 1: Create invisible link and click it - works better in preview mode
        const downloadLink = document.createElement('a');
        downloadLink.href = `${getBackendUrl()}/export`;
        downloadLink.download = 'Edited_Document.docm'; // Suggest filename
        downloadLink.target = '_blank'; // Open in new tab if direct download fails
        downloadLink.style.display = 'none';
        
        // Add to page, click, then remove
        document.body.appendChild(downloadLink);
        downloadLink.click();
        document.body.removeChild(downloadLink);
        
        // Show success message
        setTimeout(() => {
            showStatus('exportStatus', 'Download started!');
            showMessage('Document download initiated. If download didn\'t start automatically, the file will open in a new tab.');
        }, 1000);
        
    } catch (error) {
        console.log('Link method failed, trying fetch method...');
        
        try {
            // Method 2: Fetch + Blob (fallback for strict environments)
            const response = await fetch(`${getBackendUrl()}/export`);
            if (!response.ok) throw new Error(`Server error: ${response.status}`);
            
            const blob = await response.blob();
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = 'Edited_Document.docm';
            document.body.appendChild(a);
            a.click();
            a.remove();
            window.URL.revokeObjectURL(url);
            
            showStatus('exportStatus', 'Download completed!');
            showMessage('Document downloaded successfully.');
            
        } catch (fetchError) {
            console.log('Fetch method failed, trying direct redirect...');
            
            // Method 3: Direct redirect (last resort)
            window.open(`${getBackendUrl()}/export`, '_blank');
            showStatus('exportStatus', 'Opening in new tab...');
            showMessage('Download link opened in new tab. Please check for popup blocker.');
        }
    }
};

// Refresh status button
document.getElementById('refreshStatus').onclick = loadStatus;

// Save backend URL to localStorage (disabled for read-only)
// document.getElementById('backendUrl').onchange = function() {
//     localStorage.setItem('wordIntegrationBackendUrl', this.value);
//     // Reload status when URL changes
//     setTimeout(loadStatus, 500);
// };

// Load saved backend URL and initial status (read-only URL)
document.addEventListener('DOMContentLoaded', function() {
    // URL is fixed, no need to load from localStorage
    
    // Load initial status
    setTimeout(loadStatus, 1000);
});

// Auto-refresh status every 30 seconds
setInterval(loadStatus, 30000);
</script>