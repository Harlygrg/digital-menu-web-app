import 'package:digital_menu_order/utils/capitalize_first_letter.dart';
import 'package:digital_menu_order/utils/image_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/item_model.dart';
import '../../../models/option_models.dart';
import '../../../controllers/cart_controller.dart';
import '../../../providers/home_provider.dart';
import '../../../theme/theme.dart';
import 'modifier_info_popup.dart';

/// Helper to present the AddToCart popup as a dialog.
/// Returns the payload passed to [onSubmit] via `Navigator.pop`.
Future<T?> showAddToCartPopup<T>({
  required BuildContext context,
  required ItemModel item,
  required List<UnitPriceListModel> sizes,
  required List<ModifierModel> addons,
  ValueChanged<T?>? onSubmit,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: Responsive.padding(context, 12),
        vertical: Responsive.padding(context, 12),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: AddToCartPopup<T>(
        item: item,
        sizes: sizes,
        addons: addons,
        onSubmit: (value) {
          onSubmit?.call(value);
          Navigator.of(ctx).pop<T>(value);
        },
      ),
    ),
  );
}

/// Popup widget representing the Add-to-Cart flow.
/// This is UI-only; it manages local state and exposes the result through [onSubmit].
class AddToCartPopup<T> extends StatefulWidget {
  final ItemModel item;
  final List<UnitPriceListModel> sizes;
  final List<ModifierModel> addons;
  final ValueChanged<T?>? onSubmit;

  const AddToCartPopup({
    super.key,
    required this.item,
    required this.sizes,
    required this.addons,
    this.onSubmit,
  });

  @override
  State<AddToCartPopup<T>> createState() => _AddToCartPopupState<T>();
}

class _AddToCartPopupState<T> extends State<AddToCartPopup<T>> {
  final TextEditingController _noteController = TextEditingController();

  late int _quantity;
  late int _selectedSizeIndex;
  late List<int> _addonQuantities;

  @override
  void initState() {
    super.initState();
    _quantity = 1;
    _selectedSizeIndex = 0;
    _addonQuantities = List<int>.filled(widget.addons.length, 0);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  double _computeUnitPrice() {
    // If sizes are available, use the selected size price as the base price
    // Otherwise, use the item's base price
    final basePrice = widget.sizes.isNotEmpty
        ? widget.sizes[_selectedSizeIndex].price
        : widget.item.price;
    
    return basePrice;
  }

  double _computeAddonsTotal() {
    return List.generate(widget.addons.length, (i) {
      return widget.addons[i].price * _addonQuantities[i];
    }).fold<double>(0.0, (a, b) => a + b);
  }

  double _computeTotal() {
    final unitPrice = _computeUnitPrice();
    final addonsTotal = _computeAddonsTotal();
    return (unitPrice * _quantity) + addonsTotal;
  }

  void _updateAddonQty(int index, int delta) {
    setState(() {
      final next = (_addonQuantities[index] + delta).clamp(0, 99);
      _addonQuantities[index] = next;
    });
  }

  void _updateQuantity(int delta) {
    setState(() {
      _quantity = (_quantity + delta).clamp(1, 99);
    });
  }

  Future<void> _submit() async {
    try {
      // Get the cart controller and home provider
      final cartController = Provider.of<CartController>(context, listen: false);
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      final isEnglish = homeProvider.isEnglish;
      
      // Create the payload for the cart controller
      final payload = {
        'itemId': widget.item.id,
        'size': widget.sizes.isNotEmpty ? widget.sizes[_selectedSizeIndex].unitName : null,
        'quantity': _quantity,
        'addons': [
          for (int i = 0; i < widget.addons.length; i++)
            if (_addonQuantities[i] > 0)
              {
                'id': widget.addons[i].id,
                'title': isEnglish ? widget.addons[i].modifier : (widget.addons[i].otherLang.isNotEmpty ? widget.addons[i].otherLang : widget.addons[i].modifier),
                'qty': _addonQuantities[i],
                'price': widget.addons[i].price,
              }
        ],
        'note': _noteController.text.trim(),
        'unitPrice': _computeUnitPrice(),
        'total': _computeTotal(),
      };

      // Add to cart using the cart controller (with availability check)
      await cartController.addToCartFromPopup(
        item: widget.item,
        payload: payload,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEnglish ? 'Item added to cart!' : 'تم إضافة العنصر للسلة!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          duration: Duration(seconds: 2),
        ),
      );

      // Close the popup
      Navigator.of(context).pop();
    } catch (e) {
      // Handle different error cases
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      final isEnglish = homeProvider.isEnglish;
      
      String errorMessage;
      bool shouldRefreshMenu = false;
      
      // Check if this is an availability error that requires menu refresh
      if (e.toString().contains('no longer available') || e.toString().contains('Refreshing menu')) {
        errorMessage = isEnglish ? '⚠️ This item is no longer available. Refreshing menu...' : '⚠️ هذا العنصر لم يعد متوفراً. جاري تحديث القائمة...';
        shouldRefreshMenu = true;
      } else if (e.toString().contains('Session expired')) {
        errorMessage = isEnglish ? 'Session expired. Please log in again.' : 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى.';
      } else if (e.toString().contains('Product ID missing')) {
        errorMessage = isEnglish ? 'Product ID missing — please try again.' : 'معرف المنتج مفقود — يرجى المحاولة مرة أخرى.';
      } else {
        errorMessage = isEnglish ? 'Unable to check item availability. Please try again.' : 'غير قادر على التحقق من توفر العنصر. يرجى المحاولة مرة أخرى.';
      }
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: Duration(seconds: 3),
        ),
      );
      
