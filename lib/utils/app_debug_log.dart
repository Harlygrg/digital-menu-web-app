import 'package:flutter/foundation.dart';

/// Logs [message] only in debug mode ([kDebugMode]). Use instead of [print].
void appDebugLog(Object? message) {
  if (kDebugMode) {
    debugPrint(message?.toString());
  }
}
