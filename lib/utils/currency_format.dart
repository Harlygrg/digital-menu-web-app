import 'package:digital_menu_order/config/app_config.dart';

/// Formats a single monetary amount for display using [AppConfig.currencySymbol].
///
/// Loaded from `currencySymbol` in `web/config.json` at startup.
String formatCurrencyAmount(double amount) {
  return '${AppConfig.currencySymbol} ${amount.toStringAsFixed(2)}';
}

/// Formats a minimum–maximum price range (e.g. different unit sizes).
///
/// Each bound uses the same rules as [formatCurrencyAmount], separated by ` - `.
String formatCurrencyRange(double low, double high) {
  return '${formatCurrencyAmount(low)} - ${formatCurrencyAmount(high)}';
}
