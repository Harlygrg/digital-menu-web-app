# Automatic Token Refresh Implementation Summary

## Overview
This document describes the implementation of automatic token refresh functionality in the Flutter app. The system now automatically detects expired access tokens, refreshes them in the background, and retries failed requests—all without user intervention.

## Implementation Details

### 1. API Endpoint Addition
**File:** `lib/constants/api_constants.dart`

Added a new constant for the refresh token endpoint:
```dart
static const String refreshToken = "refreshToken";
```

### 2. Refresh Token Method
**File:** `lib/services/api/guest_user_api.dart`

Created `refreshAccessToken()` method that:
- Calls the `refreshToken` API endpoint
- Receives new access and refresh tokens
- Automatically saves updated tokens to local storage
- Handles errors by clearing invalid tokens

Also added corresponding response models:
- `RefreshTokenResponse`
- `RefreshTokenData`

### 3. API Service Enhancement
**File:** `lib/services/api/api_service.dart`

Added `refreshTokenApiCall()` method that:
- Makes a POST request to the refresh token endpoint
- Uses the stored refresh token (automatically injected by TokenInterceptor)
- Includes a special flag (`skipTokenRefresh: true`) to prevent circular refresh calls
- Returns the new tokens from the server

### 4. Automatic Token Refresh Logic
**File:** `lib/services/api/api_service.dart` (TokenInterceptor)

Completely redesigned the `TokenInterceptor` to automatically:

#### Detection Phase
- Intercepts all HTTP 401 errors
- Checks if the error message contains "Invalid access token"
- Identifies which endpoints should be excluded from auto-refresh

#### Refresh Phase
- Sets a `_isRefreshing` flag to prevent multiple simultaneous refresh attempts
- Calls the refresh token API endpoint
- Saves new tokens to local storage
- Manages a queue of requests waiting for refresh completion

#### Retry Phase
- Updates the original request headers with the new access token
- Retries the failed request automatically
- Returns the successful response to the caller

#### Exclusion Logic
The following endpoints are **excluded** from automatic refresh:
1. `guestUserRegister` - Guest user registration endpoint
2. `refreshToken` - Refresh token endpoint itself (prevents circular calls)
3. `addUserFcm` - FCM token registration endpoint
4. Any request with `skipTokenRefresh: true` in extra options

### 5. Concurrent Request Handling
The implementation includes sophisticated handling for multiple concurrent requests:
- If a refresh is already in progress, subsequent requests wait for it to complete
- Uses a polling mechanism with timeout (5 seconds max)
- All queued requests retry with the new token once refresh completes

### 6. Error Handling
**Graceful degradation when refresh fails:**
- Clears all stored authentication data
- Allows the error to propagate to the UI layer
- Prevents infinite refresh loops

**Specific error scenarios:**
- If refresh token API fails → Clear auth data, user needs to restart app
- If refresh token is invalid → Clear auth data, user needs to restart app
- If network error during refresh → Error propagates, app shows network error

## How It Works

### Normal Flow (Token Valid)
```
1. User makes API request (e.g., getUserOrders)
2. TokenInterceptor injects access token into headers
3. Server validates token → Success
4. Response returned to user
```

### Token Expired Flow (Automatic Refresh)
```
1. User makes API request (e.g., getUserOrders)
2. TokenInterceptor injects expired access token
3. Server returns 401: "Invalid access token"
4. TokenInterceptor detects the error
5. TokenInterceptor calls refreshTokenApiCall()
6. Server returns new access and refresh tokens
7. Tokens saved to local storage
8. Original request retried with new access token
9. Server validates new token → Success
10. Response returned to user (seamless experience)
```

### Multiple Concurrent Requests
```
1. Request A, B, C made simultaneously (all with expired token)
2. All three get 401 errors
3. Request A starts token refresh, sets _isRefreshing = true
4. Requests B and C see _isRefreshing = true, enter waiting state
5. Request A completes refresh, saves new tokens
6. Request A notifies waiting requests
7. Requests A, B, C all retry with new token
8. All succeed, return responses
```

## Code Quality Features

### 1. Clear Debug Logging
- Uses emoji prefixes (🔄, ✅, ❌, ⏳) for easy log filtering
- Detailed logging at each step of the refresh process
- Helps with debugging and monitoring

### 2. Modular Design
- Refresh logic isolated in `_performTokenRefresh()`
- Retry logic isolated in `_retryRequest()`
- Wait logic isolated in `_waitForTokenRefresh()`
- Easy to test and maintain

### 3. Comprehensive Documentation
- All methods have detailed doc comments
- Explains the purpose and behavior
- Documents expected responses and error cases

