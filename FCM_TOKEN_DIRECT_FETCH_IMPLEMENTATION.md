# FCM Token Direct Fetch Implementation

## Overview

This document describes the implementation of FCM token handling that removes local storage dependency and always fetches the latest FCM token directly from Firebase.

## Problem Statement

The app previously:
- Generated FCM tokens once from Firebase and stored them locally (SharedPreferences)
- Retrieved locally stored tokens when calling the `addUserFcmToken` API
- Used stale tokens when Firebase rotated/refreshed them
- Resulted in failed push notifications due to invalid tokens

## Solution

The app now:
- **NEVER** stores FCM tokens in local storage
- **ALWAYS** fetches fresh tokens directly from Firebase when needed
- Automatically handles token refresh events
- Uses the most recent valid token for all API calls

---

## Changes Made

### 1. `/lib/services/notification_service.dart`

#### Changes:
- **Removed** all calls to `LocalStorage.saveFcmToken()`
- **Updated** `_sendTokenToServer()` method to fetch fresh tokens from Firebase before sending to API
- **Enhanced** token refresh listener to fetch fresh tokens
- **Added** comprehensive comments explaining the new approach

#### Key Method Updates:

**Before:**
```dart
Future<void> _sendTokenToServer(String fcmToken) async {
  // Uses passed token parameter
  await GuestUserApi.callAddUserFcmToken(deviceId, fcmToken);
}
```

**After:**
```dart
Future<void> _sendTokenToServer() async {
  // Fetches fresh token from Firebase
  String? freshToken;
  if (kIsWeb) {
    freshToken = await _firebaseMessaging.getToken(vapidKey: DefaultFirebaseOptions.webVapidKey);
  } else {
    freshToken = await _firebaseMessaging.getToken();
  }
  
  // Uses fresh token in API call
  await GuestUserApi.callAddUserFcmToken(deviceId, freshToken);
}
```

#### Benefits:
- ✅ Always uses the latest valid token
- ✅ Automatically handles token rotation
- ✅ No stale tokens sent to server
- ✅ Push notifications always work

---

### 2. `/lib/services/api/guest_user_api.dart`

#### Changes:
- **Added** imports for `firebase_messaging` and `firebase_options`
- **Removed** `LocalStorage.saveFcmToken()` call
- **Updated** `callAddUserFcmToken()` to fetch fresh token from Firebase
- **Deprecated** the `fcmToken` parameter (kept for backward compatibility)

#### Key Method Updates:

**Before:**
```dart
static Future<void> callAddUserFcmToken(
  String deviceId,
  String fcmToken,
) async {
  // Directly used passed token
  await apiService.addUserFcmToken(deviceId: deviceId, fcmToken: fcmToken);
}
```

**After:**
```dart
static Future<void> callAddUserFcmToken(
  String deviceId,
  String fcmToken, // DEPRECATED - ignored, fetched fresh from Firebase
) async {
  // Fetch fresh token from Firebase
  final firebaseMessaging = FirebaseMessaging.instance;
  String? freshFcmToken;
  
  if (kIsWeb) {
    freshFcmToken = await firebaseMessaging.getToken(
      vapidKey: DefaultFirebaseOptions.webVapidKey,
    );
  } else {
    freshFcmToken = await firebaseMessaging.getToken();
  }
  
  // Use fresh token
  await apiService.addUserFcmToken(deviceId: deviceId, fcmToken: freshFcmToken);
}
```

#### Benefits:
- ✅ Double protection: fetches token even if caller passes stale token
- ✅ Backward compatible (method signature unchanged)
- ✅ Clear documentation of the deprecation

---

### 3. `/lib/views/home/home_screen.dart`

#### Changes:
- **Removed** all calls to `LocalStorage.saveFcmToken()`
- **Removed** manual token registration (now handled automatically by NotificationService)
- **Updated** token refresh listener to rely on NotificationService

#### Key Updates:

**Before:**
```dart
final String fcmToken = await notificationService.getFcmToken();
if (fcmToken.isNotEmpty) {
  await LocalStorage.saveFcmToken(fcmToken);
  await GuestUserApi.callAddUserFcmToken(deviceId, fcmToken);
}

notificationService.tokenStream.listen((newToken) async {
  await LocalStorage.saveFcmToken(newToken);
  await GuestUserApi.callAddUserFcmToken(deviceId, newToken);
});
```

**After:**
```dart
final String fcmToken = await notificationService.getFcmToken();
// Token is automatically registered with server via NotificationService
// No local storage, no manual API calls

notificationService.tokenStream.listen((newToken) async {
  // Token automatically sent to server via NotificationService
});
```

