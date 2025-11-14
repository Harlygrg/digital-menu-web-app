# FCM Token Direct Fetch - Testing Guide

## Quick Testing Checklist

This guide helps you verify that FCM tokens are always fetched fresh from Firebase and never rely on local storage.

---

## Pre-Testing Setup

### 1. Clear Local Storage
```javascript
// In browser console
localStorage.clear();
sessionStorage.clear();
```

### 2. Clear Service Worker Cache
```javascript
// In browser console
navigator.serviceWorker.getRegistrations().then(function(registrations) {
  for(let registration of registrations) {
    registration.unregister();
  }
});
```

### 3. Hard Refresh Browser
- Press `Ctrl + Shift + R` (Windows/Linux)
- Press `Cmd + Shift + R` (Mac)

---

## Test Cases

### ✅ Test 1: Initial Token Generation

**Steps:**
1. Open the app with empty cache
2. Open browser console
3. Look for FCM token logs

**Expected Logs:**
```
🔔 Initializing Firebase Messaging...
📱 Requesting notification permission from browser...
✅ Permission GRANTED
✅ FCM Token obtained: [token]
📤 Sending FCM token to server...
   Device ID: [device_id]
   Token (fresh from Firebase): [token_preview]...
✅ FCM token successfully sent to server
```

**Success Criteria:**
- ✅ "Fetching fresh FCM token from Firebase" appears in logs
- ✅ No "Using cached token" messages
- ✅ No errors in console
- ✅ Token is registered with server

---

### ✅ Test 2: Token Not Stored Locally

**Steps:**
1. After app loads and token is registered
2. Open browser console
3. Run:
```javascript
localStorage.getItem('fcm_token')
```

**Expected Result:**
```
⚠️ WARNING: Retrieving FCM token from local storage is deprecated. Always fetch from Firebase.
null  // or the old deprecated value if it existed
```

**Success Criteria:**
- ✅ Deprecation warning appears
- ✅ Value should be null (or ignore if it exists from old version)
- ✅ App does not use this value (verified in network tab)

---

### ✅ Test 3: Fresh Token on Every API Call

**Steps:**
1. Open browser DevTools → Network tab
2. Filter by: `addUserFcm`
3. Trigger FCM token registration (refresh page)
4. Check request payload

**Expected Request Payload:**
```json
{
  "device": "web_1234567890",
  "token": "[fresh_token_from_firebase]",
  "usertype": "user"
}
```

**How to Verify Token is Fresh:**
1. Copy the token from request payload
2. Open browser console
3. Run:
```javascript
// Get fresh token from Firebase
const messaging = firebase.messaging();
messaging.getToken({ vapidKey: 'YOUR_VAPID_KEY' }).then(token => {
  console.log('Fresh token:', token);
});
```
4. Compare tokens - they should match

**Success Criteria:**
- ✅ Token in API request matches fresh Firebase token
- ✅ No stale tokens are sent

---

### ✅ Test 4: Token Refresh Handling

**Steps:**
1. Open browser console
2. Simulate token refresh:
```javascript
// Manually trigger token refresh
const messaging = firebase.messaging();
messaging.deleteToken().then(() => {
  return messaging.getToken({ vapidKey: 'YOUR_VAPID_KEY' });
}).then(newToken => {
  console.log('New token:', newToken);
});
```
3. Watch the console logs

**Expected Logs:**
```
🔄 FCM Token refreshed: [new_token]
📤 Sending FCM token to server...
   Token (fresh from Firebase): [new_token_preview]...
✅ FCM token successfully sent to server
```

**Success Criteria:**
- ✅ New token is automatically fetched from Firebase
- ✅ New token is sent to server
- ✅ No errors occur
- ✅ No local storage operations

---

### ✅ Test 5: Multiple API Calls Use Fresh Tokens

**Steps:**
1. Open Network tab
2. Refresh page multiple times
3. Check each `addUserFcm` request

**Expected Behavior:**
- Each request should log: "Fetching fresh FCM token from Firebase"
- Each request should use current Firebase token
- No cached tokens should be used

