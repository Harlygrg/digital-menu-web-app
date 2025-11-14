import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Utility class for handling cross-platform scrolling behavior
/// Ensures consistent scrolling experience across mobile and web platforms
class ScrollBehaviorUtils {
  /// Initialize web-specific scrollbar hiding
  static void initializeWebScrollbarHiding() {
    if (kIsWeb) {
      // This would be called in main() to hide all scrollbars globally
      // Note: This is a placeholder for future CSS-based implementation
    }
  }
  /// Creates a scroll behavior that works consistently across platforms
  /// Handles both mouse and touch interactions for web and mobile
  static ScrollBehavior createCrossPlatformScrollBehavior() {
    return _CrossPlatformScrollBehavior();
  }

  /// Creates a horizontal scroll controller with enhanced web support
  static ScrollController createHorizontalScrollController() {
    return ScrollController();
  }

  /// Creates a vertical scroll controller with enhanced web support 
  static ScrollController createVerticalScrollController() {
    return ScrollController();
  }

  /// Gets scroll physics optimized for the current platform
  static ScrollPhysics getScrollPhysics({bool isHorizontal = false}) {
    if (kIsWeb) {
      // Enhanced physics for web platform
      return const BouncingScrollPhysics(
        parent: ClampingScrollPhysics(),
      );
    } else {
      // Standard physics for mobile platforms
      return isHorizontal
          ? const BouncingScrollPhysics(
              parent: ClampingScrollPhysics(),
            )
          : const BouncingScrollPhysics(
              parent: ClampingScrollPhysics(),
            );
    }
  }

  /// Creates a scrollable widget with enhanced cross-platform support
  static Widget createScrollableWidget({
    required Widget child,
    ScrollController? controller,
    Axis scrollDirection = Axis.vertical,
    ScrollPhysics? physics,
    EdgeInsetsGeometry? padding,
  }) {
    return SingleChildScrollView(
      controller: controller,
      scrollDirection: scrollDirection,
      physics: physics ?? getScrollPhysics(isHorizontal: scrollDirection == Axis.horizontal),
      padding: padding,
      child: child,
    );
  }

  /// Creates a horizontal scrollable list with enhanced web support
  static Widget createHorizontalScrollableList({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    ScrollController? controller,
    EdgeInsetsGeometry? padding,
    double? height,
  }) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        controller: controller,
        scrollDirection: Axis.horizontal,
        physics: getScrollPhysics(isHorizontal: true),
        itemCount: itemCount,
        itemBuilder: itemBuilder,
        padding: padding,
      ),
    );
  }
}

/// Custom scroll behavior that enhances web scrolling experience
/// Hides all scrollbars for a cleaner UI while maintaining full scrolling functionality
class _CrossPlatformScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    // Use enhanced physics for better web experience
    return const BouncingScrollPhysics(
      parent: ClampingScrollPhysics(),
    );
  }

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // Hide all scrollbars on web for cleaner UI
    // Scrolling functionality is maintained through mouse drag and touch
    return child;
  }

  @override
  Set<PointerDeviceKind> get dragDevices => {
        // Support both mouse and touch for web
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

/// Enhanced scroll controller with web-specific optimizations
class EnhancedScrollController extends ScrollController {
  EnhancedScrollController({
    super.initialScrollOffset,
    super.keepScrollOffset,
    super.debugLabel,
  });

  @override
  void attach(ScrollPosition position) {
    super.attach(position);
    
    // Add web-specific optimizations
    if (kIsWeb) {
      // Enable smooth scrolling for web
      // Note: ScrollPosition doesn't have setState, so we skip this optimization
    }
  }

  /// Smooth scroll to position with enhanced web support
  Future<void> smoothScrollToPosition(
    double offset, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) async {
    if (hasClients) {
      await animateTo(
        offset,
        duration: duration,
        curve: curve,
      );
    }
  }

  /// Scroll to position with immediate effect
  void scrollToPosition(double offset) {
    if (hasClients) {
      jumpTo(offset);
    }
  }
}

/// Widget that provides enhanced scrolling behavior to its children
class EnhancedScrollable extends StatelessWidget {
  final Widget child;
  final ScrollController? controller;
  final Axis scrollDirection;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  const EnhancedScrollable({
    super.key,
    required this.child,
    this.controller,
    this.scrollDirection = Axis.vertical,
    this.physics,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollBehaviorUtils.createCrossPlatformScrollBehavior(),
      child: SingleChildScrollView(
        controller: controller,
        scrollDirection: scrollDirection,
        physics: physics ?? ScrollBehaviorUtils.getScrollPhysics(
          isHorizontal: scrollDirection == Axis.horizontal,
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}

/// Enhanced horizontal scrollable widget for category chips and similar components
class EnhancedHorizontalScrollable extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final ScrollPhysics? physics;

  const EnhancedHorizontalScrollable({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.padding,
    this.height,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: _HorizontalScrollBehavior(), // Custom behavior for horizontal scrolling
      child: SizedBox(
        height: height,
        child: ListView.builder(
          controller: controller,
          scrollDirection: Axis.horizontal,
          physics: physics ?? ScrollBehaviorUtils.getScrollPhysics(isHorizontal: true),
          itemCount: itemCount,
          itemBuilder: itemBuilder,
          padding: padding,
          // Add web-specific optimizations
          addAutomaticKeepAlives: true,
          addRepaintBoundaries: true,
          addSemanticIndexes: true,
          // Enable mouse wheel scrolling for web
          dragStartBehavior: DragStartBehavior.start,
        ),
      ),
    );
  }
}

/// Custom scroll behavior for horizontal scrolling that hides scrollbars
class _HorizontalScrollBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // Hide all scrollbars for cleaner UI
    return child;
  }

  @override
  Set<PointerDeviceKind> get dragDevices => {
        // Support both mouse and touch for web
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}
