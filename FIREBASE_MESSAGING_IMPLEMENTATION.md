# Firebase Cloud Messaging (FCM) Implementation Guide

## 🎯 Overview

This document describes the complete Firebase Cloud Messaging implementation for the Flutter Web Digital Menu Order app. The implementation follows the MVC pattern and includes real-time order tracking with push notifications.

## 📁 Project Structure

```
lib/
├── models/
│   └── order_tracking_model.dart          # Order model with status enum
├── services/
│   ├── notification_service.dart          # FCM token & message handling
│   └── order_tracking_api_service.dart    # API service with mock data
├── controllers/
│   └── order_tracking_controller.dart     # Business logic & state management
├── views/
│   └── order_tracking/
│       └── order_tracking_screen.dart     # UI for order tracking
└── main.dart                              # Firebase initialization

web/
└── firebase-messaging-sw.js               # Service worker for background notifications
```

## 🚀 Features Implemented

### ✅ Core Features
- Firebase Messaging initialization (web-compatible)
- FCM token generation and management
- Token refresh handling
- Notification permission requests
- Foreground message handling
- Background message handling (service worker)
- Token lifecycle management (login/logout)

### ✅ Order Tracking Features
- Real-time order status updates
- Periodic polling (every 30 seconds)
- Tab visibility detection (auto-refresh when tab becomes visible)
- Mock API service with simulated network delays
- Order status change detection with snackbar notifications
- Pull-to-refresh support
- Order details modal
- Active vs. past orders separation

### ✅ UI Features
- Material Design 3 components
- Responsive design (mobile & tablet)
- Loading, error, and empty states
- Status badges with color coding
- Last refresh time indicator
- Order details bottom sheet

## 🔧 Setup Instructions

### 1. Get Your VAPID Key

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `msi-restaurant`
3. Go to **Project Settings** > **Cloud Messaging**
4. Under **Web Push certificates**, click **Generate key pair**
5. Copy the key

### 2. Update VAPID Key

Open `lib/main.dart` and replace the placeholder:

```dart
// Line ~70
const vapidKey = 'YOUR_VAPID_KEY_HERE'; // Replace with your actual key
```

### 3. Configure API Service

When your backend is ready:

1. Open `lib/services/order_tracking_api_service.dart`
2. Update the base URL:
   ```dart
   static const String _baseUrl = 'https://api.yourrestaurant.com';
   ```
3. Set mock mode to false:
   ```dart
   static const bool _useMockData = false;
   ```

### 4. Test the Implementation

#### Run the app:
```bash
flutter run -d chrome --web-port=8080
```

#### Access the order tracking screen:
```dart
Navigator.pushNamed(context, AppRoutes.orderTracking);
```

## 📱 How It Works

### Firebase Messaging Flow

```
App Start
   ↓
Initialize Firebase
   ↓
Request Notification Permission
   ↓
Get FCM Token
   ↓
Save Token to Backend (mock)
   ↓
Listen for Messages
   ↓
Handle Foreground/Background Messages
```

### Order Tracking Flow

```
User Opens Order Tracking Screen
   ↓
Initialize OrderTrackingController
   ↓
Fetch Current Orders (mock API)
   ↓
Start Periodic Polling (30s)
   ↓
Listen for FCM Notifications
   ↓
Check for Status Changes
   ↓
Show Snackbar if Status Changed
   ↓
Auto-refresh when Tab Becomes Visible
```

## 🔔 Notification Types

### Foreground Notifications
When the app is open and in focus, notifications are handled by `NotificationService` and trigger:
- Order refresh
- Snackbar notification
- Status badge update

### Background Notifications
When the app is not in focus, notifications are handled by the service worker (`firebase-messaging-sw.js`) and show:
- Native browser notification
- Action buttons (View Order, Close)
- Clicking opens the app to `/order-tracking`

## 📊 Mock Data

The app currently uses mock data with these features:

### Mock Orders
- 3 sample orders with different statuses
- Realistic delays (800ms - 1200ms)
- Proper JSON structure matching backend expectations

### Mock API Endpoints
- `saveDeviceToken()` - Simulates saving FCM token
- `removeDeviceToken()` - Simulates removing token
- `fetchCurrentOrders()` - Returns mock orders
- `fetchOrderById()` - Returns single mock order

## 🎨 UI Components

### Order Card
Shows:
- Order ID
- Status badge (color-coded)
- Item list (first 3 items + count)
- Last update time
- Total amount