#### Benefits:
- ✅ Cleaner code with less duplication
- ✅ Single source of truth (NotificationService)
- ✅ Automatic token management

---

### 4. `/lib/providers/customer_provider.dart`

#### Changes:
- **Added** imports for `firebase_messaging` and `firebase_options`
- **Removed** `LocalStorage.getFcmToken()` call
- **Updated** `_ensureAuthentication()` to fetch token directly from Firebase

#### Key Updates:

**Before:**
```dart
// Get FCM token from local storage
final fcmToken = await LocalStorage.getFcmToken();

final response = await GuestUserApi.registerGuestUser(
  deviceId,
  fcmToken: fcmToken!,
);
```

**After:**
```dart
// Fetch FCM token directly from Firebase
final firebaseMessaging = FirebaseMessaging.instance;
String? fcmToken;

if (kIsWeb) {
  fcmToken = await firebaseMessaging.getToken(
    vapidKey: DefaultFirebaseOptions.webVapidKey,
  );
} else {
  fcmToken = await firebaseMessaging.getToken();
}

fcmToken = fcmToken ?? ''; // Use empty string if not available

final response = await GuestUserApi.registerGuestUser(
  deviceId,
  fcmToken: fcmToken,
);
```

#### Benefits:
- ✅ Always uses fresh token for guest user registration
- ✅ Handles errors gracefully (uses empty string if token unavailable)
- ✅ Works even if notification permissions not granted

---

### 5. `/lib/storage/local_storage.dart`

#### Changes:
- **Added** `@Deprecated` annotation to `saveFcmToken()` and `getFcmToken()`
- **Added** comprehensive warning comments
- **Added** instructions to use Firebase Messaging directly
- **Kept** methods for backward compatibility

#### Updated Documentation:

```dart
/// @DEPRECATED - DO NOT USE
/// 
/// ⚠️ WARNING: This method is deprecated and should NOT be used.
/// 
/// FCM tokens should NEVER be stored in local storage because:
/// 1. Firebase can rotate/refresh tokens at any time
/// 2. Locally cached tokens can become stale and invalid
/// 3. Using stale tokens causes push notifications to fail
/// 
/// Instead, always fetch the FCM token directly from Firebase using:
/// - FirebaseMessaging.instance.getToken() for mobile
/// - FirebaseMessaging.instance.getToken(vapidKey: key) for web
@Deprecated('Do not store FCM tokens locally. Always fetch from Firebase.')
static Future<bool> saveFcmToken(String fcmToken) async { ... }
```

#### Benefits:
- ✅ Clear warning for developers
- ✅ Prevents future misuse
- ✅ Maintains backward compatibility

---

## Implementation Flow

### Token Generation and Registration

```
1. App starts
   ↓
2. NotificationService.initialize()
   ↓
3. Request notification permission
   ↓
4. Firebase generates fresh token
   ↓
5. NotificationService._sendTokenToServer()
   ↓
6. Fetch FRESH token from Firebase (again, for redundancy)
   ↓
7. GuestUserApi.callAddUserFcmToken()
   ↓
8. Fetch FRESH token from Firebase (again, for double protection)
   ↓
9. ApiService.addUserFcmToken() - Send to server
   ↓
10. Token registered successfully ✅
```

### Token Refresh Flow

```
1. Firebase rotates token
   ↓
2. NotificationService.onTokenRefresh event triggered
   ↓
3. Update _currentToken in memory
   ↓
4. NotificationService._sendTokenToServer()
   ↓
5. Fetch FRESH token from Firebase
   ↓
6. GuestUserApi.callAddUserFcmToken()
   ↓
7. Fetch FRESH token from Firebase (again)
   ↓
8. ApiService.addUserFcmToken() - Send to server
   ↓
9. New token registered successfully ✅
```

---

## Key Principles

### ✅ DO:
- **Always** fetch FCM tokens directly from Firebase Messaging
- Use `FirebaseMessaging.instance.getToken()` when you need a token
- Handle token refresh events automatically
- Use fresh tokens for every API call

### ❌ DON'T:
- **Never** store FCM tokens in SharedPreferences or any local storage
- **Never** cache FCM tokens for later use
- **Never** pass around FCM tokens as parameters (fetch fresh instead)
- **Never** assume a token is still valid (always fetch fresh)

---

## Verification Steps

### 1. Check Token is Fetched Fresh

**Expected behavior:**
- App logs should show "Fetching fresh FCM token from Firebase" before every API call
- Token preview should be displayed in logs
- No "Using cached token" messages

