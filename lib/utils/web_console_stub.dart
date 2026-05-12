import 'package:flutter/foundation.dart';

/// Non-web fallback: only prints in debug mode.
class WebConsole {
  static void log(String message) {
    if (kDebugMode) debugPrint(message);
  }

  static void info(String message) {
    if (kDebugMode) debugPrint(message);
  }

  static void debug(String message) {
    if (kDebugMode) debugPrint(message);
  }

  static void warn(String message) {
    if (kDebugMode) debugPrint(message);
  }

  static void error(String message) {
    if (kDebugMode) debugPrint(message);
  }
}

