import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/theme.dart';

/// Shimmer loading widget for table screen
/// 
/// This widget provides shimmer loading effects for:
/// - Floor tabs
/// - Table grid items
/// - Loading states
class TableShimmerWidget extends StatelessWidget {
  const TableShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
      highlightColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
      child: Column(
        children: [
          // Floor tabs shimmer
          _buildFloorTabsShimmer(context),
          SizedBox(height: Responsive.padding(context, 16)),
          // Table grid shimmer
          Expanded(
            child: _buildTableGridShimmer(context),
          ),
        ],
      ),
    );
  }

  /// Build shimmer for floor tabs
  Widget _buildFloorTabsShimmer(BuildContext context) {
    return Container(
      height: Responsive.padding(context, 48),
      margin: EdgeInsets.symmetric(horizontal: Responsive.padding(context, 16)),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3, // Show 3 shimmer tabs
        itemBuilder: (context, index) {
          return Container(
            width: Responsive.padding(context, 120),
            height: Responsive.padding(context, 40),
            margin: EdgeInsets.only(right: Responsive.padding(context, 12)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  }

  /// Build shimmer for table grid
  Widget _buildTableGridShimmer(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(Responsive.padding(context, 16)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Responsive.gridColumns(context),
        crossAxisSpacing: Responsive.padding(context, 12),
        mainAxisSpacing: Responsive.padding(context, 12),
        childAspectRatio: 1.2,
      ),
      itemCount: 12, // Show 12 shimmer table cards
      itemBuilder: (context, index) {
        return _buildTableCardShimmer(context);
      },
    );
  }

  /// Build shimmer for individual table card
  Widget _buildTableCardShimmer(BuildContext context) {
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
        padding: EdgeInsets.all(Responsive.padding(context, 16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Table name shimmer
            Container(
              width: Responsive.padding(context, 80),
              height: Responsive.fontSize(context, 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: Responsive.padding(context, 8)),
            // Table ID shimmer
            Container(
              width: Responsive.padding(context, 60),
              height: Responsive.fontSize(context, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer loading widget for floor tabs only
class FloorTabsShimmerWidget extends StatelessWidget {
  const FloorTabsShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
      highlightColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
      child: Container(
        height: Responsive.padding(context, 48),
        margin: EdgeInsets.symmetric(horizontal: Responsive.padding(context, 16)),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 3, // Show 3 shimmer tabs
          itemBuilder: (context, index) {
            return Container(
              width: Responsive.padding(context, 120),
              height: Responsive.padding(context, 40),
              margin: EdgeInsets.only(right: Responsive.padding(context, 12)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Shimmer loading widget for table grid only
class TableGridShimmerWidget extends StatelessWidget {
  const TableGridShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
      highlightColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
      child: GridView.builder(
        padding: EdgeInsets.all(Responsive.padding(context, 16)),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: Responsive.gridColumns(context),
          crossAxisSpacing: Responsive.padding(context, 12),
          mainAxisSpacing: Responsive.padding(context, 12),
          childAspectRatio: 1.2,
        ),
        itemCount: 12, // Show 12 shimmer table cards
        itemBuilder: (context, index) {
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
              padding: EdgeInsets.all(Responsive.padding(context, 16)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Table name shimmer
                  Container(
                    width: Responsive.padding(context, 80),
                    height: Responsive.fontSize(context, 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: Responsive.padding(context, 8)),
                  // Table ID shimmer
                  Container(
                    width: Responsive.padding(context, 60),
                    height: Responsive.fontSize(context, 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
