# Word Integration WordPress Plugin - Installation Guide

## 🚀 Quick Installation

### 1. Install WordPress Plugin
1. Upload the `wordpress/plugins/word-integration/` folder to your WordPress `/wp-content/plugins/` directory
2. Activate "Word Integration" plugin in WordPress admin
3. Use shortcode `[word_integration]` on any page/post

### 2. Install Backend Server
```bash
cd backend/
npm install
node src/server.js
```

Your server will run on port 3002. Update the WordPress plugin if you use a different URL.

## 🔧 Configuration

### Backend Requirements
- Node.js 14+
- npm packages: express, cors, docx-templates

### WordPress Requirements  
- WordPress 5.0+
- PHP 7.4+

## 📋 Features
- **Add Button**: Changes document title
- **Remove Button**: Restores original title  
- **Export Button**: Downloads modified .docx file

## 🌐 Live Demo
- Backend URL: `https://didactic-space-succotash-4j5rv77xpp5fqg9p-3002.app.github.dev`
- WordPress shortcode: `[word_integration]`

## 🛠️ Technical Details
- Uses clean .docx format (converted from .docm)
- Backend processes documents with docx-templates library
- No document corruption, reliable title replacement
- CORS enabled for cross-origin requests

## 📂 Package Contents
- `wordpress/plugins/word-integration/` - WordPress plugin
- `backend/` - Node.js API server
- `README.md` - Documentation
- `DEPLOYMENT-GUIDE.md` - Deployment instructions

## 🚨 Important Notes
1. The backend server must be running for the plugin to work
2. Update the backend URL in the WordPress plugin if hosting elsewhere
3. Ensure proper CORS configuration for your domain
4. Original .docm file is converted to .docx for better compatibility

---
**Need Help?** Check the DEPLOYMENT-GUIDE.md for detailed setup instructions.
