/// Language provider for managing app-wide locale and text direction.
///
/// This provider is the authoritative source for language state used by
/// MaterialApp (locale, text direction). Extracted from HomeProvider to
/// prevent full widget tree rebuilds when unrelated state changes.
///
/// HomeProvider retains its own _language field for internal filtering
/// (search by product name). Both providers are kept in sync by the
/// view layer when language changes.
import 'package:flutter/material.dart';

/// Provider for managing app language and text direction
class LanguageProvider extends ChangeNotifier {
  /// Current language code ('en' or 'ar')
  String _language = 'en';

  /// Current language code
  String get language => _language;

  /// Whether the current language is English
  bool get isEnglish => _language == 'en';

  /// Whether the current language is Arabic
  bool get isArabic => _language == 'ar';

  /// Text direction based on current language
  TextDirection get textDirection =>
      isEnglish ? TextDirection.ltr : TextDirection.rtl;

  /// Toggle language between English and Arabic
  void toggleLanguage() {
    _language = _language == 'en' ? 'ar' : 'en';
    notifyListeners();
  }

  /// Set language to a specific value
  void setLanguage(String lang) {
    if ((lang == 'en' || lang == 'ar') && lang != _language) {
      _language = lang;
      notifyListeners();
    }
  }
}
