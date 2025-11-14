import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/home_provider.dart';
import '../../../controllers/home_controller.dart';
import '../../../theme/theme.dart';

/// Language dropdown widget for switching between English and Arabic
class LanguageDropdownWidget extends StatelessWidget {
  final HomeController controller;

  const LanguageDropdownWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        return Container(
          height: MediaQuery.of(context).size.width > 1200 ? 35 : 30,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(
            horizontal: 8,
          ),
          decoration: ShapeDecoration(
            shape: StadiumBorder(
              side: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3), width: 1.5),
            ),
            color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.2),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: provider.language,
              icon: const SizedBox.shrink(),
              focusColor: Colors.transparent,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w500,
              ),
              dropdownColor: Theme.of(context).colorScheme.surface,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  controller.setLanguage(newValue);
                }
              },
              items: <String>['en', 'ar'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        value == 'en' ? 'English' : 'عربي',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: value == provider.language
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: Responsive.padding(context, 4)),
                      Icon(
                        value == 'en' ? Icons.language : Icons.translate,
                        size: Responsive.fontSize(context, 16),
                        color: value == provider.language
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
