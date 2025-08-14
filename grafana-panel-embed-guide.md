# Grafana Panel Embed Guide for WordPress
# NY Transport Dashboard - Individual Panel Embedding

## Available Panels for Embedding:

### 1. Total Call Records (Panel ID: 1)
**d-solo URL (Local testing):**
```
http://localhost:3000/d-solo/fc054eb6-69ab-461d-a315-b10354622963/ny-transport-dashboard?orgId=1&from=now-24h&to=now&panelId=1&theme=light&refresh=30s
```

**Public URL (For WordPress):**
```
http://localhost:3000/public-dashboards/d97ee04f70284c21b6f316aa1337b3b2?orgId=1&from=now-24h&to=now&panelId=1&theme=light&refresh=30s
```

### 2. System Health Score (Panel ID: 2) 
**d-solo URL:**
```
http://localhost:3000/d-solo/fc054eb6-69ab-461d-a315-b10354622963/ny-transport-dashboard?orgId=1&from=now-24h&to=now&panelId=2&theme=light&refresh=30s
```

### 3. Network Load (Panel ID: 5)
**d-solo URL:**
```
http://localhost:3000/d-solo/fc054eb6-69ab-461d-a315-b10354622963/ny-transport-dashboard?orgId=1&from=now-24h&to=now&panelId=5&theme=light&refresh=30s
```

### 4. General Error Code Distribution (Panel ID: 25)
**d-solo URL:**
```
http://localhost:3000/d-solo/fc054eb6-69ab-461d-a315-b10354622963/ny-transport-dashboard?orgId=1&from=now-24h&to=now&panelId=25&theme=light&refresh=30s
```

### 5. Top 5 Bases With Most Interference (Panel ID: 15)
**d-solo URL:**
```
http://localhost:3000/d-solo/fc054eb6-69ab-461d-a315-b10354622963/ny-transport-dashboard?orgId=1&from=now-24h&to=now&panelId=15&theme=light&refresh=30s
```

### 6. Source Location Maintenance Table (Panel ID: 34)
**d-solo URL:**
```
http://localhost:3000/d-solo/fc054eb6-69ab-461d-a315-b10354622963/ny-transport-dashboard?orgId=1&from=now-24h&to=now&panelId=34&theme=light&refresh=30s
```

## WordPress Custom HTML Code Templates:

### For Stats/Gauges (Square format):
```html
<div style="position:relative;width:100%;height:0;padding-bottom:50%;">
  <iframe
    src="http://localhost:3000/d-solo/fc054eb6-69ab-461d-a315-b10354622963/ny-transport-dashboard?orgId=1&from=now-24h&to=now&panelId=1&theme=light&refresh=30s"
    style="position:absolute;top:0;left:0;width:100%;height:100%;border:0;"
    loading="lazy"
    referrerpolicy="no-referrer"
    allow="fullscreen"
  ></iframe>
</div>
```

### For Charts/Tables (Wider format):
```html
<div style="position:relative;width:100%;height:0;padding-bottom:40%;">
  <iframe
    src="http://localhost:3000/d-solo/fc054eb6-69ab-461d-a315-b10354622963/ny-transport-dashboard?orgId=1&from=now-24h&to=now&panelId=25&theme=light&refresh=30s"
    style="position:absolute;top:0;left:0;width:100%;height:100%;border:0;"
    loading="lazy"
    referrerpolicy="no-referrer"
    allow="fullscreen"
  ></iframe>
</div>
```

## URL Parameters Explained:

- `d-solo/` = Shows only the panel (not full dashboard)
- `panelId=X` = Which panel to show
- `from=now-24h&to=now` = Time range (last 24 hours)
- `theme=light` = Light theme (use `dark` for dark theme)
- `refresh=30s` = Auto-refresh every 30 seconds
- `kiosk` = (optional) Full screen mode without headers

## Steps for WordPress:

1. **Choose a panel** from the list above
2. **Copy the d-solo URL** for that panel
3. **In WordPress:**
   - Add "Custom HTML" block
   - Paste the HTML template
   - Replace the `src` URL with your chosen panel URL
   - Adjust `padding-bottom` if needed (50% for square, 40% for wide)
4. **Test and adjust** the size as needed

## Making Panels Public (if needed):

If you want to share these without login:
1. Go to Grafana dashboard
2. Click "Share" → "Public dashboard"
3. Enable public access
4. Use the public URL instead of localhost in the iframe src
