// Order Tracking Button Widget
// Reusable button component for navigating to order tracking screen
// Can be used in AppBar, FAB, or anywhere in the app

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/order_tracking_controller.dart';
import '../routes/routes.dart';
import '../theme/theme.dart';

/// Icon button for order tracking (use in AppBar)
class OrderTrackingIconButton extends StatelessWidget {
  const OrderTrackingIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderTrackingController>(
      builder: (context, controller, child) {
        final hasActiveOrders = controller.hasActiveOrders;
        
        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.receipt_long),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.orderTracking);
              },
              tooltip: 'My Orders',
            ),
            // Show badge if there are active orders
            if (hasActiveOrders)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Card button for order tracking (use on home screen)
class OrderTrackingCard extends StatelessWidget {
  const OrderTrackingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderTrackingController>(
      builder: (context, controller, child) {
        final activeOrdersCount = controller.activeOrders.length;
        
        return Card(
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.orderTracking);
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(Responsive.padding(context, 16)),
              child: Row(
                children: [
                  // Icon
                  Container(
                    padding: EdgeInsets.all(Responsive.padding(context, 12)),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.receipt_long,
                      size: Responsive.fontSize(context, 32),
                      color: AppColors.primary,
                    ),
                  ),
                  
                  SizedBox(width: Responsive.padding(context, 16)),
                  
                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Orders',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontSize: Responsive.fontSize(context, 16),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        SizedBox(height: Responsive.padding(context, 4)),
                        Text(
                          activeOrdersCount > 0
                              ? '$activeOrdersCount active ${activeOrdersCount == 1 ? "order" : "orders"}'
                              : 'View your order history',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: Responsive.fontSize(context, 12),
                                color: activeOrdersCount > 0
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Arrow
                  Icon(
                    Icons.arrow_forward_ios,
                    size: Responsive.fontSize(context, 16),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Floating Action Button for order tracking
class OrderTrackingFAB extends StatelessWidget {
  const OrderTrackingFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderTrackingController>(
      builder: (context, controller, child) {
        final activeOrdersCount = controller.activeOrders.length;
        
        return FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.orderTracking);
          },
          icon: Stack(
            children: [
              const Icon(Icons.receipt_long),
              if (activeOrdersCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        activeOrdersCount > 9 ? '9+' : '$activeOrdersCount',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          label: const Text('My Orders'),
        );
      },
    );
  }
}

/// List tile for order tracking (use in drawer)
class OrderTrackingListTile extends StatelessWidget {
  final VoidCallback? onTap;
  
  const OrderTrackingListTile({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderTrackingController>(
      builder: (context, controller, child) {
        final activeOrdersCount = controller.activeOrders.length;
        
        return ListTile(
          leading: Stack(
            children: [
              const Icon(Icons.receipt_long),
              if (activeOrdersCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          title: const Text('My Orders'),
          subtitle: activeOrdersCount > 0
              ? Text('$activeOrdersCount active')
              : null,
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            onTap?.call();
            Navigator.pushNamed(context, AppRoutes.orderTracking);
          },
        );
      },
    );
  }
}

/// Badge widget showing active order count
class OrderTrackingBadge extends StatelessWidget {
  final Widget child;
  
  const OrderTrackingBadge({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderTrackingController>(
      builder: (context, controller, child) {
        final activeOrdersCount = controller.activeOrders.length;
        
        return Badge(
          isLabelVisible: activeOrdersCount > 0,
          label: Text(
            activeOrdersCount > 9 ? '9+' : '$activeOrdersCount',
          ),
          backgroundColor: AppColors.error,
          child: this.child,
        );
      },
    );
  }
}

