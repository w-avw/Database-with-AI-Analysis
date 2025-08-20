jQuery(document).ready(function($) {
    let currentSections = [];
    
    // Initialize the interface
    init();
    
    function init() {
        // Load sections on page load
        loadSections();
        
        // Bind button events
        $('#add-title-btn').click(function() {
            var userText = $('#add-title-input').val();
            if (!userText) {
                showStatus('error', 'Please enter text to add.');
                return;
            }
            handleAction('add', userText);
        });
        // Update button label
        $('#add-title-btn .button-text').text('Add and Download');
        
    // Only Add button remains
    }
    
    // No section removal or export functionality
    
    function handleAction(action, customText) {
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
            nonce: word_integration_ajax.nonce,
            section: 'Title',
            value: customText
        };
        // Send AJAX request
        $.ajax({
            url: word_integration_ajax.ajax_url,
            type: 'POST',
            data: requestData,
            timeout: 10000, // 10 second timeout for Make.com webhook
            success: function(response) {
                if (response.success) {
                    showStatus('success', response.message);
                    handleSuccessResponse(action, response.data);
                    // If response contains file_url, trigger download
                    if (response.data && response.data.file_url) {
                        var link = document.createElement('a');
                        link.href = response.data.file_url;
                        link.download = '';
                        document.body.appendChild(link);
                        link.click();
                        document.body.removeChild(link);
                        $('#word-integration-result').html('<a class="download-link" href="' + response.data.file_url + '" download>Download .docx</a>');
                    }
                    // Reload sections after add operations
                    if (action === 'add') {
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
            default:
                return 'Processing request...';
        }
    }
    
    function handleSuccessResponse(action, data) {
        var $result = $('#word-integration-result');
        if (action === 'add') {
            $result.html('<div class="success-message"><strong>Title added successfully!</strong><br>Your custom title has been added to your document.</div>');
        }
        // Show additional data if available
        if (data && data.sections) {
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
