import 'package:flutter/foundation.dart';

import 'web_console.dart';

/// Logs to browser console in Web release builds, and to `debugPrint` in debug.
void appDebugLog(Object? message) {
  final text = message?.toString() ?? '';
  if (kIsWeb) {
    WebConsole.log('[Log] $text');
    return;
  }
  if (kDebugMode) debugPrint(text);
}

/// Info-level log (shows as `[Info] ...` in browser console).
void appInfoLog(Object? message) {
  final text = message?.toString() ?? '';
  if (kIsWeb) {
    WebConsole.info('[Info] $text');
    return;
  }
  if (kDebugMode) debugPrint('[Info] $text');
}

/// Debug-level log (shows as `[Debug] ...` in browser console).
void appWebDebugLog(Object? message) {
  final text = message?.toString() ?? '';
  if (kIsWeb) {
    WebConsole.debug('[Debug] $text');
    return;
  }
  if (kDebugMode) debugPrint('[Debug] $text');
}

void appWarnLog(Object? message) {
  final text = message?.toString() ?? '';
  if (kIsWeb) {
    WebConsole.warn('[Warn] $text');
    return;
  }
  if (kDebugMode) debugPrint('[Warn] $text');
}

void appErrorLog(Object? message) {
  final text = message?.toString() ?? '';
  if (kIsWeb) {
    WebConsole.error('[Error] $text');
    return;
  }
  if (kDebugMode) debugPrint('[Error] $text');
}
