# Testing Guide - Create Order Flow

## 🧪 Quick Testing Steps

### Prerequisites
1. Ensure the app is running
2. Ensure API base URL is accessible
3. Ensure guest user is registered (access token available)
4. Ensure branch is selected

---

## 📋 Step-by-Step Testing

### 1. **Add Items to Cart**
- Navigate to home screen
- Browse menu items
- Click on an item
- Add to cart popup should appear
- Select size/unit (if applicable)
- Add modifiers/addons
- Enter quantity
- Add special instructions (optional)
- Click "Add to Cart"
- Verify cart icon shows item count

### 2. **View Cart**
- Click on cart icon in app bar
- Verify all items are displayed
- Verify modifiers are shown
- Verify quantities are correct
- Verify prices are calculated correctly
- Verify total amount is correct

### 3. **Place Order - Select Service Type**
- Click "Place Order" button
- Service Type Popup should appear
- Verify "Select Service Type" header
- Verify order types are displayed (Dine-In, Take-Away)
- Select an order type (e.g., Dine-In)
- Click "Continue"

### 4. **Select Table**
- Table Screen should appear
- Verify floor tabs are displayed
- Verify tables are shown in grid
- Select a table
- Verify table is highlighted
- Verify "Confirm Selection (1 table)" button appears
- Click "Confirm Selection"

### 5. **API Call & Loading**
- Loading dialog should appear with:
  - Circular progress indicator
  - "Placing your order..." text
- Wait for API response

### 6. **Success Scenario**
If order is successful:
- Success popup should appear with:
  - Green checkmark icon
  - "Order placed successfully!" message
  - Order ID
  - Online Order ID
  - Order Number
  - "View Order Details" button
  - "Back to Menu" button

### 7. **View Order Details**
- Click "View Order Details"
- Order Screen should appear with:
  - Success header
  - Order details card
  - Order items list
  - Total amount
  - "Back to Menu" button
- Verify all information is correct

### 8. **Return to Menu**
- Click "Back to Menu"
- Should navigate to home screen
- Cart should be cleared
- Ready for next order

---

## ❌ Error Scenarios to Test

### 1. **Empty Cart**
- Try to place order with empty cart
- Should show error: "Cart is empty. Please add items first."

### 2. **No Table Selected**
- Add items to cart
- Select service type
- Don't select any table
- Click "Confirm Selection"
- Should show error: "Please select a table first"

### 3. **Network Error**
- Disconnect from internet
- Try to place order
- Should show error: "Network error. Please check your connection."

### 4. **Server Error**
- If server returns 500
- Should show error: "Server error. Please try again later."

### 5. **Unauthorized Error**
- If token is invalid
- Should show error: "Unauthorized. Please log in again."

---

## 🔍 Things to Verify

### Data Accuracy
- [ ] Order ID is displayed correctly
- [ ] Online Order ID is displayed correctly
- [ ] Order Number is displayed correctly
- [ ] All cart items are included in the order
- [ ] All modifiers are included in the order
- [ ] Special instructions are sent correctly
- [ ] Quantities are accurate
- [ ] Prices are accurate
- [ ] Total amount is correct
- [ ] Table ID is sent correctly
- [ ] Order Type ID is sent correctly
- [ ] Branch ID is sent correctly

### UI/UX
- [ ] All popups are centered and properly sized
- [ ] Loading dialog cannot be dismissed
- [ ] Success popup is visually appealing
- [ ] Order screen is well-formatted
- [ ] All buttons are clickable
- [ ] Navigation works correctly
- [ ] Cart is cleared after order
- [ ] Responsive on mobile (portrait)
- [ ] Responsive on tablet (portrait)

### Error Handling
- [ ] All validation errors show appropriate messages
- [ ] Network errors are handled gracefully
- [ ] API errors show user-friendly messages
- [ ] Loading state prevents multiple submissions
- [ ] Context.mounted checks prevent navigation errors

---

## 🔧 Debugging Tips

### Enable Debug Logging
The implementation includes debug prints for:
- API request data
- API response data
- Order creation status
- Error messages

Check the console for:
```
Creating order...
Order request data: {...}
Create order API response status: 200
Create order API response data: {...}
Order saved: ID=402041, Online ID=740108, Order No=134647
```

### Common Issues

**Issue**: "No access token available"
- **Solution**: Ensure guest user registration completed successfully

**Issue**: "Branch not selected"
- **Solution**: Ensure branch ID is saved in local storage

**Issue**: API timeout
- **Solution**: Check network connection and API server status

**Issue**: "Invalid request"
- **Solution**: Check order details structure, verify all required fields

---

## 📱 Device Testing

### Mobile (< 600px)
- [ ] Popup fits on screen
- [ ] Buttons are easily tappable
- [ ] Text is readable
- [ ] Grid layout is appropriate

### Tablet (600px - 900px)
- [ ] Scaled UI elements (1.2x)
- [ ] Proper spacing
- [ ] Max content width applied

### Desktop (> 900px)
- [ ] Centered content
- [ ] Max width constraints
- [ ] Scaled UI elements (1.4x-1.6x)

---

## 🎯 Expected API Request Format

```json
{
  "grosstotal": 908,
  "discount": 0,
  "servicecharge": 0,
  "nettotal": 908,
  "tableID": 12,
  "OrderType": "8",
  "cid": 2,
  "orderNotes": null,
  "roundoff": 0.0,
  "orderDtls": [
    {
      "slno": 1,
      "itmId": 60,
      "itmremarks": "Extra spicy",
      "qty": 2,
      "unitID": 1,
      "rate": 25.0,
      "total": 50.0,
      "itmType": 0
    },
    {
      "slno": 2,
      "itmId": 5,
      "itmremarks": "",
      "qty": 1,
      "unitID": 0,
      "rate": 5.0,
      "total": 5.0,
      "itmType": 1
    }
  ],
  "defaults_info": ""
}
```

---

## 🎯 Expected API Response Format

**Success**:
```json
{
  "success": true,
  "data": {
    "message": "Order created successfully",
    "orderid": 402041,
    "online_order_id": 740108,
    "OrderNo": 134647
  }
}
```

**Error**:
```json
{
  "success": false,
  "message": "Error message here"
}
```

---

## ✅ Testing Checklist Summary

- [ ] Can add items to cart
- [ ] Can view cart
- [ ] Can select service type
- [ ] Can select table
- [ ] Can place order successfully
- [ ] Loading indicator works
- [ ] Success popup appears
- [ ] Order details are correct
- [ ] Can view order screen
- [ ] Can return to menu
- [ ] Cart is cleared after order
- [ ] All error scenarios handled
- [ ] UI is responsive
- [ ] No console errors
- [ ] No linting errors

---

## 📊 Performance Metrics

### Expected Response Times
- API call: < 3 seconds
- Popup animation: < 300ms
- Screen navigation: < 100ms

### Memory Usage
- No memory leaks
- Proper widget disposal
- Provider cleanup

---

**Happy Testing! 🚀**

