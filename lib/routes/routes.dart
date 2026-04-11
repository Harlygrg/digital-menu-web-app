import 'package:flutter/material.dart';
import '../views/landing/landing_shell_screen.dart';
import '../views/cart/cart_screen.dart';
import '../views/table/table_screen.dart';
import '../views/order/order_screen.dart';
import '../views/order_tracking/order_tracking_screen.dart';
import '../views/errors/not_found_screen.dart';
import '../views/errors/item_detail_placeholder_screen.dart';

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
        // LandingShellScreen renders HomeScreen and dispatches
        // the flutter-first-frame event to remove the HTML boot shell.
        return MaterialPageRoute(
          builder: (context) => const LandingShellScreen(),
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
          builder: (context) =>
              ItemDetailPlaceholderScreen(itemId: args?['itemId'] ?? ''),
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
