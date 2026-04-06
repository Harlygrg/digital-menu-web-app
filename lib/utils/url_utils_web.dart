// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:digital_menu_order/utils/app_debug_log.dart';

/// Web-specific implementation for URL parameter extraction
String? getQueryParameterImpl(String paramName) {
  try {
    final uri = Uri.parse(html.window.location.href);
    return uri.queryParameters[paramName];
  } catch (e) {
    appDebugLog('Error extracting query parameter $paramName: $e');
    return null;
  }
}

/// Gets all query parameters from the current URL
Map<String, String> getAllQueryParametersImpl() {
  try {
    final uri = Uri.parse(html.window.location.href);
    return uri.queryParameters;
  } catch (e) {
    appDebugLog('Error extracting query parameters: $e');
    return {};
  }
}
