import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../localization/app_strings.dart';
import '../../providers/language_provider.dart';
import '../../routes/routes.dart';
import '../../theme/theme.dart';

/// Full-screen route for unknown named routes.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  void _goHome(BuildContext context) {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
  }

  void _backOrHome(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      _goHome(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, lang, _) {
        final isEnglish = lang.isEnglish;
        return Scaffold(
          appBar: AppBar(title: Text(AppStrings.pageNotFoundTitle(isEnglish))),
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(Responsive.padding(context, 24)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.travel_explore_outlined,
                    size: Responsive.fontSize(context, 64),
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.7),
                  ),
                  SizedBox(height: Responsive.padding(context, 16)),
                  Text(
                    AppStrings.pageNotFoundTitle(isEnglish),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: Responsive.padding(context, 8)),
                  Text(
                    AppStrings.pageNotFoundBody(isEnglish),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: Responsive.padding(context, 32)),
                  FilledButton(
                    onPressed: () => _backOrHome(context),
                    child: Text(AppStrings.backToMenu(isEnglish)),
                  ),
                  SizedBox(height: Responsive.padding(context, 12)),
                  TextButton(
                    onPressed: () => _goHome(context),
                    child: Text(AppStrings.goHome(isEnglish)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
