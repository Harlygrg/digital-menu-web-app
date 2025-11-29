# External Runtime Configuration Implementation Summary

## ✅ Implementation Complete

The Flutter web app now supports **external runtime configuration** via a `config.json` file. Clients can change the API base URL after deployment without rebuilding the app.

---

## 📁 Files Created

### 1. **lib/config/app_config.dart**
- Main configuration loader class
- Fetches and parses `/config.json` from the web server
- Provides fallback to default URL if config is missing
- Never crashes - gracefully handles all error cases
- Exports `AppConfig.apiBase` for use throughout the app

### 2. **web/config.json**
- External configuration file (deployed with the app)
- Contains the API base URL
- Can be edited after build without recompiling
- Default URL: `https://msibusinesssolutions.com/digitalmenu/api/v1/`

### 3. **web/config.example.json**
- Example configuration file
- Template for creating custom configs

### 4. **web/HOW_TO_CHANGE_API_URL.txt**
- Simple, non-technical instructions for clients
- Step-by-step guide to changing the API URL
- Troubleshooting tips

### 5. **CONFIG_README.md**
- Comprehensive technical documentation
- Deployment checklist
- Troubleshooting guide
- File structure explanation

---

## 🔧 Files Modified

### 1. **lib/main.dart**
**Changes:**
- Added import for `config/app_config.dart`
- Added `await AppConfig.load()` call before Firebase initialization
- Loads config before any API calls are made
- Added explanatory comments

**Why:** Ensures configuration is loaded at app startup, before any services initialize.

### 2. **lib/constants/api_constants.dart**
**Changes:**
- Changed `baseUrl` from a static const String to a static getter
- Now returns `AppConfig.apiBase` dynamically
- Added import for `app_config.dart`
- Updated documentation comments

**Why:** Allows the base URL to be dynamic and configurable at runtime.

### 3. **lib/services/api/api_service.dart**
**Changes:**
- Updated comments to clarify that baseUrl comes from config
- Removed unused `flutter/foundation.dart` import (linter cleanup)

**Why:** Documentation update to reflect the new configuration system.

### 4. **pubspec.yaml**
**Changes:**
- Added `http: ^1.2.0` package dependency

**Why:** Required for loading the config.json file from the server.

---

## 🚀 How It Works

### Initialization Flow

```
main() starts
    ↓
WidgetsFlutterBinding.ensureInitialized()
    ↓
AppConfig.load() ← Loads config.json
    ↓
Firebase.initializeApp()
    ↓
ApiService().initialize() ← Uses AppConfig.apiBase
    ↓
runApp()
```

### Configuration Loading Process

1. **App starts** → `main()` is called
2. **Config loads** → `AppConfig.load()` fetches `/config.json` via HTTP GET
3. **Parse JSON** → Extracts the `apiBase` field
4. **Store value** → Sets `AppConfig.apiBase` to the loaded URL
5. **Fallback** → If any step fails, uses default URL
6. **API init** → `ApiService` uses `ApiConstants.baseUrl` which returns `AppConfig.apiBase`

### What Happens If Config Is Missing?

✅ **App continues to work** - Uses default URL
✅ **No crashes or errors shown to users**
✅ **Warning logged to console** - Developers can see what happened
✅ **Graceful degradation** - App functions normally with fallback URL

---

## 📝 Usage Instructions

### For Developers

#### During Development
```bash
# Edit the config file
nano web/config.json

# Run the app
flutter run -d chrome
```

#### Building for Production
```bash
# Build the web app
flutter build web

# The config file is copied to build/web/config.json
# You can edit it there before deploying
```

#### Testing Configuration
```bash
# 1. Build the app
flutter build web

# 2. Edit build/web/config.json
# 3. Serve the app locally
cd build/web
python3 -m http.server 8000

# 4. Open browser to http://localhost:8000
# 5. Check console (F12) for config loading messages
```

### For Clients (Non-Technical Users)

**To change the API URL after deployment:**

1. Open `build/web/config.json` in any text editor
2. Change the URL:
   ```json
   {
     "apiBase": "https://your-new-api-url.com/api/v1/"
   }
   ```
3. Save the file
4. Refresh the browser

**That's it!** No rebuilding required.

---

## 🔍 Configuration File Format

### Schema

```json
{
  "apiBase": "string"
}
```

### Field Specifications

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `apiBase` | string | Yes | https://msibusinesssolutions.com/digitalmenu/api/v1/ | Base URL for all API endpoints. Must include protocol and trailing slash. |

### Valid Examples

```json
✅ { "apiBase": "https://api.example.com/v1/" }
✅ { "apiBase": "http://localhost:8080/api/v1/" }
✅ { "apiBase": "https://192.168.1.100:3000/api/" }
```

### Invalid Examples

```json
❌ { "apiBase": "api.example.com" }          // Missing protocol
❌ { "apiBase": "https://api.example.com" }  // Missing trailing slash
❌ { "base_url": "https://..." }             // Wrong field name
❌ { apiBase: "https://..." }                // Missing quotes (invalid JSON)
```

---

## 🧪 Testing Checklist

### Pre-Deployment Tests

- [ ] **Config loads successfully**
  - Open browser console and look for: `✅ AppConfig: Successfully loaded API base URL`
  
- [ ] **Fallback works**
  - Delete or rename `config.json`
  - App should use default URL and show warning
  
- [ ] **Invalid JSON handled**
  - Add invalid JSON to `config.json`
  - App should fallback to default URL
  
