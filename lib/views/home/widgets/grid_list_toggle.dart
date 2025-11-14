import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/home_provider.dart';
import '../../../controllers/home_controller.dart';
import '../../../theme/theme.dart';

/// Grid/List toggle widget for switching between grid and list view
class GridListToggleWidget extends StatelessWidget {
  final HomeController controller;

  const GridListToggleWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grid view button
              _buildToggleButton(
                context,
                icon: Icons.grid_view,
                isSelected: provider.isGridView,
                onTap: () => controller.setGridView(true),
              ),
              // Divider
              Container(
                height: Responsive.padding(context, 24),
                width: 1,
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
              // List view button
              _buildToggleButton(
                context,
                icon: Icons.list,
                isSelected: !provider.isGridView,
                onTap: () => controller.setGridView(false),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build individual toggle button
  Widget _buildToggleButton(
    BuildContext context, {
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(Responsive.padding(context, 8)),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          size: Responsive.fontSize(context, 20),
        ),
      ),
    );
  }
}
