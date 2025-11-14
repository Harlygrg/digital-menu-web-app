// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Web-specific implementation for URL parameter extraction
String? getQueryParameterImpl(String paramName) {
  try {
    final uri = Uri.parse(html.window.location.href);
    return uri.queryParameters[paramName];
  } catch (e) {
    print('Error extracting query parameter $paramName: $e');
    return null;
  }
}

/// Gets all query parameters from the current URL
Map<String, String> getAllQueryParametersImpl() {
  try {
    final uri = Uri.parse(html.window.location.href);
    return uri.queryParameters;
  } catch (e) {
    print('Error extracting query parameters: $e');
    return {};
  }
}

