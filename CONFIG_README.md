# External Runtime Configuration Guide

## Overview

This Flutter web app supports **external runtime configuration** through a `config.json` file. This allows you to change the API base URL **AFTER building the app**, without needing to rebuild or have any Flutter/programming knowledge.

## How It Works

1. The app loads configuration from `/config.json` when it starts
2. If the file is missing or invalid, it uses a built-in default URL
3. All API calls use the configured URL from the config file

## For Developers

### During Development

The config file is located at:
```
web/config.json
```

When you run `flutter run -d chrome` or similar, the app will use this file.

### Building for Production

After running `flutter build web`, the config file will be copied to:
```
build/web/config.json
```

This is the file that will be deployed with your web app.

## For Clients (Post-Deployment)

### Changing the API URL After Deployment

**You do NOT need to rebuild the app!** Simply follow these steps:

1. **Locate the config file** in your deployed web application:
   ```
   build/web/config.json
   ```
   
   Or after deployment to your server:
   ```
   https://your-domain.com/config.json
   ```

2. **Edit the config file** with any text editor (Notepad, TextEdit, VS Code, etc.):
   ```json
   {
     "apiBase": "https://your-custom-api-url.com/api/v1/"
   }
   ```

3. **Important**: Always include a trailing slash (`/`) at the end of the URL

4. **Save the file** and refresh your browser

5. The app will automatically use your new URL!

### Example Configurations

#### Default Configuration
```json
{
  "apiBase": "https://msibusinesssolutions.com/digitalmenu/api/v1/"
}
```

#### Custom Configuration
```json
{
  "apiBase": "https://api.mycompany.com/restaurant/v1/"
}
```

#### Local Development Configuration
```json
{
  "apiBase": "http://localhost:8080/api/v1/"
}
```

## File Structure

```
project/
├── web/
│   └── config.json          # Development config (edit during development)
└── build/
    └── web/
        ├── config.json      # Production config (edit after build)
        ├── index.html
        ├── main.dart.js
        └── ... (other build files)
```

## Technical Details

### Configuration Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `apiBase` | String | Yes | The base URL for all API endpoints. Must include protocol (http:// or https://) and trailing slash |

### Fallback Behavior

If `config.json` is missing or contains errors:
- The app will NOT crash
- It will automatically use the default URL: `https://msibusinesssolutions.com/digitalmenu/api/v1/`
- A warning message will appear in the browser console (press F12 to view)

### Validation

The app performs the following checks:
- ✅ Config file exists and is accessible
- ✅ JSON is valid and parseable
- ✅ `apiBase` field exists and is a string
- ✅ `apiBase` is not empty
- ⚠️ If any check fails, the default URL is used

## Deployment Checklist

Before deploying to production:

- [ ] Build the app: `flutter build web`
- [ ] Navigate to `build/web/` folder
- [ ] Open and verify `config.json` contains the correct API URL
- [ ] Test the configuration by opening `build/web/index.html` in a browser
- [ ] Deploy the entire `build/web/` folder to your web server
- [ ] After deployment, verify the app loads and makes API calls to the correct URL

## Troubleshooting

### App is using the wrong URL

1. Open browser developer console (F12)
2. Look for messages starting with `🔧 AppConfig:`
3. Verify the config file is loading correctly
4. Check that `apiBase` is set correctly in `config.json`

### Config file not loading

1. Verify the file is named exactly `config.json` (case-sensitive)
2. Verify it's in the root of your web deployment (same level as `index.html`)
3. Verify the JSON syntax is correct (use a JSON validator)
4. Check for CORS issues (file should be served from same origin)

### API calls failing after changing URL

1. Verify the new URL is accessible from a browser
2. Check that the URL has a trailing slash
3. Verify CORS headers are configured on the API server
4. Test the API endpoint directly (e.g., using Postman or curl)

## Support

For technical issues:
1. Check browser console (F12) for error messages
2. Verify `config.json` is valid JSON
3. Test the API URL independently
4. Contact your development team if issues persist






