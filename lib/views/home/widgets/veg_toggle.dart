import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/home_provider.dart';
import '../../../controllers/home_controller.dart';
import '../../../theme/theme.dart';

/// Veg/Non-veg toggle widget for filtering items
class VegToggleWidget extends StatelessWidget {
  final HomeController controller;

  const VegToggleWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        return Row(
          children: [
            // Veg button
            _buildToggleButton(
              context,
              label: provider.isEnglish ? 'Veg' : 'نباتي',
              isSelected: provider.isVegFilter == true,
              onTap: () => controller.toggleVegOnly(),
              icon: Icons.eco,
              color: AppColors.veg,
            ),
            SizedBox(width: Responsive.padding(context, 8)),
            // Non-veg button
            _buildToggleButton(
              context,
              label: provider.isEnglish ? 'Non-Veg' : 'غير نباتي',
              isSelected: provider.isVegFilter == false,
              onTap: () => controller.toggleNonVegOnly(),
              icon: Icons.restaurant,
              color: AppColors.nonVeg,
            ),
          ],
        );
      },
    );
  }

  /// Build individual toggle button
  Widget _buildToggleButton(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        constraints: BoxConstraints(minWidth: 100),
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          vertical: Responsive.padding(context, 12),
          horizontal: Responsive.padding(context, 16),
        ),
        decoration: ShapeDecoration(
          shadows:isSelected
              ? [
            BoxShadow(
              color: AppColors.primary,
              blurRadius: 3,
              spreadRadius: -1,
              offset: const Offset(0, 2),
            ),
          ]
              : null ,
          shape: StadiumBorder(
          ),
          color:  isSelected ?  AppColors.primaryLight :  Color(0xffF5F5F9), // Light blue for selected,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? color
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              size: Responsive.fontSize(context, 18),
            ),
            SizedBox(width: Responsive.padding(context, 8)),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
