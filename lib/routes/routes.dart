import 'package:flutter/material.dart';
import '../views/home/home_screen.dart';
import '../views/cart/cart_screen.dart';
import '../views/table/table_screen.dart';
import '../views/order/order_screen.dart';
import '../views/order_tracking/order_tracking_screen.dart';

/// Central route configuration for the app
class AppRoutes {
  static const String home = '/';
  static const String cart = '/cart';
  static const String table = '/table';
  static const String order = '/order';
  static const String orderTracking = '/order-tracking';
  static const String itemDetail = '/item-detail';
  
  /// Generate routes based on route settings
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
          settings: settings,
        );
      case cart:
        return MaterialPageRoute(
          builder: (context) => const CartScreen(),
          settings: settings,
        );
      case table:
        return MaterialPageRoute(
          builder: (context) => const TableScreen(),
          settings: settings,
        );
      case order:
        return MaterialPageRoute(
          builder: (context) => const OrderScreen(),
          settings: settings,
        );
      case orderTracking:
        return MaterialPageRoute(
          builder: (context) => const OrderTrackingScreen(),
          settings: settings,
        );
      case itemDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => ItemDetailScreen(
            itemId: args?['itemId'] ?? '',
          ),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (context) => const NotFoundScreen(),
          settings: settings,
        );
    }
  }
}


/// Placeholder item detail screen
class ItemDetailScreen extends StatelessWidget {
  final String itemId;
  
  const ItemDetailScreen({
    super.key,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
      ),
      body: Center(
        child: Text('Item details for: $itemId'),
      ),
    );
  }
}

/// 404 screen for unknown routes
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: const Center(
        child: Text('The requested page was not found.'),
      ),
    );
  }
}
