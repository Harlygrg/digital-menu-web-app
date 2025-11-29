import 'package:digital_menu_order/utils/capitalize_first_letter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../providers/branch_provider.dart';
import '../../../providers/home_provider.dart';
import '../../../controllers/cart_controller.dart';
import '../../../theme/theme.dart';

/// Branch dropdown widget with styling matching the cart button
/// 
/// Displays:
/// - Branch name text only when a saved branch is matched
/// - Compact dropdown when no branch is selected
class BranchDropdownWidget extends StatelessWidget {
  const BranchDropdownWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<BranchProvider, HomeProvider>(
      builder: (context, branchProvider, homeProvider, child) {
        // Show shimmer while loading or not yet initialized
        if (branchProvider.isLoading || !branchProvider.isInitialized) {
          return Row(
            children: [
              _buildShimmerLoading(context),
            ],
          );
        }

        // Show error or empty state (after initialization)
        if (branchProvider.branches.isEmpty) {
          return const SizedBox.shrink();
        }

        final selectedBranch = branchProvider.selectedBranch;
        final hasBranchSelected = branchProvider.hasBranchSelected;

        // If branch is already selected (matched with saved ID), show only the name
        if (hasBranchSelected && selectedBranch != null) {
// debugPrint('🏪 Showing branch name: ${selectedBranch.cname}');
          return _buildBranchNameDisplay(context, selectedBranch.cname);
        }

        // Otherwise show the dropdown for selection
// debugPrint('📋 Showing branch dropdown (no branch selected)');
        return _buildBranchDropdown(context, branchProvider, homeProvider);
      },
    );
  }

  /// Build branch name display (no dropdown functionality)
  Widget _buildBranchNameDisplay(BuildContext context, String branchName) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.store,
          color: Theme.of(context).colorScheme.primary,
          size: Responsive.fontSize(context, 20),
        ),
        SizedBox(width: Responsive.padding(context, 8)),
        Text(
          branchName.toLowerCase().capitalizeFirst(),
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  /// Build branch dropdown (with selection functionality)
  Widget _buildBranchDropdown(
    BuildContext context,
    BranchProvider branchProvider,
    HomeProvider homeProvider,
  ) {
    final displayText = homeProvider.isEnglish ? 'Select Branch' : 'اختر الفرع';

    return InkWell(
      onTap: () => _showBranchSelectionDialog(context, branchProvider, homeProvider),
      child: Container(
        height: Responsive.padding(context, 36),
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.padding(context, 12),
          vertical: Responsive.padding(context, 5),
        ),
        constraints: BoxConstraints(
          minWidth: Responsive.padding(context, 120),
          maxWidth: Responsive.padding(context, 180),
        ),
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          color: Theme.of(context).colorScheme.tertiary,
          shape: const StadiumBorder(),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.store,
              color: Theme.of(context).colorScheme.onPrimary,
              size: Responsive.fontSize(context, 20),
            ),
            SizedBox(width: Responsive.padding(context, 8)),
            Flexible(
              child: Text(
                displayText,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            SizedBox(width: Responsive.padding(context, 4)),
            Icon(
              Icons.arrow_drop_down,
              color: Theme.of(context).colorScheme.onPrimary,
              size: Responsive.fontSize(context, 20),
            ),
          ],
        ),
      ),
    );
  }

  /// Build shimmer loading effect
  Widget _buildShimmerLoading(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: Responsive.padding(context, 28),
        width: Responsive.padding(context, 120),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: const StadiumBorder(),
        ),
      ),
    );
  }

  /// Show branch selection dialog
  void _showBranchSelectionDialog(
    BuildContext context,
    BranchProvider branchProvider,
    HomeProvider homeProvider,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            homeProvider.isEnglish ? 'Select Branch' : 'اختر الفرع',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 18),
              fontWeight: FontWeight.bold,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: Responsive.padding(context, 12),
          ),
          content: SizedBox(
            width: Responsive.padding(context, 300),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: branchProvider.branches.length,
              itemBuilder: (context, index) {
                final branch = branchProvider.branches[index];
                final isSelected = branchProvider.selectedBranch?.id == branch.id;

                return ListTile(
                  leading: Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    branch.cname,
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 16),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected 
                        ? Theme.of(context).colorScheme.primary 
                        : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  onTap: () async {
                    Navigator.of(dialogContext).pop();
                    await _handleBranchSelection(context, branchProvider, branch, homeProvider);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                homeProvider.isEnglish ? 'Cancel' : 'إلغاء',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 14),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Handle branch selection with warning dialog if needed
  Future<void> _handleBranchSelection(
    BuildContext context,
    BranchProvider branchProvider,
    branch,
    HomeProvider homeProvider,
  ) async {
    final cartController = Provider.of<CartController>(context, listen: false);
    final savedBranchId = branchProvider.selectedBranchId;

    // If there's an existing branch selection and it's different
    if (savedBranchId != null && savedBranchId != branch.id.toString()) {
      // Check if cart has items
      if (cartController.isNotEmpty) {
        // Show warning dialog
        final shouldContinue = await _showWarningDialog(context, homeProvider);
        
        if (shouldContinue != true) {
          // User cancelled, don't change branch
          return;
        }
      }
    }

    // Select the branch (this will clear cart if needed)
    await branchProvider.selectBranch(
      branch,
      clearCart: () async {
        await cartController.clearCart();
      },
    );

    // Show success message
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            homeProvider.isEnglish 
              ? 'Branch changed to ${branch.cname}' 
              : 'تم تغيير الفرع إلى ${branch.cname}',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 14),
            ),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  /// Show warning dialog when changing branch with items in cart
  Future<bool?> _showWarningDialog(BuildContext context, HomeProvider homeProvider) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            homeProvider.isEnglish ? 'Warning' : 'تحذير',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          content: Text(
            homeProvider.isEnglish
              ? 'Changing the branch will remove all items from the cart. Do you want to continue?'
              : 'سيؤدي تغيير الفرع إلى إزالة جميع العناصر من السلة. هل تريد المتابعة؟',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 14),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                homeProvider.isEnglish ? 'Cancel' : 'إلغاء',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 14),
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(
                homeProvider.isEnglish ? 'Continue' : 'متابعة',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 14),
                  color: Theme.of(context).colorScheme.onError,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

