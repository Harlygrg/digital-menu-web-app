# FCM Token Fix - Testing Guide

## Testing the FCM Token Generation Fix

This guide helps you verify that the FCM token is now properly generated before the guestUserRegister API is called.

## Quick Test (Web/PWA)

### 1. Build and Run Production Build

```bash
# Clean previous builds
flutter clean

# Build for web (production)
flutter build web --release

# Or run in profile mode for testing with debug logs
flutter run -d chrome --profile
```

### 2. Open Browser Developer Console

- Press F12 or Right-click → Inspect
- Go to the **Console** tab
- Clear any existing logs

### 3. Reload the Application

Refresh the page and watch for the following log sequence:

#### ✅ Expected Success Log Sequence:

```
🔑 HomeScreen: Fetching FCM token before initialization...
🔍 getFcmToken: Starting...
✅ getFcmToken: Token obtained successfully: eyJhbGci...
🔑 HomeScreen: FCM token received: eyJhbGci...
✅ HomeScreen: Initializing with FCM token
🚀 HomeController: initialize started
🔑 HomeController: FCM token parameter: eyJhbGci...
📱 HomeController: Device ID: web_1234-5678...
🔑 HomeController: FCM token for registration: eyJhbGci...
registerGuestUser called
Device ID: web_1234-5678...
FCM Token: eyJhbGci...
Calling registerGuestUserApiCall...
registerGuestUserApiCall
Device ID: web_1234-5678...
FCM Token: eyJhbGci...
Making POST request to /guestUserRegister
registerGuestUserApiCall data: {device: eyJhbGci..., login_type: from web}
```

### 4. Verify API Request

In the **Network** tab:
- Find the `guestUserRegister` request
- Click on it and go to **Payload** or **Request** tab
- Verify the body contains:
  ```json
  {
    "device": "eyJhbGci...",  // ← Should be FCM token (long string)
    "login_type": "from web"
  }
  ```

#### ❌ OLD BEHAVIOR (Bug):
```json
{
  "device": "",  // ← Empty or null
  "login_type": "from web"
}
```

#### ✅ NEW BEHAVIOR (Fixed):
```json
{
  "device": "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9...",  // ← Valid FCM token
  "login_type": "from web"
}
```

## Test Scenarios

### Scenario 1: Fresh Installation (No Cached Token)

**Steps:**
1. Clear browser data (Application → Clear storage)
2. Reload the app
3. Grant notification permission when prompted

**Expected Result:**
- App requests notification permission
- FCM token is generated
- Token is logged in console
- guestUserRegister receives valid token

**Log to Look For:**
```
🔍 getFcmToken: Starting...
⏳ getFcmToken: No cached token, initializing Firebase Messaging...
📱 Requesting notification permission...
🔔 Permission status: authorized
✅ getFcmToken: Token obtained successfully: {token}
```

### Scenario 2: Cached Token Exists

**Steps:**
1. Run the app once (to generate and cache token)
2. Reload the page

**Expected Result:**
- App uses cached token immediately
- No permission request
- Token passed to API instantly

**Log to Look For:**
```
🔍 getFcmToken: Starting...
✅ getFcmToken: Using cached token: {token}
```

### Scenario 3: Permission Denied

**Steps:**
1. Clear browser data
2. Reload the app
3. Click "Block" when notification permission is requested

**Expected Result:**
- App continues to work (doesn't crash)
- Empty token is passed to API
- Warning logged

**Log to Look For:**
```
📱 Requesting notification permission...
❌ getFcmToken: Notification permission denied
⚠️ HomeScreen: FCM token is empty, proceeding with initialization anyway
```

### Scenario 4: Token Retry Logic

**Steps:**
1. Run on slow network
2. Monitor for retry attempts

**Expected Result:**
- If first attempt fails, automatically retries after 500ms
- Second attempt should succeed

**Log to Look For:**
```
⚠️ getFcmToken: First attempt returned null, retrying...
✅ getFcmToken: Token obtained on retry: {token}
```

## Production Build Testing

### For Web Production:

```bash
# Build production
flutter build web --release

# Serve locally
cd build/web
python3 -m http.server 8000

# Open browser
open http://localhost:8000
```

### For Android Production:

```bash
# Build APK
flutter build apk --release

# Install on device
adb install build/app/outputs/flutter-apk/app-release.apk

# View logs
adb logcat | grep -E "FCM|HomeScreen|HomeController"
```

## Verification Checklist

- [ ] FCM token is generated before API call
- [ ] Token is NOT empty or null in API request
- [ ] Token is logged correctly in all debug prints
- [ ] App doesn't crash if token generation fails
- [ ] Token is saved to local storage
- [ ] Second app load uses cached token
- [ ] API receives FCM token in "device" field
- [ ] addUserFcmToken is still called as backup

## Common Issues and Solutions

### Issue 1: Token is NULL
**Cause:** Firebase not initialized or permission denied
**Solution:** 
- Check Firebase configuration
- Verify VAPID key is correct in notification_service.dart
- Grant notification permission

### Issue 2: Token is EMPTY string
**Cause:** Both attempts to fetch token failed
**Solution:**
- Check network connection
- Verify Firebase project settings
- Check browser console for Firebase errors

### Issue 3: API receives empty device field
**Cause:** FCM token not passed to initialize()
**Solution:**
- Verify home_screen.dart calls `getFcmToken()` before `initialize()`
- Check async/await flow is correct
- Look for any exceptions in the logs

### Issue 4: App crashes on startup
**Cause:** Unhandled exception during token fetch
**Solution:**
- Check try-catch blocks in getFcmToken()
- Verify error handling in home_screen.dart
- Review stack trace in console

## Backend Verification

To verify the backend receives the FCM token:

1. Check backend logs for incoming guestUserRegister requests
2. Verify the "device" field contains a valid FCM token
3. Confirm token is stored in the database
4. Test sending a notification to verify token works

## Success Criteria

✅ **The fix is working correctly if:**

1. Console logs show FCM token is fetched BEFORE initialize()
2. API request body contains a valid FCM token (long string)
3. No NULL or empty device field in API requests
4. App continues to work even if FCM token fails
5. Token is logged at each step for debugging
6. Production builds work identically to dev builds

## Monitoring in Production

Add these checks to your monitoring:

1. **Monitor API requests:**
   - Track % of requests with empty "device" field
   - Alert if percentage increases

2. **Monitor logs:**
   - Track "FCM token is empty" warnings
   - Alert on high frequency

3. **Monitor user experience:**
   - Ensure app doesn't crash on startup
   - Verify notifications are received

## Rollback Plan

If issues occur, the changes can be safely rolled back:

```bash
# Revert to previous commit
git revert HEAD

# Or restore specific files
git checkout HEAD~1 -- lib/services/notification_service.dart
git checkout HEAD~1 -- lib/views/home/home_screen.dart
git checkout HEAD~1 -- lib/controllers/home_controller.dart
git checkout HEAD~1 -- lib/services/api/guest_user_api.dart
git checkout HEAD~1 -- lib/services/api/api_service.dart
```

## Support

If you encounter issues:

1. Check FCM_TOKEN_FIX_IMPLEMENTATION.md for implementation details
2. Review console logs for error messages
3. Verify Firebase configuration
4. Test with different browsers/devices
5. Check network connectivity

## Testing Complete

Once all test scenarios pass and the verification checklist is complete, the fix is ready for production deployment.

