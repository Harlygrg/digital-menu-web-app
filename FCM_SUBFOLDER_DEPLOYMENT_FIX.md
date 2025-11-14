# FCM Token Fix for Subfolder Deployment

## Problem Summary

When deploying the Flutter web app to a subfolder (e.g., `/waraq/`), the Firebase Cloud Messaging (FCM) service worker was not being registered correctly, causing the FCM token to be empty in production.

### Root Cause
The service worker was being registered with an absolute path `/firebase-messaging-sw.js`, which looked for the file at the domain root (`https://msibusinesssolutions.com/firebase-messaging-sw.js`) instead of in the subfolder (`https://msibusinesssolutions.com/waraq/firebase-messaging-sw.js`).

## Changes Made

### 1. Updated `web/index.html`
- ✅ Added dynamic service worker registration that reads the base href
- ✅ Constructs the service worker path relative to the base href
- ✅ Sets the service worker scope to match the base path

### 2. Updated `lib/views/home/home_screen.dart`
- ✅ Added `_waitForServiceWorkerReady()` helper method
- ✅ Waits up to 10 seconds for service worker to be active before requesting FCM token
- ✅ Added proper error handling and logging
- ✅ Fixed linter warnings (removed unused imports)

### 3. Built with Correct Base Href
```bash
flutter build web --release --base-href /waraq/
```

## Deployment Instructions

### Step 1: Upload the Build Files
Upload the entire contents of `build/web/` to your server's `/waraq/` folder.

**Important files to verify:**
- ✅ `index.html` - Contains the service worker registration code
- ✅ `firebase-messaging-sw.js` - The Firebase service worker
- ✅ `main.dart.js` - The compiled Flutter app
- ✅ `flutter.js`, `flutter_bootstrap.js` - Flutter runtime files

### Step 2: Verify Server Configuration

Ensure your web server serves the files with correct MIME types:
```
.js   -> application/javascript
.json -> application/json
.html -> text/html
```

### Step 3: Test the Deployment

1. Open your browser to: `https://msibusinesssolutions.com/waraq/?branch_id=1`

2. Open the browser console (F12) and look for these log messages:
```
🔧 Registering service worker at: /waraq/firebase-messaging-sw.js
🔧 Base path: /waraq/
✅ Firebase Service Worker registered successfully
   Scope: https://msibusinesssolutions.com/waraq/
✅ Firebase Service Worker is ready
```

3. Check for FCM token logs:
```
⏳ Waiting for service worker to be ready...
🔍 Checking for service worker registration...
✅ Service worker found and registered
   Scope: https://msibusinesssolutions.com/waraq/
✅ Service worker is ready
🔔 FCM Token: eyJhbGciOiJS... (a long token)
✅ FCM token saved to local storage
```

4. If you see a 404 error for `firebase-messaging-sw.js`, verify that:
   - The file exists at `https://msibusinesssolutions.com/waraq/firebase-messaging-sw.js`
   - The file is accessible (not blocked by .htaccess or server config)
   - HTTPS is enabled (FCM requires HTTPS)

### Step 4: Grant Notification Permissions

When prompted by the browser, click "Allow" to enable notifications. The FCM token will only be generated after permission is granted.

## How It Works Now

1. **Page Loads**: The browser loads `index.html`
2. **Service Worker Registration**: JavaScript in the `<head>` reads the base href and registers the service worker at the correct path
3. **Flutter App Starts**: The Flutter app boots after the service worker is registered
4. **Wait for Service Worker**: `home_screen.dart` waits for the service worker to be active
5. **Initialize FCM**: NotificationService initializes and requests the FCM token
6. **Token Generated**: FCM generates a token (requires service worker + notification permission)
7. **Token Saved**: Token is saved to local storage and sent to your backend

## Troubleshooting

### Issue: Still getting 404 for service worker
**Solution**: 
- Verify the file exists at the exact path: `https://msibusinesssolutions.com/waraq/firebase-messaging-sw.js`
- Check server logs to see what path is being requested
- Ensure no URL rewrite rules are interfering

### Issue: FCM token is empty
**Solution**:
1. Check browser console for errors
2. Verify notification permission was granted
3. Ensure HTTPS is enabled (HTTP will not work)
4. Wait for service worker to be fully active (up to 10 seconds)

### Issue: Works locally but not in production
**Solution**:
- Ensure you built with the correct base href: `--base-href /waraq/`
- Verify all files were uploaded (especially `firebase-messaging-sw.js`)
- Check HTTPS certificate is valid
- Clear browser cache and reload

## Testing Checklist

- [ ] Service worker registers without 404 errors
- [ ] Service worker scope is `https://msibusinesssolutions.com/waraq/`
- [ ] Notification permission prompt appears
- [ ] FCM token is generated and logged to console
- [ ] FCM token is saved to local storage
- [ ] FCM token is sent to backend API
- [ ] Notifications can be received when sent from Firebase Console

## Build Commands for Different Environments

### For `/waraq/` subfolder:
```bash
flutter build web --release --base-href /waraq/
```

### For root domain:
```bash
flutter build web --release --base-href /
```

### For other subfolders:
```bash
flutter build web --release --base-href /your-folder-name/
```

## Related Files
- `web/index.html` - Service worker registration
- `web/firebase-messaging-sw.js` - Service worker implementation
- `lib/views/home/home_screen.dart` - FCM initialization
- `lib/services/notification_service.dart` - FCM service

## Additional Notes

- The service worker will cache itself and may need hard refresh (Ctrl+Shift+R) when updating
- FCM tokens can expire and will be refreshed automatically by the `tokenStream` listener
- In development, use `flutter run -d chrome --web-port=8080` to test locally
- The VAPID key is hardcoded but can be extracted to configuration if needed

