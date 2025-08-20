<div id="word-integration-interface" class="word-integration-container">
    <div class="word-integration-header">
        <h3>Word Document Manager</h3>
        <p>Manage your Word document titles using cloud processing</p>
    </div>
    <div class="word-integration-buttons">
        <input type="text" id="add-title-input" class="cool-input" placeholder="Type anything..." style="margin-right:10px;max-width:220px;">
        <select id="add-section-dropdown" class="cool-input" style="margin-right:10px;max-width:120px;">
            <option value="Title">Title</option>
        </select>
        <button id="add-title-btn" class="cool-button cool-button-word-light" data-action="add">
            <span class="button-text">Add and Download</span>
            <span class="button-icon">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M12 5v14M5 12h14"/>
                </svg>
            </span>
        </button>
        <!-- Only Add button remains -->
    </div>
    <div id="word-integration-status" class="word-integration-status"></div>
    <div id="word-integration-result" class="word-integration-result"></div>
</div>
