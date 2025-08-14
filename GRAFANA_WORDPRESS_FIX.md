# WordPress Grafana Embed Solution
# Fixing "No se puede acceder a este sitio web" Error

## 🚨 The Problem:
`localhost:3000` only works on your local machine, not from external websites like WordPress.

## ✅ Solution Options:

### Option 1: Use Your Server's Public IP/Domain (Recommended)

If your Grafana is on a server, replace `localhost:3000` with your server's public address:

**Instead of:**
```html
src="http://localhost:3000/d-solo/..."
```

**Use:**
```html
src="http://YOUR_SERVER_IP:3000/d-solo/..."
```
or
```html
src="https://your-domain.com/d-solo/..."
```

### Option 2: Ngrok Tunnel (For Testing)

1. **Install ngrok** (if not already done)
2. **Run:** `ngrok http 3000`
3. **Copy the https URL** (like `https://abc123.ngrok.io`)
4. **Replace localhost** in your iframe with the ngrok URL

**Example:**
```html
<div style="position:relative;width:100%;height:0;padding-bottom:50%;">
  <iframe
    src="https://abc123.ngrok.io/d-solo/fc054eb6-69ab-461d-a315-b10354622963/ny-transport-dashboard?orgId=1&from=now-24h&to=now&panelId=1&theme=light&refresh=30s"
    style="position:absolute;top:0;left:0;width:100%;height:100%;border:0;"
    loading="lazy"
    referrerpolicy="no-referrer"
    allow="fullscreen"
  ></iframe>
</div>
```

### Option 3: Public Dashboard (Most Secure)

Use the public dashboard token we found:

**Public Panel URLs:**
```
# Replace localhost:3000 with your public address
http://YOUR_PUBLIC_ADDRESS/public-dashboards/d97ee04f70284c21b6f316aa1337b3b2?orgId=1&from=now-24h&to=now&panelId=1
```

## 🔧 Quick Fix Instructions:

### Step 1: Get Your Public Address
- **If on a server:** Use the server's IP or domain
- **If testing locally:** Use ngrok tunnel
- **If using codespaces:** Use the codespace forwarded port URL

### Step 2: Update Your Iframe
Replace this part:
```
src="http://localhost:3000/d-solo/...
```

With your public address:
```
src="http://YOUR_PUBLIC_ADDRESS/d-solo/...
```

### Step 3: Test
Before adding to WordPress, test the URL directly in your browser from a different device or incognito window.

## 📱 For Codespaces Users:

If you're using GitHub Codespaces:

1. **Go to the Ports tab** in your codespace
2. **Find port 3000** 
3. **Copy the forwarded address** (looks like `https://xxx-3000.app.github.dev`)
4. **Use that URL** instead of localhost:3000

**Example Codespace URL:**
```html
src="https://xxx-3000.app.github.dev/d-solo/fc054eb6-69ab-461d-a315-b10354622963/ny-transport-dashboard?orgId=1&from=now-24h&to=now&panelId=1&theme=light&refresh=30s"
```

## 🔐 Security Note:

- **Localhost** = Only accessible from your machine
- **Public IP/Domain** = Accessible from internet (ensure proper security)
- **Ngrok** = Temporary tunnel (good for testing)
- **Public Dashboard** = Grafana's built-in public sharing (safest option)

## ✅ Final WordPress Code Template:

```html
<div style="position:relative;width:100%;height:0;padding-bottom:50%;">
  <iframe
    src="REPLACE_WITH_YOUR_PUBLIC_GRAFANA_URL/d-solo/fc054eb6-69ab-461d-a315-b10354622963/ny-transport-dashboard?orgId=1&from=now-24h&to=now&panelId=1&theme=light&refresh=30s"
    style="position:absolute;top:0;left:0;width:100%;height:100%;border:0;"
    loading="lazy"
    referrerpolicy="no-referrer"
    allow="fullscreen"
  ></iframe>
</div>
```

**Replace `REPLACE_WITH_YOUR_PUBLIC_GRAFANA_URL` with:**
- Your server IP: `http://123.456.789.10:3000`
- Your domain: `https://grafana.yourdomain.com`
- Ngrok tunnel: `https://abc123.ngrok.io`
- Codespace URL: `https://xxx-3000.app.github.dev`