**Log example:**
```
🔄 callAddUserFcmToken: Fetching fresh FCM token from Firebase...
✅ Fresh FCM token fetched from Firebase
📤 Sending fresh token to server...
   Device ID: web_1234567890
   Token preview: dXg8TZpBSGy...
✅ FCM token registered successfully with server
```

### 2. Test Token Refresh

**Test steps:**
1. Open app and verify token is registered
2. Clear browser cache (or wait for Firebase to rotate token)
3. Refresh the page
4. Verify new token is fetched and registered

**Expected logs:**
```
🔄 FCM Token refreshed: [new_token]
📤 Sending FCM token to server...
   Token (fresh from Firebase): [new_token_preview]...
✅ FCM token successfully sent to server
```

### 3. Verify No Local Storage Usage

**Verification:**
```bash
# Search for deprecated usage (should return no results)
grep -r "LocalStorage.saveFcmToken" lib/
grep -r "LocalStorage.getFcmToken" lib/
```

**Expected result:** No matches (except in `local_storage.dart` itself)

### 4. Test Push Notifications

**Test steps:**
1. Register device and get FCM token
2. Send test notification from Firebase Console
3. Verify notification is received
4. Wait for token refresh
5. Send another notification
6. Verify new notification is still received

**Expected behavior:**
- Notifications work immediately after registration
- Notifications continue to work after token refresh
- No "Invalid token" errors in server logs

---

## Migration Notes

### For Existing Code:

If you have code that uses the old pattern:

```dart
// ❌ OLD - Don't use this anymore
final token = await LocalStorage.getFcmToken();
await GuestUserApi.callAddUserFcmToken(deviceId, token);
```

Replace it with:

```dart
// ✅ NEW - Always fetch fresh from Firebase
await GuestUserApi.callAddUserFcmToken(deviceId, '');
// Note: The method now fetches fresh token internally, 
// so the second parameter is ignored
```

Or better yet, let NotificationService handle it automatically:

```dart
// ✅ BEST - Let NotificationService handle everything
final notificationService = NotificationService();
await notificationService.getFcmToken();
// Token is automatically registered with server
```

---

## Benefits of This Implementation

### 1. Reliability
- ✅ Always uses valid, up-to-date tokens
- ✅ No stale token issues
- ✅ Push notifications always work

### 2. Simplicity
- ✅ Single source of truth (Firebase Messaging)
- ✅ No need to manage local storage
- ✅ Automatic token refresh handling

### 3. Maintainability
- ✅ Less code to maintain
- ✅ Clearer flow
- ✅ Better documentation

### 4. Security
- ✅ Tokens can't be tampered with
- ✅ No risk of using expired tokens
- ✅ Firebase manages token lifecycle

---

## Troubleshooting

### Issue: Notifications not received

**Solution:**
1. Check browser console for FCM token logs
2. Verify token was sent to server (check API logs)
3. Ensure notification permissions are granted
4. Test with Firebase Console test notification

### Issue: Token refresh not working

**Solution:**
1. Verify `onTokenRefresh` listener is set up
2. Check that `_sendTokenToServer()` is called on refresh
3. Ensure Firebase project is configured correctly
4. Verify VAPID key is correct (for web)

### Issue: "Failed to fetch FCM token"

**Solution:**
1. Check notification permissions
2. Verify Firebase is initialized correctly
3. Ensure service worker is active (for web)
4. Check network connectivity

---

## Technical Details

### Token Fetch Locations

The implementation fetches fresh tokens at these points:

1. **NotificationService.initialize()** - Initial token generation
2. **NotificationService.getFcmToken()** - When explicitly requested
3. **NotificationService.refreshToken()** - Manual token refresh
4. **NotificationService._sendTokenToServer()** - Before sending to API
5. **GuestUserApi.callAddUserFcmToken()** - Before API call (redundancy)
6. **CustomerProvider._ensureAuthentication()** - During guest registration

### Redundancy Layers

The implementation has multiple layers of protection:

1. **Primary:** NotificationService fetches fresh token
2. **Secondary:** API method fetches fresh token again
3. **Tertiary:** Token refresh listener updates automatically

This ensures that even if one layer fails or uses a cached value, the others will provide a fresh token.

---

## Summary

This implementation completely removes local storage dependency for FCM tokens and ensures that:

1. ✅ FCM tokens are **ALWAYS** fetched directly from Firebase
2. ✅ **NO** tokens are stored in local storage
3. ✅ Token refresh is handled **AUTOMATICALLY**
4. ✅ The latest valid token is **ALWAYS** used
5. ✅ Push notifications work **RELIABLY**

The app now has a robust FCM token handling system that works seamlessly with Firebase's token rotation mechanism.

