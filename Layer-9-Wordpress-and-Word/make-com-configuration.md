# Make.com Scenario Configuration Guide

This guide explains how to set up a Make.com scenario to handle Word document processing for the WordPress plugin.

## Scenario Overview

The Make.com scenario will:
1. Receive webhook requests from WordPress
2. Process Word documents based on the action
3. Return results to WordPress

## Required Modules

### 1. Custom Webhook (Trigger)
- **Module**: Custom Webhook
- **Purpose**: Receive requests from WordPress
- **Configuration**:
  - Create a new webhook in Make.com (Custom Webhook module)
  - After creation, copy the generated webhook URL
  - In WordPress, go to Settings > Word Integration
  - Paste the webhook URL into the "Webhook URL" field
  - (Reference: This field is saved in the plugin and used in `word-integration.php` line where `$this->webhook_url = get_option('word_integration_webhook_url', '');` is set)
  - Set data structure to handle JSON payload

### 2. Router
- **Module**: Router
- **Purpose**: Route requests based on action type
- **Routes**:
  - Add Title Route
  - Remove Title Route  
  - Export Document Route
  - Get Sections Route
  - Test Connection Route

### 3. Document Processing Modules

#### For Add Title Action:
- **HTTP Module**: Download template document
- **Text Processing**: Add title to document content
- **File Storage**: Save modified document

#### For Remove Title Action:
- **HTTP Module**: Download current document
- **Text Processing**: Remove specified section
- **File Storage**: Save modified document

#### For Export Action:
- **HTTP Module**: Download current document
- **Cloud Storage**: Upload to temporary storage
- **Generate**: Public download link

### 4. Webhook Response (Final)
- **Module**: Webhook Response
- **Purpose**: Send results back to WordPress
- **Response Format**:
```json
{
  "success": true,
  "message": "Operation completed successfully",
  "data": {
    "sections": ["Section 1", "Section 2"],
    "download_url": "https://storage.example.com/document.docx"
  }
}
```

## Detailed Configuration Steps

### Step 1: Create Custom Webhook
1. Add Custom Webhook module as trigger
2. Click "Add" to create new webhook
3. Copy the generated webhook URL from the Custom Webhook module in Make.com
4. In WordPress, navigate to Settings > Word Integration
5. Paste the webhook URL into the "Webhook URL" field (this connects Make.com to the plugin; see `word-integration.php` line with `$this->webhook_url = get_option('word_integration_webhook_url', '');`)
6. Configure the webhook module in Make.com to accept JSON data
5. Set up data structure with these fields:
   - action (text)
   - title (text, optional)
   - section (text, optional)
   - timestamp (text)
   - source (text)
   - api_key (text, optional)

### Step 2: Set Up Router
1. Add Router module after webhook
2. Create 5 routes with these filters:
   - Route 1: `action = "add"`
   - Route 2: `action = "remove"`
   - Route 3: `action = "export"`
   - Route 4: `action = "get_sections"`
   - Route 5: `action = "test"`

### Step 3: Configure Add Title Route
1. **HTTP Module**: Download template
   - URL: Your document storage location
   - Method: GET
   
2. **Text Processing**: Add title
   - Input: Downloaded document content
   - Process: Insert "PROTOCOLO MANTENIMIENTO REMOTO ESTACIÓN BASE NEBULA"
   
3. **Cloud Storage**: Save document
   - Service: Google Drive, Dropbox, etc.
   - File: Modified document

4. **Webhook Response**:
   ```json
   {
     "success": true,
     "message": "Title added successfully",
     "data": {
       "sections": ["{{sections_array}}"],
       "document_id": "{{document_id}}"
     }
   }
   ```

### Step 4: Configure Remove Title Route
1. **HTTP Module**: Download current document
2. **Text Processing**: Remove section
   - Input: Document content
   - Process: Remove section based on webhook.section parameter
3. **Cloud Storage**: Save modified document
4. **Webhook Response**: Success with updated sections

### Step 5: Configure Export Route
1. **HTTP Module**: Download current document
2. **Cloud Storage**: Upload to public location
3. **Generate**: Temporary public download URL
4. **Webhook Response**:
   ```json
   {
     "success": true,
     "message": "Document ready for download",
     "data": {
       "download_url": "{{public_download_url}}",
       "expires_at": "{{expiration_time}}"
     }
   }
   ```

### Step 6: Configure Get Sections Route
1. **HTTP Module**: Download current document
2. **Text Processing**: Extract section list
3. **Webhook Response**:
   ```json
   {
     "success": true,
     "message": "Sections retrieved",
     "data": {
       "sections": ["{{extracted_sections}}"]
     }
   }
   ```

### Step 7: Configure Test Route
1. **Simple Response**: Return success for connection testing
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

## Error Handling

Add error handling to each route:
1. **HTTP Response Error**: Return 400 status with error message
2. **Processing Error**: Return 500 status with error details
3. **Invalid Action**: Return 400 status with "Invalid action" message

## Security Considerations

1. **API Key Validation**: Check webhook.api_key if provided
2. **Rate Limiting**: Implement request throttling
3. **Input Validation**: Sanitize all input data
4. **File Access**: Secure document storage and access

## Testing

1. In WordPress, use the "Test Webhook Connection" button in Settings > Word Integration to verify connectivity
2. Monitor Make.com execution logs
3. Verify document processing results
4. Test error scenarios

## Monitoring

Set up monitoring for:
- Webhook execution success/failure rates
- Processing time metrics
- Error patterns
- Storage usage

This configuration provides a robust cloud-based solution for Word document processing without the complexity of local server management.
