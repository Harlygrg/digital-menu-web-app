import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/home_provider.dart';
import '../../../theme/theme.dart';
import '../../../models/option_models.dart';

/// Popup widget to display modifier information
class ModifierInfoPopup extends StatelessWidget {
  final ModifierModel modifier;

  const ModifierInfoPopup({
    super.key,
    required this.modifier,
  });

  /// Show the popup
  static void show({
    required BuildContext context,
    required ModifierModel modifier,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ModifierInfoPopup(modifier: modifier),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        final isEnglish = provider.isEnglish;
        final modifierName = isEnglish ? modifier.modifier : (modifier.otherLang.isNotEmpty ? modifier.otherLang : modifier.modifier);
        final description = isEnglish ? (modifier.otherLang): (modifier.descriptionOl.isNotEmpty ? modifier.descriptionOl : '');
        
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: Responsive.isDesktop(context) ? 500 : double.infinity,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon and close button
                Container(
                  height: Responsive.padding(context, 120),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  ),
                  child: Stack(
                    children: [
                      // Modifier icon
                      Center(
                        child: Container(
                          width: Responsive.padding(context, 80),
                          height: Responsive.padding(context, 80),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.local_cafe,
                            size: Responsive.fontSize(context, 40),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      // Close button
                      Positioned(
                        top: Responsive.padding(context, 12),
                        right: Responsive.padding(context, 12),
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: EdgeInsets.all(Responsive.padding(context, 8)),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: Responsive.fontSize(context, 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.all(Responsive.padding(context, 20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Modifier name
                        Text(
                          modifierName,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: Responsive.padding(context, 8)),
                        // Price
                        Text(
                          'QR${modifier.price.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: Responsive.padding(context, 16)),
                        // Description
                        if (description.isNotEmpty) ...[
                          Text(
                            isEnglish ? 'Description' : 'الوصف',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: Responsive.padding(context, 8)),
                          Flexible(
                            child: SingleChildScrollView(
                              child: Text(
                                description,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          // No description available
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(Responsive.padding(context, 20)),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.description_outlined,
                                  size: Responsive.fontSize(context, 32),
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                                SizedBox(
                                    height: Responsive.padding(context, 8)
                                ),
                                Text(
                                  isEnglish
                                      ? 'No description available'
                                      : 'لا يوجد وصف متاح',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        SizedBox(height: Responsive.padding(context, 20)),
                        // Close button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              padding: EdgeInsets.symmetric(
                                vertical: Responsive.padding(context, 12),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              isEnglish ? 'Close' : 'إغلاق',
                              style: TextStyle(
                                fontSize: Responsive.fontSize(context, 16),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
