# WordPress Word Integration - Complete Setup Guide

## 🚀 Quick Deployment Guide

### Backend Deployment (Your API Server)

#### Option 1: Deploy Backend to Cloud (Recommended)
You can deploy the backend to any cloud service that supports Node.js:

**Vercel (Free tier available):**
1. Create a `vercel.json` in your backend folder:
```json
{
  "version": 2,
  "builds": [
    {
      "src": "src/server.js",
      "use": "@vercel/node"
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "/src/server.js"
    }
  ]
}
```

**Heroku:**
1. Create a `Procfile` in your backend folder:
```
web: node src/server.js
```

**Railway/Render/DigitalOcean:**
- Set start command: `node src/server.js`
- Set port: `3001` (or use PORT environment variable)

#### Option 2: VPS/Server Deployment
1. Upload your backend folder to your server
2. Install Node.js and npm
3. Run: `npm install`
4. Start with PM2: `pm2 start src/server.js --name word-api`
5. Configure nginx/apache to proxy to port 3001

### WordPress Plugin Installation

#### Step 1: Upload Plugin
1. Download `word-integration-complete.zip`
2. In WordPress admin, go to Plugins → Add New → Upload Plugin
3. Upload the zip file and activate

#### Step 2: Configure Backend URL
1. Add the shortcode `[word_integration_panel]` to any page/post
2. Update the "Backend API URL" field with your deployed backend URL
3. Test the connection by trying to download the original document

## 🔧 Configuration

### Backend Requirements
- Node.js 14+ 
- Dependencies: express, cors, pizzip, docxtemplater
- Port 3001 (or configurable)
- CORS enabled for your WordPress domain

### WordPress Requirements
- WordPress 5.0+
- Modern browser with JavaScript enabled
- Internet connection to reach your backend API

## 📋 API Endpoints

Your backend provides these endpoints:

```javascript
// Add content to document
POST /generate
{
  "action": "add",
  "text": "Content to add at beginning"
}

// Remove short paragraphs
POST /remove-paragraphs  
{
  "maxLines": 2,
  "maxCharacters": 100
}

// Download original document
POST /generate
{
  "action": "original"
}
```

## 🎯 Usage Workflow

1. **Deploy Backend**: Deploy your Node.js backend to any cloud service
2. **Install Plugin**: Upload and activate the WordPress plugin
3. **Configure URL**: Set your backend URL in the plugin interface
4. **Use Features**:
   - Add content at document beginning
   - Remove short paragraphs (configurable)
   - Download original document

## 🔒 Security Considerations

- Use HTTPS for production backend URLs
- Configure CORS properly on your backend
- Consider API authentication if needed
- Validate all inputs on backend side

## 📁 File Structure

```
Backend (Deploy this):
/backend/
├── package.json
├── src/
│   └── server.js
└── templates/
    └── [your-docm-file].docm

WordPress Plugin (Upload this):
word-integration-complete.zip
```

## ✅ Current Status

✅ Backend API running on port 3001  
✅ Add functionality working  
✅ Remove paragraphs functionality working  
✅ WordPress plugin created and packaged  
✅ Configurable backend URL  
✅ User-friendly interface  
✅ Error handling and status messages  
✅ Ready for deployment  

## 🚀 Next Steps

1. Deploy your backend to a cloud service
2. Update the backend URL in the WordPress plugin
3. Test all functionality on your live WordPress site
4. Share the plugin with users who need this functionality

The plugin is now ready for production use! 🎉
