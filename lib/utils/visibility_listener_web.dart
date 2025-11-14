// Web-specific implementation of visibility listener
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

/// Setup visibility change listener for web platform
/// Calls [onVisible] callback when the tab becomes visible
void setupVisibilityChangeListener(Function() onVisible) {
  if (kDebugMode) {
    print('👁️ Setting up web visibility listener');
  }

  html.document.onVisibilityChange.listen((html.Event event) {
    final isVisible = !html.document.hidden!;
    
    if (kDebugMode) {
      print('👁️ Tab visibility changed: ${isVisible ? "visible" : "hidden"}');
    }

    if (isVisible) {
      // Tab became visible, trigger callback
      if (kDebugMode) {
        print('🔄 Tab visible, triggering callback...');
      }
      onVisible();
    }
  });
}

