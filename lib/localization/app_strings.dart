/// Centralized English / Arabic strings for shared UI (routes, empty states, a11y).
///
/// Add new user-facing copy here to keep views free of scattered literals.
class AppStrings {
  AppStrings._();

  static String searchHint(bool isEnglish) =>
      isEnglish ? 'Search for dishes...' : 'ابحث عن الأطباق...';

  static String clearSearchTooltip(bool isEnglish) =>
      isEnglish ? 'Clear search' : 'مسح البحث';

  static String noItemsFound(bool isEnglish) =>
      isEnglish ? 'No items found' : 'لم يتم العثور على أطباق';

  static String clearSearchAction(bool isEnglish) =>
      isEnglish ? 'Clear search' : 'مسح البحث';

  static String showAllCategories(bool isEnglish) =>
      isEnglish ? 'Show all categories' : 'عرض كل الفئات';

  static String gridViewTooltip(bool isEnglish) =>
      isEnglish ? 'Grid view' : 'عرض شبكي';

  static String listViewTooltip(bool isEnglish) =>
      isEnglish ? 'List view' : 'عرض قائمة';

  static String itemDetailsTooltip(bool isEnglish) =>
      isEnglish ? 'Item details' : 'تفاصيل الصنف';

  static String pageNotFoundTitle(bool isEnglish) =>
      isEnglish ? 'Page not found' : 'الصفحة غير موجودة';

  static String pageNotFoundBody(bool isEnglish) => isEnglish
      ? 'We could not find that page. Check the link or return to the menu.'
      : 'تعذر العثور على هذه الصفحة. تحقق من الرابط أو عد إلى القائمة.';

  static String backToMenu(bool isEnglish) =>
      isEnglish ? 'Back to menu' : 'العودة إلى القائمة';

  static String goHome(bool isEnglish) =>
      isEnglish ? 'Go home' : 'الصفحة الرئيسية';

  static String itemUnavailableTitle(bool isEnglish) =>
      isEnglish ? 'Item' : 'الصنف';

  static String itemUnavailableBody(bool isEnglish) => isEnglish
      ? 'This item is not available or could not be loaded.'
      : 'هذا الصنف غير متاح أو تعذر تحميله.';
}