### Status Colors
- **Pending**: Orange (#FF9800)
- **Confirmed**: Blue (#2196F3)
- **Preparing**: Purple (#9C27B0)
- **Ready**: Green (#4CAF50)
- **Delivered**: Green (#4CAF50)
- **Cancelled**: Red (#F44336)

### Order Details Modal
- Draggable bottom sheet
- Complete order information
- All items listed
- Order timeline info

## 🔐 Token Management

### On Login (when implemented)
```dart
final notificationService = NotificationService();
final token = await notificationService.currentToken;

if (token != null) {
  await OrderTrackingApiService().saveDeviceToken(
    userId,
    token,
    deviceInfo: {
      'platform': 'web',
      'browser': 'Chrome', // Add actual browser detection
      'timestamp': DateTime.now().toIso8601String(),
    },
  );
}
```

### On Logout (when implemented)
```dart
final notificationService = NotificationService();
await notificationService.deleteToken();

await OrderTrackingApiService().removeDeviceToken(userId, token);

// Clear orders
final controller = context.read<OrderTrackingController>();
controller.clearOrders();
```

## 🌐 Backend API Requirements

When your backend developer is ready, they need to implement:

### 1. Save FCM Token
```http
POST /api/v1/customers/fcm-tokens
Content-Type: application/json

{
  "userId": "customer_12345",
  "token": "fcm_token_here...",
  "deviceInfo": {
    "platform": "web",
    "browser": "Chrome"
  },
  "timestamp": "2025-10-11T10:00:00Z"
}
```

### 2. Remove FCM Token
```http
DELETE /api/v1/customers/fcm-tokens
Content-Type: application/json

{
  "userId": "customer_12345",
  "token": "fcm_token_here..."
}
```

### 3. Fetch Current Orders
```http
GET /api/v1/customers/{userId}/orders?activeOnly=true&limit=20

Response:
{
  "orders": [
    {
      "orderId": "ORD-2025-001",
      "status": "preparing",
      "items": ["Item 1", "Item 2"],
      "updatedAt": "2025-10-11T10:00:00Z",
      "createdAt": "2025-10-11T09:45:00Z",
      "totalAmount": 45.50,
      "tableNumber": "T12",
      "customerName": "John Doe"
    }
  ]
}
```

### 4. Send Push Notification (Backend Side)
```javascript
// Using Firebase Admin SDK (Node.js example)
const admin = require('firebase-admin');

await admin.messaging().send({
  token: customerFcmToken,
  notification: {
    title: 'Order Update',
    body: 'Your order is now ready for pickup!'
  },
  data: {
    orderId: 'ORD-2025-001',
    status: 'ready',
    type: 'order_update'
  },
  webpush: {
    fcmOptions: {
      link: 'https://yourdomain.com/order-tracking'
    }
  }
});
```

## 🧪 Testing Checklist

### Functionality Tests
- [ ] FCM token generated on app start
- [ ] Token printed to console
- [ ] Notification permission requested
- [ ] Orders load on screen open
- [ ] Periodic polling works (check console every 30s)
- [ ] Manual refresh works
- [ ] Tab visibility refresh works
- [ ] Status changes show snackbar
- [ ] Order details modal opens
- [ ] Pull-to-refresh works

### UI Tests
- [ ] Responsive on mobile width
- [ ] Responsive on tablet width
- [ ] Status badges show correct colors
- [ ] Loading state displays
- [ ] Error state displays
- [ ] Empty state displays
- [ ] Last refresh time updates

### Browser Tests
- [ ] Chrome
- [ ] Firefox
- [ ] Safari
- [ ] Edge

## 🐛 Troubleshooting

### Token Not Generated
**Problem**: No FCM token in console  
**Solution**: Check VAPID key is correct and permission granted

### Notifications Not Showing
**Problem**: Background notifications don't appear  
**Solution**: 
1. Check service worker is registered
2. Open DevTools > Application > Service Workers
3. Verify `firebase-messaging-sw.js` is active

### Polling Not Working
**Problem**: Orders don't auto-refresh  
**Solution**: Check browser console for errors and verify controller is initialized

### Mock Data Not Loading
**Problem**: Empty screen or loading forever  
**Solution**: 
1. Check `_useMockData = true` in API service
2. Verify no network errors in console

## 📝 Next Steps

1. **Get VAPID Key** from Firebase Console
2. **Update VAPID key** in `main.dart`
3. **Test locally** with `flutter run -d chrome`
4. **Add navigation** to order tracking from your home screen:
   ```dart
   Navigator.pushNamed(context, AppRoutes.orderTracking);
   ```
5. **Coordinate with backend** developer using this guide
6. **Update API service** when backend is ready
7. **Implement authentication** and replace mock user ID

## 🔗 Useful Resources

- [Firebase Console](https://console.firebase.google.com/)
- [FCM Documentation](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Firebase Messaging](https://pub.dev/packages/firebase_messaging)
- [Web Push Protocol](https://web.dev/push-notifications-overview/)

## 📞 Support

If you encounter any issues:
1. Check browser console for errors
2. Verify Firebase configuration
3. Test with mock data first
4. Review this guide's troubleshooting section

---

**Implementation completed**: October 11, 2025  
**Flutter version**: 3.8.1  
**Firebase Core**: 4.1.1  
**Firebase Messaging**: 16.0.2  
**Target platform**: Web (primary), with mobile support

✅ **Ready for production** after backend integration!

