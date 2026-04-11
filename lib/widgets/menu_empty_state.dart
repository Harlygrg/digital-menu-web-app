import 'package:flutter/material.dart';
import '../localization/app_strings.dart';
import '../theme/theme.dart';

/// Empty state when filters yield no menu items, with optional recovery actions.
class MenuEmptyState extends StatelessWidget {
  final bool isEnglish;
  final bool showClearSearch;
  final bool showShowAllCategories;
  final VoidCallback? onClearSearch;
  final VoidCallback? onShowAllCategories;

  const MenuEmptyState({
    super.key,
    required this.isEnglish,
    required this.showClearSearch,
    required this.showShowAllCategories,
    this.onClearSearch,
    this.onShowAllCategories,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.all(Responsive.padding(context, 32)),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: Responsive.fontSize(context, 48),
              color: scheme.onSurface.withValues(alpha: 0.3),
            ),
            SizedBox(height: Responsive.padding(context, 16)),
            Text(
              AppStrings.noItemsFound(isEnglish),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 16),
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            if (showClearSearch || showShowAllCategories) ...[
              SizedBox(height: Responsive.padding(context, 20)),
              Wrap(
                spacing: Responsive.padding(context, 12),
                runSpacing: Responsive.padding(context, 8),
                alignment: WrapAlignment.center,
                children: [
                  if (showClearSearch && onClearSearch != null)
                    TextButton(
                      onPressed: onClearSearch,
                      child: Text(AppStrings.clearSearchAction(isEnglish)),
                    ),
                  if (showShowAllCategories && onShowAllCategories != null)
                    TextButton(
                      onPressed: onShowAllCategories,
                      child: Text(AppStrings.showAllCategories(isEnglish)),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
