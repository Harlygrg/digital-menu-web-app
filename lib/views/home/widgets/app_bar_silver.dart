import 'package:digital_menu_order/views/home/widgets/branch_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/home_provider.dart';
import '../../../controllers/home_controller.dart';
import '../../../config/app_config.dart';
import '../../../theme/theme.dart';
import '../../../widgets/restaurant_logo.dart';
import 'language_dropdown.dart';

/// Silver app bar with logo, title, and language dropdown
/// Note: Cart button has been moved to a Floating Action Button in home_screen.dart
class AppBarSilver extends StatelessWidget implements PreferredSizeWidget {
  const AppBarSilver({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      leadingWidth: Responsive.isDesktop(context) ? null : 280,
      leading: Responsive.isDesktop(context)
          ? null // Hide default leading for desktop
          : Padding(
              padding: EdgeInsetsDirectional.only(
                start: Responsive.padding(context, 8),
              ),
              child: Row(
                children: [
                  const RestaurantLogo(),
                  SizedBox(width: Responsive.padding(context, 8)),
                  const Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: BranchDropdownWidget(),
                    ),
                  ),
                ],
              ),
            ),
      actions: Responsive.isDesktop(context)
          ? null // Hide default actions for desktop
          : [
              if (AppConfig.multiLanguage)
                Consumer<HomeProvider>(
                  builder: (context, provider, child) {
                    return LanguageDropdownWidget(
                      controller: HomeController(provider),
                    );
                  },
                ),
              // Cart button moved to Floating Action Button in home_screen.dart
              SizedBox(width: Responsive.padding(context, 16)),
            ],
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.onPrimary,
              Theme.of(context).colorScheme.onPrimary,
            ],
          ),
        ),
        child: Responsive.isDesktop(context)
            ? Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: Responsive.maxContentWidth(context),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: Responsive.padding(context, 16),
                        ),
                        child: const RestaurantLogo(),
                      ),
                      const Spacer(),
                      // Language dropdown (cart button moved to FAB in home_screen.dart)
                      if (AppConfig.multiLanguage)
                        Consumer<HomeProvider>(
                          builder: (context, provider, child) {
                            return LanguageDropdownWidget(
                              controller: HomeController(provider),
                            );
                          },
                        ),
                      SizedBox(width: Responsive.padding(context, 16)),
                    ],
                  ),
                ),
              )
            : null,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