**Success Criteria:**
- ✅ Multiple calls all fetch fresh tokens
- ✅ All requests succeed
- ✅ Logs show fresh fetch each time

---

### ✅ Test 6: Guest User Registration

**Steps:**
1. Clear all data (localStorage, cookies, service worker)
2. Refresh page
3. Try to add a customer or place an order
4. Watch console logs

**Expected Logs:**
```
CustomerProvider: No access token found, registering as guest user...
CustomerProvider: Fetching fresh FCM token from Firebase...
CustomerProvider: Fresh FCM token obtained from Firebase
✅ Guest user marked as registered
🔄 callAddUserFcmToken: Fetching fresh FCM token from Firebase...
✅ Fresh FCM token fetched from Firebase
📤 Sending fresh token to server...
✅ FCM token registered successfully with server
```

**Success Criteria:**
- ✅ Token is fetched fresh for guest registration
- ✅ Token is fetched fresh again when calling API
- ✅ No local storage operations
- ✅ Guest user registration succeeds

---

### ✅ Test 7: Notification Delivery

**Steps:**
1. Register device and get FCM token
2. Note the token from console logs
3. Go to Firebase Console → Cloud Messaging
4. Send test notification to that token
5. Verify notification is received

**Expected Result:**
- Notification appears in browser
- No "Invalid token" errors
- Notification handler is triggered

**To test after token refresh:**
1. Delete token and generate new one (see Test 4)
2. Send notification to NEW token
3. Verify notification is still received

**Success Criteria:**
- ✅ Notifications work with initial token
- ✅ Notifications work after token refresh
- ✅ No delivery failures

---

### ✅ Test 8: Deprecated Methods Warning

**Steps:**
1. Try to call deprecated methods from console:
```javascript
// Test save (should show warning)
LocalStorage.saveFcmToken('test_token');

// Test get (should show warning)
LocalStorage.getFcmToken();
```

**Expected Console Output:**
```
⚠️ WARNING: Storing FCM token locally is deprecated. Always fetch from Firebase.
⚠️ WARNING: Retrieving FCM token from local storage is deprecated. Always fetch from Firebase.
```

**Success Criteria:**
- ✅ Deprecation warnings appear
- ✅ App code doesn't use these methods
- ✅ No errors occur

---

### ✅ Test 9: Permission Denied Scenario

**Steps:**
1. Clear browser data
2. Refresh page
3. Deny notification permission
4. Watch console logs

**Expected Logs:**
```
📱 Requesting notification permission from browser...
❌ Permission DENIED
⚠️ Failed to fetch FCM token from Firebase
ℹ️ This may happen if notification permissions are not granted
```

**Success Criteria:**
- ✅ App handles denial gracefully
- ✅ No crashes or errors
- ✅ App continues to work (just without notifications)
- ✅ No attempts to use cached tokens

---

### ✅ Test 10: Long-Running Session

**Steps:**
1. Open app and register device
2. Keep app open for 24+ hours
3. Check if token is still valid
4. Send test notification

**Expected Behavior:**
- Token should auto-refresh if Firebase rotates it
- Notifications should continue to work
- No manual intervention needed

**Success Criteria:**
- ✅ Token automatically refreshes when needed
- ✅ Notifications work after long sessions
- ✅ No stale token errors

---

## Automated Verification Script

Run this script in the browser console to check implementation:

```javascript
async function verifyFCMImplementation() {
  console.log('🔍 Verifying FCM Implementation...\n');
  
  // Check 1: LocalStorage should not have FCM token in active use
  console.log('✓ Check 1: Local storage usage');
  const storedToken = localStorage.getItem('fcm_token');
  if (storedToken) {
    console.warn('⚠️ WARNING: Token found in localStorage (should not be used)');
  } else {
    console.log('✅ No token in localStorage (correct)');
  }
  
  // Check 2: Get fresh token from Firebase
  console.log('\n✓ Check 2: Fresh token from Firebase');
  try {
    const messaging = firebase.messaging();
    const freshToken = await messaging.getToken({ 
      vapidKey: 'YOUR_VAPID_KEY' // Replace with your actual VAPID key
    });
    console.log('✅ Fresh token obtained:', freshToken.substring(0, 20) + '...');
  } catch (e) {
    console.error('❌ Failed to get fresh token:', e.message);
  }
  
  // Check 3: Verify NotificationService exists
  console.log('\n✓ Check 3: NotificationService');
  if (window.NotificationService) {
    console.log('✅ NotificationService is available');
  } else {
    console.warn('⚠️ NotificationService not found in window');
  }
  
  console.log('\n✅ Verification complete!');
}

// Run verification
verifyFCMImplementation();
```

