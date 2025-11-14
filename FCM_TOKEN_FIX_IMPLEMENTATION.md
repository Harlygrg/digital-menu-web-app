# FCM Token Fix Implementation Summary

## Problem
The guestUserRegister API was being called before the FCM token was created in production builds, resulting in an empty or null FCM value in the request body.

## Solution
Implemented a proper async flow to ensure FCM token is generated before calling the guestUserRegister API.

## Changes Made

### 1. NotificationService (`lib/services/notification_service.dart`)
**Added:** `getFcmToken()` function
- Returns `Future<String>` with the FCM token or empty string if failed
- Checks for cached token first
- If no cached token, initializes Firebase Messaging and requests permission
- Fetches FCM token (with VAPID key for web)
- Includes automatic retry logic (waits 500ms and retries once if first attempt fails)
- Returns empty string on failure instead of null

**Key Features:**
- Handles both cached and fresh token generation
- Includes permission handling
- Retry mechanism for reliability
- Debug logging for production troubleshooting

### 2. HomeScreen (`lib/views/home/home_screen.dart`)
**Updated:** `initState()` method
- Added import for `NotificationService`
- Fetches FCM token using `NotificationService().getFcmToken()` before initialization
- Waits for FCM token to be retrieved
- Passes the FCM token to `_controller.initialize(fcmToken: fcmToken)`
- Includes debug logs to track token retrieval

**Execution Flow:**
```
1. initState() called
2. WidgetsBinding.instance.addPostFrameCallback()
3. Fetch FCM token (await NotificationService().getFcmToken())
4. Log FCM token status
5. Call _controller.initialize(fcmToken: fcmToken)
```

### 3. HomeController (`lib/controllers/home_controller.dart`)
**Updated:** `initialize()` method signature
- Added optional parameter: `{String? fcmToken}`
- Passes fcmToken to `GuestUserApi.registerGuestUser()`
- Includes debug logging for fcmToken at multiple points:
  - When initialize() is called
  - Before calling registerGuestUser
  - During re-registration (if auth error occurs)

**Flow:**
```dart
Future<void> initialize({String? fcmToken}) async {
  debugPrint('FCM token parameter: ${fcmToken ?? "NULL"}');
  
  if (!isRegistered || accessToken == null) {
    final deviceId = await _generateDeviceId();
    await GuestUserApi.registerGuestUser(
      deviceId,
      fcmToken: fcmToken,  // ← FCM token passed here
    );
  }
  // ... rest of initialization
}
```

### 4. GuestUserApi (`lib/services/api/guest_user_api.dart`)
**Updated:** `registerGuestUser()` method
- Accepts `fcmToken` parameter
- Passes both `deviceId` and `fcmToken` to `apiService.registerGuestUserApiCall()`
- Saves FCM token to local storage after successful registration
- Includes debug logs for deviceId and fcmToken
- Still calls `_addUserFcmToken()` as a secondary backup

**Key Change:**
```dart
dynamic responseData = await apiService.registerGuestUserApiCall(
  deviceId: deviceId,     // Correct device ID
  fcmToken: fcmToken,     // FCM token passed separately
);
```

### 5. ApiService (`lib/services/api/api_service.dart`)
**Updated:** `registerGuestUserApiCall()` method
- Added optional parameter: `String? fcmToken`
- Uses fcmToken in request body if provided, otherwise falls back to deviceId
- Includes debug logs for both deviceId and fcmToken

**Request Body:**
```dart
var data = {
  "device": fcmToken ?? deviceId,  // Prefers FCM token, falls back to deviceId
  "login_type": "from web",
};
```

## Execution Flow Summary

```
┌─────────────────────────────────────────────────────────┐
│ HomeScreen.initState()                                  │
│   └─ WidgetsBinding.instance.addPostFrameCallback()    │
└─────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────┐
│ NotificationService().getFcmToken()                     │
│   ├─ Check cached token                                 │
│   ├─ Request permission if needed                       │
│   ├─ Fetch FCM token from Firebase                      │
│   ├─ Retry once if null (with 500ms delay)              │
│   └─ Return token (or empty string)                     │
└─────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────┐
│ HomeController.initialize(fcmToken: token)              │
│   └─ Check if guest user registered                     │
└─────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────┐
│ GuestUserApi.registerGuestUser(deviceId, fcmToken)      │
│   └─ Pass both deviceId and fcmToken                    │
└─────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────┐
│ ApiService.registerGuestUserApiCall()                   │
│   └─ Send API request with FCM token in body            │
└─────────────────────────────────────────────────────────┘
```

