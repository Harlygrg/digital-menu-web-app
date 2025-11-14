# Customer Feature - Quick Testing Guide

## 🚀 Quick Start

This guide will help you quickly test the new customer API integration and bottom sheet flow.

---

## Prerequisites

1. Ensure the app is running
2. Ensure you have items in your menu
3. Ensure the API endpoint is accessible: `https://msibusinesssolutions.com/johny_web_qr/api/v1/api/v1/orderCustomerAdd`

---

## Test Scenario 1: First-Time User (New Customer)

### Steps:
1. **Clear existing data** (if any):
   - Open browser DevTools (F12)
   - Go to Application > Local Storage
   - Clear `customer_id` key (if exists)
   - Or use: `localStorage.clear()`

2. **Add items to cart**:
   - Browse menu items
   - Click on any item
   - Add to cart with desired quantity
   - Navigate to cart screen

3. **Initiate order**:
   - Click "Place Order" button at the bottom
   - ✅ **EXPECT**: Bottom sheet should appear

4. **Test validation**:
   - Click "Continue" without filling fields
   - ✅ **EXPECT**: Validation errors appear
   - Fill only name, click Continue
   - ✅ **EXPECT**: Phone validation error appears
   - Fill only phone, click Continue
   - ✅ **EXPECT**: Name validation error appears

5. **Complete customer registration**:
   - Enter name: "John Doe"
   - Enter phone: "1234567890"
   - Click "Continue"
   - ✅ **EXPECT**: Loading indicator appears
   - ✅ **EXPECT**: Success message appears
   - ✅ **EXPECT**: Bottom sheet closes
   - ✅ **EXPECT**: Service Type popup appears

6. **Complete order**:
   - Select service type (e.g., TAKE-AWAY)
   - ✅ **EXPECT**: Order is placed successfully

### Expected Console Logs:
```
CustomerProvider: Initializing...
CustomerProvider: No saved customer ID found
CustomerProvider: Adding customer - name: John Doe, phone: 1234567890
CustomerRepository: Adding customer - name: John Doe, phone: 1234567890
Add customer API response status: 200
CustomerProvider: Customer added successfully - ID: 123
CustomerRepository: Saving customer ID: 123
```

---

## Test Scenario 2: Returning User (Existing Customer)

### Steps:
1. **Ensure customer data exists**:
   - Complete Test Scenario 1 first
   - Or manually set: `localStorage.setItem('customer_id', '123')`

2. **Reload the page**:
   - Refresh browser (F5)
   - ✅ **EXPECT**: App loads normally

3. **Add items to cart**:
   - Add any items to cart
   - Navigate to cart screen

4. **Initiate order**:
   - Click "Place Order" button
   - ✅ **EXPECT**: Bottom sheet does NOT appear
   - ✅ **EXPECT**: Service Type popup appears immediately

5. **Complete order**:
   - Select service type
   - ✅ **EXPECT**: Order is placed successfully

### Expected Console Logs:
```
CustomerProvider: Initializing...
CustomerProvider: Found saved customer ID: 123
```

---

## Test Scenario 3: Error Handling

### Test 3A: Invalid Phone Number
1. Open bottom sheet (clear customer_id first)
2. Enter name: "Test User"
3. Enter phone: "123" (too short)
4. Click Continue
5. ✅ **EXPECT**: "Please enter a valid phone number" error

### Test 3B: Invalid Name
1. Enter name: "A" (too short)
2. Enter valid phone
3. Click Continue
4. ✅ **EXPECT**: "Name must be at least 2 characters" error

### Test 3C: Network Error (Simulated)
1. Open DevTools > Network tab
2. Set throttling to "Offline"
3. Fill valid details
4. Click Continue
5. ✅ **EXPECT**: Network error message
6. ✅ **EXPECT**: Retry option available

---

## Test Scenario 4: Responsive Design

### Mobile View:
1. Open DevTools (F12)
2. Toggle device toolbar (Ctrl+Shift+M)
3. Select iPhone/Android device
4. Open bottom sheet
5. ✅ **EXPECT**: Bottom sheet fits screen
6. ✅ **EXPECT**: Form fields are properly sized
7. ✅ **EXPECT**: Buttons are touch-friendly

### Tablet View:
1. Select iPad or tablet device
2. Open bottom sheet
3. ✅ **EXPECT**: Larger padding and fonts
4. ✅ **EXPECT**: Professional appearance

---

## Verification Checklist

