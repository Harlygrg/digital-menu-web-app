import 'package:flutter/material.dart';
import '../views/landing/landing_shell_screen.dart';
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
      default:
        return MaterialPageRoute(
          builder: (context) => const NotFoundScreen(),
          settings: settings,
        );
    }
  }
}

/// 404 screen for unknown routes
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: const Center(child: Text('The requested page was not found.')),
    );
  }
}
