import 'package:flutter/foundation.dart';

/// Runtime logging toggles (primarily for Flutter Web).
///
/// Defaults to `true` in debug/profile builds so developers still see logs.
/// Defaults to `false` in release builds unless enabled via `/config.json`.
class LoggingFlags {
  LoggingFlags._();

  /// When `true`, web console logs are allowed.
  static bool consoleLoggingEnabled = kDebugMode || kProfileMode;
}
