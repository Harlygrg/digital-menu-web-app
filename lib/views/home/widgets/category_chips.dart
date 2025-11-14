import 'package:digital_menu_order/utils/capitalize_first_letter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/home_provider.dart';
import '../../../controllers/home_controller.dart';
import '../../../theme/theme.dart';
import '../../../utils/scroll_behavior_utils.dart';
import '../../../utils/category_icon_helper.dart';

/// Category chips widget for filtering items by category
class CategoryChipsWidget extends StatelessWidget {
  final HomeController controller;

  const CategoryChipsWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        return EnhancedHorizontalScrollable(
          height: Responsive.padding(context, 80), // Increased height for cards with images
          itemCount: provider.categories.length + 1, // +1 for "All Categories" chip
          itemBuilder: (context, index) {
            // Check if this is the "All Categories" chip (first item)
            if (index == 0) {
              final isAllSelected = provider.selectedCategoryId == 0;
              
              return Padding(
                padding: EdgeInsets.only(
                  right: Responsive.padding(context, 12),
                ),
                child: _AllCategoriesCard(
                  isSelected: isAllSelected,
                  isEnglish: provider.isEnglish,
                  onTap: () => controller.clearCategorySelection(),
                ),
              );
            }
            
            // Regular category chips (adjusted index by -1)
            final category = provider.categories[index - 1];
            final isSelected = category.id == provider.selectedCategoryId;
            
            return Padding(
              padding: EdgeInsets.only(
                right: Responsive.padding(context, 12),
              ),
              child: _CategoryCard(
                category: category,
                isSelected: isSelected,
                isEnglish: provider.isEnglish,
                onTap: () {
                  if (isSelected) {
                    controller.clearCategorySelection();
                  } else {
                    controller.selectCategory(category.id);
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}

/// Custom category card widget that matches the design
class _CategoryCard extends StatelessWidget {
  final dynamic category; // Using dynamic to work with CategoryModel
  final bool isSelected;
  final bool isEnglish;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.isSelected,
    required this.isEnglish,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: Responsive.padding(context, 100),
        margin: EdgeInsets.only(bottom: 5),// Fixed width for cards
        decoration: BoxDecoration(
          color: isSelected ?  AppColors.primaryLight :  Color(0xffF5F5F9), // Light blue for selected
          borderRadius: BorderRadius.circular(Responsive.padding(context, 15)),
          // border: Border.all(
          //   color: isSelected ? const Color(0xFF1976D2) : Colors.grey.shade300,
          //   width: 1,
          // ),
          boxShadow: [
            if(isSelected)
            BoxShadow(
              color: AppColors.primary,
              blurRadius: 3,
              spreadRadius: -1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category image/icon
            SizedBox(
              width: Responsive.padding(context, 30),
              height: Responsive.padding(context, 30),
              child: CategoryIconHelper.getCategoryIcon(
                isEnglish ? category.category : (category.inOl.isNotEmpty ? category.inOl : category.category), 
                context
              ),
            ),
            SizedBox(height: 5,),
            // Category name
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.padding(context, 4)),
              child: Text(
                isEnglish ? category.category.toString().toLowerCase().capitalizeFirst() : (category.inOl.isNotEmpty ? category.inOl : category.category),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isSelected ? const Color(0xFF1976D2) : Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

}

/// "All Categories" card widget
class _AllCategoriesCard extends StatelessWidget {
  final bool isSelected;
  final bool isEnglish;
  final VoidCallback onTap;

  const _AllCategoriesCard({
    required this.isSelected,
    required this.isEnglish,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: Responsive.padding(context, 100),
        margin: EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Color(0xffF5F5F9),
          borderRadius: BorderRadius.circular(Responsive.padding(context, 15)),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary,
                blurRadius: 3,
                spreadRadius: -1,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // All categories icon
            SizedBox(
              width: Responsive.padding(context, 30),
              height: Responsive.padding(context, 30),
              child: Icon(
                Icons.apps,
                size: Responsive.padding(context, 24),
                color: isSelected ? AppColors.primary : Colors.grey[600],
              ),
            ),
            SizedBox(height: 5),
            // All categories text
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.padding(context, 4)),
              child: Text(
                isEnglish ? 'All' : 'الكل',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isSelected ? const Color(0xFF1976D2) : Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
