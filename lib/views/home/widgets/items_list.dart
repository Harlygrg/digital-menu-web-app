import 'package:digital_menu_order/views/home/widgets/add_item_button.dart';
import 'package:digital_menu_order/views/home/widgets/add_to_cart_popup.dart';
import 'package:digital_menu_order/views/home/widgets/item_info_button.dart';
import 'package:digital_menu_order/views/home/widgets/product_description_popup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/home_provider.dart';
import '../../../controllers/home_controller.dart';
import '../../../theme/theme.dart';
import '../../../models/item_model.dart';
import '../../../models/option_models.dart';
import '../../../utils/image_utils.dart';
import '../../../widgets/home_shimmer_widget.dart';

/// List view widget for displaying items in a list layout
class ItemsListWidget extends StatelessWidget {
  final HomeController controller;

  const ItemsListWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        final items = provider.filteredItems;
        final language = provider.language;
        
        // Show shimmer when loading OR when data has never been loaded
        if (provider.isLoading || !provider.hasEverLoadedData) {
          return const SliverToBoxAdapter(
            child: ItemsListShimmerWidget(),
          );
        }
        
        // Show empty state only when not loading, data has been loaded, and no items
        if (items.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(Responsive.padding(context, 32)),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off,
                      size: Responsive.fontSize(context, 48),
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                    ),
                    SizedBox(height: Responsive.padding(context, 16)),
                    Text(
                      provider.isEnglish
                          ? 'No items found'
                          : 'لم يتم العثور على أطباق',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 16),
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.padding(context, 16),
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = items[index];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: Responsive.padding(context, 12),
                  ),
                  // Use RepaintBoundary to isolate each card's repaints
                  child: RepaintBoundary(
                    child: _ListItemCard(
                      key: ValueKey(item.id),
                      item: item,
                      controller: controller,
                      language: language,
                      getModifiers: provider.getModifiersForProduct,
                    ),
                  ),
                );
              },
              childCount: items.length,
              // Optimizations for better scroll performance
              findChildIndexCallback: (Key key) {
                if (key is ValueKey<int>) {
                  final index = items.indexWhere((item) => item.id == key.value);
                  return index >= 0 ? index : null;
                }
                return null;
              },
            ),
          ),
        );
      },
    );
  }
}

/// Individual item card for list view
class _ListItemCard extends StatelessWidget {
  final ItemModel item;
  final HomeController controller;
  final String language;
  final List<ModifierModel> Function(int) getModifiers;

  const _ListItemCard({
    super.key,
    required this.item,
    required this.controller,
    required this.language,
    required this.getModifiers,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate optimal cache dimensions for list item images
    final imageSize = Responsive.padding(context, 80);
    final cacheSize = (imageSize * MediaQuery.of(context).devicePixelRatio).toInt();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(Responsive.padding(context, 12)),
        child: Row(
          children: [
            // Image with optimized caching
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ImageUtils.buildImageFromBase64(
                item.image,
                imageUrl: item.imageUrl,
                width: Responsive.padding(context, 80),
                height: Responsive.padding(context, 80),
                fit: BoxFit.cover,
                cacheWidth: cacheSize,
                cacheHeight: cacheSize,
                placeholder: Container(
                  width: Responsive.padding(context, 80),
                  height: Responsive.padding(context, 80),
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  child: Center(
                    child: Icon(
                      Icons.fastfood,
                      size: Responsive.fontSize(context, 24),
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                ),
                errorWidget: Container(
                  width: Responsive.padding(context, 80),
                  height: Responsive.padding(context, 80),
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.fastfood,
                    size: Responsive.fontSize(context, 32),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            SizedBox(width: Responsive.padding(context, 12)),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and info button
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.getProductName(language),
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, 16),
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: Responsive.padding(context, 8)),
                      ItemInfoButton(
                        buttonSize: 18,
                        onTap: () {
                          ProductDescriptionPopup.show(
                            context: context,
                            item: item,
                          );
                        },
                      )
                    ],
                  ),
                  SizedBox(height: Responsive.padding(context, 4)),
                  // Price and add button row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Text(
                        'QR ${item.lowestPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 16),
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      AddItemButton(
                        isListItem: true,
                        onTap: () {
                          showAddToCartPopup(
                            context: context,
                            item: item,
                            sizes: item.unitPriceList,
                            addons: getModifiers(item.id),
                          );
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: Responsive.padding(context, 8)),
          ],
        ),
      ),
    );
  }
}
