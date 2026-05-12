/// Localized copy for mandatory QR / menu-link gate screens.
class QrGateMessages {
  QrGateMessages._();

  /// English text returned by [resolveQrFromInitialToken] for missing token.
  static const String missingTokenEn =
      'No menu token was found in the link. Open the menu using the QR link from your table.';

  /// English text returned when persisting QR context fails.
  static const String saveContextFailedEn =
      'Could not save the menu session on this device. Please try again or clear app data.';

  static String missingToken(bool isEnglish) =>
      isEnglish ? missingTokenEn : missingTokenAr;

  static const String missingTokenAr =
      'لم يتم العثور على رمز القائمة في الرابط. افتح القائمة باستخدام رابط رمز الاستجابة السريعة من طاولتك.';

  static String saveContextFailed(bool isEnglish) =>
      isEnglish ? saveContextFailedEn : saveContextFailedAr;

  static const String saveContextFailedAr =
      'تعذر حفظ جلسة القائمة على هذا الجهاز. حاول مرة أخرى أو امسح بيانات التطبيق.';

  static String startupTitleMissingToken(bool isEnglish) => isEnglish
      ? 'Menu link required'
      : 'رابط القائمة مطلوب';

  static String startupTitleTokenFailed(bool isEnglish) => isEnglish
      ? 'Unable to open menu'
      : 'تعذر فتح القائمة';

  static String startupTitleGeneric(bool isEnglish) => isEnglish
      ? 'Unable to start app'
      : 'تعذر تشغيل التطبيق';

  static String retryButton(bool isEnglish) =>
      isEnglish ? 'Retry' : 'إعادة المحاولة';

  static String openMenuLinkButton(bool isEnglish) =>
      isEnglish ? 'Try again' : 'حاول مرة أخرى';
}
