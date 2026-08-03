import 'package:flutter/foundation.dart';
import '../models/tax_settings_model.dart';
import '../services/api/api_service.dart';
import 'package:digital_menu_order/utils/app_debug_log.dart';

/// Holds branch tax settings from getTaxSettings for cart UI and create order.
class TaxProvider extends ChangeNotifier {
  TaxSettingsData? _settings;

  TaxSettingsData? get settings => _settings;

  /// Branch tax mode: `0` bill-wise, `1` item-wise (defaults to `0`).
  int get taxmode => _settings?.taxmode ?? 0;

  bool get isItemWise => _settings?.isItemWise ?? false;

  /// True when the API says tax is on and at least one tax line exists.
  bool get shouldApplyTax =>
      _settings != null &&
      _settings!.taxEnabled &&
      _settings!.taxes.isNotEmpty;

  /// Loads tax settings for [branchId]. On failure, clears to “no tax” behavior.
  Future<void> fetchTaxSettings(int branchId) async {
    try {
      final response = await ApiService().getTaxSettings(branchId: branchId);
      if (response.success && response.data != null) {
        _settings = response.data;
      } else {
        _settings = null;
      }
    } catch (e) {
      appDebugLog('TaxProvider: fetchTaxSettings failed: $e');
      _settings = null;
    }
    notifyListeners();
  }
}
