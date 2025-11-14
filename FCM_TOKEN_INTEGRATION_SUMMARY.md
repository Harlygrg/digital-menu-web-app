# FCM Token Integration Summary

## Overview
Successfully integrated the "Add User FCM" API to send the FCM token to the server right after guest user registration.

## Changes Made

### 1. API Constants (`lib/constants/api_constants.dart`)
- Added `addUserFcm` constant for the FCM token endpoint

### 2. API Service (`lib/services/api/api_service.dart`)
- Added `addUserFcmToken()` method to handle FCM token registration
- Method uses POST request with Authorization Bearer token
- Sends device ID, FCM token, and usertype="user" as body parameters

### 3. Guest User API (`lib/services/api/guest_user_api.dart`)
- Updated `registerGuestUser()` to accept optional `fcmToken` and `context` parameters
- Added `_addUserFcmToken()` private method to send FCM token after successful guest registration
- Handles success silently and shows SnackBar on error (when context is available)
- FCM token registration happens asynchronously and doesn't block the main flow

### 4. Local Storage (`lib/storage/local_storage.dart`)
- Added `saveFcmToken()` method to save FCM token
- Added `getFcmToken()` method to retrieve FCM token
- Added `clearFcmToken()` method to remove FCM token

### 5. Main App (`lib/main.dart`)
- Updated `_initializeFirebaseMessaging()` to save FCM token when received
- Saves token to local storage on initial retrieval and on refresh

### 6. Home Controller (`lib/controllers/home_controller.dart`)
- Updated both registration calls to retrieve and pass FCM token from local storage
- Ensures FCM token is sent during initial registration and re-registration scenarios

### 7. Customer Provider (`lib/providers/customer_provider.dart`)
- Updated `_ensureAuthentication()` to retrieve and pass FCM token when registering guest user

## API Details

### Endpoint
- **Path**: `/api/Customer/adduserfcm`
- **Full URL**: When using Dio with the configured baseUrl, the path starting with `/` will be resolved from the domain root
- **Method**: POST
- **Authorization**: Bearer token (JWS token from guest user registration)

### Request Body
```json
{
  "device": "deviceid",
  "token": "fcm token",
  "usertype": "user"
}
```

### Response Example
```json
{
  "success": true,
  "message": "FCM token added successfully",
  "data": {
    "id": 2,
    "device": "11133",
    "token": "123d",
    "usertype": "user",
    "created_at": "2025-10-19 17:21:49",
    "updated_at": "2025-10-19 17:21:49"
  }
}
```

## Implementation Flow

1. **App Initialization** (`main.dart`):
   - Firebase Messaging is initialized
   - FCM token is retrieved and saved to local storage
   - Token refresh listener saves updated tokens automatically

2. **Guest User Registration**:
   - Device ID is generated
   - FCM token is retrieved from local storage
   - `registerGuestUser()` is called with device ID and FCM token
   - On successful registration, tokens are saved
   - `_addUserFcmToken()` is called to register FCM token with server

3. **Error Handling**:
   - If FCM token registration fails, error is logged
   - SnackBar is shown if BuildContext is available
   - Main app flow continues uninterrupted

## Key Features

✅ Non-blocking implementation - FCM token registration doesn't delay user navigation
✅ Automatic token refresh - Updates server when FCM token is refreshed
✅ Graceful error handling - Shows user-friendly error messages
✅ Backward compatible - Works with existing code, FCM token is optional
✅ Persisted token - FCM token saved to local storage for reuse
✅ Authorization secured - Uses Bearer token for API authentication

## Testing Recommendations

1. Test fresh installation - Verify FCM token is sent after first registration
2. Test token refresh - Verify server is updated when FCM token refreshes
3. Test re-registration - Verify FCM token is sent during re-authentication
4. Test network errors - Verify error handling and SnackBar display
5. Test without FCM token - Verify app works if FCM token is unavailable

## Notes

- FCM token is optional - if not available, guest registration proceeds normally
- BuildContext is optional - error SnackBar only shown when context is provided
- Token registration is asynchronous - doesn't block the main registration flow
- All linting checks passed - no errors in the implementation

