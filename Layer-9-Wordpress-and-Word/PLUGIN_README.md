# WordPress Word Integration Plugin

## Installation Instructions

### 1. WordPress Plugin Installation
1. Upload `word-integration.zip` to your WordPress site
2. Go to `Plugins > Add New > Upload Plugin`
3. Upload the zip file and activate the plugin
4. Add the shortcode `[word_integration]` to any page or post

### 2. Backend Server Setup
The plugin requires a Node.js backend server running. You have two options:

#### Option A: GitHub Codespace (Recommended)
The backend is already running at:
`https://didactic-space-succotash-4j5rv77xpp5fqg9p-3004.app.github.dev`

#### Option B: Local Setup
1. Install Node.js and npm
2. Copy the `backend` folder to your server
3. Run:
   ```bash
   cd backend
   npm install
   node simple-server.js
   ```
4. Update the URL in the WordPress plugin code

## How It Works

1. **Add Button**: Changes the document title to your custom text
2. **Remove Button**: Restores the original title 
3. **Export Button**: Downloads the edited document

## Features

- ✅ **Works with .docx files** - Clean, compatible format
- ✅ **Simple binary replacement** - Fast and reliable
- ✅ **No file corruption** - Safe editing approach
- ✅ **Real-time status** - See current title state
- ✅ **Easy integration** - Just add shortcode to any page

## Technical Details

- Backend: Node.js/Express with simple binary string replacement
- Frontend: WordPress plugin with clean UI
- File Format: .docx (converted from .docm for better compatibility)
- No external dependencies required

## Support

This plugin is designed to work out of the box with the provided backend server. The simple approach ensures maximum compatibility and minimal setup requirements.
