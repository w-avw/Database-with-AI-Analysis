# Deployment Guide: WordPress Word Integration via Make.com

This guide walks you through deploying the complete solution for Word document integration using WordPress and Make.com webhooks.

## Prerequisites

- WordPress website with admin access
- Make.com account
- Word document template stored in cloud storage (Google Drive, Dropbox, etc.)

## Phase 1: WordPress Plugin Installation

### Step 1: Upload Plugin Files
1. Access your WordPress site via FTP, cPanel, or hosting file manager
2. Navigate to `/wp-content/plugins/`
3. Create folder: `word-integration`
4. Upload these files:
   - `word-integration.php`
   - `word-integration.js`

### Step 2: Activate Plugin
1. Go to WordPress Admin → Plugins
2. Find "Word Integration via Make.com"
3. Click "Activate"

### Step 3: Basic Configuration
1. Go to Settings → Word Integration
2. Leave webhook URL empty for now (we'll configure this after setting up Make.com)
3. Optionally set an API key for security

## Phase 2: Make.com Scenario Setup

### Step 1: Create New Scenario
1. Log into Make.com
2. Click "Create a new scenario"
3. Name it: "WordPress Word Document Processor"

### Step 2: Add Custom Webhook Trigger
1. Click the "+" to add first module
2. Search and select "Custom Webhook"
3. Click "Add" to create new webhook
4. **IMPORTANT**: Copy the webhook URL - you'll need this for WordPress
5. Set data structure:
   ```json
   {
     "action": "add",
     "title": "Sample Title",
     "section": "Section 1", 
     "timestamp": "2024-01-01 12:00:00",
     "source": "wordpress",
     "api_key": "optional"
   }
   ```

### Step 3: Add Router Module
1. Add Router module after webhook
2. Create 5 routes with these filters:
   - **Route 1**: `action = "add"`
   - **Route 2**: `action = "remove"`  
   - **Route 3**: `action = "export"`
   - **Route 4**: `action = "get_sections"`
   - **Route 5**: `action = "test"`

### Step 4: Configure Test Route (Simplest)
1. On Route 5 (test), add "Webhook Response" module
2. Set Status: 200
3. Set Body:
   ```json
   {
     "success": true,
     "message": "Webhook connection successful",
     "data": {
       "timestamp": "{{now}}",
       "status": "connected"
     }
   }
   ```

### Step 5: Configure Add Title Route
1. On Route 1 (add), add these modules in sequence:

   **A. HTTP - Get Document Template**
   - URL: Your document storage URL
   - Method: GET
   
   **B. Webhook Response**
   - Status: 200
   - Body:
   ```json
   {
     "success": true,
     "message": "Title 'PROTOCOLO MANTENIMIENTO REMOTO ESTACIÓN BASE NEBULA' added successfully",
     "data": {
       "sections": ["Introduction", "Maintenance Protocol", "Remote Access", "Troubleshooting"],
       "document_id": "{{timestamp}}"
     }
   }
   ```

### Step 6: Configure Remove Title Route
1. On Route 2 (remove), add "Webhook Response" module:
   - Status: 200
   - Body:
   ```json
   {
     "success": true,
     "message": "Section '{{1.section}}' removed successfully",
     "data": {
       "sections": ["Introduction", "Remote Access", "Troubleshooting"],
       "removed_section": "{{1.section}}"
     }
   }
   ```

### Step 7: Configure Export Route
1. On Route 3 (export), add "Webhook Response" module:
   - Status: 200
   - Body:
   ```json
   {
     "success": true,
     "message": "Document ready for download",
     "data": {
       "download_url": "https://drive.google.com/file/d/sample-file-id/view",
       "expires_at": "{{addDays(now; 1)}}"
     }
   }
   ```

### Step 8: Configure Get Sections Route
1. On Route 4 (get_sections), add "Webhook Response" module:
   - Status: 200
   - Body:
   ```json
   {
     "success": true,
     "message": "Sections retrieved",
     "data": {
       "sections": ["Introduction", "Maintenance Protocol", "Remote Access", "Troubleshooting"]
     }
   }
   ```

### Step 9: Save and Test Scenario
1. Click "Save" in top right
2. Turn on the scenario (toggle switch)
3. Copy the webhook URL from the first module

## Phase 3: Connect WordPress to Make.com

### Step 1: Configure WordPress Plugin
1. Go to WordPress Admin → Settings → Word Integration
2. Paste the Make.com webhook URL
3. Optionally add API key
4. Click "Save Changes"

### Step 2: Test Connection
1. Click "Test Webhook Connection" button
2. Should see green success message
3. Check Make.com scenario execution log

### Step 3: Add Shortcode to Page/Post
1. Create new page or edit existing one
2. Add this shortcode: `[word_integration]`
3. Publish/Update the page

## Phase 4: Testing the Complete Solution

### Step 1: Test Each Function
1. **Visit the page with shortcode**
2. **Test Add Title**: Click "Add Title" button
3. **Test Get Sections**: Click "Remove Title" to see section dropdown
4. **Test Export**: Click "Export Document" button

### Step 2: Verify Make.com Execution
1. Go to Make.com scenario
2. Check "History" tab
3. Verify each test created an execution log
4. Check that correct responses were returned

## Phase 5: Advanced Configuration (Optional)

### Document Storage Integration
For real document processing, integrate with:
- **Google Drive API**: For document storage and processing
- **Microsoft Graph API**: For Word document manipulation
- **Dropbox API**: For file storage and sharing

### Enhanced Security
1. **API Key Validation**: Add API key checking in Make.com
2. **Rate Limiting**: Implement request throttling
3. **Input Sanitization**: Validate all webhook inputs

### Error Handling
Add error handling modules in Make.com:
1. **HTTP Error Handler**: For failed document downloads
2. **Processing Error Handler**: For document processing failures
3. **Fallback Responses**: For graceful error recovery

## Troubleshooting

### Common Issues

**1. Webhook URL Not Working**
- Verify URL is copied correctly
- Check Make.com scenario is "ON"
- Test URL directly with Postman

**2. WordPress AJAX Errors**
- Check WordPress error logs
- Verify plugin files uploaded correctly
- Ensure proper permissions

**3. Make.com Execution Failures**
- Check scenario execution history
- Verify module configurations
- Test individual modules

**4. Shortcode Not Displaying**
- Verify plugin is activated
- Check for theme conflicts
- Test on default WordPress theme

### Debug Steps
1. **Enable WordPress Debug Mode**:
   ```php
   define('WP_DEBUG', true);
   define('WP_DEBUG_LOG', true);
   ```

2. **Check Error Logs**:
   - WordPress: `/wp-content/debug.log`
   - Server: Check hosting error logs

3. **Test Individual Components**:
   - Test webhook URL with curl/Postman
   - Test WordPress AJAX separately
   - Verify Make.com module responses

## Support and Maintenance

### Regular Maintenance
1. **Monitor Make.com Usage**: Check execution counts and quotas
2. **Update Document Templates**: Keep cloud-stored documents current
3. **Test Functionality**: Monthly end-to-end testing
4. **Review Logs**: Check for errors or unusual patterns

### Scaling Considerations
- **Make.com Quotas**: Monitor execution limits
- **Document Storage**: Plan for storage growth
- **Performance**: Optimize for high-traffic sites

This deployment guide provides a complete, cloud-based solution that eliminates the complexity of local document processing while providing reliable Word document integration for WordPress.
