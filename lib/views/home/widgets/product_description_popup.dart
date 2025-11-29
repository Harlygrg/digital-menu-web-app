import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/home_provider.dart';
import '../../../theme/theme.dart';
import '../../../models/item_model.dart';
import '../../../utils/image_utils.dart';

/// Popup widget to display product description
class ProductDescriptionPopup extends StatelessWidget {
  final ItemModel item;

  const ProductDescriptionPopup({
    super.key,
    required this.item,
  });

  /// Show the popup
  static void show({
    required BuildContext context,
    required ItemModel item,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ProductDescriptionPopup(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        final description = item.getDescription(provider.language);
        final productName = item.getProductName(provider.language);
        
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
                // Header with image and close button
                Container(
                  height: Responsive.padding(context, 200),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: Stack(
                    children: [
                      // Product image
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: ImageUtils.buildImageFromBase64(
                          item.image,
                          imageUrl: item.imageUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorWidget: Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            child: Icon(
                              Icons.fastfood,
                              size: Responsive.fontSize(context, 48),
                              color: Theme.of(context).colorScheme.primary,
                            ),
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
                      // Veg/Non-veg badge
                      if (item.isVegetarian || !item.isVegetarian)
                        Positioned(
                          top: Responsive.padding(context, 12),
                          left: Responsive.padding(context, 12),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Responsive.padding(context, 8),
                              vertical: Responsive.padding(context, 4),
                            ),
                            decoration: BoxDecoration(
                              color: item.isVegetarian ? AppColors.veg : AppColors.nonVeg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              item.isVegetarian
                                  ? (provider.isEnglish ? 'VEG' : 'نباتي')
                                  : (provider.isEnglish ? 'NON-VEG' : 'غير نباتي'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: Responsive.fontSize(context, 12),
                                fontWeight: FontWeight.bold,
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
                        // Product name
                        Text(
                          productName,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: Responsive.padding(context, 8)),
                        // Price and Preparation Time
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.priceRange,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            if (item.preparationtime.isNotEmpty)
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: Responsive.fontSize(context, 18),
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                  SizedBox(width: Responsive.padding(context, 4)),
                                  Text(
                                    item.preparationtime,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        SizedBox(height: Responsive.padding(context, 16)),
                        // Description
                        if (description.isNotEmpty) ...[
                          Text(
                            provider.isEnglish ? 'Description' : 'الوصف',
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
                                SizedBox(height: Responsive.padding(context, 8)),
                                Text(
                                  provider.isEnglish 
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
                              provider.isEnglish ? 'Close' : 'إغلاق',
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