### 4. Prevents Common Issues
- **Circular refresh loops:** Uses `skipTokenRefresh` flag
- **Multiple simultaneous refreshes:** Uses `_isRefreshing` flag
- **Infinite retries:** Proper error handling and cleanup
- **Race conditions:** Proper async/await with state management

## Testing Guidelines

### Manual Testing Checklist

1. **Basic Token Refresh**
   - [ ] Let access token expire naturally
   - [ ] Make any API call
   - [ ] Verify token refreshes automatically
   - [ ] Verify request succeeds without error shown to user

2. **Multiple Concurrent Requests**
   - [ ] Let token expire
   - [ ] Trigger multiple API calls simultaneously
   - [ ] Verify only one refresh happens
   - [ ] Verify all requests succeed

3. **Excluded Endpoints**
   - [ ] Verify FCM token registration doesn't trigger refresh
   - [ ] Verify refresh endpoint itself doesn't trigger refresh
   - [ ] Verify guest registration doesn't use token auth

4. **Error Scenarios**
   - [ ] Test with invalid refresh token (should clear auth)
   - [ ] Test with network error during refresh (should show error)
   - [ ] Test refresh endpoint returning 401 (should clear auth)

5. **Edge Cases**
   - [ ] Token expires during app suspension
   - [ ] Token expires during slow network
   - [ ] Multiple tabs/windows (if applicable for web)

### Expected Behaviors

**✅ Success Cases:**
- User never sees "Invalid access token" error
- All API calls work seamlessly even with expired tokens
- No interruption to user experience
- Tokens updated in local storage

**❌ Failure Cases (When Refresh Token Also Invalid):**
- User sees generic "Authentication failed" message
- User needs to restart app to re-register
- All auth data cleared from storage

## Configuration

### Timeouts and Limits
- **Refresh wait timeout:** 5 seconds (50 attempts × 100ms)
- **Connection timeout:** 30 seconds (from ApiConstants)
- **Receive timeout:** 30 seconds (from ApiConstants)

### Customization Points
To modify behavior, update these values in `TokenInterceptor`:
```dart
const maxAttempts = 50;  // Refresh wait attempts
const waitDuration = Duration(milliseconds: 100);  // Wait between attempts
```

## Security Considerations

1. **Token Storage:** Uses SharedPreferences (should consider encrypted storage for production)
2. **Token Exposure:** Tokens only logged in debug mode
3. **Token Clearing:** Automatic cleanup on refresh failure
4. **Refresh Token Rotation:** Server provides new refresh token on each refresh

## Files Modified

1. `lib/constants/api_constants.dart` - Added refresh token endpoint
2. `lib/services/api/guest_user_api.dart` - Added refresh method and models
3. `lib/services/api/api_service.dart` - Added refresh API call and automatic refresh logic

## Dependencies

- `dio` - HTTP client with interceptor support
- `shared_preferences` - Local storage for tokens
- `flutter` - Framework with async/await support

## Performance Impact

- **Negligible overhead:** Only activates on 401 errors
- **Prevents duplicate calls:** Multiple requests share one refresh
- **Minimal wait time:** Concurrent requests wait max 5 seconds
- **Reduced server load:** Prevents unnecessary re-registration

## Future Enhancements

Potential improvements for future iterations:

1. **Proactive Refresh:** Refresh token before it expires (e.g., 5 min before expiry)
2. **Token Expiry Tracking:** Store token expiry timestamp and refresh proactively
3. **Encrypted Storage:** Use flutter_secure_storage for token storage
4. **Refresh Queue:** More sophisticated queue management for waiting requests
5. **Analytics:** Track refresh frequency to monitor token expiry patterns
6. **Retry Count Limit:** Add max retry count per request to prevent infinite loops

## Troubleshooting

### Issue: Token keeps refreshing repeatedly
**Solution:** Check if refresh token endpoint is excluded from auto-refresh

### Issue: Requests fail after refresh
**Solution:** Verify new token is properly saved to local storage

### Issue: Multiple refresh calls happening
**Solution:** Verify `_isRefreshing` flag is properly managed

### Issue: Requests timeout waiting for refresh
**Solution:** Increase `maxAttempts` or check refresh API performance

## Summary

The automatic token refresh implementation provides a seamless authentication experience by:
- ✅ Detecting expired tokens automatically
- ✅ Refreshing tokens in the background
- ✅ Retrying failed requests with new tokens
- ✅ Handling concurrent requests efficiently
- ✅ Preventing circular refresh loops
- ✅ Maintaining clean separation of concerns
- ✅ Providing comprehensive error handling
- ✅ Requiring zero user intervention

Users will never see token-related errors unless both access and refresh tokens are invalid, in which case they'll see a clear message to restart the app.

