import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../controllers/cart_controller.dart';
import '../../models/cart_item_model.dart';
import '../../models/order_type_model.dart';
import '../../utils/image_utils.dart';
import '../../theme/theme.dart';
import '../../routes/routes.dart';
import '../../widgets/service_type_popup.dart';
import '../../providers/order_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/home_provider.dart';
import '../../storage/local_storage.dart';
import '../../widgets/order_success_popup.dart';

/// Full cart screen with complete cart functionality
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
              title: Responsive.isDesktop(context)
                  ? null // Hide default title for desktop
                  : Text(
                      provider.isEnglish ? 'Cart' : 'السلة',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 0,
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
                  : [
                      // Orders button
                      TextButton(
                        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.orderTracking),
                        child: Text(
                          provider.isEnglish ? 'Orders' : 'الطلبات',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: Responsive.fontSize(context, 14),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Consumer<CartController>(
                        builder: (context, cartController, child) {
                          if (cartController.isNotEmpty) {
                            return TextButton(
                              onPressed: () => _showClearCartDialog(context, cartController, provider.isEnglish),
                              child: Text(
                                provider.isEnglish ? 'Clear' : 'مسح',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: Responsive.fontSize(context, 14),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
              flexibleSpace: Responsive.isDesktop(context)
                  ? Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      child: Center(
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: Responsive.maxContentWidth(context),
                          ),
                          child: Row(
                            children: [
                              // Back button
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              // Title
                              Expanded(
                                child: Text(
                                  provider.isEnglish ? 'Cart' : 'السلة',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              // Actions
                              Consumer<CartController>(
                                builder: (context, cartController, child) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Orders button
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.orderTracking),
                                        child: Text(
                                          provider.isEnglish ? 'Orders' : 'الطلبات',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontSize: Responsive.fontSize(context, 14),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      // Clear button
                                      if (cartController.isNotEmpty)
                                        TextButton(
                                          onPressed: () => _showClearCartDialog(context, cartController, provider.isEnglish),
                                          child: Text(
                                            provider.isEnglish ? 'Clear' : 'مسح',
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.error,
                                              fontSize: Responsive.fontSize(context, 14),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : null,
          ),
          body: Responsive.isDesktop(context)
              ? _buildDesktopLayout(context, provider)
              : _buildMobileLayout(context, provider),
        );
      },
    );
  }

  /// Build mobile/tablet layout
  Widget _buildMobileLayout(BuildContext context, HomeProvider provider) {
    return Consumer<CartController>(
      builder: (context, cartController, child) {
        if (cartController.isEmpty) {
          return _buildEmptyCart(context, provider.isEnglish);
        }

        return Column(
          children: [
            // Cart items list
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(Responsive.padding(context, 16)),
                itemCount: cartController.cartItems.length,
                itemBuilder: (context, index) {
                  final cartItem = cartController.cartItems[index];
                  return _buildCartItemCard(context, cartController, cartItem, provider.isEnglish);
                },
              ),
            ),
            // Total and checkout section
            _buildCheckoutSection(context, cartController, provider.isEnglish),
          ],
        );
      },
    );
  }

  /// Build desktop layout with centered content and side spacing
  Widget _buildDesktopLayout(BuildContext context, HomeProvider provider) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: Responsive.maxContentWidth(context),
        ),
        child: Consumer<CartController>(
          builder: (context, cartController, child) {
            if (cartController.isEmpty) {
              return _buildEmptyCart(context, provider.isEnglish);
            }

            return Column(
              children: [
                // Cart items list
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(Responsive.padding(context, 16)),
                    itemCount: cartController.cartItems.length,
                    itemBuilder: (context, index) {
                      final cartItem = cartController.cartItems[index];
                      return _buildCartItemCard(context, cartController, cartItem, provider.isEnglish);
                    },
                  ),
                ),
                // Total and checkout section
                _buildCheckoutSection(context, cartController, provider.isEnglish),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Build empty cart state
  Widget _buildEmptyCart(BuildContext context, bool isEnglish) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: Responsive.fontSize(context, 80),
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          SizedBox(height: Responsive.padding(context, 24)),
          Text(
            isEnglish ? 'Your cart is empty' : 'سلتك فارغة',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: Responsive.padding(context, 8)),
          Text(
            isEnglish ? 'Add some delicious items to get started!' : 'أضف بعض الأطباق اللذيذة للبدء!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: Responsive.padding(context, 32)),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.padding(context, 32),
                vertical: Responsive.padding(context, 16),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isEnglish ? 'Start Shopping' : 'ابدأ التسوق',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual cart item card
  Widget _buildCartItemCard(
    BuildContext context,
    CartController cartController,
    CartItemModel cartItem,
    bool isEnglish,
  ) {
    final theme = Theme.of(context);
    
    return Card(
      margin: EdgeInsets.only(bottom: Responsive.padding(context, 12)),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(Responsive.padding(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item header with image and basic info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ImageUtils.buildImageFromBase64(
                    cartItem.item.image,
                    imageUrl: cartItem.item.imageUrl,
                    width: Responsive.padding(context, 60),
                    height: Responsive.padding(context, 60),
                    fit: BoxFit.cover,
                    errorWidget: Container(
                      width: Responsive.padding(context, 60),
                      height: Responsive.padding(context, 60),
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.fastfood,
                        color: theme.colorScheme.primary,
                        size: Responsive.fontSize(context, 24),
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
                        isEnglish ? cartItem.item.iname : (cartItem.item.nameinol.isNotEmpty ? cartItem.item.nameinol : cartItem.item.iname),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: Responsive.fontSize(context, 16),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: Responsive.padding(context, 4)),
                      Text(
                        cartItem.unitDisplayName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          fontSize: Responsive.fontSize(context, 12),
                        ),
                      ),
                      SizedBox(height: Responsive.padding(context, 8)),
                      Text(
                        'QR ${cartItem.unitPrice.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: Responsive.fontSize(context, 16),
                        ),
                      ),
                    ],
                  ),
                ),
                // Delete button
                IconButton(
                  onPressed: () async => await cartController.removeItem(cartItem),
                  icon: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                    size: Responsive.fontSize(context, 20),
                  ),
                ),
              ],
            ),
            
            // Modifiers section - show all modifiers, including those with 0 quantity
            if (cartItem.modifiers.isNotEmpty) ...[
              SizedBox(height: Responsive.padding(context, 12)),
              Text(
                isEnglish ? 'Add-ons:' : 'الإضافات:',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: Responsive.fontSize(context, 12),
                ),
              ),
              SizedBox(height: Responsive.padding(context, 8)),
              ...cartItem.modifiers.map((modifier) => _buildModifierRow(
                context,
                cartController,
                cartItem,
                modifier,
              )),
            ],
            
            // Special instructions with edit option
            SizedBox(height: Responsive.padding(context, 12)),
            Container(
              padding: EdgeInsets.all(Responsive.padding(context, 8)),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.note_alt_outlined,
                    size: Responsive.fontSize(context, 16),
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(width: Responsive.padding(context, 8)),
                  Expanded(
                    child: Text(
                      cartItem.specialInstructions?.isNotEmpty == true
                          ? cartItem.specialInstructions!
                          : (isEnglish ? 'No special instructions' : 'لا توجد تعليمات خاصة'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: Responsive.fontSize(context, 12),
                        fontStyle: FontStyle.italic,
                        color: cartItem.specialInstructions?.isEmpty != false
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(width: Responsive.padding(context, 8)),
                  InkWell(
                    onTap: () => _showEditInstructionsDialog(
                      context,
                      cartController,
                      cartItem,
                      isEnglish,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: EdgeInsets.all(Responsive.padding(context, 4)),
                      child: Icon(
                        Icons.edit_outlined,
                        size: Responsive.fontSize(context, 16),
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Quantity controls and total
            SizedBox(height: Responsive.padding(context, 16)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Quantity controls
                Row(
                  children: [
                    _buildQuantityButton(
                      context,
                      icon: Icons.remove,
                      onPressed: () async => await cartController.decreaseQuantity(cartItem),
                    ),
                    SizedBox(width: Responsive.padding(context, 16)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.padding(context, 16),
                        vertical: Responsive.padding(context, 8),
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${cartItem.quantity}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: Responsive.fontSize(context, 16),
                        ),
                      ),
                    ),
                    SizedBox(width: Responsive.padding(context, 16)),
                    _buildQuantityButton(
                      context,
                      icon: Icons.add,
                      onPressed: () async => await cartController.increaseQuantity(cartItem),
                    ),
                  ],
                ),
                // Item total
                Text(
                  'QR ${cartItem.totalPrice.toStringAsFixed(2)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    fontSize: Responsive.fontSize(context, 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build modifier row with quantity controls
  Widget _buildModifierRow(
    BuildContext context,
    CartController cartController,
    CartItemModel cartItem,
    CartModifier modifier,
  ) {
    final theme = Theme.of(context);
    final isZeroQuantity = modifier.quantity == 0;
    
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.padding(context, 8)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '• ${modifier.name}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: Responsive.fontSize(context, 12),
                color: isZeroQuantity 
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            'QR ${modifier.price.toStringAsFixed(2)}',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: Responsive.fontSize(context, 12),
              color: isZeroQuantity 
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                  : theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(width: Responsive.padding(context, 8)),
          Row(
            children: [
              _buildModifierQuantityButton(
                context,
                icon: Icons.remove,
                isEnabled: modifier.quantity > 0,
                onPressed: modifier.quantity > 0 
                    ? () async => await cartController.decreaseModifierQuantity(
                        cartItem,
                        modifier.id,
                      )
                    : null,
              ),
              SizedBox(width: Responsive.padding(context, 8)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.padding(context, 8),
                  vertical: Responsive.padding(context, 4),
                ),
                decoration: BoxDecoration(
                  color: isZeroQuantity 
                      ? theme.colorScheme.outline.withValues(alpha: 0.1)
                      : theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${modifier.quantity}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: Responsive.fontSize(context, 12),
                    color: isZeroQuantity 
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                        : theme.colorScheme.primary,
                  ),
                ),
              ),
              SizedBox(width: Responsive.padding(context, 8)),
              _buildModifierQuantityButton(
                context,
                icon: Icons.add,
                isEnabled: true,
                onPressed: () async => await cartController.increaseModifierQuantity(
                  cartItem,
                  modifier.id,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build quantity control button
  Widget _buildQuantityButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: Responsive.padding(context, 32),
      height: Responsive.padding(context, 32),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        child: Icon(
          icon,
          size: Responsive.fontSize(context, 16),
        ),
      ),
    );
  }

  /// Build modifier quantity control button
  Widget _buildModifierQuantityButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback? onPressed,
    bool isEnabled = true,
  }) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: Responsive.padding(context, 24),
      height: Responsive.padding(context, 24),
      child: OutlinedButton(
        onPressed: isEnabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          side: BorderSide(
            color: isEnabled 
                ? theme.colorScheme.outline.withValues(alpha: 0.3)
                : theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Icon(
          icon,
          size: Responsive.fontSize(context, 12),
          color: isEnabled 
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurface.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  /// Build checkout section with total and place order button
  Widget _buildCheckoutSection(BuildContext context, CartController cartController, bool isEnglish) {
    final theme = Theme.of(context);
    final total = cartController.totalPrice;
    final itemCount = cartController.itemCount;

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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Order notes text field
          _buildOrderNotesField(context, cartController, isEnglish),
          SizedBox(height: Responsive.padding(context, 16)),
          // Order summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEnglish 
                    ? 'Total ($itemCount ${itemCount == 1 ? 'item' : 'items'}):'
                    : 'المجموع ($itemCount ${itemCount == 1 ? 'عنصر' : 'عناصر'}):',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: Responsive.fontSize(context, 16),
                ),
              ),
              Text(
                'QR${total.toStringAsFixed(2)}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  fontSize: Responsive.fontSize(context, 20),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.padding(context, 20)),
          // Place order button
          SizedBox(
            width: double.infinity,
            height: Responsive.padding(context, 52),
            child: ElevatedButton(
              onPressed: () => _placeOrder(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Text(
                isEnglish ? 'Place Order' : 'اطلب الآن',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: Responsive.fontSize(context, 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build order notes text field
  Widget _buildOrderNotesField(BuildContext context, CartController cartController, bool isEnglish) {
    final theme = Theme.of(context);
    
    return TextFormField(
      initialValue: cartController.orderNotes,
      onChanged: (value) => cartController.setOrderNotes(value),
      decoration: InputDecoration(
        labelText: isEnglish ? 'Order Notes (Optional)' : 'ملاحظات الطلب (اختياري)',
        hintText: isEnglish 
            ? 'Add special instructions for your order...' 
            : 'أضف تعليمات خاصة لطلبك...',
        prefixIcon: Icon(
          Icons.note_outlined,
          color: theme.colorScheme.primary,
          size: Responsive.fontSize(context, 20),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: Responsive.padding(context, 16),
          vertical: Responsive.padding(context, 14),
        ),
      ),
      maxLines: 3,
      minLines: 1,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontSize: Responsive.fontSize(context, 14),
      ),
    );
  }

  /// Show edit special instructions dialog
  void _showEditInstructionsDialog(
    BuildContext context,
    CartController cartController,
    CartItemModel cartItem,
    bool isEnglish,
  ) {
    final TextEditingController controller = TextEditingController(
      text: cartItem.specialInstructions ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          isEnglish ? 'Edit Special Instructions' : 'تعديل التعليمات الخاصة',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: Responsive.fontSize(context, 18),
          ),
        ),
        content: TextFormField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: isEnglish ? 'Special Instructions' : 'تعليمات خاصة',
            hintText: isEnglish 
                ? 'Add note (extra mayo, no onions, etc.)' 
                : 'أضف ملاحظة (مايونيز إضافي، بدون بصل، إلخ)',
            prefixIcon: Icon(
              Icons.note_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: Responsive.fontSize(context, 20),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: Responsive.padding(context, 16),
              vertical: Responsive.padding(context, 14),
            ),
          ),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: Responsive.fontSize(context, 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.dispose();
              Navigator.of(dialogContext).pop();
            },
            child: Text(
              isEnglish ? 'Cancel' : 'إلغاء',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: Responsive.fontSize(context, 14),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final newInstructions = controller.text.trim();
              await cartController.updateSpecialInstructions(cartItem, newInstructions);
              controller.dispose();
              Navigator.of(dialogContext).pop();
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEnglish 
                          ? 'Special instructions updated successfully' 
                          : 'تم تحديث التعليمات الخاصة بنجاح'
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Text(
              isEnglish ? 'Save' : 'حفظ',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: Responsive.fontSize(context, 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show clear cart confirmation dialog
  void _showClearCartDialog(BuildContext context, CartController cartController, bool isEnglish) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isEnglish ? 'Clear Cart' : 'مسح السلة',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          isEnglish 
              ? 'Are you sure you want to remove all items from your cart?'
              : 'هل أنت متأكد من أنك تريد إزالة جميع العناصر من سلة التسوق؟',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              isEnglish ? 'Cancel' : 'إلغاء',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await cartController.clearCart();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isEnglish ? 'Cart cleared successfully' : 'تم مسح السلة بنجاح'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
            },
            child: Text(
              isEnglish ? 'Clear' : 'مسح',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Handle place order action
  void _placeOrder(BuildContext context) async {
    final customerProvider = context.read<CustomerProvider>();
    
    // Check if customer is already registered
    final needsRegistration = await customerProvider.needsRegistration();
    
    if (needsRegistration && context.mounted) {
      // Show customer details bottom sheet
        final customerAdded = await _showCustomerBottomSheet(context);
      
      if (!customerAdded) {
        // User cancelled or failed to add customer details
        return;
      }
    }
    
    // Proceed with service type selection
    if (context.mounted) {
      await _showServiceTypeAndPlaceOrder(context);
    }
  }

  /// Show customer details bottom sheet
  /// 
  /// Returns true if customer was added successfully, false otherwise
  Future<bool> _showCustomerBottomSheet(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => const CustomerBottomSheet(),
    );
    
    return result ?? false;
  }

  /// Show service type popup and place order
  Future<void> _showServiceTypeAndPlaceOrder(BuildContext context) async {
    // Show service type selection popup
    final selectedOrderType = await showDialog<OrderTypeModel>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) => const ServiceTypePopup(),
    );

    // If user selected an order type
    if (selectedOrderType != null && context.mounted) {
      // Check if the selected order type is DINE-IN
      if (selectedOrderType.orderType.toUpperCase() == 'DINE-IN') {
        // Navigate to table screen for DINE-IN orders
        Navigator.of(context).pushNamed(
          AppRoutes.table,
          arguments: {'selectedOrderType': selectedOrderType},
        );
      } else {
        // For other order types (TAKE-AWAY, etc.), place order with table_id = 0
        await _placeOrderForNonDineIn(context, selectedOrderType);
      }
    }
  }

  /// Place order for non-dine-in service types (TAKE-AWAY, etc.)
  Future<void> _placeOrderForNonDineIn(BuildContext context, OrderTypeModel orderType) async {
    // Get cart controller
    final cartController = context.read<CartController>();
    
    // Check if cart is empty
    if (cartController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cart is empty. Please add items first.'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    
    // Get branch ID from local storage
    final branchIdString = await LocalStorage.getBranchId();
    if (branchIdString == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Branch not selected. Please restart the app.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }
    
    final branchId = int.tryParse(branchIdString) ?? 0;
    
    // Show loading dialog
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PopScope(
          canPop: false,
          child: Center(
            child: Container(
              padding: EdgeInsets.all(Responsive.padding(context, 24)),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(height: Responsive.padding(context, 16)),
                  Text(
                    'Placing your order...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: Responsive.fontSize(context, 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    // Call create order API with table_id = 0 for non-dine-in orders
    final orderProvider = context.read<OrderProvider>();
    final response = await orderProvider.createOrder(
      cartItems: cartController.cartItems,
      tableId: 0, // table_id = 0 for non-dine-in orders
      orderTypeId: orderType.id.toString(),
      branchId: branchId,
      orderNotes: cartController.orderNotes.isNotEmpty ? cartController.orderNotes : null,
    );
    
    // Close loading dialog
    if (context.mounted) {
      Navigator.of(context).pop();
    }
    
    // Handle response
    if (response != null && response.success) {
      // Clear cart after successful order placement
      await cartController.clearCart();
      
      // Show success popup
      if (context.mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => OrderSuccessPopup(orderResponse: response),
        );
      }
    } else {
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(orderProvider.errorMessage ?? 'Failed to place order'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

/// Customer Bottom Sheet Widget
/// 
/// This widget displays a bottom sheet to collect customer information
/// (name and phone number) for first-time users before placing an order.
class CustomerBottomSheet extends StatefulWidget {
  const CustomerBottomSheet({super.key});

  @override
  State<CustomerBottomSheet> createState() => _CustomerBottomSheetState();
}

class _CustomerBottomSheetState extends State<CustomerBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        final isEnglish = provider.isEnglish;
        
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(Responsive.padding(context, 24)),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Handle bar
                          Center(
                            child: Container(
                              width: Responsive.padding(context, 40),
                              height: Responsive.padding(context, 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          SizedBox(height: Responsive.padding(context, 24)),
                          
                          // Title
                          Text(
                            isEnglish ? 'Complete Your Order' : 'أكمل طلبك',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: Responsive.fontSize(context, 20),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: Responsive.padding(context, 8)),
                          
                          // Subtitle
                          Text(
                            isEnglish ? 'We need your contact info to deliver your order' : 'نحتاج معلومات الاتصال الخاصة بك لتوصيل طلبك',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              fontSize: Responsive.fontSize(context, 14),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: Responsive.padding(context, 32)),
                          
                          // Name field
                          TextFormField(
                            controller: _nameController,
                            enabled: !_isLoading,
                            decoration: InputDecoration(
                              labelText: isEnglish ? 'Your Name' : 'اسمك',
                              hintText: isEnglish ? 'Enter your full name' : 'أدخل اسمك الكامل',
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: theme.colorScheme.primary,
                                size: Responsive.fontSize(context, 20),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return isEnglish ? 'Please enter your name' : 'يرجى إدخال اسمك';
                              }
                              if (value.trim().length < 2) {
                                return isEnglish ? 'Name should be at least 2 characters' : 'يجب أن يكون الاسم حرفين على الأقل';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: Responsive.padding(context, 20)),
                          
                          // Phone field
                          TextFormField(
                            controller: _phoneController,
                            enabled: !_isLoading,
                            decoration: InputDecoration(
                              labelText: isEnglish ? 'Mobile Number' : 'رقم الجوال',
                              hintText: isEnglish ? 'Enter your mobile number' : 'أدخل رقم جوالك',
                              prefixIcon: Icon(
                                Icons.phone_outlined,
                                color: theme.colorScheme.primary,
                                size: Responsive.fontSize(context, 20),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return isEnglish ? 'Please enter your mobile number' : 'يرجى إدخال رقم جوالك';
                              }
                              if (value.trim().length < 8) {
                                return isEnglish ? 'Please enter a valid mobile number' : 'يرجى إدخال رقم جوال صحيح';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) => _handleContinue(),
                          ),
                          SizedBox(height: Responsive.padding(context, 32)),
                          
                          // Continue button
                          SizedBox(
                            height: Responsive.padding(context, 52),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleContinue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                                disabledBackgroundColor: theme.colorScheme.primary.withValues(alpha: 0.5),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      height: Responsive.padding(context, 20),
                                      width: Responsive.padding(context, 20),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          theme.colorScheme.onPrimary,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      isEnglish ? 'Continue' : 'متابعة',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: theme.colorScheme.onPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: Responsive.fontSize(context, 16),
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(height: Responsive.padding(context, 12)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
      },
    );
  }

  /// Handle continue button press
  void _handleContinue() async {
    // Unfocus keyboard
    FocusScope.of(context).unfocus();
    
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    final customerProvider = context.read<CustomerProvider>();
    
    // Add customer
    final customerId = await customerProvider.addCustomer(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
    );
    
    if (!mounted) return;
    
    setState(() {
      _isLoading = false;
    });
    
    if (customerId != null) {
      // Success - close bottom sheet with success result
      final provider = context.read<HomeProvider>();
      _showSuccessSnackBar(
        provider.isEnglish 
          ? 'Your information saved successfully!' 
          : 'تم حفظ معلوماتك بنجاح!'
      );
      Navigator.of(context).pop(true);
    } else {
      // Error - show error message
      final provider = context.read<HomeProvider>();
      final errorMessage = customerProvider.errorMessage ?? 
          (provider.isEnglish 
            ? 'Failed to save your information. Please try again.' 
            : 'فشل حفظ معلوماتك. يرجى المحاولة مرة أخرى.');
      
      _showErrorSnackBar(errorMessage);
    }
  }

  /// Show success snackbar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.white,
              size: Responsive.fontSize(context, 20),
            ),
            SizedBox(width: Responsive.padding(context, 12)),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 14),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show error snackbar with retry option
  void _showErrorSnackBar(String message) {
    final provider = context.read<HomeProvider>();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: Responsive.fontSize(context, 20),
            ),
            SizedBox(width: Responsive.padding(context, 12)),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 14),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: provider.isEnglish ? 'Retry' : 'إعادة المحاولة',
          textColor: Colors.white,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          onPressed: _handleContinue,
        ),
      ),
    );
  }
}