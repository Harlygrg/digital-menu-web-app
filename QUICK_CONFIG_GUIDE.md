# 🚀 Quick Configuration Guide

## Change API URL Without Rebuilding

### 📍 Location
```
build/web/config.json
```

### ✏️ Edit This File
```json
{
  "apiBase": "https://your-api-url.com/api/v1/"
}
```

### ✅ Rules
- Include `https://` or `http://`
- End with a slash `/`
- Use quotes around the URL
- Valid JSON syntax

### 🔄 Apply Changes
1. Save the file
2. Refresh browser (Ctrl+F5)

### ⚠️ Troubleshooting
- **Not working?** Check browser console (F12)
- **Invalid JSON?** Use [jsonlint.com](https://jsonlint.com)
- **Still failing?** App will use default URL automatically

---

## Examples

### Production
```json
{
  "apiBase": "https://api.mycompany.com/restaurant/v1/"
}
```

### Local Development
```json
{
  "apiBase": "http://localhost:8080/api/v1/"
}
```

### Staging
```json
{
  "apiBase": "https://staging-api.mycompany.com/api/v1/"
}
```

---

## Before Deploying

1. ✅ Build: `flutter build web`
2. ✅ Edit: `build/web/config.json`
3. ✅ Verify: Open `build/web/index.html` in browser
4. ✅ Deploy: Upload `build/web/` folder to server

---

## After Deploying

To change URL:
1. 📝 Edit `config.json` on your server
2. 💾 Save
3. 🔄 Users refresh browser
4. ✅ Done!

**No rebuild. No downtime. No Flutter required.**






