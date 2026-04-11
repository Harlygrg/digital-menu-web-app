import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../localization/app_strings.dart';
import '../../../providers/home_provider.dart';
import '../../../controllers/home_controller.dart';
import '../../../theme/theme.dart';

/// Search bar widget with debounced search functionality.
class SearchBarWidget extends StatefulWidget {
  final HomeController controller;
  final TextEditingController searchFieldController;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.searchFieldController,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withValues(
                      alpha: 0.1,
                    ),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: widget.searchFieldController,
            builder: (context, value, _) {
              return TextField(
                controller: widget.searchFieldController,
                onChanged: (v) {
                  widget.controller.updateSearchQuery(v);
                },
                decoration: InputDecoration(
                  hintText: AppStrings.searchHint(provider.isEnglish),
                  hintStyle: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                    fontSize: Responsive.fontSize(context, 14),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.primary,
                    size: Responsive.fontSize(context, 20),
                  ),
                  suffixIcon: value.text.isNotEmpty
                      ? IconButton(
                          tooltip: AppStrings.clearSearchTooltip(
                            provider.isEnglish,
                          ),
                          onPressed: () {
                            widget.searchFieldController.clear();
                            widget.controller.clearSearchQuery();
                          },
                          icon: Icon(
                            Icons.clear,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5),
                            size: Responsive.fontSize(context, 18),
                          ),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: Responsive.padding(context, 16),
                    vertical: Responsive.padding(context, 12),
                  ),
                ),
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 14),
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
