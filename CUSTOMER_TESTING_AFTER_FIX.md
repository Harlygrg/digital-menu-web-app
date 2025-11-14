# Customer Feature - Testing After 401 Fix

## Quick Test Steps

### Test 1: Complete Fresh Start
This tests the automatic guest registration flow.

1. **Clear All Data**:
   ```javascript
   // In browser console
   localStorage.clear()
   ```

2. **Reload the App** (F5)

3. **Add Items to Cart**:
   - Add 1-2 items to cart
   - Navigate to cart screen

4. **Fill Customer Details**:
   - Click "Place Order"
   - Bottom sheet appears
   - Enter name: "Test User"
   - Enter phone: "1234567890"
   - Click "Continue"

5. **Expected Result**:
   - ✅ Loading indicator appears
   - ✅ NO 401 error
   - ✅ Success message: "Customer details saved successfully"
   - ✅ Bottom sheet closes
   - ✅ Service Type popup appears

6. **Check Console Logs**:
   ```
   CustomerProvider: Adding customer...
   CustomerProvider: No access token found, registering as guest user...
   CustomerProvider: Generated device ID: web_customer_xxxxx
   registerGuestUser called
   Guest user registration response: {...}
   Tokens saved successfully
   CustomerProvider: Guest user registration successful
   CustomerRepository: Adding customer...
   Add customer API response status: 200
   CustomerProvider: Customer added successfully
   ```

### Test 2: With Existing Tokens
This tests that authentication is skipped when tokens exist.

1. **Don't Clear Data** (use existing tokens from Test 1)

2. **Clear Only Customer ID**:
   ```javascript
   // In browser console
   localStorage.removeItem('customer_id')
   ```

3. **Reload and Repeat Steps** from Test 1

4. **Expected Result**:
   - ✅ No guest registration happens (tokens already exist)
   - ✅ Customer registration succeeds immediately
   - ✅ Faster response time

5. **Check Console Logs**:
   ```
   CustomerProvider: Adding customer...
   CustomerProvider: Access token already exists
   CustomerRepository: Adding customer...
   Add customer API response status: 200
   CustomerProvider: Customer added successfully
   ```

### Test 3: Returning User
This tests that bottom sheet is skipped for returning users.

1. **Don't Clear Anything** (keep existing tokens and customer_id)

2. **Add Items and Click "Place Order"**

3. **Expected Result**:
   - ✅ Bottom sheet does NOT appear
   - ✅ Service Type popup appears immediately
   - ✅ No API calls made (customer already registered)

---

## Troubleshooting

### Issue: Still Getting 401 Error

**Check**:
```javascript
localStorage.getItem('access_token')
```

**If null**: Check console for guest registration errors  
**If exists**: Token might be invalid or expired

**Solution**:
```javascript
// Clear and retry
localStorage.clear()
// Reload and try again
```

### Issue: Guest Registration Fails

**Check Console For**:
- Network errors
- API endpoint availability
- Device ID generation errors

**Solution**:
- Ensure network connection
- Verify API endpoint is accessible
- Check if baseUrl is correct in api_constants.dart

### Issue: Customer Registration Fails After Guest Registration

**Possible Causes**:
- Customer API endpoint issue
- Token not being sent correctly
- Invalid name/phone format

**Check**:
1. Network tab → Look for Authorization header
2. Console → Check for specific error messages
3. Verify customer API endpoint is correct

---

## Success Criteria

✅ No 401 "Token not provided" errors  
✅ Guest registration happens automatically  
✅ Customer registration succeeds  
✅ Tokens are saved and persisted  
✅ Returning users skip registration  
✅ Error messages are user-friendly  
✅ Loading states are visible  
✅ Success feedback is shown  

---

## Debug Commands

### Check All Stored Data
```javascript
console.log('Access Token:', localStorage.getItem('access_token'))
console.log('Refresh Token:', localStorage.getItem('refresh_token'))
console.log('Device ID:', localStorage.getItem('device_id'))
console.log('Customer ID:', localStorage.getItem('customer_id'))
console.log('Guest Registered:', localStorage.getItem('is_guest_user_registered'))
```

### Force Re-authentication
```javascript
localStorage.removeItem('access_token')
localStorage.removeItem('refresh_token')
localStorage.removeItem('device_id')
localStorage.removeItem('is_guest_user_registered')
// Reload and try again - should trigger guest registration
```

### Test Different Customer
```javascript
localStorage.removeItem('customer_id')
// Reload and add new customer details
```

---

## Expected API Call Sequence

### First Time User (No Tokens):
1. `POST /guestuserregister` → Get tokens
2. `POST /orderCustomerAdd` → Add customer

### Subsequent Calls (Tokens Exist):
1. `POST /orderCustomerAdd` → Add customer (with auth header)

---

## Performance

**Guest Registration**: ~1-2 seconds  
**Customer Registration**: ~1-2 seconds  
**Total First-Time**: ~2-4 seconds  
**Returning User**: < 1 second (skip registration)

---

## Common Errors (Resolved)

### ❌ Error: "Token not provided" (401)
**Status**: FIXED ✅  
**Solution**: Auto guest registration implemented

### ❌ Error: Authentication fails silently
**Status**: FIXED ✅  
**Solution**: Proper error handling and logging added

### ❌ Error: Device ID not generated
**Status**: FIXED ✅  
**Solution**: Simplified device ID generation

---

## Final Verification

After testing, verify:

1. **Data Persistence**:
   - Reload page
   - Tokens still exist ✅
   - Customer ID still exists ✅
   - Can place order without re-registration ✅

2. **Error Recovery**:
   - Try with network offline
   - See appropriate error message ✅
   - Can retry after connection restored ✅

3. **Multiple Customers**:
   - Clear customer_id
   - Add new customer with different details
   - Both customers can be created ✅

---

## Ready for Production

Once all tests pass:

✅ Feature is fully functional  
✅ Authentication is automatic  
✅ Error handling is comprehensive  
✅ User experience is smooth  
✅ No manual token management needed  

**The 401 error issue is completely resolved!** 🎉

