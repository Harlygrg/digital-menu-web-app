# Quick Deployment Steps for Waraq Subfolder

## What Was Fixed?
The service worker path issue has been resolved. The app now:
- ✅ Dynamically reads the base href from `<base>` tag
- ✅ Registers service worker at correct path: `/waraq/firebase-messaging-sw.js`
- ✅ Waits for service worker to be ready before requesting FCM token
- ✅ Properly handles subfolder deployments

## Deploy to Production (Waraq Folder)

### 1. Build the App
```bash
cd /Users/harlygeorge/StudioProjects/digital_menu_order
flutter build web --release --base-href /waraq/
```

### 2. Upload Files to Server
Upload the entire contents of `build/web/` to your server's `waraq/` folder:

```
Server path: /var/www/html/waraq/ (or wherever your waraq folder is)
```

**Critical files to verify are uploaded:**
- `index.html`
- `firebase-messaging-sw.js` ⚠️ IMPORTANT
- `main.dart.js`
- `flutter.js`
- `flutter_bootstrap.js`
- `manifest.json`
- All folders: `assets/`, `icons/`, `canvaskit/`

### 3. Test in Browser

Open: `https://msibusinesssolutions.com/waraq/?branch_id=1`

### 4. Check Console Logs

You should see:
```
✅ Firebase Service Worker registered successfully
✅ Firebase Service Worker is ready
✅ Service worker found and registered
🔔 FCM Token: eyJ... (long token string)
✅ FCM token saved to local storage
```

### 5. Allow Notifications

When the browser prompts, click **"Allow"** to enable notifications.

## Expected Console Output (Success)

```
🔧 Registering service worker at: /waraq/firebase-messaging-sw.js
🔧 Base path: /waraq/
✅ Firebase Service Worker registered successfully
   Scope: https://msibusinesssolutions.com/waraq/
✅ Firebase Service Worker is ready
🔍 _extractAndSaveBranchId: Starting extraction...
✅ Branch ID found in URL: 1
⏳ Waiting for service worker to be ready...
🔍 Checking for service worker registration...
✅ Service worker found and registered
   Scope: https://msibusinesssolutions.com/waraq/
✅ Service worker is ready
🔔 Initializing Firebase Messaging...
📱 Requesting notification permission...
🔔 Permission status: AuthorizationStatus.authorized
✅ FCM Token obtained: eyJhbGc... [LONG TOKEN]
✅ FCM token saved to local storage
🚀 HomeController: initialize started
✅ Guest user registered successfully
✅ Initialization complete
```

## If You See Errors

### ❌ 404 Error for firebase-messaging-sw.js
**Problem**: Service worker file not found

**Solution**:
1. Verify the file exists at: `https://msibusinesssolutions.com/waraq/firebase-messaging-sw.js`
2. Upload the file again if missing
3. Check server permissions (file should be readable)

### ❌ Failed to obtain FCM token
**Problem**: Service worker not ready or permissions denied

**Solution**:
1. Check if notification permission was granted
2. Wait 10-15 seconds for service worker to activate
3. Hard refresh the page (Ctrl+Shift+R or Cmd+Shift+R)
4. Clear browser cache and try again

### ⚠️ Service worker not found after 10000ms
**Problem**: Service worker taking too long to activate

**Solution**:
1. This is just a warning, FCM will still attempt to initialize
2. Refresh the page
3. Check if file is accessible at the URL

## Production URLs

- **Main App**: `https://msibusinesssolutions.com/waraq/?branch_id=1`
- **Service Worker**: `https://msibusinesssolutions.com/waraq/firebase-messaging-sw.js`
- **Manifest**: `https://msibusinesssolutions.com/waraq/manifest.json`

## Important Notes

⚠️ **HTTPS Required**: FCM only works over HTTPS
⚠️ **Permissions**: User must grant notification permissions
⚠️ **Service Worker Scope**: Must be within `/waraq/` path
⚠️ **Cache**: Service workers cache aggressively - use hard refresh when updating

## Need to Deploy to a Different Subfolder?

If you need to deploy to a different path (e.g., `/menu/`):

```bash
flutter build web --release --base-href /menu/
```

Then upload to the `/menu/` folder on your server.

## For Root Domain Deployment

If deploying to root (e.g., `https://msibusinesssolutions.com/`):

```bash
flutter build web --release --base-href /
```

Then upload to the root web folder.

