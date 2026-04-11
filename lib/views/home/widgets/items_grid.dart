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

/// Grid view widget for displaying items in a grid layout
class ItemsGridWidget extends StatelessWidget {
  final HomeController controller;

  const ItemsGridWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        final items = provider.filteredItems;
        final columns = Responsive.gridColumns(context);
        final language = provider.language;

        // Show shimmer only while active loading is in progress.
        if (provider.isLoading) {
          return const SliverToBoxAdapter(child: ItemsGridShimmerWidget());
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
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    SizedBox(height: Responsive.padding(context, 16)),
                    Text(
                      provider.isEnglish
                          ? 'No items found'
                          : 'لم يتم العثور على أطباق',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 16),
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
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
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              childAspectRatio: Responsive.isDesktop(context) ? 0.8 : 0.9,
              crossAxisSpacing: Responsive.padding(context, 8),
              mainAxisSpacing: Responsive.padding(context, 8),
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = items[index];
                return _ItemCard(
                  key: ValueKey(item.id),
                  item: item,
                  controller: controller,
                  language: language,
                  getModifiers: provider.getModifiersForProduct,
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

/// Individual item card for grid view
class _ItemCard extends StatelessWidget {
  final ItemModel item;
  final HomeController controller;
  final String language;
  final List<ModifierModel> Function(int) getModifiers;

  const _ItemCard({
    super.key,
    required this.item,
    required this.controller,
    required this.language,
    required this.getModifiers,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = item.imageUrl?.isNotEmpty == true || item.image.isNotEmpty;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: hasImage
                  ? ImageUtils.buildImageFromBase64(
                      item.image,
                      imageUrl: item.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: const _GridItemPlaceholder(),
                      errorWidget: const _GridItemPlaceholder(),
                    )
                  : const _GridItemPlaceholder(),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(Responsive.padding(context, 10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.getProductName(language),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.black,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ItemInfoButton(
                          onTap: () {
                            ProductDescriptionPopup.show(
                              context: context,
                              item: item,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            formatCurrencyAmount(item.lowestPrice),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          height: 25,
                          child: AddItemButton(
                            onTap: () {
                              showAddToCartPopup(
                                context: context,
                                item: item,
                                sizes: item.unitPriceList,
                                addons: getModifiers(item.id),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridItemPlaceholder extends StatelessWidget {
  const _GridItemPlaceholder();

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
