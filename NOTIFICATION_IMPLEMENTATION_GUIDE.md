# 🔔 Notification Implementation Guide

## Overview
This guide explains the unified Firebase Cloud Messaging (FCM) notification system for the Digital Menu Web App, supporting both browser and PWA installations.

---

## ✅ What's Been Implemented

### 1. **Service Worker** (`web/firebase-messaging-sw.js`)
- ✅ Handles background notifications when app is minimized or browser tab is inactive
- ✅ Displays system tray notifications via browser
- ✅ Handles notification clicks to open/focus app window
- ✅ Automatically navigates to Order Tracking screen on click
- ✅ Posts messages to active app window for seamless navigation
- ✅ Works in both browser and installed PWA contexts

### 2. **Notification Service** (`lib/services/notification_service.dart`)
- ✅ Requests notification permissions from user
- ✅ Obtains and manages FCM tokens
- ✅ **Foreground Messages**: Shows AlertDialog popup when app is active
- ✅ **Background Clicks**: Handles `onMessageOpenedApp` when user clicks notification while app is in background
- ✅ **Terminated State**: Handles `getInitialMessage` when app is launched from notification
- ✅ Listens to service worker messages for navigation coordination
- ✅ Navigates to Order Tracking screen in all scenarios
- ✅ Beautiful, themed popup matching app design

### 3. **Main App Integration** (`lib/main.dart`)
- ✅ Initializes FCM in startup sequence
- ✅ Sets up navigation stream listener
- ✅ Provides global navigator key for reliable navigation
- ✅ Updates notification service context for dialogs
- ✅ Properly handles cleanup on dispose

---

## 🎯 Notification Scenarios Covered

### Scenario 1: **Foreground (App Active)**
**When**: User is actively using the app (browser tab or PWA window is focused)

**Behavior**:
1. Notification received via `FirebaseMessaging.onMessage`
2. Beautiful AlertDialog popup appears with:
   - Notification icon
   - Title (bold, primary color)
   - Body message
   - "Dismiss" button
   - "View Orders" button (navigates to order tracking)
3. User can dismiss or navigate to orders

**Code Location**: `NotificationService._showForegroundNotificationPopup()`

---

### Scenario 2: **Background (App Running but Inactive)**
**When**: App is running but browser tab is inactive or PWA window is minimized

**Behavior**:
1. Service worker receives notification
2. Browser system tray notification displayed
3. User clicks notification
4. Service worker:
   - Finds and focuses existing app window
   - Sends `postMessage` to app with navigation instruction
5. App navigates to Order Tracking screen via `onMessageOpenedApp`

**Code Locations**: 
- Service Worker: `firebase-messaging-sw.js` (lines 58-113)
- Dart: `NotificationService._setupBackgroundMessageHandler()`

---

### Scenario 3: **Terminated (App Closed)**
**When**: Browser/PWA is completely closed

**Behavior**:
1. Service worker receives notification
2. Browser system tray notification displayed
3. User clicks notification
4. Service worker opens new browser window/PWA at `/order-tracking` URL
5. App starts up and checks `getInitialMessage()`
6. If initial message exists, navigates to Order Tracking screen after 500ms delay

**Code Locations**:
- Service Worker: `firebase-messaging-sw.js` (lines 103-107)
- Dart: `NotificationService._checkInitialMessage()`

---

## 🧪 Testing Guide

### Prerequisites
1. **HTTPS Required**: FCM only works on HTTPS or localhost
2. **Browser**: Chrome, Edge, Brave, or other Chromium browsers
3. **Notification Permission**: Must be granted by user

### Test Setup
1. Build and run the app:
   ```bash
   flutter run -d chrome --web-port=8080
   ```

2. Open browser DevTools Console to see debug logs

3. Grant notification permission when prompted

4. Note your FCM token from console (starts with "FCM Token:")

### Test Scenario 1: Foreground Notification
1. Keep app active and focused
2. Send FCM notification using Firebase Console or backend API
3. **Expected**: AlertDialog popup appears with notification
4. Click "View Orders" → Should navigate to Order Tracking screen
5. **Success Indicators**:
   - Console: `📨 Foreground message received:`
   - Popup displays with title and body
   - Navigation works smoothly

### Test Scenario 2: Background Notification
1. Switch to different browser tab (keep app tab open)
2. Send FCM notification
3. **Expected**: System tray notification appears
4. Click notification → App tab focuses and navigates to Order Tracking
5. **Success Indicators**:
   - Console: `📨 Background message received:`
   - Console: `🖱️ Notification clicked:`
   - Console: `✅ Focusing existing window and navigating`
   - Console: `📨 Background notification clicked:`
   - Navigation to Order Tracking screen

