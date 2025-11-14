/// Mobile-specific implementation for URL utilities
/// On mobile, URL parameters are not applicable, so these return null/empty

String? getQueryParameterImpl(String paramName) {
  return null;
}

Map<String, String> getAllQueryParametersImpl() {
  return {};
}

