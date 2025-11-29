// Order Details Screen
// Displays detailed information about a specific order
// Follows MVC architecture and Material Design 3 principles

import 'package:digital_menu_order/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/order_tracking_controller.dart';
import '../../models/user_order_model.dart';
import '../../theme/theme.dart';

/// Screen for displaying detailed order information
class OrderDetailsScreen extends StatefulWidget {
  final UserOrder order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool _isCancelling = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(context),
    );
  }
  /// Build app bar
  PreferredSizeWidget _buildAppBar(){
    return AppBar(

      title: Responsive.isDesktop(context)
          ? null // Hide default title for desktop
          : Consumer<HomeProvider>(
          builder: (context,provider,child) {
            return Text(
              provider.isEnglish ? 'Order details' : 'تفاصيل الطلب',
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
    );
  }



  /// Build main body content
  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(Responsive.padding(context, 16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order header card
          _buildOrderHeaderCard(),
          
          SizedBox(height: Responsive.padding(context, 16)),
          
          // Order details card
          _buildOrderDetailsCard(),
          
          SizedBox(height: Responsive.padding(context, 16)),
          
          // Order items card
          _buildOrderItemsCard(),
          
          SizedBox(height: Responsive.padding(context, 16)),
          
          // Order notes card
          if (widget.order.orderNotes.isNotEmpty && widget.order.orderNotes != 'No notes')
            _buildOrderNotesCard(),
          
          if (widget.order.orderNotes.isNotEmpty && widget.order.orderNotes != 'No notes')
            SizedBox(height: Responsive.padding(context, 16)),
          
          // Action buttons
          if(widget.order.orderStatus == 0)
          _buildActionButtons(),
          
          SizedBox(height: Responsive.padding(context, 24)),
        ],
      ),
    );
  }

  /// Build order header card
  Widget _buildOrderHeaderCard() {
    return Card(
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
                    widget.order.onlineOrderId,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: Responsive.fontSize(context, 20),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                _buildStatusChip(widget.order.orderStatus),
              ],
            ),
            
            SizedBox(height: Responsive.padding(context, 12)),
            
            // Order total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Consumer<HomeProvider>(
                  builder: (context, provider, child) {
                    return Text(
                      provider.isEnglish ? 'Total Amount' : 'المبلغ الإجمالي',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: Responsive.fontSize(context, 16),
                            fontWeight: FontWeight.w600,
                          ),
                    );
                  },
                ),
                Text(
                  widget.order.formattedTotal,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: Responsive.fontSize(context, 20),
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build order details card
  Widget _buildOrderDetailsCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(Responsive.padding(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<HomeProvider>(
              builder: (context, provider, child) {
                return Text(
                  provider.isEnglish ? 'Order Information' : 'معلومات الطلب',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: Responsive.fontSize(context, 18),
                        fontWeight: FontWeight.bold,
                      ),
                );
              },
            ),
            
            SizedBox(height: Responsive.padding(context, 16)),
            
            Consumer<HomeProvider>(
              builder: (context, provider, child) {
                return Column(
                  children: [
                    _buildDetailRow(
                      provider.isEnglish ? 'Pin Number' : 'رقم التعريف',
                      widget.order.orderNo.toString()
                    ),
                    _buildDetailRow(
                      provider.isEnglish ? 'Order Type' : 'نوع الطلب',
                      widget.order.orderType == '1'
                          ? (provider.isEnglish ? "Dine in" : "تناول الطعام")
                          : (provider.isEnglish ? "Take away" : "الوجبات الجاهزة")
                    ),
                    _buildDetailRow(
                      provider.isEnglish ? 'Table' : 'الطاولة',
                      widget.order.tableName.toString()
                    ),
                    _buildDetailRow(
                      provider.isEnglish ? 'Placed' : 'تم الطلب',
                      _formatDateTime(widget.order.createdAt)
                    ),
                  ],
                );
              },
            ),
            
            SizedBox(height: Responsive.padding(context, 16)),
            
            // Price breakdown
            Consumer<HomeProvider>(
              builder: (context, provider, child) {
                return Text(
                  provider.isEnglish ? 'Price Breakdown' : 'تفاصيل السعر',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: Responsive.fontSize(context, 16),
                        fontWeight: FontWeight.w600,
                      ),
                );
              },
            ),
            
            SizedBox(height: Responsive.padding(context, 8)),
            
            Consumer<HomeProvider>(
              builder: (context, provider, child) {
                return Column(
                  children: [
                    _buildPriceRow(
                      provider.isEnglish ? 'Gross Total' : 'الإجمالي الكلي',
                      widget.order.grosstotal
                    ),
                    if (widget.order.discount > 0)
                      _buildPriceRow(
                        provider.isEnglish ? 'Discount' : 'الخصم',
                        -widget.order.discount
                      ),
                    if (widget.order.servicecharge > 0)
                      _buildPriceRow(
                        provider.isEnglish ? 'Service Charge' : 'رسوم الخدمة',
                        widget.order.servicecharge
                      ),
                    if (widget.order.taxamnt > 0)
                      _buildPriceRow(
                        provider.isEnglish ? 'Tax Amount' : 'مبلغ الضريبة',
                        widget.order.taxamnt
                      ),
                    if (widget.order.roundoff != 0)
                      _buildPriceRow(
                        provider.isEnglish ? 'Round Off' : 'التقريب',
                        widget.order.roundoff
                      ),
                    Divider(height: Responsive.padding(context, 16)),
                    _buildPriceRow(
                      provider.isEnglish ? 'Net Total' : 'الإجمالي الصافي',
                      widget.order.nettotal,
                      isTotal: true
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build order items card
  Widget _buildOrderItemsCard() {
    // Group items with their modifiers using slno
    Map<int, List<OrderDetail>> itemsWithModifiers = {};
    
    // First pass: add all normal items using slno as key
    for (var detail in widget.order.orderDetails) {
      if (detail.isNormalItem) {
        itemsWithModifiers[detail.slno] = [];
      }
    }
    
    // Second pass: add modifiers to their parent items using main_item_slno
    for (var detail in widget.order.orderDetails) {
      if (detail.isModifier && detail.mainItemSlno != null) {
        if (itemsWithModifiers.containsKey(detail.mainItemSlno)) {
          itemsWithModifiers[detail.mainItemSlno]!.add(detail);
        }
      }
    }
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(Responsive.padding(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<HomeProvider>(
              builder: (context, provider, child) {
                return Text(
                  provider.isEnglish ? 'Order Items' : 'عناصر الطلب',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: Responsive.fontSize(context, 18),
                        fontWeight: FontWeight.bold,
                      ),
                );
              },
            ),
            
            SizedBox(height: Responsive.padding(context, 16)),
            
            // Display items
            ...widget.order.orderDetails
                .where((detail) => detail.isNormalItem)
                .map((item) {
              // Get modifiers for this item using slno
              List<OrderDetail> modifiers = itemsWithModifiers[item.slno] ?? [];
              
              return _buildOrderItemTile(item, modifiers);
            }),
          ],
        ),
      ),
    );
  }

  /// Build a single order item tile with its modifiers
  Widget _buildOrderItemTile(OrderDetail item, List<OrderDetail> modifiers) {
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.padding(context, 12)),
      padding: EdgeInsets.all(Responsive.padding(context, 12)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item name and quantity
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quantity badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.padding(context, 8),
                  vertical: Responsive.padding(context, 4),
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${item.qty}x',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: Responsive.fontSize(context, 14),
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                ),
              ),
              
              SizedBox(width: Responsive.padding(context, 12)),
              
              // Item details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item name
                    Text(
                      item.itemname,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: Responsive.fontSize(context, 16),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    
                    SizedBox(height: Responsive.padding(context, 4)),
                    
                    // Unit name
                    if (item.unitname.isNotEmpty && item.unitname != 'Addon')
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.padding(context, 8),
                          vertical: Responsive.padding(context, 2),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.grey200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.unitname,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: Responsive.fontSize(context, 12),
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ),
                    
                    // Item remarks
                    if (item.itmremarks != null && item.itmremarks!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: Responsive.padding(context, 4)),
                        child: Text(
                          item.itmremarks!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: Responsive.fontSize(context, 12),
                                fontStyle: FontStyle.italic,
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Item price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.formattedTotal,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: Responsive.fontSize(context, 16),
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  if (item.rate > 0)
                    Text(
                      '${item.formattedPrice} each',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: Responsive.fontSize(context, 11),
                            color: AppColors.textSecondary,
                          ),
                    ),
                ],
              ),
            ],
          ),
          
          // Modifiers/Addons - Full width section
          if (modifiers.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: Responsive.padding(context, 12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: modifiers.map((modifier) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: Responsive.padding(context, 6)),
                    child: Container(
                      padding: EdgeInsets.all(Responsive.padding(context, 8)),
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Icon
                          Icon(
                            Icons.add_circle_outline,
                            size: Responsive.fontSize(context, 14),
                            color: AppColors.accent,
                          ),
                          SizedBox(width: Responsive.padding(context, 8)),
                          
                          // Quantity badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Responsive.padding(context, 6),
                              vertical: Responsive.padding(context, 2),
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${modifier.qty}x',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: Responsive.fontSize(context, 11),
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                            ),
                          ),
                          
                          SizedBox(width: Responsive.padding(context, 8)),
                          
                          // Modifier name
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  modifier.itemname,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontSize: Responsive.fontSize(context, 13),
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textPrimary,
                                      ),
                                ),
                                if (modifier.rate > 0)
                                  Text(
                                    '${modifier.formattedPrice} each',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontSize: Responsive.fontSize(context, 11),
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                              ],
                            ),
                          ),
                          
                          // Total price
                          if (modifier.total > 0)
                            Text(
                              modifier.formattedTotal,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: Responsive.fontSize(context, 13),
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accent,
                                  ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  /// Build order notes card
  Widget _buildOrderNotesCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(Responsive.padding(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<HomeProvider>(
              builder: (context, provider, child) {
                return Text(
                  provider.isEnglish ? 'Order Notes' : 'ملاحظات الطلب',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: Responsive.fontSize(context, 16),
                        fontWeight: FontWeight.w600,
                      ),
                );
              },
            ),
            
            SizedBox(height: Responsive.padding(context, 8)),
            
            Text(
              widget.order.orderNotes,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: Responsive.fontSize(context, 14),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build action buttons
  Widget _buildActionButtons() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(Responsive.padding(context, 16)),
        child: Column(
          children: [
            // Update Order button
            // SizedBox(
            //   width: double.infinity,
            //   height: Responsive.padding(context, 48),
            //   child: ElevatedButton.icon(
            //     onPressed: _isUpdating || widget.order.isOrderCompleted ? null : _updateOrder,
            //     icon: _isUpdating
            //         ? SizedBox(
            //             width: Responsive.fontSize(context, 20),
            //             height: Responsive.fontSize(context, 20),
            //             child: CircularProgressIndicator(
            //               strokeWidth: 2,
            //               valueColor: AlwaysStoppedAnimation<Color>(
            //                 Theme.of(context).colorScheme.onPrimary,
            //               ),
            //             ),
            //           )
            //         : Icon(Icons.update),
            //     label: Text(
            //       _isUpdating ? 'Updating...' : 'Update Order',
            //       style: Theme.of(context).textTheme.titleMedium?.copyWith(
            //             fontSize: Responsive.fontSize(context, 16),
            //             fontWeight: FontWeight.w600,
            //           ),
            //     ),
            //     style: ElevatedButton.styleFrom(
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //     ),
            //   ),
            // ),
            //
            // SizedBox(height: Responsive.padding(context, 12)),
            
            // Cancel Order button
            Consumer<HomeProvider>(
              builder: (context, provider, child) {
                return SizedBox(
                  width: double.infinity,
                  height: Responsive.padding(context, 48),
                  child: ElevatedButton.icon(
                    onPressed: _isCancelling || widget.order.isCancelled || widget.order.isOrderCompleted ? null : _cancelOrder,
                    icon: _isCancelling
                        ? SizedBox(
                            width: Responsive.fontSize(context, 20),
                            height: Responsive.fontSize(context, 20),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.onError,
                              ),
                            ),
                          )
                        : Icon(Icons.cancel),
                    label: Text(
                      _isCancelling 
                          ? (provider.isEnglish ? 'Cancelling...' : 'جاري الإلغاء...')
                          : (provider.isEnglish ? 'Cancel Order' : 'إلغاء الطلب'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: Responsive.fontSize(context, 16),
                            fontWeight: FontWeight.w600,
                        color: AppColors.white,
                          ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build status chip
  /// Status values: 0 = Pending, 1 = Accepted, 2 = Cancelled, 3 = Completed
  Widget _buildStatusChip(int orderStatus) {
    Color backgroundColor;
    Color textColor;

    switch (orderStatus) {
      case 0: // Pending
        backgroundColor = AppColors.warning;
        textColor = AppColors.white;
        break;
      case 1: // Accepted
        backgroundColor = AppColors.success;
        textColor = AppColors.white;
        break;
      case 2: // Cancelled
        backgroundColor = AppColors.error;
        textColor = AppColors.white;
        break;
      case 3: // Completed
        backgroundColor = Theme.of(context).colorScheme.primary;
        textColor = Theme.of(context).colorScheme.onPrimary;
        break;
      default:
        backgroundColor = AppColors.grey400;
        textColor = AppColors.white;
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
            horizontal: Responsive.padding(context, 16),
            vertical: Responsive.padding(context, 8),
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            statusText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: Responsive.fontSize(context, 14),
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        );
      },
    );
  }

  /// Build detail row
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.padding(context, 8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: Responsive.fontSize(context, 14),
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: Responsive.fontSize(context, 14),
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  /// Build price row
  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.padding(context, 4)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: Responsive.fontSize(context, 14),
                  fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
                  color: isTotal ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
          Text(
            'QR ${amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: Responsive.fontSize(context, 14),
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                  color: isTotal ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ],
      ),
    );
  }

  /// Handle update order action

  /// Handle cancel order action
  Future<void> _cancelOrder() async {
    final provider = context.read<HomeProvider>();
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(provider.isEnglish ? 'Cancel Order' : 'إلغاء الطلب'),
        content: Text(
          provider.isEnglish 
              ? 'Are you sure you want to cancel this order? This action cannot be undone.'
              : 'هل أنت متأكد من أنك تريد إلغاء هذا الطلب؟ لا يمكن التراجع عن هذا الإجراء.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(provider.isEnglish ? 'No' : 'لا'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              provider.isEnglish ? 'Yes, Cancel' : 'نعم، إلغاء',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isCancelling = true;
    });

    try {
      final controller = context.read<OrderTrackingController>();
      final success = await controller.cancelOrder(widget.order.onlineOrderId);

      if (mounted) {
        final provider = context.read<HomeProvider>();
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                provider.isEnglish 
                    ? 'Order cancelled successfully'
                    : 'تم إلغاء الطلب بنجاح'
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          // Navigate back to refresh the order list
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                provider.isEnglish 
                    ? 'Failed to cancel order'
                    : 'فشل إلغاء الطلب'
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final provider = context.read<HomeProvider>();
        // Extract error message from the exception
        String errorMessage = provider.isEnglish 
            ? 'Failed to cancel order. Please try again.'
            : 'فشل إلغاء الطلب. يرجى المحاولة مرة أخرى.';
        
        final exceptionString = e.toString();
        if (exceptionString.contains('Order ID is required')) {
          errorMessage = provider.isEnglish 
              ? 'Order ID is required'
              : 'معرف الطلب مطلوب';
        } else if (exceptionString.contains('Session expired') || 
                   exceptionString.contains('Please login again')) {
          errorMessage = provider.isEnglish 
              ? 'Session expired. Please login again.'
              : 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى.';
          
          // Optional: Navigate to login screen after showing error
          // Future.delayed(Duration(seconds: 2), () {
          //   if (mounted) {
          //     Navigator.of(context).pushReplacementNamed('/login');
          //   }
          // });
        } else if (exceptionString.contains('Order not found')) {
          errorMessage = provider.isEnglish 
              ? 'Order not found.'
              : 'الطلب غير موجود.';
        } else if (exceptionString.contains('Exception:')) {
          // Extract the actual error message from the Exception
          errorMessage = exceptionString.replaceFirst('Exception:', '').trim();
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCancelling = false;
        });
      }
    }
  }

  /// Format date time with 12-hour format and AM/PM
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
  }
}
