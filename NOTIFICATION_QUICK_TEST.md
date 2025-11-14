# 🚀 Quick Notification Test Guide

## Run App
```bash
flutter run -d chrome --web-port=8080
```

## Get Your FCM Token
1. Open browser console
2. Look for: `🔔 FCM Token: [your-token]`
3. Copy the token (starts with something like `dL6h8f...`)

---

## 3 Quick Tests

### ✅ Test 1: Foreground (30 seconds)
**Goal**: Show popup while app is active

1. **Keep app focused** (don't switch tabs)
2. Send notification (method below)
3. **Expected**: Popup appears in app
4. Click "View Orders"
5. **Success**: Navigate to Order Tracking screen

**Console Log**: `📨 Foreground message received:`

---

### ✅ Test 2: Background (30 seconds)
**Goal**: Click notification from system tray

1. **Switch to different browser tab** (app tab stays open)
2. Send notification
3. **Expected**: System notification appears
4. Click the notification
5. **Success**: App tab focuses + navigates to Order Tracking

**Console Logs**:
```
📨 Background message received:
🖱️ Notification clicked:
📨 Background notification clicked:
```

---

### ✅ Test 3: Terminated (30 seconds)
**Goal**: Launch app from notification

1. **Close browser completely**
2. Send notification
3. **Expected**: System notification appears
4. Click the notification
5. **Success**: App opens to Order Tracking screen

**Console Log**: `📨 App opened from notification (terminated state):`

---

## Send Test Notification

### Option A: Firebase Console (Easiest)
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Your Project → Cloud Messaging → "Send your first message"
3. Title: `Order Ready!`
4. Body: `Your order is ready for pickup`
5. Click "Send test message"
6. Paste your FCM token
7. Click "Test"

### Option B: cURL (Quick)
```bash
# Replace YOUR_SERVER_KEY and DEVICE_FCM_TOKEN

curl -X POST "https://fcm.googleapis.com/fcm/send" \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "DEVICE_FCM_TOKEN",
    "notification": {
      "title": "Order Ready!",
      "body": "Your order #12345 is ready",
      "click_action": "FLUTTER_NOTIFICATION_CLICK"
    },
    "data": {
      "orderId": "12345"
    }
  }'
```

**Get Server Key**: Firebase Console → Project Settings → Cloud Messaging → Server key

---

## Troubleshooting

### ❌ No notification permission prompt?
```
1. Open browser settings
2. Privacy → Site settings → Notifications
3. Find your app domain
4. Set to "Ask" or "Allow"
5. Clear cache and reload
```

### ❌ Foreground popup not showing?
**Check**:
- App is actually focused?
- Console shows `📨 Foreground message received:`?
- Any JavaScript errors in console?

### ❌ Background notification not showing?
**Check**:
- Service worker registered? (DevTools → Application → Service Workers)
- App tab is open but not focused?
- Check browser notification settings

### ❌ Navigation not working?
**Check**:
- Console shows navigation logs?
- Route `/order-tracking` exists?
- Any red errors in console?

### ❌ Service worker issues?
**Reset service worker**:
```javascript
// Run in browser console
navigator.serviceWorker.getRegistrations().then(regs => {
  regs.forEach(reg => reg.unregister());
});
// Then reload page (Ctrl+Shift+R)
```

---

## Success Indicators

### ✅ All Working If You See:

**Foreground Test**:
- Popup appears with notification
- "View Orders" button works
- Navigates smoothly

**Background Test**:
- System notification in tray
- Click focuses app
- Navigates to Order Tracking

**Terminated Test**:
- Click opens app
- Lands on Order Tracking screen
- No navigation delay

---

## Next Steps

1. ✅ All 3 tests pass → Ready for PWA testing
2. ✅ PWA installed → Test all 3 scenarios again
3. ✅ PWA tests pass → Integration with backend
4. ✅ Backend connected → Production deployment

---

## Quick Commands

### Check Service Worker Status
```javascript
// In browser console
navigator.serviceWorker.controller
// Should show: ServiceWorker object
```

### Check Notification Permission
```javascript
// In browser console
Notification.permission
// Should show: "granted"
```

### Get All Service Workers
```javascript
// In browser console
navigator.serviceWorker.getRegistrations().then(regs => {
  console.log('Registered SWs:', regs.length);
  regs.forEach(reg => console.log(reg.scope));
});
```

### Listen to Service Worker Messages
```javascript
// In browser console
navigator.serviceWorker.addEventListener('message', event => {
  console.log('SW Message:', event.data);
});
```

---

## Expected Timeline

| Test | Time | Success Criteria |
|------|------|------------------|
| Foreground | 30 sec | Popup appears |
| Background | 30 sec | Notification + navigation |
| Terminated | 30 sec | App launches to correct screen |
| PWA Install | 2 min | All 3 tests pass in PWA |
| **Total** | **~5 min** | **All scenarios working** |

---

## Files Modified

✅ `web/firebase-messaging-sw.js` - Service worker  
✅ `lib/services/notification_service.dart` - Notification handler  
✅ `lib/main.dart` - App integration  

---

## Support

Check full documentation: `NOTIFICATION_IMPLEMENTATION_GUIDE.md`

Happy Testing! 🎉

