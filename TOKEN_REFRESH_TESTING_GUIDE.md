# Token Refresh Testing Guide

## Quick Start Testing

This guide will help you verify that the automatic token refresh feature is working correctly.

## Prerequisites

Before testing, ensure:
1. The app is running and you're logged in as a guest user
2. You have access to the app logs/console
3. The backend refresh token endpoint is working

## Test Scenarios

### Test 1: Basic Token Refresh (Recommended First Test)

**Goal:** Verify that expired tokens are automatically refreshed

**Steps:**
1. Start the app and let it register as a guest user
2. Wait for the access token to expire (or manually expire it on the backend)
3. Perform any API action (e.g., view menu, check orders, etc.)
4. Check the logs for the following sequence:

**Expected Log Output:**
```
🔴 Received 401 error. Message: Invalid access token
🔄 Invalid access token detected. Attempting to refresh...
🔄 Calling refreshAccessToken...
🔄 refreshTokenApiCall - calling refresh token endpoint
Making POST request to refreshToken
✅ Refresh token API call successful
✅ Tokens saved successfully after refresh
✅ Token refreshed successfully. Retrying original request...
🔄 Retrying original request: [endpoint name]
```

**Expected User Experience:**
- ✅ No error message shown to user
- ✅ The action completes successfully
- ✅ No need to restart the app
- ✅ Seamless experience

**If Test Fails:**
- Check if the refresh token endpoint is working
- Verify tokens are being saved to local storage
- Check network connectivity

---

### Test 2: Multiple Concurrent Requests

**Goal:** Verify that multiple requests with expired tokens trigger only one refresh

**Steps:**
1. Let the access token expire
2. Trigger multiple API calls simultaneously (e.g., fetch menu + fetch orders)
3. Watch the logs

**Expected Log Output:**
```
🔴 Received 401 error. Message: Invalid access token [for request 1]
🔴 Received 401 error. Message: Invalid access token [for request 2]
🔄 Invalid access token detected. Attempting to refresh...
⏳ Token refresh already in progress. Queuing request... [for request 2]
🔄 Calling refreshAccessToken...
✅ Token refreshed successfully. Retrying original request...
🔄 Retrying original request: [endpoint 1]
🔄 Retrying original request: [endpoint 2]
```

**Expected Behavior:**
- ✅ Only ONE refresh call is made
- ✅ Second request waits for first refresh to complete
- ✅ Both requests succeed with the new token
- ✅ No duplicate refresh calls

---

### Test 3: FCM Token Registration (Should NOT Trigger Refresh)

**Goal:** Verify that FCM token registration is excluded from auto-refresh

**Steps:**
1. Clear app data to force re-registration
2. Start the app
3. Grant notification permission (if prompted)
4. Let the FCM token registration happen
5. Watch the logs

**Expected Behavior:**
- ✅ FCM token endpoint should NOT trigger refresh even if it gets 401
- ✅ No refresh logs during FCM token registration
- ✅ FCM registration works independently

---

### Test 4: Refresh Token Fails (Edge Case)

**Goal:** Verify proper error handling when refresh token is also invalid

**Steps:**
1. Manually invalidate both access and refresh tokens on the backend
2. Trigger any API call
3. Watch for proper error handling

**Expected Log Output:**
```
🔴 Received 401 error. Message: Invalid access token
🔄 Invalid access token detected. Attempting to refresh...
🔄 Calling refreshAccessToken...
❌ DioException during token refresh: [error message]
🔴 Refresh token endpoint failed. Clearing auth data.
```

**Expected User Experience:**
- ✅ Error message shown: "Authentication failed. Please restart the app."
- ✅ Auth data cleared from local storage
- ✅ User needs to restart app (which will re-register as guest)

---

### Test 5: Guest User Registration (Should NOT Use Tokens)

**Goal:** Verify guest registration doesn't use authentication

**Steps:**
1. Clear app data completely
2. Start the app for the first time
3. Watch the registration process

**Expected Behavior:**
- ✅ Guest registration succeeds without tokens
- ✅ No "Invalid token" errors during registration
- ✅ Tokens are saved after successful registration

