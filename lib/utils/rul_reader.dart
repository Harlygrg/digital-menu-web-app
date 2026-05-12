import 'package:flutter/foundation.dart';

import 'app_debug_log.dart';

String? readQrTokenFromEnvironment() {
  if (kIsWeb) {
    // ignore: avoid_web_libraries_in_flutter
    final uri = Uri.parse(
      // ignore: undefined_prefixed_name
        (Uri.base.toString())
    );
    final token = uri.queryParameters['token']?.trim();
    if (token != null && token.isNotEmpty) {
      appInfoLog('Token extracted from URL: $token');
    } else {
      appWebDebugLog('No token found in URL query params');
    }
    return token;
  } else {
    final token = Uri.base.queryParameters['token']?.trim();
    if (token != null && token.isNotEmpty) {
      appInfoLog('Token extracted from URL: $token');
    } else {
      appWebDebugLog('No token found in URL query params');
    }
    return token;
  }
}