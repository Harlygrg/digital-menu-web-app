import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/theme.dart';

/// Shimmer loading widget for home screen items
/// 
/// This widget provides shimmer loading effects for:
/// - Grid view items
/// - List view items
/// - Loading states
class HomeShimmerWidget extends StatelessWidget {
  final bool isGridView;
  
  const HomeShimmerWidget({
    super.key,
    required this.isGridView,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
      highlightColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
      child: isGridView ? _buildGridShimmer(context) : _buildListShimmer(context),
    );
  }

  /// Build shimmer for grid view
  Widget _buildGridShimmer(BuildContext context) {
    final columns = Responsive.gridColumns(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.padding(context, 16),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          childAspectRatio: Responsive.isDesktop(context) ? 1.1 : 1.2,
          crossAxisSpacing: Responsive.padding(context, 8),
          mainAxisSpacing: Responsive.padding(context, 8),
        ),
        itemCount: 12, // Show 12 shimmer items
        itemBuilder: (context, index) => _buildGridItemShimmer(context),
      ),
    );
  }

  /// Build shimmer for list view
  Widget _buildListShimmer(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.padding(context, 16),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 8, // Show 8 shimmer items
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.only(
            bottom: Responsive.padding(context, 12),
          ),
          child: _buildListItemShimmer(context),
        ),
      ),
    );
  }

  /// Build shimmer for individual grid item
  Widget _buildGridItemShimmer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image shimmer
          Expanded(
            flex: 3,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
            ),
          ),
          // Content shimmer
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(Responsive.padding(context, 4)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title shimmer
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: Responsive.fontSize(context, 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        SizedBox(width: Responsive.padding(context, 4)),
                        Container(
                          width: Responsive.padding(context, 20),
                          height: Responsive.padding(context, 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2),
                  // Price and button shimmer
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: Responsive.fontSize(context, 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        SizedBox(width: Responsive.padding(context, 4)),
                        Container(
                          width: Responsive.padding(context, 24),
                          height: Responsive.padding(context, 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
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

  /// Build shimmer for individual list item
  Widget _buildListItemShimmer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(Responsive.padding(context, 12)),
        child: Row(
          children: [
            // Image shimmer
            Container(
              width: Responsive.padding(context, 80),
              height: Responsive.padding(context, 80),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(width: Responsive.padding(context, 12)),
            // Content shimmer
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and info button shimmer
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: Responsive.fontSize(context, 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      SizedBox(width: Responsive.padding(context, 8)),
                      Container(
                        width: Responsive.padding(context, 18),
                        height: Responsive.padding(context, 18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.padding(context, 4)),
                  // Price and add button shimmer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: Responsive.padding(context, 80),
                        height: Responsive.fontSize(context, 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        width: Responsive.padding(context, 24),
                        height: Responsive.padding(context, 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer loading widget for grid view only
class ItemsGridShimmerWidget extends StatelessWidget {
  const ItemsGridShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeShimmerWidget(isGridView: true);
  }
}

/// Shimmer loading widget for list view only
class ItemsListShimmerWidget extends StatelessWidget {
  const ItemsListShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeShimmerWidget(isGridView: false);
  }
}
