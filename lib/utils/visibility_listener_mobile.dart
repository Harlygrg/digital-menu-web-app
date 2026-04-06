// Mobile/default implementation of visibility listener
// For mobile platforms, we don't need visibility change detection
// as the app lifecycle handles this automatically

import 'package:flutter/foundation.dart';
import 'package:digital_menu_order/utils/app_debug_log.dart';

/// Setup visibility change listener for mobile platforms
/// This is a no-op on mobile as app lifecycle handles visibility
void setupVisibilityChangeListener(Function() onVisible) {
  if (kDebugMode) {
    appDebugLog(
      '👁️ Visibility listener not needed on mobile (using app lifecycle)',
    );
  }
  // No-op for mobile - the app lifecycle already handles this
}
