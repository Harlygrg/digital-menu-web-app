import 'package:digital_menu_order/utils/capitalize_first_letter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_type_model.dart';
import '../providers/order_type_provider.dart';
import '../theme/theme.dart';
import '../widgets/table_shimmer_widget.dart';

/// Service Type Selection Popup
/// 
/// This popup allows users to select a service type (Eat-In or Take-Away)
/// before proceeding to the table selection screen.
/// 
/// Features:
/// - Fetches order types from API
/// - Displays order types in a responsive grid
/// - Shows shimmer loading effect
/// - Handles errors gracefully
/// - Single selection with confirmation
class ServiceTypePopup extends StatefulWidget {
  const ServiceTypePopup({super.key});

  @override
  State<ServiceTypePopup> createState() => _ServiceTypePopupState();
}

class _ServiceTypePopupState extends State<ServiceTypePopup> {
  OrderTypeModel? _selectedOrderType;

  @override
  void initState() {
    super.initState();
    // Fetch order types when popup opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderTypeProvider>().fetchOrderTypes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: Responsive.maxContentWidth(context),
          maxHeight: MediaQuery.of(context).size.height * 0.7, // Increased slightly to prevent overflow
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(
              child: Consumer<OrderTypeProvider>(
                builder: (context, orderTypeProvider, child) {
                  if (orderTypeProvider.isLoading) {
                    return _buildLoadingState(context);
                  }

                  if (orderTypeProvider.errorMessage != null) {
                    return _buildErrorState(context, orderTypeProvider);
                  }

                  if (!orderTypeProvider.hasOrderTypes) {
                    return _buildEmptyState(context);
                  }

                  return _buildOrderTypesGrid(context, orderTypeProvider);
                },
              ),
            ),
            _buildSubmitButton(context),
          ],
        ),
      ),
    );
  }

  /// Build popup header with title and close button
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.all(Responsive.padding(context, 16)), // Reduced header padding
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Stack(
        children: [
          // Title centered
          Center(
            child: Text(
              'Select Service Type',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: Responsive.fontSize(context, 20),
              ),
            ),
          ),
          // Close button at top-right (matching Add-to-Cart popup style)
          Align(
            alignment: AlignmentDirectional.topEnd,
            child: InkWell(
              onTap: () => Navigator.of(context).maybePop(),
              child: const Icon(Icons.cancel_outlined, color: AppColors.nonVeg),
            ),
          ),
        ],
      ),
    );
  }

  /// Build loading state with shimmer effect
  Widget _buildLoadingState(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.padding(context, 20)),
      child: Column(
        children: [
          Text(
            'Loading service types...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: Responsive.fontSize(context, 14),
            ),
          ),
          SizedBox(height: Responsive.padding(context, 16)),
          const Expanded(
            child: TableShimmerWidget(),
          ),
        ],
      ),
    );
  }

  /// Build error state with retry option
  Widget _buildErrorState(BuildContext context, OrderTypeProvider provider) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.all(Responsive.padding(context, 20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: Responsive.fontSize(context, 48),
            color: theme.colorScheme.error,
          ),
          SizedBox(height: Responsive.padding(context, 16)),
          Text(
            'Failed to load service types',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: Responsive.fontSize(context, 16),
            ),
          ),
          SizedBox(height: Responsive.padding(context, 8)),
          Text(
            provider.errorMessage ?? 'An unexpected error occurred',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: Responsive.fontSize(context, 14),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: Responsive.padding(context, 24)),
          ElevatedButton.icon(
            onPressed: () => provider.refresh(),
            icon: Icon(
              Icons.refresh,
              size: Responsive.fontSize(context, 16),
            ),
            label: Text(
              'Retry',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 14),
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.padding(context, 24),
                vertical: Responsive.padding(context, 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty state when no order types are available
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.all(Responsive.padding(context, 20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_outlined,
            size: Responsive.fontSize(context, 48),
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          SizedBox(height: Responsive.padding(context, 16)),
          Text(
            'No service types available',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: Responsive.fontSize(context, 16),
            ),
          ),
          SizedBox(height: Responsive.padding(context, 8)),
          Text(
            'Please contact support for assistance',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: Responsive.fontSize(context, 14),
            ),
          ),
        ],
      ),
    );
  }

  /// Build grid of order types for selection
  Widget _buildOrderTypesGrid(BuildContext context, OrderTypeProvider provider) {
    final theme = Theme.of(context);
    final orderTypes = provider.activeOrderTypes;
    
    return Container(
      padding: EdgeInsets.all(Responsive.padding(context, 16)), // Reduced padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose your preferred service type:',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: Responsive.fontSize(context, 14),
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: Responsive.padding(context, 12)), // Reduced spacing
          Flexible(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: Responsive.gridColumns(context),
                crossAxisSpacing: Responsive.padding(context, 16),
                mainAxisSpacing: Responsive.padding(context, 16),
                childAspectRatio: 1.1, // Slightly reduced to fit better
              ),
              itemCount: orderTypes.length,
              itemBuilder: (context, index) {
                final orderType = orderTypes[index];
                final isSelected = _selectedOrderType?.id == orderType.id;
                if(orderType.id == 1 || orderType.id == 2) {
                  return _buildOrderTypeCard(context, orderType, isSelected);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual order type selection card
  Widget _buildOrderTypeCard(
    BuildContext context,
    OrderTypeModel orderType,
    bool isSelected,
  ) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOrderType = orderType;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with increased top padding
            Container(
              margin: EdgeInsets.only(top: Responsive.padding(context, 8)), // Added top margin for better spacing
              padding: EdgeInsets.all(Responsive.padding(context, 16)),
              decoration: BoxDecoration(
                color: isSelected 
                    ? theme.colorScheme.primary.withValues(alpha: 0.2)
                    : theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForOrderType(orderType.orderType),
                size: Responsive.fontSize(context, 32),
                color: isSelected 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primary.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: Responsive.padding(context, 12)),
            // Title
            Text(
              orderType.displayName.toLowerCase().capitalizeFirst(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: Responsive.fontSize(context, 16),
                color: isSelected 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Responsive.padding(context, 4)),
          ],
        ),
      ),
    );
  }

  /// Build submit button
  Widget _buildSubmitButton(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = _selectedOrderType != null;
    
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
      child: SizedBox(
        width: double.infinity,
        height: Responsive.padding(context, 48),
        child: ElevatedButton(
          onPressed: isEnabled ? () => _submitSelection(context) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled 
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            foregroundColor: isEnabled 
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: isEnabled ? 2 : 0,
          ),
          child: Text(
            'Continue',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 16),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  /// Handle submission of selected order type
  void _submitSelection(BuildContext context) {
    if (_selectedOrderType != null) {
      // Close the popup and return the selected order type
      Navigator.of(context).pop(_selectedOrderType);
    }
  }

  /// Get appropriate icon for order type
  IconData _getIconForOrderType(String orderType) {
    switch (orderType.toUpperCase()) {
      case 'DINE-IN':
        return Icons.restaurant;
      case 'TAKE-AWAY':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.shopping_cart_outlined;
    }
  }
}
