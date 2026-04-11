import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../localization/app_strings.dart';
import '../../providers/language_provider.dart';
import '../../routes/routes.dart';
import '../../theme/theme.dart';

/// Placeholder when `/item-detail` is opened without a full product flow.
class ItemDetailPlaceholderScreen extends StatelessWidget {
  final String itemId;

  const ItemDetailPlaceholderScreen({super.key, required this.itemId});

  void _goHome(BuildContext context) {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
  }

  void _backOrHome(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      _goHome(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, lang, _) {
        final isEnglish = lang.isEnglish;
        return Scaffold(
          appBar: AppBar(
            title: Text(AppStrings.itemUnavailableTitle(isEnglish)),
          ),
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(Responsive.padding(context, 24)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fastfood_outlined,
                    size: Responsive.fontSize(context, 64),
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.7),
                  ),
                  SizedBox(height: Responsive.padding(context, 16)),
                  Text(
                    AppStrings.itemUnavailableBody(isEnglish),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (itemId.isNotEmpty) ...[
                    SizedBox(height: Responsive.padding(context, 12)),
                    Text(
                      itemId,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                  SizedBox(height: Responsive.padding(context, 32)),
                  FilledButton(
                    onPressed: () => _backOrHome(context),
                    child: Text(AppStrings.backToMenu(isEnglish)),
                  ),
                  SizedBox(height: Responsive.padding(context, 12)),
                  TextButton(
                    onPressed: () => _goHome(context),
                    child: Text(AppStrings.goHome(isEnglish)),
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