- [ ] **API calls work**
  - Verify API requests use the configured URL
  - Check Network tab in browser DevTools

### Post-Deployment Tests

- [ ] **Config file accessible**
  - Navigate to `https://your-domain.com/config.json` in browser
  - Should show the JSON content
  
- [ ] **URL change works**
  - Edit `config.json` on server
  - Refresh browser
  - Verify new URL is used (check console logs)
  
- [ ] **CORS configured**
  - Config file must be served from same origin as app
  - Check for CORS errors in console

---

## 🐛 Troubleshooting

### Issue: Config not loading

**Symptoms:**
- Console shows: `⚠️ AppConfig: Failed to load config.json`
- App uses default URL

**Solutions:**
1. Verify file is named exactly `config.json` (case-sensitive)
2. Check file is in web root (same level as `index.html`)
3. Verify JSON syntax is valid
4. Check browser console for specific error messages

### Issue: API calls fail after changing URL

**Symptoms:**
- Network errors in browser console
- API requests timeout or fail

**Solutions:**
1. Verify new URL is accessible from browser
2. Check API server is running
3. Verify CORS headers on API server
4. Confirm URL has trailing slash
5. Test API endpoint directly (Postman/curl)

### Issue: Changes not taking effect

**Symptoms:**
- Edited config.json but app still uses old URL

**Solutions:**
1. Hard refresh browser (Ctrl+F5 / Cmd+Shift+R)
2. Clear browser cache
3. Check you edited the deployed file, not the source file
4. Verify file was saved correctly
5. Check browser console for config loading messages

---

## 📊 Console Messages Reference

### Success Messages

```
🔧 AppConfig: Loading external configuration from /config.json...
✅ AppConfig: Successfully loaded API base URL from config.json
   📡 API Base: https://your-api-url.com/api/v1/
🌐 AppConfig: Final API Base URL: https://your-api-url.com/api/v1/
```

### Warning Messages

```
⚠️ AppConfig: Timeout loading config.json, using default URL
⚠️ AppConfig: Failed to load config.json (HTTP 404), using default URL
⚠️ AppConfig: apiBase field not found in config.json, using default
⚠️ AppConfig: Error loading config.json: <error details>
ℹ️ AppConfig: Using default API base URL: <default-url>
```

---

## 🔐 Security Considerations

1. **No Secrets in Config**
   - Do NOT store API keys, passwords, or secrets in config.json
   - This file is publicly accessible
   - Only store non-sensitive configuration

2. **CORS Configuration**
   - Config file must be served from same origin
   - Configure proper CORS headers on API server
   - Test cross-origin requests

3. **HTTPS in Production**
   - Always use HTTPS for production API URLs
   - HTTP is acceptable only for local development

4. **URL Validation**
   - App does basic validation (non-empty string)
   - No special characters escaping/sanitization
   - Ensure URLs are from trusted sources

---

## 📦 Deployment Workflow

### Standard Deployment

```bash
# 1. Build the app
flutter build web

# 2. Navigate to build output
cd build/web

# 3. (Optional) Edit config.json for this deployment
nano config.json

# 4. Deploy to your web server
# Example: Using Firebase Hosting
firebase deploy --only hosting

# Example: Using SCP
scp -r * user@server:/var/www/html/

# Example: Using rsync
rsync -avz --delete * user@server:/var/www/html/
```

### Multi-Environment Deployment

```bash
# Production
cp web/config.production.json build/web/config.json
firebase deploy --only hosting --project production

# Staging
cp web/config.staging.json build/web/config.json
firebase deploy --only hosting --project staging

# Development
cp web/config.development.json build/web/config.json
firebase deploy --only hosting --project development
```

---

## 📚 Additional Resources

### Documentation Files

- **CONFIG_README.md** - Comprehensive guide (this file)
- **web/HOW_TO_CHANGE_API_URL.txt** - Simple client instructions
- **lib/config/app_config.dart** - Code documentation

### Related Flutter Documentation

- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)
- [Flutter Build Web](https://docs.flutter.dev/platform-integration/web/building)
- [Flutter Configuration](https://docs.flutter.dev/development/tools/flutter-config)

---

## ✨ Benefits

### For Developers

✅ **No environment-specific builds** - Single build works everywhere
✅ **Easy testing** - Change URL without rebuilding
✅ **Flexible deployment** - Same build for dev/staging/prod
✅ **Better CI/CD** - Configure at deploy time, not build time

### For Clients

✅ **Zero Flutter knowledge required** - Just edit a text file
✅ **No rebuilding needed** - Instant configuration changes
✅ **Simple process** - Edit, save, refresh
✅ **No risk** - If something breaks, app uses default URL

### For DevOps

✅ **Environment-agnostic builds** - One artifact for all environments
✅ **Easier deployments** - Configure post-build
✅ **Faster updates** - No rebuild for URL changes
✅ **Better separation** - Config separate from code

---

## 📝 Version History

### v1.0.0 - Initial Implementation
- Created AppConfig loader
- Added config.json support
- Updated API service integration
- Created documentation

---

## 🤝 Support

For issues or questions:

1. Check browser console for error messages
2. Verify config.json syntax using a JSON validator
3. Review the troubleshooting section above
4. Check that the API URL is accessible
5. Contact your development team

---

**Implementation Date:** 2025-11-21  
**Status:** ✅ Complete and Ready for Use






