# Word Document Title Editor - WordPress Plugin

## Quick Start Guide

### 1. Plugin Installation
1. Download: `/wordpress/plugins/word-integration-plugin.zip`
2. WordPress Admin → Plugins → Add New → Upload Plugin
3. Upload ZIP file and activate
4. Add `[word_integration]` shortcode to any page/post

### 2. Backend API Setup
**Local Development URL:** `http://localhost:3002`
**GitHub Codespace URL:** `https://didactic-space-succotash-4j5rv77xpp5fqg9p-3002.app.github.dev`

**Note:** The GitHub Codespace URL requires authentication when accessed from external sources. For WordPress integration, you may need to:
1. Use the plugin within the same Codespace environment, OR
2. Deploy the backend to a public server, OR  
3. Set up proper authentication for external access

For testing within the same Codespace, use `http://localhost:3002`.

---

## API Documentation

### Base URL
```
https://didactic-space-succotash-4j5rv77xpp5fqg9p-3002.app.github.dev
```

### Endpoints

#### 1. GET /status
**Purpose:** Check current document status
```bash
curl -X GET https://didactic-space-succotash-4j5rv77xpp5fqg9p-3002.app.github.dev/status
```
**Response:**
```json
{
  "success": true,
  "originalTitle": "PROTOCOLO MANTENIMIENTOREMOTO ESTACIÓN BASE NEBULA",
  "currentTitle": "Your Modified Title",
  "isEdited": true,
  "editedFileExists": true
}
```

#### 2. POST /edit
**Purpose:** Edit the document title
```bash
curl -X POST https://didactic-space-succotash-4j5rv77xpp5fqg9p-3002.app.github.dev/edit \
  -H "Content-Type: application/json" \
  -d '{"newTitle": "My Custom Title"}'
```
**Response:**
```json
{
  "success": true,
  "message": "Title updated to: \"My Custom Title\"",
  "originalTitle": "PROTOCOLO MANTENIMIENTOREMOTO ESTACIÓN BASE NEBULA",
  "newTitle": "My Custom Title"
}
```

#### 3. POST /remove
**Purpose:** Remove edits and restore original title
```bash
curl -X POST https://didactic-space-succotash-4j5rv77xpp5fqg9p-3002.app.github.dev/remove \
  -H "Content-Type: application/json"
```
**Response:**
```json
{
  "success": true,
  "message": "Title reverted to original",
  "originalTitle": "PROTOCOLO MANTENIMIENTOREMOTO ESTACIÓN BASE NEBULA"
}
```

#### 4. GET /export
**Purpose:** Download the document (original or edited)
```bash
curl -X GET https://didactic-space-succotash-4j5rv77xpp5fqg9p-3002.app.github.dev/export \
  --output document.docm
```
**Response:** Binary file download (.docm format)

---

## WordPress Plugin Features

### 3-Button Interface

1. **✏️ Edit Title Button**
   - Input field for new title
   - Section dropdown (currently: "Title Section")
   - Replaces original title: "PROTOCOLO MANTENIMIENTOREMOTO ESTACIÓN BASE NEBULA"

2. **🗑️ Remove Edit Button**
   - Restores original title
   - Confirmation dialog included
   - Resets document to template state

3. **💾 Export Document Button**
   - Downloads edited document as .docm file
   - Saves as copy (doesn't overwrite template)
   - Automatic filename based on edit status

### Status Panel
- Real-time status display
- Shows current vs original title
- Edit status indicator
- Auto-refresh every 30 seconds

---

## Technical Details

### File Structure
```
word-integration/
├── word-integration.php      # Main plugin file
├── templates/
│   └── control-panel.php     # UI interface
└── assets/
    ├── js/main.js           # JavaScript functionality
    └── css/style.css        # Styling
```

### Template Document
- Location: `backend/templates/RPM_PR-_3240_ESTACIÓN_BASE1_20250324_01_LAND_MOBILE_RADIO_NETWORK_FOR_NEW_JERSEY_TRANSIT(NJT).docm`
- Format: Microsoft Word Macro-Enabled Document (.docm)
- Target Title: "PROTOCOLO MANTENIMIENTOREMOTO ESTACIÓN BASE NEBULA"

### Backend Technology
- **Framework:** Node.js + Express
- **Document Processing:** docxtemplater + pizzip
- **CORS:** Enabled for WordPress integration
- **Port:** 3002 (forwarded via GitHub Codespace)

---

## Security & Production Notes

### Current Setup (Development)
- ✅ CORS enabled
- ✅ HTTPS via GitHub Codespace
- ✅ Input validation
- ✅ Error handling

### For Production Deployment
- [ ] Implement authentication/authorization
- [ ] Rate limiting
- [ ] File upload restrictions
- [ ] Environment-based configuration
- [ ] Database persistence (optional)

---

## Troubleshooting

### Common Issues

1. **"Failed to connect" error**
   - Check if backend URL is correct in plugin settings
   - Verify GitHub Codespace is running

2. **CORS errors**
   - Backend has CORS enabled for all origins
   - Check browser console for specific errors

3. **File download issues**
   - Ensure popup blocker is disabled
   - Check browser download settings

### Testing the API
```bash
# Quick test
curl https://didactic-space-succotash-4j5rv77xpp5fqg9p-3002.app.github.dev/status

# Should return JSON with success: true
```

---

## Support & Development

- **Plugin Version:** 1.0
- **WordPress Compatibility:** 5.0+
- **Backend Status:** Live and operational
- **Last Updated:** August 16, 2025

For issues or modifications, check the Layer-9-Wordpress-and-Word directory in the Universal-DB repository.
