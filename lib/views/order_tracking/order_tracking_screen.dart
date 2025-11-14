// Order Tracking Screen
// Displays customer's active and past orders with real-time status updates
// Follows MVC architecture and Material Design 3 principles

import 'package:digital_menu_order/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/order_tracking_controller.dart';
import '../../models/user_order_model.dart';
import '../../theme/theme.dart';
import 'order_details_screen.dart';

/// Main screen for tracking customer orders
class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  // Track previously shown order statuses to detect changes (using integer status)
  final Map<String, int> _previousStatuses = {};

  @override
  void initState() {
    super.initState();
    _initializeOrderTracking();
  }

  /// Initialize order tracking
  Future<void> _initializeOrderTracking() async {
    final controller = context.read<OrderTrackingController>();
    await controller.refreshOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar( ),
      body: _buildBody(context),
    );
  }
  /// Build app bar with refresh action
 PreferredSizeWidget _buildAppBar(){
    return AppBar(

      title: Responsive.isDesktop(context)
          ? null // Hide default title for desktop
          : Consumer<HomeProvider>(
            builder: (context,provider,child) {
              return Text(
                      provider.isEnglish ? 'My orders' : 'طلباتي',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
                      ),
                    );
            }
          ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0.0,
      leading: Responsive.isDesktop(context)
          ? null // Hide default leading for desktop
          : IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: Responsive.isDesktop(context)
          ? null // Hide default actions for desktop
          :
         [
          Consumer<OrderTrackingController>(
            builder: (context, controller, child) {
              return IconButton(
                icon: controller.isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.black,
                  ),
                )
                    :  Icon(Icons.refresh,color: AppColors.primary,),
                onPressed: controller.isLoading
                    ? null
                    : () => controller.refreshOrders(),
                tooltip: 'Refresh orders',
              );
            },
          ),
          const SizedBox(width: 8),
        ],
    );
 }


  /// Build main body content
  Widget _buildBody(BuildContext context) {
    return Consumer<OrderTrackingController>(
      builder: (context, controller, child) {
        // Show loading indicator on first load
        if (controller.isLoading && !controller.hasOrders) {
          return _buildLoadingState();
        }

        // Show error state
        if (controller.error != null && !controller.hasOrders) {
          return _buildErrorState(controller);
        }

        // Show empty state
        if (!controller.hasOrders) {
          return _buildEmptyState();
        }

        // Show orders list
        return _buildOrdersList(controller);
      },
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Consumer<HomeProvider>(
            builder: (context, provider, child) {
              return Text(
                provider.isEnglish ? 'Loading your orders...' : 'جاري تحميل طلباتك...',
              );
            },
          ),
        ],
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState(OrderTrackingController controller) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Responsive.padding(context, 24)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: Responsive.fontSize(context, 64),
              color: AppColors.error,
            ),
            SizedBox(height: Responsive.padding(context, 16)),
            Consumer<HomeProvider>(
              builder: (context, provider, child) {
                return Text(
                  provider.isEnglish ? 'Failed to load orders' : 'فشل تحميل الطلبات',
                  style: Theme.of(context).textTheme.titleLarge,
                );
              },
            ),
            SizedBox(height: Responsive.padding(context, 8)),
            Text(
              controller.error ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Responsive.padding(context, 24)),
            Consumer<HomeProvider>(
              builder: (context, provider, child) {
                return ElevatedButton.icon(
                  onPressed: () => controller.retry(),
                  icon: const Icon(Icons.refresh),
                  label: Text(provider.isEnglish ? 'Retry' : 'إعادة المحاولة'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Responsive.padding(context, 24)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: Responsive.fontSize(context, 80),
              color: AppColors.grey400,
            ),
            SizedBox(height: Responsive.padding(context, 16)),
            Consumer<HomeProvider>(
              builder: (context, provider, child) {
                return Text(
                  provider.isEnglish ? 'No Orders Found' : 'لا توجد طلبات',
                  style: Theme.of(context).textTheme.titleLarge,
                );
              },
            ),
            SizedBox(height: Responsive.padding(context, 8)),
            Consumer<HomeProvider>(
              builder: (context, provider, child) {
                return Text(
                  provider.isEnglish 
                      ? 'Your orders will appear here once you place them'
                      : 'ستظهر طلباتك هنا بمجرد تقديمها',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build orders list
  Widget _buildOrdersList(OrderTrackingController controller) {
    return RefreshIndicator(
      onRefresh: () => controller.refreshOrders(),
      child: ListView.builder(
        padding: EdgeInsets.all(Responsive.padding(context, 16)),
        itemCount: controller.userOrders.length,
        itemBuilder: (context, index) {
          final order = controller.userOrders[index];
          _checkAndShowStatusChange(order);
          return _buildOrderCard(order);
        },
      ),
    );
  }

  /// Build individual order card
  Widget _buildOrderCard(UserOrder order) {
    return Card(
      margin: EdgeInsets.only(bottom: Responsive.padding(context, 12)),
      child: InkWell(
        onTap: () => _navigateToOrderDetails(order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(Responsive.padding(context, 16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order ID and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      order.onlineOrderId,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: Responsive.fontSize(context, 16),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  _buildStatusChip(order.orderStatus),
                ],
              ),
              
              SizedBox(height: Responsive.padding(context, 12)),

              // Order details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: Responsive.fontSize(context, 14),
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: Responsive.padding(context, 4)),
                        Expanded(
                          child: Text(
                            _formatOrderDateTime(order.createdAt),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: Responsive.fontSize(context, 12),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: Responsive.padding(context, 8)),
                  Text(
                    order.formattedTotal,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: Responsive.fontSize(context, 16),
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build status chip with color
  /// Status values: 0 = Pending, 1 = Accepted, 2 = Cancelled, 3 = Completed
  Widget _buildStatusChip(int orderStatus) {
    Color backgroundColor;
    Color textColor = AppColors.white;

    switch (orderStatus) {
      case 0: // Pending
        backgroundColor = AppColors.warning;
        break;
      case 1: // Accepted
        backgroundColor = AppColors.success;
        break;
      case 2: // Cancelled
        backgroundColor = AppColors.error;
        break;
      case 3: // Completed
        backgroundColor = AppColors.primary;
        break;
      default:
        backgroundColor = AppColors.grey400;
    }

    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        String statusText;
        
        switch (orderStatus) {
          case 0: // Pending
            statusText = provider.isEnglish ? 'Pending' : 'قيد الانتظار';
            break;
          case 1: // Accepted
            statusText = provider.isEnglish ? 'Accepted' : 'مقبول';
            break;
          case 2: // Cancelled
            statusText = provider.isEnglish ? 'Cancelled' : 'ملغى';
            break;
          case 3: // Completed
            statusText = provider.isEnglish ? 'Completed' : 'مكتمل';
            break;
          default:
            statusText = provider.isEnglish ? 'Unknown' : 'غير معروف';
        }

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.padding(context, 12),
            vertical: Responsive.padding(context, 6),
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            statusText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: Responsive.fontSize(context, 12),
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        );
      },
    );
  }

  /// Check for status changes and show snackbar
  void _checkAndShowStatusChange(UserOrder order) {
    if (_previousStatuses.containsKey(order.onlineOrderId)) {
      final previousStatus = _previousStatuses[order.onlineOrderId];
      if (previousStatus != order.orderStatus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showStatusChangeSnackbar(order);
        });
      }
    }
    _previousStatuses[order.onlineOrderId] = order.orderStatus;
  }

  /// Show snackbar for status changes
  void _showStatusChangeSnackbar(UserOrder order) {
    final provider = context.read<HomeProvider>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          provider.isEnglish
              ? 'Order ${order.onlineOrderId} is now ${order.statusDisplayName}'
              : 'الطلب ${order.onlineOrderId} الآن ${order.statusDisplayName}',
        ),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: provider.isEnglish ? 'View' : 'عرض',
          onPressed: () => _navigateToOrderDetails(order),
        ),
      ),
    );
  }

  /// Navigate to order details screen
  void _navigateToOrderDetails(UserOrder order) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderDetailsScreen(order: order),
      ),
    );
  }

  /// Format order date and time with 12-hour format and AM/PM
  String _formatOrderDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
  }
}

