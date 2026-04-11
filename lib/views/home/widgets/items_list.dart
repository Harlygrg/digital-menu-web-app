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
import '../../../utils/currency_format.dart';
import '../../../utils/image_utils.dart';
import '../../../widgets/home_shimmer_widget.dart';
import '../../../widgets/menu_empty_state.dart';

/// List view widget for displaying items in a list layout
class ItemsListWidget extends StatelessWidget {
  final HomeController controller;
  final VoidCallback onClearSearch;
  final VoidCallback onShowAllCategories;

  const ItemsListWidget({
    super.key,
    required this.controller,
    required this.onClearSearch,
    required this.onShowAllCategories,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        final items = provider.filteredItems;
        final language = provider.language;

        // Show shimmer only while active loading is in progress.
        if (provider.isLoading) {
          return const SliverToBoxAdapter(child: ItemsListShimmerWidget());
        }

        // Show empty state only when not loading, data has been loaded, and no items
        if (items.isEmpty) {
          final hasSearch = provider.searchQuery.isNotEmpty;
          final hasCategory = provider.selectedCategoryId != 0;
          return SliverToBoxAdapter(
            child: MenuEmptyState(
              isEnglish: provider.isEnglish,
              showClearSearch: hasSearch,
              showShowAllCategories: hasCategory,
              onClearSearch: hasSearch ? onClearSearch : null,
              onShowAllCategories: hasCategory ? onShowAllCategories : null,
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
                  child: _ListItemCard(
                    key: ValueKey(item.id),
                    item: item,
                    controller: controller,
                    language: language,
                    getModifiers: provider.getModifiersForProduct,
                  ),
                );
              },
              childCount: items.length,
              // Optimizations for better scroll performance
              findChildIndexCallback: (Key key) {
                if (key is ValueKey<int>) {
                  final index = items.indexWhere(
                    (item) => item.id == key.value,
                  );
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
    final imageSize = Responsive.padding(context, 80);
    final hasImage = item.imageUrl?.isNotEmpty == true || item.image.isNotEmpty;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(Responsive.padding(context, 12)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: imageSize,
                height: imageSize,
                child: hasImage
                    ? ImageUtils.buildImageFromBase64(
                        item.image,
                        imageUrl: item.imageUrl,
                        width: imageSize,
                        height: imageSize,
                        fit: BoxFit.cover,
                        placeholder: const _ListItemPlaceholder(),
                        errorWidget: const _ListItemPlaceholder(),
                      )
                    : const _ListItemPlaceholder(),
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
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.padding(context, 4)),
                  // Price and add button row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatCurrencyAmount(item.lowestPrice),
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
                      ),
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

class _ListItemPlaceholder extends StatelessWidget {
  const _ListItemPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
      child: Center(
        child: Icon(
          Icons.fastfood,
          size: Responsive.fontSize(context, 28),
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}
