import 'package:flutter/material.dart';
import '../models/create_order_response_model.dart';
import '../theme/theme.dart';
import '../routes/routes.dart';

/// Order Success Popup
/// 
/// This popup is displayed after successfully placing an order.
/// It shows:
/// - Success icon and message
/// - Order ID and Order Number
/// - Button to view order details
class OrderSuccessPopup extends StatelessWidget {
  final CreateOrderResponseModel orderResponse;
  
  const OrderSuccessPopup({
    super.key,
    required this.orderResponse,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: Responsive.maxContentWidth(context),
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, theme),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(Responsive.padding(context, 24)),
                child: _buildContent(context, theme),
              ),
            ),
            _buildActionButton(context, theme),
          ],
        ),
      ),
    );
  }

  /// Build popup header with success icon
  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(Responsive.padding(context, 24)),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          // Success icon
          Container(
            width: Responsive.padding(context, 80),
            height: Responsive.padding(context, 80),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: Responsive.fontSize(context, 48),
              color: AppColors.success,
            ),
          ),
          SizedBox(height: Responsive.padding(context, 16)),
          // Success message
          Text(
            'Order placed successfully!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: Responsive.fontSize(context, 22),
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build content with order details
  Widget _buildContent(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Message
        Text(
          orderResponse.message,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: Responsive.fontSize(context, 16),
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: Responsive.padding(context, 24)),
        
        // Order details
        // _buildOrderDetailRow(
        //   context,
        //   theme,
        //   'Order ID',
        //   '${orderResponse.orderId ?? 'N/A'}',
        // ),
        SizedBox(height: Responsive.padding(context, 12)),
        _buildOrderDetailRow(
          context,
          theme,
          'Online Order ID',
          '${orderResponse.onlineOrderId ?? 'N/A'}',
        ),
        SizedBox(height: Responsive.padding(context, 12)),
        _buildOrderDetailRow(
          context,
          theme,
          'Pin Number',
          '${orderResponse.orderNo ?? 'N/A'}',
        ),
      ],
    );
  }

  /// Build order detail row
  Widget _buildOrderDetailRow(
    BuildContext context,
    ThemeData theme,
    String label,
    String value,
  ) {
    return Container(
      padding: EdgeInsets.all(Responsive.padding(context, 16)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: Responsive.fontSize(context, 15),
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: Responsive.fontSize(context, 16),
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// Build action button
  Widget _buildActionButton(BuildContext context, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(Responsive.padding(context, 20)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // View Order Details button
          SizedBox(
            width: double.infinity,
            height: Responsive.padding(context, 48),
            child: ElevatedButton(
              onPressed: () {
                // Close popup and navigate to order screen
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed(
                  AppRoutes.order,
                  arguments: orderResponse,
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
                'View Order Details',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 16),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: Responsive.padding(context, 12)),
          // OK button
          SizedBox(
            width: double.infinity,
            height: Responsive.padding(context, 48),
            child: OutlinedButton(
              onPressed: () {
                // Close popup and navigate to home
                Navigator.of(context).pop();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.home,
                  (route) => false,
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                side: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Back to Menu',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 16),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