### Functional:
- [ ] Bottom sheet appears for new users
- [ ] Bottom sheet is skipped for returning users
- [ ] Form validation works correctly
- [ ] API call succeeds with valid data
- [ ] Customer ID is saved to local storage
- [ ] Service Type popup appears after registration
- [ ] Order placement works end-to-end

### UI/UX:
- [ ] Bottom sheet animation is smooth
- [ ] Loading indicator appears during API call
- [ ] Success message is visible
- [ ] Error messages are clear
- [ ] Keyboard appears for text input
- [ ] Phone field accepts only digits
- [ ] Continue button is disabled during loading
- [ ] Form fields are properly styled

### Error Handling:
- [ ] Empty fields show validation errors
- [ ] Invalid phone number shows error
- [ ] Short name shows error
- [ ] Network errors show appropriate message
- [ ] Retry option works for errors

### State Management:
- [ ] Customer ID persists after page refresh
- [ ] Customer ID persists after app restart
- [ ] Clearing storage shows bottom sheet again
- [ ] Provider state updates correctly

---

## Debug Commands

### Check if customer is registered:
```javascript
// In browser console
localStorage.getItem('customer_id')
// Should return customer ID or null
```

### Manually set customer ID:
```javascript
// In browser console
localStorage.setItem('customer_id', '123')
```

### Clear customer data:
```javascript
// In browser console
localStorage.removeItem('customer_id')
```

### View all storage:
```javascript
// In browser console
console.log(localStorage)
```

---

## Common Issues & Solutions

### Issue: Bottom sheet appears every time
**Solution**: Check if customer_id is being saved correctly
```javascript
localStorage.getItem('customer_id') // Should return a number
```

### Issue: API call fails with 401
**Solution**: Check if access token is valid
- Restart the app to refresh tokens
- Check token interceptor is working

### Issue: Bottom sheet doesn't close after success
**Solution**: Check console for JavaScript errors
- Ensure Navigator.pop is called
- Check if context is still mounted

### Issue: Form validation not working
**Solution**: Check if form key is properly initialized
- Ensure _formKey.currentState is not null
- Check validator functions

---

## API Testing with cURL

Test the API directly:

```bash
curl -X POST https://msibusinesssolutions.com/johny_web_qr/api/v1/api/v1/orderCustomerAdd \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "phone": "1234567890",
    "name": "Test User"
  }'
```

Expected response:
```json
{
  "success": true,
  "message": "Number added successfully",
  "customer_id": 123
}
```

---

## Performance Testing

1. **Load Time**:
   - Bottom sheet should appear < 500ms
   - API response should complete < 2s

2. **State Updates**:
   - Provider updates should be immediate
   - UI should reflect state changes smoothly

3. **Memory**:
   - No memory leaks from unclosed controllers
   - Proper disposal of resources

---

## Acceptance Criteria

✅ All tests in this document pass  
✅ No console errors or warnings  
✅ UI matches design specifications  
✅ App remains stable during testing  
✅ Customer data persists correctly  
✅ Error handling is comprehensive  

---

## Next Steps After Testing

1. If all tests pass:
   - ✅ Feature is ready for staging/production
   - Document any edge cases found
   - Update user documentation

2. If issues found:
   - Note the issue and steps to reproduce
   - Check console logs for errors
   - Review relevant code sections
   - Fix and retest

---

## Support & Debugging

If you encounter issues:

1. **Check Console Logs**: Look for errors prefixed with:
   - `CustomerProvider:`
   - `CustomerRepository:`
   - `API Service:`

2. **Check Network Tab**: Verify API requests:
   - Request payload
   - Response status
   - Response data

3. **Check Local Storage**: Verify data persistence:
   - Open Application > Local Storage
   - Look for `customer_id` key

4. **Check Provider State**: Add debug prints:
   ```dart
   debugPrint('Customer ID: ${customerProvider.customerId}');
   debugPrint('Is Loading: ${customerProvider.isLoading}');
   debugPrint('Error: ${customerProvider.errorMessage}');
   ```

---

## Test Data Suggestions

### Valid Test Data:
- Name: "John Doe", Phone: "1234567890"
- Name: "Jane Smith", Phone: "9876543210"
- Name: "Test User", Phone: "5555555555"

### Invalid Test Data:
- Name: "A", Phone: "1234567890" (name too short)
- Name: "John Doe", Phone: "123" (phone too short)
- Name: "", Phone: "" (empty fields)

---

## Completion

When all tests pass, you can confidently say:
✅ Customer API integration is working correctly  
✅ Bottom sheet flow is functioning as expected  
✅ State persistence is reliable  
✅ Error handling is comprehensive  
✅ UI/UX meets requirements  

**The feature is ready for production! 🎉**