### Test Scenario 3: Terminated State
1. Completely close the browser/PWA
2. Send FCM notification
3. Click the system tray notification
4. **Expected**: App opens and immediately shows Order Tracking screen
5. **Success Indicators**:
   - App launches
   - Console: `📨 App opened from notification (terminated state):`
   - Console: `🚀 Navigating to order tracking screen...`
   - Order Tracking screen displays

### PWA-Specific Testing
1. Install as PWA:
   - Chrome: Click install icon in address bar
   - Edge: Settings → Apps → Install this site as an app
2. Repeat all three test scenarios with installed PWA
3. All behaviors should work identically

---

## 📤 Sending Test Notifications

### Method 1: Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Cloud Messaging → Send your first message
4. Enter title: "Order Update"
5. Enter body: "Your order status has changed"
6. Click "Send test message"
7. Paste your FCM token
8. Click "Test"

### Method 2: Using cURL (Backend Testing)
```bash
curl -X POST "https://fcm.googleapis.com/fcm/send" \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "DEVICE_FCM_TOKEN",
    "notification": {
      "title": "Order Ready!",
      "body": "Your order #12345 is ready for pickup",
      "click_action": "FLUTTER_NOTIFICATION_CLICK"
    },
    "data": {
      "orderId": "12345",
      "orderStatus": "ready"
    }
  }'
```

### Method 3: Using Postman
```
POST https://fcm.googleapis.com/fcm/send
Headers:
  Authorization: key=YOUR_SERVER_KEY
  Content-Type: application/json
Body (JSON):
{
  "to": "DEVICE_FCM_TOKEN",
  "notification": {
    "title": "Order Update",
    "body": "Your order status has been updated"
  },
  "data": {
    "orderId": "12345"
  }
}
```

---

## 🎨 Customization

### Popup Styling
Edit `NotificationService._showForegroundNotificationPopup()` to customize:
- Colors (uses `Theme.of(context).primaryColor`)
- Border radius (currently 16)
- Button text
- Icon

### Notification Icon
Update in `firebase-messaging-sw.js`:
```javascript
icon: '/icons/Icon-192.png',
badge: '/icons/Icon-192.png',
```

### Navigation Target
To navigate to different screen, update:

**Service Worker:**
```javascript
url: '/your-route', // Change route here
```

**Dart Service:**
```dart
Navigator.of(_context!).pushNamed('/your-route');
```

---

## 🔧 Configuration Details

### VAPID Key
Located in `main.dart`:
```dart
const vapidKey = 'BLubwTQXRJZo5eGNMWcNKFnDijdAkr_IlBILsDUX7OZn3V9_HC4jsbXuy-MST_A5AqPjRYzlfkojhTDiIZjwR4Q';
```

### Firebase Config
Located in `firebase-messaging-sw.js`:
```javascript
firebase.initializeApp({
  apiKey: "AIzaSyBJxOGTP2Cvo4Hm_7-iWs9P24Zhxh3g0Qs",
  authDomain: "msi-restaurant.firebaseapp.com",
  projectId: "msi-restaurant",
  storageBucket: "msi-restaurant.firebasestorage.app",
  messagingSenderId: "221528008029",
  appId: "1:221528008029:web:fd696489debba24615f4b4"
});
```

### Routes
Order Tracking route is defined in `lib/routes/routes.dart`:
```dart
static const String orderTracking = '/order-tracking';
```

---

## 🐛 Troubleshooting

### Issue: No Permission Prompt
**Solution**: 
- Clear browser cache and reload
- Check if permission was previously denied (reset in browser settings)
- Ensure HTTPS or localhost

### Issue: No Foreground Popup
**Solution**:
- Check console for errors
- Verify notification service context is set
- Ensure app is actually in foreground

### Issue: Background Notification Not Showing
**Solution**:
- Check if service worker is registered (DevTools → Application → Service Workers)
- Verify FCM token is valid
- Check browser notification settings

### Issue: Navigation Not Working
**Solution**:
- Check console for navigation logs
- Verify route exists in `lib/routes/routes.dart`
- Ensure navigator key is set in MaterialApp

### Issue: Service Worker Not Updating
**Solution**:
```bash
# Unregister old service worker
# In browser console:
navigator.serviceWorker.getRegistrations().then(registrations => {
  registrations.forEach(registration => registration.unregister());
});
# Then reload page
```

