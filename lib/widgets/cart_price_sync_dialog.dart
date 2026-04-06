import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// A gentle popup shown when the QR/order context changes while the cart has items.
///
/// Returns:
/// - `true` if user chooses Proceed (sync now)
/// - `false` if user chooses Cancel
class CartPriceSyncDialog extends StatelessWidget {
  final bool isEnglish;

  const CartPriceSyncDialog({super.key, required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final title = isEnglish ? 'Update cart prices?' : 'تحديث أسعار السلة؟';
    final body = isEnglish
        ? 'You changed the order type. Prices and item availability may be different for this order. Update your cart to continue.'
        : 'لقد قمت بتغيير نوع الطلب. قد تختلف الأسعار وتوفر الأصناف لهذا الطلب. قم بتحديث السلة للمتابعة.';
    final proceed = isEnglish ? 'Proceed' : 'متابعة';
    final cancel = isEnglish ? 'Cancel' : 'إلغاء';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: Responsive.maxContentWidth(context),
        ),
        child: Padding(
          padding: EdgeInsets.all(Responsive.padding(context, 20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: Responsive.padding(context, 12)),
              Text(
                body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  height: 1.35,
                ),
              ),
              SizedBox(height: Responsive.padding(context, 20)),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(cancel),
                    ),
                  ),
                  SizedBox(width: Responsive.padding(context, 12)),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                      child: Text(proceed),
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
}