      // If product is unavailable, refresh the menu in background
      if (shouldRefreshMenu) {
        // Get branch ID from home provider or use default
        final branchId = '1'; // You might want to get this from branch provider
        homeProvider.refreshProductListSilently(branchId: branchId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<HomeProvider, _LanguageState>(
      selector: (_, provider) => _LanguageState(
        isEnglish: provider.isEnglish,
        textDirection: provider.textDirection,
      ),
      builder: (context, langState, child) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final isEnglish = langState.isEnglish;

        final padding16 = Responsive.padding(context, 16);
        final padding12 = Responsive.padding(context, 12);
        final radius12 = 12.0;
        final String title =  isEnglish ? widget.item.iname : (widget.item.nameinol.isNotEmpty ? widget.item.nameinol : widget.item.iname);
        final cacheWidth = (100 * MediaQuery.of(context).devicePixelRatio).toInt();
        return Directionality(
          textDirection: langState.textDirection,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Responsive.isMobile(context) ? 480 : 720,
            ),
            child: Material(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Flexible(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(padding16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header - Static image + language-dependent text
                            Stack(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Static product image wrapped in RepaintBoundary
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: ImageUtils.buildImageFromBase64(
                                        widget.item.image,
                                        imageUrl: widget.item.imageUrl,
                                        width: Responsive.isMobile(context) ? 64 : 84,
                                        height: Responsive.isMobile(context) ? 64 : 84,
                                        fit: BoxFit.cover,
                                        cacheWidth: cacheWidth,
                                        cacheHeight: cacheWidth,
                                        placeholder: Container(
                                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                                          child: Center(
                                            child: Icon(
                                              Icons.fastfood,
                                              size: Responsive.fontSize(context, 24),
                                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                                            ),
                                          ),
                                        ),
                                        errorWidget: Container(
                                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                          width: Responsive.isMobile(context) ? 64 : 84,
                                          height: Responsive.isMobile(context) ? 64 : 84,
                                          child: Icon(
                                            Icons.fastfood,
                                            size: Responsive.fontSize(context, 30),
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: padding12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                 title.capitalizeFirst().length > 24 ?('${title.capitalizeFirst().substring(0,24)}\n${title.capitalizeFirst().substring(24,title.length)}'):title.capitalizeFirst() ,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: theme.textTheme.titleLarge?.copyWith(
                                                    fontSize: Responsive.fontSize(context, 18),
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: Responsive.padding(context, 6)),
                                          Text(
                                            isEnglish ? widget.item.descriptionEn : (widget.item.descriptionOtherLang.isNotEmpty ? widget.item.descriptionOtherLang : widget.item.descriptionEn),
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              fontSize: Responsive.fontSize(context, 12),
                                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                            ),
                                          ),
                                          SizedBox(height: Responsive.padding(context, 10)),
                                          Row(
                                            children: [
                                              Text(
                                                'QR${widget.item.price.toStringAsFixed(2)}',
                                                style: theme.textTheme.titleMedium?.copyWith(
                                                  fontSize: Responsive.fontSize(context, 16),
                                                  fontWeight: FontWeight.w800,
                                                  color: theme.colorScheme.onSurface,
                                                ),
                                              ),
                                              if (widget.item.preparationtime.isNotEmpty) ...[
                                                SizedBox(width: Responsive.padding(context, 12)),
                                                Icon(
                                                  Icons.access_time,
                                                  size: Responsive.fontSize(context, 16),
                                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                                ),
                                                SizedBox(width: Responsive.padding(context, 4)),
                                                Text(
                                                  widget.item.preparationtime,
                                                  style: theme.textTheme.titleMedium?.copyWith(
                                                    fontSize: Responsive.fontSize(context, 14),
                                                    fontWeight: FontWeight.w600,
                                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Align(
                                  alignment: AlignmentDirectional.topEnd,
                                  child: InkWell(
                                    onTap: () => Navigator.of(context).maybePop(),
                                    child: const Icon(Icons.cancel_outlined,color: AppColors.nonVeg,),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: Responsive.padding(context, 16)),

                            // Quantity
                            _SectionLabel(text: isEnglish ? 'Quantity' : 'الكمية'),
                            SizedBox(height: Responsive.padding(context, 8)),
                            _Counter(
                              value: _quantity,
                              onDecrement: () => _updateQuantity(-1),
                              onIncrement: () => _updateQuantity(1),
                            ),

                            SizedBox(height: Responsive.padding(context, 18)),

                            // Size
                            _SectionLabel(text: isEnglish ? 'Size' : 'الحجم'),
                            SizedBox(height: Responsive.padding(context, 8)),
                            Wrap(
                              spacing: Responsive.padding(context, 10),
                              runSpacing: Responsive.padding(context, 8),
                              children: List.generate(widget.sizes.length, (i) {
                                final selected = i == _selectedSizeIndex;
                                final option = widget.sizes[i];
                                return _SizeChip(
                                  selected: selected,
                                  label:isEnglish ? option.unitName : (option.otherLang.isEmpty ? option.unitName : option.otherLang),
                                  price: option.price,
                                  onTap: () => setState(() => _selectedSizeIndex = i),
                                );
                              }),
                            ),

                            SizedBox(height: Responsive.padding(context, 18)),

                            // Addons
                            _SectionLabel(text: isEnglish ? 'Add-ons' : 'الإضافات'),
                            SizedBox(height: Responsive.padding(context, 8)),
                            SizedBox(
                              height: Responsive.isMobile(context) ? 120 : 140,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.symmetric(horizontal: Responsive.padding(context, 4)),
                                itemBuilder: (c, i) {
                                  final addon = widget.addons[i];
                                  final qty = _addonQuantities[i];
                                  return _AddonCard(
                                    addon: addon,
                                    qty: qty,
                                    isEnglish: isEnglish,
                                    onDecrement: () => _updateAddonQty(i, -1),
                                    onIncrement: () => _updateAddonQty(i, 1),
                                  );
                                },
                                separatorBuilder: (c, i) => SizedBox(width: Responsive.padding(context, 10)),
                                itemCount: widget.addons.length,
                              ),
                            ),

                            SizedBox(height: Responsive.padding(context, 18)),

                            // Notes
                            _SectionLabel(text: isEnglish ? 'Special Instructions' : 'تعليمات خاصة'),
                            SizedBox(height: Responsive.padding(context, 8)),
                            _NoteField(
                              controller: _noteController,
                              hint: isEnglish ? 'Add note (extra mayo, cheese, etc.)' : 'أضف ملاحظة (مايونيز إضافي، جبن، إلخ)',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom bar button
                  Container(
                    padding: EdgeInsets.all(padding16),
                    decoration: BoxDecoration(
                      color: isDark ? theme.colorScheme.surface : AppColors.white,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(radius12)),
                    ),
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _submit,
                        child: Text(
                          '${isEnglish ? 'Add to Cart' : 'أضف للسلة'} – QR${_computeTotal().toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontSize: Responsive.fontSize(context, 14),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
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

/// Helper class to track language state for Selector
class _LanguageState {
  final bool isEnglish;
  final TextDirection textDirection;

  _LanguageState({
    required this.isEnglish,
    required this.textDirection,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _LanguageState &&
          runtimeType == other.runtimeType &&
          isEnglish == other.isEnglish &&
          textDirection == other.textDirection;

  @override
  int get hashCode => isEnglish.hashCode ^ textDirection.hashCode;
}

/// Static product image widget that won't rebuild on state changes


class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: Responsive.fontSize(context, 12),
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  const _Counter({required this.value, required this.onDecrement, required this.onIncrement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = 36.0;
    final radius = 8.0;

    Widget btn(IconData icon, VoidCallback onTap) {
      return SizedBox(
        width: size,
        height: size,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
          ),
          onPressed: onTap,
          child: Icon(icon, size: 18),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        btn(Icons.remove, onDecrement),
        SizedBox(width: Responsive.padding(context, 10)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Text(
            '$value',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: Responsive.fontSize(context, 14),
            ),
          ),
        ),
        SizedBox(width: Responsive.padding(context, 10)),
        btn(Icons.add, onIncrement),
      ],
    );
  }
}

class _SizeChip extends StatelessWidget {
  final bool selected;
  final String label;
  final double price;
  final VoidCallback onTap;
  const _SizeChip({required this.selected, required this.label, required this.price, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priceText = ' QR${price.toStringAsFixed(2)}';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.4),
          ),
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 18,
              color: selected ? theme.colorScheme.primary : theme.colorScheme.outline,
            ),
            const SizedBox(width: 8),
            Text(
              '$label$priceText',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: Responsive.fontSize(context, 12),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddonCard extends StatelessWidget {
  final ModifierModel addon;
  final int qty;
  final bool isEnglish;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  const _AddonCard({required this.addon, required this.qty, required this.isEnglish, required this.onDecrement, required this.onIncrement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = Responsive.isMobile(context) ? 200.0 : 240.0;
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 64,
              height: 64,
              child: Container(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                child: Icon(Icons.local_cafe, color: theme.colorScheme.primary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isEnglish ? addon.modifier : (addon.descriptionOl.isNotEmpty ? addon.descriptionOl : addon.modifier),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: Responsive.fontSize(context, 12),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => ModifierInfoPopup.show(
                        context: context,
                        modifier: addon,
                      ),
                      child: Container(
                        padding: EdgeInsets.all(Responsive.padding(context, 4)),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.info_outline, 
                          size: 16, 
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'QR${addon.price.toStringAsFixed(2)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _QtyMiniButton(icon: Icons.remove, onPressed: onDecrement),
                    const SizedBox(width: 8),
                    Text('$qty', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    _QtyMiniButton(icon: Icons.add, onPressed: onIncrement),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _QtyMiniButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const _QtyMiniButton({required this.icon, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
        child: Icon(icon, size: 16),
      ),
    );
  }
}

class _NoteField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  const _NoteField({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: theme.colorScheme.primary.withValues(alpha: 0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}