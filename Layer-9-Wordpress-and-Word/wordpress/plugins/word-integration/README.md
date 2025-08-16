# Word Integration WordPress Plugin

## Description
This WordPress plugin provides functionality to modify Word documents (.docm files) by adding content at the beginning or removing short paragraphs. It works with a backend API server to process the documents.

## Features
- ✅ Add custom text at the beginning of Word documents
- ✅ Remove short paragraphs (configurable by lines and character count)
- ✅ Download original document
- ✅ Configurable backend API URL
- ✅ User-friendly interface with status messages
- ✅ Local storage for backend URL settings

## Installation

### 1. Install the Plugin
1. Download the `word-integration` folder
2. Upload it to your WordPress `/wp-content/plugins/` directory
3. Activate the plugin in your WordPress admin panel

### 2. Setup Backend Server
You need a backend server running to process the Word documents. The backend should provide these endpoints:

- `POST /generate` - For adding content and downloading original
- `POST /remove-paragraphs` - For removing short paragraphs

#### Backend API Requirements:
```javascript
// Add content endpoint
POST /generate
Content-Type: application/json
Body: { "action": "add", "text": "Your content here" }

// Remove paragraphs endpoint  
POST /remove-paragraphs
Content-Type: application/json
Body: { "maxLines": 2, "maxCharacters": 100 }

// Download original endpoint
POST /generate
Content-Type: application/json
Body: { "action": "original" }
```

## Usage

### 1. Access the Plugin
After activation, you can use the plugin by adding the shortcode to any page or post:
```
[word_integration_panel]
```

### 2. Configure Backend URL
1. In the plugin interface, update the "Backend API URL" field
2. Enter your backend server URL (e.g., `https://your-backend-server.com`)
3. The URL is automatically saved in browser localStorage

### 3. Add Content
1. Enter text in the "Add Content" textarea
2. Click "Add Content & Export"
3. The document will be downloaded with your content added at the beginning

### 4. Remove Short Paragraphs
1. Configure the maximum lines and characters for paragraphs to remove
2. Click "Remove Short Paragraphs & Export"
3. The document will be downloaded with short paragraphs removed

### 5. Download Original
1. Click "Download Original Document"
2. The unmodified document will be downloaded

## Plugin Structure
```
word-integration/
├── word-integration.php          # Main plugin file
├── README.md                     # This file
├── assets/
│   ├── css/
│   │   └── style.css            # Plugin styles
│   └── js/
│       └── main.js              # Additional JavaScript (if needed)
└── templates/
    └── control-panel.php        # Main interface template
```

## Configuration

### Backend URL Configuration
The plugin allows you to configure the backend URL through the interface. The URL is saved in the browser's localStorage for convenience.

### Default Settings
- Default backend URL: `http://localhost:3001`
- Default max lines for removal: 2
- Default max characters for removal: 100

## Error Handling
The plugin includes comprehensive error handling:
- Server connection errors
- Invalid responses
- User input validation
- Status messages for all operations

## Browser Compatibility
- Modern browsers with JavaScript enabled
- Supports fetch API and localStorage
- Compatible with WordPress admin area

## Security Notes
- Always use HTTPS for production backend URLs
- Ensure your backend server has proper CORS configuration
- Validate all inputs on the backend side

## Support
This plugin is designed to work with the specific Word document processing backend. Make sure your backend server is running and accessible before using the plugin.

## Version
Current version: 1.0.0