---

## Manual Token Expiry Testing

If you want to test without waiting for natural token expiry, you can:

### Option 1: Backend Modification (Recommended)
Modify the backend to issue tokens with very short expiry (e.g., 30 seconds) for testing:
```
access_token_expiry: 30 seconds
refresh_token_expiry: 5 minutes
```

### Option 2: Manual Token Invalidation
If your backend has admin tools, manually invalidate the access token while keeping the refresh token valid.

### Option 3: Code Modification (Temporary, for testing only)
Add a debug button that clears only the access token:
```dart
// In your debug/test screen
ElevatedButton(
  onPressed: () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    print('Access token cleared for testing');
  },
  child: Text('Test Token Refresh'),
)
```

---

## Common Issues and Solutions

### Issue 1: Token refresh keeps happening repeatedly
**Symptom:** Logs show continuous refresh calls
**Solution:** 
- Check if the refresh endpoint is properly excluded from auto-refresh
- Verify the new token is being saved to local storage
- Check if the `skipTokenRefresh` flag is working

### Issue 2: Requests fail even after refresh
**Symptom:** 401 error persists after refresh attempt
**Solution:**
- Verify the refresh token endpoint returns correct response format
- Check if new tokens are properly saved to local storage
- Verify the `Authorization` header is updated in retry

### Issue 3: Multiple refresh calls happening simultaneously
**Symptom:** Multiple "Calling refreshAccessToken" logs
**Solution:**
- Verify `_isRefreshing` flag is properly managed
- Check if the flag is being reset in finally block

### Issue 4: App crashes or hangs during refresh
**Symptom:** App becomes unresponsive
**Solution:**
- Check for infinite loops or recursive calls
- Verify the wait timeout is working (max 5 seconds)
- Check for deadlocks in async operations

---

## Monitoring in Production

### Key Metrics to Track
1. **Refresh success rate:** Percentage of successful refresh attempts
2. **Refresh frequency:** How often tokens are being refreshed
3. **Concurrent refresh count:** How many requests wait for refresh
4. **Refresh latency:** Time taken for refresh operation

### Recommended Logging (for production monitoring)
```dart
// Add to TokenInterceptor._performTokenRefresh()
final startTime = DateTime.now();
// ... refresh logic ...
final duration = DateTime.now().difference(startTime);
print('Token refresh completed in ${duration.inMilliseconds}ms');
```

---

## Debug Checklist

Before reporting issues, verify:
- [ ] Backend refresh token endpoint is working
- [ ] Refresh token is being sent in request headers
- [ ] New tokens are returned in correct format
- [ ] New tokens are being saved to local storage
- [ ] The original request is being retried with new token
- [ ] Excluded endpoints are properly configured
- [ ] No network connectivity issues

---

## Success Criteria

Your implementation is working correctly if:
- ✅ Users never see "Invalid access token" errors
- ✅ API calls succeed even with expired tokens
- ✅ Only one refresh happens for multiple concurrent requests
- ✅ Excluded endpoints work without token refresh
- ✅ Failed refresh properly clears auth data
- ✅ No infinite loops or crashes
- ✅ Smooth user experience with no interruptions

---

## Quick Verification Commands

To quickly verify the implementation is working, run these checks:

### 1. Check if refresh endpoint constant exists
```bash
grep -r "refreshToken" lib/constants/api_constants.dart
```
Expected: Should find the constant definition

### 2. Check if refresh method exists
```bash
grep -r "refreshAccessToken" lib/services/api/guest_user_api.dart
```
Expected: Should find the method definition

### 3. Check if TokenInterceptor has refresh logic
```bash
grep -r "_performTokenRefresh" lib/services/api/api_service.dart
```
Expected: Should find the method implementation

---

## Final Notes

- The implementation is designed to be completely transparent to the user
- Users should never need to manually refresh or re-login due to token expiry
- Only if both tokens are invalid should the user need to restart
- All refresh operations happen automatically in the background

**Happy Testing! 🚀**

If you encounter any issues not covered in this guide, check the implementation details in `AUTO_TOKEN_REFRESH_IMPLEMENTATION.md`.

