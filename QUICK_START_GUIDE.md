# 🚀 Quick Start Guide - Firebase Messaging Integration

## ⚡ Immediate Next Steps

### 1. Get Your VAPID Key (5 minutes)

1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select project: **msi-restaurant**
3. Go to **Project Settings** (gear icon) > **Cloud Messaging** tab
4. Scroll to **Web Push certificates**
5. Click **Generate key pair** (if not already generated)
6. Copy the key

### 2. Update the Code (2 minutes)

Open `lib/main.dart` and find line ~70:

```dart
const vapidKey = 'YOUR_VAPID_KEY_HERE'; // Replace this
```

Replace with your actual VAPID key:

```dart
const vapidKey = 'BBXyZ...your_actual_vapid_key_here'; 
```

### 3. Run the App (1 minute)

```bash
flutter run -d chrome --web-port=8080
```

### 4. Test Order Tracking (2 minutes)

Add a button to your home screen to navigate to order tracking:

```dart
// In any screen, add this button:
ElevatedButton(
  onPressed: () {
    Navigator.pushNamed(context, AppRoutes.orderTracking);
  },
  child: const Text('View My Orders'),
)
```

Or navigate programmatically:
```dart
Navigator.pushNamed(context, AppRoutes.orderTracking);
```

### 5. Check Console Output

You should see:
```
🔔 Initializing Firebase Messaging...
📱 Requesting notification permission...
🔔 Permission status: AuthorizationStatus.authorized
✅ FCM Token obtained: eFfK...
✅ Firebase Messaging initialized successfully
🔔 FCM Token: eFfK...
```

## 🎯 What You Can Test Right Now

### ✅ Working Features (with Mock Data)

1. **Order Tracking Screen**
   - Shows 3 mock orders
   - Different statuses (preparing, confirmed, delivered)
   - Colored status badges
   - Last update time

2. **Auto-Refresh**
   - Polls every 30 seconds
   - Refreshes when you switch back to tab
   - Pull-to-refresh gesture

3. **Order Details**
   - Click any order to see full details
   - Draggable bottom sheet
   - All order information

4. **Notifications**
   - Browser permission request
   - FCM token generation
   - Token refresh handling
   - Console logs for debugging

## 📋 Current Mock Data

The app shows these test orders:

```
Order 1: ORD-2025-001
- Status: Preparing
- Items: Margherita Pizza, Caesar Salad, Coca Cola
- Total: $45.50
- Table: T12

Order 2: ORD-2025-002
- Status: Confirmed
- Items: Burger Combo, Fries, Milkshake
- Total: $32.00
- Table: T12

Order 3: ORD-2025-003
- Status: Delivered
- Items: Pasta Carbonara, Garlic Bread
- Total: $28.75
- Table: T12
```

## 🔧 Switching to Real Backend

When your backend is ready:

### Step 1: Update API Base URL

`lib/services/order_tracking_api_service.dart` (line ~16):

```dart
static const String _baseUrl = 'https://api.yourrestaurant.com';
```

### Step 2: Disable Mock Mode

Same file (line ~17):

```dart
static const bool _useMockData = false; // Changed from true
```

### Step 3: Send Backend Developer This Document

Share `FIREBASE_MESSAGING_IMPLEMENTATION.md` with your backend developer. It includes:
- Required API endpoints
- Request/response formats
- Firebase Admin SDK examples
- How to send notifications

## 🎨 Adding Order Tracking Button to Your UI

### Option 1: In AppBar

```dart
AppBar(
  title: const Text('Menu'),
  actions: [
    IconButton(
      icon: const Icon(Icons.receipt_long),
      onPressed: () {
        Navigator.pushNamed(context, AppRoutes.orderTracking);
      },
      tooltip: 'My Orders',
    ),
  ],
)
```

### Option 2: As Floating Action Button

```dart
Scaffold(
  // ... your content
  floatingActionButton: FloatingActionButton.extended(
    onPressed: () {
      Navigator.pushNamed(context, AppRoutes.orderTracking);
    },
    icon: const Icon(Icons.receipt_long),
    label: const Text('My Orders'),
  ),
)
```

### Option 3: In Navigation Drawer

```dart
Drawer(
  child: ListView(
    children: [
      // ... other items
      ListTile(
        leading: const Icon(Icons.receipt_long),
        title: const Text('My Orders'),
        onTap: () {
          Navigator.pop(context); // Close drawer
          Navigator.pushNamed(context, AppRoutes.orderTracking);
        },
      ),
    ],
  ),
)
```

### Option 4: As Card/Button on Home Screen

```dart
Card(
  child: ListTile(
    leading: const Icon(Icons.receipt_long, size: 40),
    title: const Text('Track My Orders'),
    subtitle: const Text('View order status in real-time'),
    trailing: const Icon(Icons.arrow_forward),
    onTap: () {
      Navigator.pushNamed(context, AppRoutes.orderTracking);
    },
  ),
)
```

## 🧪 Testing Checklist

Run through this quickly:

- [ ] App starts without errors
- [ ] FCM token appears in console
- [ ] Browser asks for notification permission
- [ ] Order tracking screen loads
- [ ] Shows 3 mock orders
- [ ] Can pull to refresh
- [ ] Clicking order shows details
- [ ] Status badges show colors
- [ ] "Last updated" shows time

## 📱 Browser Permissions

If notifications don't work:

### Chrome
1. Click padlock icon in address bar
2. Check "Notifications" is set to "Allow"

### Firefox
1. Click shield icon in address bar
2. Allow notifications when prompted

### Safari
1. Safari > Preferences > Websites > Notifications
2. Allow for your localhost/domain

## 🐛 Quick Troubleshooting

### "No FCM token" in console
**Fix**: Update VAPID key in main.dart

### "Notification permission denied"
**Fix**: 
1. Open browser settings
2. Reset site permissions
3. Refresh page
4. Allow when prompted

### "Orders not loading"
**Fix**: Check `_useMockData = true` in order_tracking_api_service.dart

### Service worker error
**Fix**: 
1. Open DevTools (F12)
2. Application tab > Service Workers
3. Click "Unregister" 
4. Refresh page

## 💡 Tips

1. **Keep Console Open** - All debug info prints there
2. **Test Visibility** - Switch tabs to test auto-refresh
3. **Check Network Tab** - Even mock calls show timing
4. **Use Debug Mode** - All logs are visible

## 📞 Need Help?

1. Check `FIREBASE_MESSAGING_IMPLEMENTATION.md` for detailed docs
2. Look at console errors
3. Verify all TODO items are complete
4. Test with Chrome first (best FCM support)

## 🎉 You're Done!

After updating the VAPID key and running the app, everything should work!

**Time to completion**: ~10 minutes  
**Mock data ready**: Yes ✅  
**Backend integration ready**: Yes ✅  
**Production ready**: After backend connection ✅

---

Need to test sending actual notifications? Share the **FCM token** from console with your backend developer!

