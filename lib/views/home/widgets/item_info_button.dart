import 'package:digital_menu_order/localization/app_strings.dart';
import 'package:digital_menu_order/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Tappable info icon for product details with tooltip and minimum touch target.
class ItemInfoButton extends StatelessWidget {
  final VoidCallback? onTap;
  final double? buttonSize;

  const ItemInfoButton({super.key, this.onTap, this.buttonSize});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, lang, _) {
        final size = buttonSize ?? 14;
        return IconButton(
          onPressed: onTap,
          tooltip: AppStrings.itemDetailsTooltip(lang.isEnglish),
          constraints: const BoxConstraints(
            minWidth: kMinInteractiveDimension,
            minHeight: kMinInteractiveDimension,
          ),
          padding: EdgeInsets.zero,
          icon: Icon(
            Icons.info_rounded,
            size: size,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        );
      },
    );
  }
}