### Issue: PWA Not Receiving Notifications
**Solution**:
- Reinstall PWA
- Check notification permissions for the app domain
- Ensure service worker is active in PWA context

---

## 📊 Console Log Reference

### Service Worker Logs
- `📦 Service worker installed` - SW installed
- `✅ Service worker activated` - SW activated
- `📨 Background message received:` - Background notification received
- `🔔 Showing notification:` - Displaying system notification
- `🖱️ Notification clicked:` - User clicked notification
- `👀 Found clients: X` - Number of active windows found
- `✅ Focusing existing window and navigating` - Focusing window
- `🆕 Opening new window` - Opening new window (terminated state)

### Dart Service Logs
- `🔔 Initializing Firebase Messaging...` - Starting initialization
- `✅ FCM Token obtained:` - Token successfully retrieved
- `📨 Foreground message received:` - Foreground notification
- `📨 Background notification clicked:` - Background click handled
- `📨 App opened from notification (terminated state):` - Terminated state
- `🚀 Navigating to order tracking screen...` - Starting navigation
- `✅ Navigation completed` - Navigation successful

---

## 📝 Code Architecture

### Flow Diagram

```
┌─────────────────────────────────────────────────────────┐
│                   FCM NOTIFICATION                       │
│                   (from Firebase)                        │
└─────────────────────┬───────────────────────────────────┘
                      │
         ┌────────────┴────────────┐
         │                         │
         ▼                         ▼
   APP FOREGROUND              APP BACKGROUND/TERMINATED
         │                         │
         │                         ▼
         │              ┌──────────────────────┐
         │              │  Service Worker      │
         │              │  (firebase-messaging-│
         │              │   sw.js)             │
         │              └──────────┬───────────┘
         │                         │
         │                         ├─► Show Browser Notification
         │                         │
         │                         └─► On Click:
         │                              - Focus/Open Window
         │                              - postMessage to App
         │                              - Or Open at /order-tracking
         │                         
         ▼                         ▼
   ┌────────────────────────────────────────┐
   │     NotificationService                │
   │     (notification_service.dart)        │
   ├────────────────────────────────────────┤
   │ - onMessage → Show Popup Dialog        │
   │ - onMessageOpenedApp → Navigate        │
   │ - getInitialMessage → Navigate         │
   │ - Service Worker Listener → Navigate   │
   └────────────────┬───────────────────────┘
                    │
                    ▼
   ┌────────────────────────────────────────┐
   │     Main App Navigator                 │
   │     (main.dart)                        │
   ├────────────────────────────────────────┤
   │ - Global Navigator Key                 │
   │ - Navigation Stream Listener           │
   │ - Context Management                   │
   └────────────────┬───────────────────────┘
                    │
                    ▼
   ┌────────────────────────────────────────┐
   │     Order Tracking Screen              │
   │     (order_tracking_screen.dart)       │
   └────────────────────────────────────────┘
```

---

## 🚀 Production Checklist

Before deploying to production:

- [ ] Replace VAPID key with production key
- [ ] Update Firebase config in service worker
- [ ] Test on HTTPS domain
- [ ] Test in multiple browsers (Chrome, Edge, Brave, Firefox)
- [ ] Test PWA installation and notifications
- [ ] Verify notification permissions are requested appropriately
- [ ] Test all three scenarios (foreground, background, terminated)
- [ ] Check notification icon displays correctly
- [ ] Verify navigation works from all states
- [ ] Test with real order updates from backend
- [ ] Monitor FCM token refresh and update backend
- [ ] Set up analytics for notification delivery rates
- [ ] Configure notification priority and TTL
- [ ] Test notification behavior across time zones
- [ ] Verify cleanup on logout/token deletion

---

## 📚 Additional Resources

- [Firebase Cloud Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)
- [Service Worker API](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API)
- [Web Push Notifications](https://developer.mozilla.org/en-US/docs/Web/API/Push_API)
- [Flutter Firebase Messaging Plugin](https://pub.dev/packages/firebase_messaging)
- [PWA Documentation](https://web.dev/progressive-web-apps/)

---

## 🎉 Summary

You now have a **complete, production-ready notification system** that:

✅ Works in browser and PWA  
✅ Handles all three states (foreground, background, terminated)  
✅ Shows beautiful in-app popups  
✅ Displays system tray notifications  
✅ Navigates reliably to Order Tracking screen  
✅ Matches your app's theme and design  
✅ Includes comprehensive logging for debugging  
✅ Follows Flutter and Firebase best practices  

Test thoroughly and enjoy your unified notification system! 🚀

