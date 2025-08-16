jQuery(document).ready(function($) {
    let currentSections = [];
    
    // Initialize the interface
    init();
    
    function init() {
        // Load sections on page load
        loadSections();
        
        // Bind button events
        $('#add-title-btn').click(function() {
            handleAction('add');
        });
        
        $('#remove-title-btn').click(function() {
            showRemoveSection();
        });
        
        $('#export-doc-btn').click(function() {
            handleAction('export');
        });
        
        $('#confirm-remove-btn').click(function() {
            var selectedSection = $('#section-dropdown').val();
            if (selectedSection) {
                handleAction('remove', selectedSection);
            } else {
                showStatus('error', 'Please select a section to remove');
            }
        });
        
        $('#cancel-remove-btn').click(function() {
            hideRemoveSection();
        });
    }
    
    function loadSections() {
    // Only allow 'Title' section for removal
    currentSections = ['Title'];
    updateSectionDropdown();
    }
    
    function updateSectionDropdown() {
    var $dropdown = $('#section-dropdown');
    $dropdown.empty();
    $dropdown.append('<option value="Title">Title</option>');
    }
    
    function showRemoveSection() {
        if (currentSections.length === 0) {
            showStatus('error', 'No sections available to remove. Try adding a title first.');
            return;
        }
        
        $('#remove-section-selector').show();
        hideStatus();
    }
    
    function hideRemoveSection() {
        $('#remove-section-selector').hide();
        $('#section-dropdown').val('');
    }
    
    function handleAction(action, section) {
        // Hide remove section if showing
        if (action !== 'remove') {
            hideRemoveSection();
        }
        
        // Disable all buttons during processing
        $('.cool-button').prop('disabled', true);
        
        // Show loading status
        showStatus('loading', getLoadingMessage(action));
        
        // Clear previous results
        $('#word-integration-result').empty();
        
        // Prepare request data
        var requestData = {
            action: 'word_integration_action',
            integration_action: action,
            nonce: word_integration_ajax.nonce
        };
        
        if (section) {
            requestData.section = section;
        }
        
        // Send AJAX request
        $.ajax({
            url: word_integration_ajax.ajax_url,
            type: 'POST',
            data: requestData,
            timeout: 30000, // 30 second timeout
            success: function(response) {
                if (response.success) {
                    showStatus('success', response.message);
                    handleSuccessResponse(action, response.data);
                    
                    // Reload sections after add/remove operations
                    if (action === 'add' || action === 'remove') {
                        setTimeout(loadSections, 1000);
                    }
                } else {
                    showStatus('error', response.message || 'Operation failed');
                }
            },
            error: function(xhr, status, error) {
                var errorMessage = 'Request failed';
                if (status === 'timeout') {
                    errorMessage = 'Request timed out. The operation may still be processing.';
                } else if (xhr.responseText) {
                    try {
                        var errorData = JSON.parse(xhr.responseText);
                        errorMessage = errorData.message || errorMessage;
                    } catch (e) {
                        errorMessage = 'Connection error: ' + error;
                    }
                } else {
                    errorMessage = 'Connection error: ' + error;
                }
                showStatus('error', errorMessage);
            },
            complete: function() {
                // Re-enable all buttons after processing
                $('.cool-button').prop('disabled', false);
            }
        });
    }
    
    function getLoadingMessage(action) {
        switch (action) {
            case 'add':
                return 'Adding title to document...';
            case 'remove':
                return 'Removing section from document...';
            case 'export':
                return 'Generating document export...';
            case 'get_sections':
                return 'Loading sections...';
            default:
                return 'Processing request...';
        }
    }
    
    function handleSuccessResponse(action, data) {
        var $result = $('#word-integration-result');
        
        switch (action) {
            case 'add':
                $result.html('<div class="success-message"><strong>Title added successfully!</strong><br>The title "PROTOCOLO MANTENIMIENTO REMOTO ESTACIÓN BASE NEBULA" has been added to your document.</div>');
                break;
                
            case 'remove':
                $result.html('<div class="success-message"><strong>Section removed successfully!</strong><br>The selected section has been removed from your document.</div>');
                hideRemoveSection();
                break;
                
            case 'export':
                var downloadUrl = data && data.download_url;
                if (downloadUrl) {
                    $result.html('<div class="success-message"><strong>Document ready for download!</strong><br><a href="' + downloadUrl + '" class="download-link" target="_blank">Download Document</a></div>');
                } else {
                    $result.html('<div class="success-message"><strong>Document exported successfully!</strong><br>Check your Make.com scenario for the processed document.</div>');
                }
                break;
        }
        
        // Show additional data if available
        if (data && data.sections && action !== 'get_sections') {
            var sectionsHtml = '<div class="sections-info"><h4>Current Sections:</h4><ul>';
            data.sections.forEach(function(section) {
                sectionsHtml += '<li>' + section + '</li>';
            });
            sectionsHtml += '</ul></div>';
            $result.append(sectionsHtml);
        }
    }
    
    function showStatus(type, message) {
        var $status = $('#word-integration-status');
        $status.removeClass('loading success error');
        $status.addClass(type);
        $status.text(message);
        $status.show();
        
        // Auto-hide success messages after 5 seconds
        if (type === 'success') {
            setTimeout(function() {
                $status.fadeOut();
            }, 5000);
        }
    }
    
    function hideStatus() {
        $('#word-integration-status').hide();
    }
    
    // Add custom CSS for result styling
    $('<style>')
        .prop('type', 'text/css')
        .html(`
            .success-message {
                background: #d4edda;
                border: 1px solid #c3e6cb;
                color: #155724;
                padding: 10px;
                border-radius: 3px;
                margin: 10px 0;
            }
            
            .sections-info {
                background: #f8f9fa;
                border: 1px solid #dee2e6;
                padding: 10px;
                border-radius: 3px;
                margin: 10px 0;
            }
            
            .sections-info h4 {
                margin: 0 0 10px 0;
                color: #495057;
            }
            
            .sections-info ul {
                margin: 0;
                padding-left: 20px;
            }
            
            .sections-info li {
                margin: 5px 0;
                color: #6c757d;
            }
        `)
        .appendTo('head');
});