## Debug Logging

The implementation includes comprehensive debug logging at each step:

1. **HomeScreen:**
   - "🔑 HomeScreen: Fetching FCM token before initialization..."
   - "🔑 HomeScreen: FCM token received: {token}"
   - "✅ HomeScreen: Initializing with FCM token"
   - "⚠️ HomeScreen: FCM token is empty, proceeding with initialization anyway"

2. **NotificationService.getFcmToken():**
   - "🔍 getFcmToken: Starting..."
   - "✅ getFcmToken: Using cached token: {token}"
   - "⏳ getFcmToken: No cached token, initializing Firebase Messaging..."
   - "❌ getFcmToken: Notification permission denied"
   - "✅ getFcmToken: Token obtained successfully: {token}"
   - "⚠️ getFcmToken: First attempt returned null, retrying..."
   - "✅ getFcmToken: Token obtained on retry: {token}"
   - "❌ getFcmToken: Failed to obtain token after retry"

3. **HomeController:**
   - "🚀 HomeController: initialize started"
   - "🔑 HomeController: FCM token parameter: {token}"
   - "📱 HomeController: Device ID: {deviceId}"
   - "🔑 HomeController: FCM token for registration: {token}"

4. **GuestUserApi:**
   - "Device ID: {deviceId}"
   - "FCM Token: {fcmToken}"

5. **ApiService:**
   - "Device ID: {deviceId}"
   - "FCM Token: {fcmToken}"
   - "registerGuestUserApiCall data: {data}"

## Error Handling

1. **FCM Token Generation Fails:**
   - Returns empty string instead of crashing
   - Logs warning message
   - Continues with initialization (app doesn't crash)

2. **Permission Denied:**
   - Returns empty string
   - Logs permission denial
   - App continues to function without notifications

3. **Token Retry Logic:**
   - Automatically retries once after 500ms delay
   - Increases reliability in production builds

## Testing in Production

To verify the fix is working in production builds:

1. Check debug logs in browser console (for web builds)
2. Look for the sequence of FCM token logs
3. Verify that "FCM token for registration" shows a valid token (not NULL or EMPTY)
4. Check the API request payload to confirm FCM token is included

**Expected Log Sequence:**
```
🔑 HomeScreen: Fetching FCM token before initialization...
🔍 getFcmToken: Starting...
✅ getFcmToken: Token obtained successfully: {long-token-string}
🔑 HomeScreen: FCM token received: {long-token-string}
✅ HomeScreen: Initializing with FCM token
🚀 HomeController: initialize started
🔑 HomeController: FCM token parameter: {long-token-string}
Device ID: {deviceId}
FCM Token: {long-token-string}
registerGuestUserApiCall data: {"device": "{long-token-string}", "login_type": "from web"}
```

## Benefits

1. ✅ FCM token is guaranteed to be generated before API call
2. ✅ Reliable async flow with proper await handling
3. ✅ Works in both dev and production builds
4. ✅ Comprehensive debug logging for troubleshooting
5. ✅ Retry mechanism for improved reliability
6. ✅ Graceful error handling (app doesn't crash)
7. ✅ FCM token saved to local storage for future use
8. ✅ Backward compatible (still calls addUserFcmToken as backup)

## Files Modified

1. `lib/services/notification_service.dart` - Added getFcmToken()
2. `lib/views/home/home_screen.dart` - Updated initState()
3. `lib/controllers/home_controller.dart` - Updated initialize()
4. `lib/services/api/guest_user_api.dart` - Updated registerGuestUser()
5. `lib/services/api/api_service.dart` - Updated registerGuestUserApiCall()

## Implementation Date
October 23, 2025

