# Integration Examples - Order Tracking UI

This document shows you exactly how to add order tracking buttons to your existing screens.

## 📱 Copy-Paste Examples

### 1. Add to AppBar (Recommended)

Open any screen with an AppBar and add the order tracking button:

```dart
import '../widgets/order_tracking_button.dart'; // Add this import

class YourScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        actions: [
          // Add this line ↓
          const OrderTrackingIconButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: YourContent(),
    );
  }
}
```

**What it looks like**: Small icon with red dot badge if there are active orders

---

### 2. Add as Card on Home Screen

Add this to your home screen layout:

```dart
import '../widgets/order_tracking_button.dart'; // Add this import

// Inside your home screen body:
Column(
  children: [
    // Your existing widgets
    
    // Add this ↓
    Padding(
      padding: const EdgeInsets.all(16),
      child: const OrderTrackingCard(),
    ),
    
    // Rest of your widgets
  ],
)
```

**What it looks like**: Full-width card with icon, text, and arrow

---

### 3. Add as Floating Action Button

Add to your Scaffold:

```dart
import '../widgets/order_tracking_button.dart'; // Add this import

Scaffold(
  appBar: AppBar(title: const Text('Menu')),
  body: YourContent(),
  
  // Add this ↓
  floatingActionButton: const OrderTrackingFAB(),
)
```

**What it looks like**: Floating button with badge showing active order count

---

### 4. Add to Navigation Drawer

```dart
import '../widgets/order_tracking_button.dart'; // Add this import

Drawer(
  child: ListView(
    padding: EdgeInsets.zero,
    children: [
      const DrawerHeader(
        decoration: BoxDecoration(color: AppColors.primary),
        child: Text('Menu'),
      ),
      
      // Your existing drawer items
      
      // Add this ↓
      const OrderTrackingListTile(),
      
      // More drawer items
    ],
  ),
)
```

**What it looks like**: List tile with icon and active order count

---

### 5. Custom Button Anywhere

Want a custom button? Use this minimal example:

```dart
import '../routes/routes.dart'; // Add this import

ElevatedButton(
  onPressed: () {
    Navigator.pushNamed(context, AppRoutes.orderTracking);
  },
  child: const Text('View My Orders'),
)
```

---

### 6. With Badge (Show Active Count)

Wrap any widget with a badge:

```dart
import '../widgets/order_tracking_button.dart'; // Add this import

OrderTrackingBadge(
  child: IconButton(
    icon: const Icon(Icons.receipt_long),
    onPressed: () {
      Navigator.pushNamed(context, AppRoutes.orderTracking);
    },
  ),
)
```

---

## 🎨 Full Screen Examples

### Example 1: Home Screen with Order Tracking Card

```dart
import 'package:flutter/material.dart';
import '../widgets/order_tracking_button.dart';
import '../theme/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Menu'),
        actions: [
          const OrderTrackingIconButton(), // Badge shows if orders exist
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.padding(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Order tracking card at top
            const OrderTrackingCard(),
            
            SizedBox(height: Responsive.padding(context, 16)),
            
            // Your menu categories
            Text(
              'Categories',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            
            // ... rest of your home screen content
          ],
        ),
      ),
    );
  }
}
```

---

### Example 2: Menu Screen with FAB

```dart
import 'package:flutter/material.dart';
import '../widgets/order_tracking_button.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
      ),
      body: ListView(
        // Your menu items
      ),
      floatingActionButton: const OrderTrackingFAB(), // Shows active order count
    );
  }
}
```

---

### Example 3: App Drawer with Order Tracking

```dart
import 'package:flutter/material.dart';
import '../widgets/order_tracking_button.dart';
import '../theme/theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  child: Icon(Icons.person, size: 30),
                ),
                SizedBox(height: 8),
                Text(
                  'Welcome!',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Order tracking (with badge)
          const OrderTrackingListTile(),
          const Divider(),
          
          // Other menu items
          ListTile(
            leading: const Icon(Icons.restaurant_menu),
            title: const Text('Menu'),
            onTap: () => Navigator.pop(context),
          ),
          
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Cart'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to cart
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
```

---

## 🔧 Customization Options

### Change Icon

```dart
// Instead of OrderTrackingIconButton, use:
IconButton(
  icon: const Icon(Icons.notifications), // Different icon
  onPressed: () {
    Navigator.pushNamed(context, AppRoutes.orderTracking);
  },
)
```

### Change Colors

```dart
// Customize the card:
Card(
  color: AppColors.primary, // Custom background
  child: InkWell(
    onTap: () => Navigator.pushNamed(context, AppRoutes.orderTracking),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.receipt_long, color: AppColors.white), // White icon
          const SizedBox(width: 16),
          Text(
            'Track Orders',
            style: TextStyle(color: AppColors.white), // White text
          ),
        ],
      ),
    ),
  ),
)
```

### Add Animation

```dart
// Animated badge:
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0.0, end: 1.0),
  duration: const Duration(milliseconds: 500),
  builder: (context, value, child) {
    return Transform.scale(
      scale: value,
      child: const OrderTrackingIconButton(),
    );
  },
)
```

---

## 📍 Where to Add Each Widget

| Widget | Best Location | Use Case |
|--------|---------------|----------|
| `OrderTrackingIconButton` | AppBar actions | Always visible, minimal space |
| `OrderTrackingCard` | Home screen body | Prominent call-to-action |
| `OrderTrackingFAB` | Floating button | Menu/category screens |
| `OrderTrackingListTile` | Navigation drawer | Part of main navigation |
| `OrderTrackingBadge` | Wrap any widget | Show count on custom UI |

---

## 🎯 Quick Integration Steps

1. **Choose a widget** from examples above
2. **Add import**: `import '../widgets/order_tracking_button.dart';`
3. **Copy the code** into your screen
4. **Run the app** - it should work immediately!

---

## 💡 Tips

- **Badge auto-updates**: The red dot/count appears automatically when there are active orders
- **No state management needed**: Widgets use Provider internally
- **Responsive**: All widgets adapt to screen size
- **RTL support**: Works with Arabic/RTL languages

---

## 🧪 Quick Test

After adding a button:

1. Run the app
2. Click your new button
3. Should navigate to Order Tracking screen
4. See 3 mock orders (Preparing, Confirmed, Delivered)

✅ If you see the orders, integration successful!

---

## 📞 Common Questions

**Q: Badge not showing?**  
A: Badge only appears when there are active orders. Mock data has 2 active orders.

**Q: Navigation not working?**  
A: Make sure you imported: `import '../routes/routes.dart';`

**Q: Widget not found?**  
A: Import: `import '../widgets/order_tracking_button.dart';`

**Q: Want to customize?**  
A: Copy the widget code from `order_tracking_button.dart` and modify!

---

**Ready to go!** Pick an example, copy the code, and you're done! 🚀

