import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/create_order_response_model.dart';
import '../../controllers/cart_controller.dart';
import '../../theme/theme.dart';
import '../../routes/routes.dart';

/// Order Screen
/// 
/// This screen displays the order details after a successful order placement.
/// It shows:
/// - Order confirmation message
/// - Order ID, Online Order ID, and Order Number
/// - Total amount
/// - Ordered items and modifiers
class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  CreateOrderResponseModel? _orderResponse;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Get order response from route arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is CreateOrderResponseModel) {
      _orderResponse = args;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _orderResponse != null
          ? _buildOrderContent(context)
          : _buildErrorState(context),
    );
  }

  /// Build app bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Order Confirmation',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: () {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.home,
            (route) => false,
          );
        },
      ),
    );
  }

  /// Build order content
  Widget _buildOrderContent(BuildContext context) {
    final theme = Theme.of(context);
    final cartController = context.watch<CartController>();
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(Responsive.padding(context, 20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success header
          _buildSuccessHeader(context, theme),
          SizedBox(height: Responsive.padding(context, 24)),
          
          // Order details card
          _buildOrderDetailsCard(context, theme),
          SizedBox(height: Responsive.padding(context, 20)),
          
          // Order items (if cart still has items)
          if (cartController.isNotEmpty) ...[
            _buildOrderItemsSection(context, theme, cartController),
            SizedBox(height: Responsive.padding(context, 20)),
          ],
          
          // Action buttons
          _buildActionButtons(context, theme, cartController),
        ],
      ),
    );
  }

  /// Build success header
  Widget _buildSuccessHeader(BuildContext context, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(Responsive.padding(context, 20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success.withValues(alpha: 0.1),
            AppColors.success.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: Responsive.padding(context, 60),
            height: Responsive.padding(context, 60),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: Responsive.fontSize(context, 32),
              color: AppColors.success,
            ),
          ),
          SizedBox(width: Responsive.padding(context, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Placed Successfully!',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: Responsive.fontSize(context, 18),
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: Responsive.padding(context, 4)),
                Text(
                  _orderResponse?.message ?? 'Your order has been confirmed',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: Responsive.fontSize(context, 14),
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build order details card
  Widget _buildOrderDetailsCard(BuildContext context, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(Responsive.padding(context, 20)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: Responsive.fontSize(context, 16),
            ),
          ),
          SizedBox(height: Responsive.padding(context, 16)),
          
          _buildDetailRow(
            context,
            theme,
            'Order ID',
            '${_orderResponse?.orderId ?? 'N/A'}',
            Icons.receipt_long,
          ),
          SizedBox(height: Responsive.padding(context, 12)),
          
          _buildDetailRow(
            context,
            theme,
            'Online Order ID',
            '${_orderResponse?.onlineOrderId ?? 'N/A'}',
            Icons.cloud_outlined,
          ),
          SizedBox(height: Responsive.padding(context, 12)),
          
          _buildDetailRow(
            context,
            theme,
            'Pin Number',
            '${_orderResponse?.orderNo ?? 'N/A'}',
            Icons.confirmation_number,
          ),
        ],
      ),
    );
  }

  /// Build detail row
  Widget _buildDetailRow(
    BuildContext context,
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(Responsive.padding(context, 8)),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: Responsive.fontSize(context, 20),
            color: theme.colorScheme.primary,
          ),
        ),
        SizedBox(width: Responsive.padding(context, 12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: Responsive.fontSize(context, 12),
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              SizedBox(height: Responsive.padding(context, 2)),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: Responsive.fontSize(context, 16),
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build order items section
  Widget _buildOrderItemsSection(
    BuildContext context,
    ThemeData theme,
    CartController cartController,
  ) {
    return Container(
      padding: EdgeInsets.all(Responsive.padding(context, 20)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Items',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: Responsive.fontSize(context, 16),
                ),
              ),
              Text(
                '${cartController.itemCount} items',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: Responsive.fontSize(context, 14),
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.padding(context, 16)),
          
          // Items list
          ...cartController.cartItems.map((item) => _buildOrderItem(
            context,
            theme,
            item.item.iname,
            item.quantity,
            item.totalPrice,
            item.modifiers.isNotEmpty
                ? item.modifiers.map((m) => m.name).join(', ')
                : null,
          )),
          
          // Divider
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: Responsive.padding(context, 12),
            ),
            child: Divider(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: Responsive.fontSize(context, 16),
                ),
              ),
              Text(
                'QR${cartController.totalPrice.toStringAsFixed(2)}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: Responsive.fontSize(context, 20),
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build individual order item
  Widget _buildOrderItem(
    BuildContext context,
    ThemeData theme,
    String itemName,
    int quantity,
    double price,
    String? modifiers,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.padding(context, 12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quantity badge
          Container(
            width: Responsive.padding(context, 28),
            height: Responsive.padding(context, 28),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '${quantity}x',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: Responsive.fontSize(context, 12),
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          SizedBox(width: Responsive.padding(context, 12)),
          
          // Item details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: Responsive.fontSize(context, 14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (modifiers != null) ...[
                  SizedBox(height: Responsive.padding(context, 4)),
                  Text(
                    modifiers,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: Responsive.fontSize(context, 12),
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Price
          Text(
            'QR${price.toStringAsFixed(2)}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontSize: Responsive.fontSize(context, 14),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build action buttons
  Widget _buildActionButtons(
    BuildContext context,
    ThemeData theme,
    CartController cartController,
  ) {
    return Column(
      children: [
        // Back to menu button
        SizedBox(
          width: double.infinity,
          height: Responsive.padding(context, 52),
          child: ElevatedButton(
            onPressed: () async {
              // Clear cart and go to home
              await cartController.clearCart();
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.home,
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Text(
              'Back to Menu',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 16),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build error state
  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Responsive.padding(context, 32)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: Responsive.fontSize(context, 80),
              color: theme.colorScheme.error,
            ),
            SizedBox(height: Responsive.padding(context, 24)),
            Text(
              'Order Not Found',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: Responsive.padding(context, 8)),
            Text(
              'Unable to load order details.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Responsive.padding(context, 32)),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.home,
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.padding(context, 32),
                  vertical: Responsive.padding(context, 16),
                ),
              ),
              child: const Text('Back to Menu'),
            ),
          ],
        ),
      ),
    );
  }
}

