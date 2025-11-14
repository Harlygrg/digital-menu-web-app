import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/home_provider.dart';
import '../../../controllers/home_controller.dart';
import '../../../theme/theme.dart';

/// Search bar widget with debounced search functionality
class SearchBarWidget extends StatefulWidget {
  final HomeController controller;

  const SearchBarWidget({
    super.key,
    required this.controller,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

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
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _textController,
            onChanged: (value) {
              widget.controller.updateSearchQuery(value);
            },
            decoration: InputDecoration(
              hintText: provider.isEnglish
                  ? 'Search for dishes...'
                  : 'ابحث عن الأطباق...',
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontSize: Responsive.fontSize(context, 14),
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.primary,
                size: Responsive.fontSize(context, 20),
              ),
              suffixIcon: _textController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _textController.clear();
                        widget.controller.updateSearchQuery('');
                      },
                      icon: Icon(
                        Icons.clear,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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
          ),
        );
      },
    );
  }
}