---

## Common Issues and Solutions

### Issue: "Failed to get FCM token"

**Possible Causes:**
- Notification permission not granted
- Service worker not active
- Firebase not initialized
- Network issues

**Solutions:**
1. Check permission status: `Notification.permission`
2. Check service worker: `navigator.serviceWorker.controller`
3. Verify Firebase config in console
4. Check network connectivity

---

### Issue: Notifications not received

**Possible Causes:**
- Token not registered with server
- Server using old/cached token
- Notification permission revoked

**Solutions:**
1. Check network tab for successful API calls
2. Verify token in server logs
3. Re-grant notification permission
4. Clear browser cache and retry

---

### Issue: Console shows "cached token" messages

**Problem:** This indicates the old implementation is still being used

**Solution:**
1. Verify all files are updated
2. Check for old code using `LocalStorage.getFcmToken()`
3. Hard refresh browser (`Ctrl + Shift + R`)
4. Clear service worker cache

---

### Issue: Deprecation warnings appearing

**This is expected!** The warnings indicate:
- ✅ Deprecated methods still exist (for backward compatibility)
- ✅ But they're not being used by app code
- ℹ️ Safe to ignore these warnings

To verify they're not in use:
```bash
# Should return no results (except in local_storage.dart itself)
grep -r "LocalStorage.getFcmToken" lib/
grep -r "LocalStorage.saveFcmToken" lib/
```

---

## Success Indicators

Your implementation is correct if:

1. ✅ All test cases pass
2. ✅ Console shows "Fetching fresh FCM token from Firebase" before API calls
3. ✅ No "Using cached token" messages appear
4. ✅ Notifications are delivered successfully
5. ✅ Token refresh works automatically
6. ✅ No errors in console
7. ✅ `LocalStorage.getFcmToken()` is never called by app code
8. ✅ Network requests show fresh tokens

---

## Test Report Template

Use this template to document your test results:

```
FCM Token Implementation Test Report
Date: [DATE]
Tester: [NAME]

✅ Test 1: Initial Token Generation - PASSED / FAILED
✅ Test 2: Token Not Stored Locally - PASSED / FAILED
✅ Test 3: Fresh Token on Every API Call - PASSED / FAILED
✅ Test 4: Token Refresh Handling - PASSED / FAILED
✅ Test 5: Multiple API Calls Use Fresh Tokens - PASSED / FAILED
✅ Test 6: Guest User Registration - PASSED / FAILED
✅ Test 7: Notification Delivery - PASSED / FAILED
✅ Test 8: Deprecated Methods Warning - PASSED / FAILED
✅ Test 9: Permission Denied Scenario - PASSED / FAILED
✅ Test 10: Long-Running Session - PASSED / FAILED

Overall Status: PASSED / FAILED

Notes:
[Add any observations, issues, or comments here]
```

---

## Final Verification

Before deploying to production:

1. ✅ Run all 10 test cases
2. ✅ Run automated verification script
3. ✅ Check console for any errors
4. ✅ Send test notifications
5. ✅ Verify with multiple browsers
6. ✅ Test on different devices
7. ✅ Monitor for 24 hours in staging
8. ✅ Review server logs for token errors

---

## Questions to Ask

After testing, confirm:

1. **Are fresh tokens fetched before every API call?** → Should be YES
2. **Is any token stored in localStorage?** → Should be NO (or ignored if present)
3. **Do notifications work after token refresh?** → Should be YES
4. **Are there any console errors?** → Should be NO
5. **Does the app work without notification permission?** → Should be YES

If all answers are correct, your implementation is successful! ✅
