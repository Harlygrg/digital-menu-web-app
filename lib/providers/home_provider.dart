import 'package:digital_menu_order/utils/capitalize_first_letter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/category_model.dart';
import '../models/item_model.dart';
import '../models/cart_item_model.dart';
import '../models/option_models.dart';
import '../services/api/api_service.dart';
import '../storage/local_storage.dart';
import 'package:digital_menu_order/utils/app_debug_log.dart';

/// Provider for managing home screen state
class HomeProvider extends ChangeNotifier {
  // Language and direction
  String _language = 'en';

  /// Creates the provider; forces English when [AppConfig.multiLanguage] is false.
  HomeProvider() {
    if (!AppConfig.multiLanguage) {
      _language = 'en';
    }
  }
  bool get isEnglish => _language == 'en';
  bool get isArabic => _language == 'ar';
  TextDirection get textDirection =>
      isEnglish ? TextDirection.ltr : TextDirection.rtl;

  // UI state
  bool _isGridView = true;
  bool? _isVegFilter; // null = no filter, true = veg only, false = non-veg only
  String _searchQuery = '';
  int _selectedCategoryId = 0; // Changed to int for new API
  bool _isLoading =
      true; // Start with loading true to prevent flash of "No items found"
  String? _errorMessage;

  // Data
  List<CategoryModel> _categories = [];
  List<ItemModel> _allItems = [];
  List<CartItemModel> _cartItems = [];
  List<ModifierModel> _modifiers = [];
  bool _hasEverLoadedData = false; // Track if data has ever been loaded

  // Getters
  String get language => _language;
  bool get isGridView => _isGridView;
  bool? get isVegFilter => _isVegFilter;
  String get searchQuery => _searchQuery;
  int get selectedCategoryId => _selectedCategoryId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<CategoryModel> get categories => _categories;
  List<ItemModel> get allItems => _allItems;
  List<CartItemModel> get cartItems => _cartItems;
  List<ModifierModel> get modifiers => _modifiers;
  int get cartCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  bool get hasEverLoadedData => _hasEverLoadedData;

  /// Get filtered items based on current filters
  List<ItemModel> get filteredItems {
    List<ItemModel> items = List.from(_allItems);

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      items = items.where((item) {
        final query = _searchQuery.toLowerCase();
        return item.getProductName(_language).toLowerCase().contains(query) ||
            item.getDescription(_language).toLowerCase().contains(query);
      }).toList();
    }

    // Filter by category
    if (_selectedCategoryId != 0) {
      items = items
          .where((item) => item.categoryId == _selectedCategoryId)
          .toList();
    }

    // Filter by veg preference
    // When _isVegFilter is null, show all items (no filter)
    // When _isVegFilter is true, show only vegetarian items
    // When _isVegFilter is false, show only non-vegetarian items
    if (_isVegFilter != null) {
      items = items
          .where(
            (item) => _isVegFilter! ? item.isVegetarian : !item.isVegetarian,
          )
          .toList();
    }

    // Filter by availability
    items = items.where((item) => item.isAvailable).toList();

    return items;
  }

  /// Initialize with sample data (legacy method - deprecated)
  @Deprecated('Use fetchProductRelatedData() instead')
  void initializeData() {
    // This method is deprecated - use fetchProductRelatedData() instead
    fetchProductRelatedData();
  }

  /// Fetch product related data from API
  ///
  /// [branchId] - The branch ID to fetch data for
  /// [silentRefresh] - If true, skips loading state updates to prevent UI stuttering during pull-to-refresh
  Future<void> fetchProductRelatedData({
    String branchId = '1',
    bool silentRefresh = false,
  }) async {
    appDebugLog(
      '---->📦 HomeProvider: fetchProductRelatedData for branch $branchId (silent: $silentRefresh)',
    );
    try {
      // Only show loading state if not a silent refresh
      if (!silentRefresh) {
        _isLoading = true;
        _errorMessage = null;
        notifyListeners();
      } else {
        // For silent refresh, just clear error message without triggering rebuild
        _errorMessage = null;
      }

      final apiService = ApiService();

      // Check if we have a valid access token before making the request
      final accessToken = await LocalStorage.getAccessToken();
      if (accessToken == null) {
        throw Exception(
          'No access token available. Please register as a guest user first.',
        );
      }
      appDebugLog('------->>> fetch product related data success1:');
      final response = await apiService.getProductRelatedData(
        branchId: branchId,
      );
      appDebugLog('------->>> fetch product related data success2:');
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];

        // Parse data asynchronously to avoid blocking the main thread
        // Yield to the scheduler between heavy operations for smoother animations
        await Future.delayed(Duration.zero);

        // Parse categories
        _categories =
            (data['categories'] as List<dynamic>?)
                ?.map((item) => CategoryModel.fromJson(item))
                .toList() ??
            [];

        // Yield frame to keep UI responsive
        await Future.delayed(Duration.zero);

        // Parse products
        _allItems =
            (data['products'] as List<dynamic>?)
                ?.map((item) => ItemModel.fromJson(item))
                .toList() ??
            [];

        // Yield frame to keep UI responsive
        await Future.delayed(Duration.zero);

        // Parse modifiers
        _modifiers =
            (data['modifiers'] as List<dynamic>?)
                ?.map((item) => ModifierModel.fromJson(item))
                .toList() ??
            [];

        appDebugLog(
          '✅ Loaded ${_categories.length} categories, ${_allItems.length} items, ${_modifiers.length} modifiers',
        );

        _hasEverLoadedData = true; // Mark that data has been loaded
        _isLoading = false;

        // Only notify once at the end to batch all updates into a single rebuild
        notifyListeners();
      } else {
        _errorMessage = _parseApiMessage(
          response,
          fallback: isEnglish
              ? 'Failed to load menu data. Please try again.'
              : 'فشل تحميل بيانات القائمة. يرجى المحاولة مرة أخرى.',
        );
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      appDebugLog('❌ Error in fetchProductRelatedData: $e');
      final errorText = e.toString().replaceFirst('Exception:', '').trim();
      _errorMessage = errorText.isNotEmpty
          ? errorText
          : (isEnglish
                ? 'Error loading menu data. Please try again.'
                : 'حدث خطأ أثناء تحميل بيانات القائمة. يرجى المحاولة مرة أخرى.');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Parse server message safely and provide a localized fallback.
  String _parseApiMessage(
    Map<String, dynamic> response, {
    required String fallback,
  }) {
    final message = response['message']?.toString().trim();
    if (message != null && message.isNotEmpty) {
      return message;
    }
    return fallback;
  }

  /// Toggle language between English and Arabic
  void toggleLanguage() {
    if (!AppConfig.multiLanguage) return;
    _language = _language == 'en' ? 'ar' : 'en';
    notifyListeners();
  }

  /// Set language
  void setLanguage(String lang) {
    if (!AppConfig.multiLanguage) {
      if (_language != 'en') {
        _language = 'en';
        notifyListeners();
      }
      return;
    }
    if (lang == 'en' || lang == 'ar') {
      _language = lang;
      notifyListeners();
    }
  }

  /// Toggle grid/list view
  void toggleView() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  /// Set view mode
  void setGridView(bool isGrid) {
    _isGridView = isGrid;
    notifyListeners();
  }

  /// Toggle veg filter with three states: null (no filter), true (veg), false (non-veg)
  void toggleVegFilter() {
    if (_isVegFilter == null) {
      _isVegFilter = true; // First tap: select veg
    } else if (_isVegFilter == true) {
      _isVegFilter = false; // Second tap: switch to non-veg
    } else {
      _isVegFilter = null; // Third tap: deselect all
    }
    notifyListeners();
  }

  /// Set veg filter directly
  void setVegFilter(bool? isVeg) {
    _isVegFilter = isVeg;
    notifyListeners();
  }

  /// Set loading state (useful for testing)
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Reset loading state to false (useful for error handling)
  void resetLoadingState() {
    _isLoading = false;
    notifyListeners();
  }

  /// Toggle veg filter specifically (for veg button)
  void toggleVegOnly() {
    if (_isVegFilter == true) {
      _isVegFilter = null; // Deselect if already selected
    } else {
      _isVegFilter = true; // Select veg
    }
    notifyListeners();
  }

  /// Toggle non-veg filter specifically (for non-veg button)
  void toggleNonVegOnly() {
    if (_isVegFilter == false) {
      _isVegFilter = null; // Deselect if already selected
    } else {
      _isVegFilter = false; // Select non-veg
    }
    notifyListeners();
  }

  /// Update search query
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Select category and reset veg/non-veg filters
  void selectCategory(int categoryId) {
    _selectedCategoryId = categoryId;
    _isVegFilter = null; // Reset veg/non-veg filter when category changes
    notifyListeners();
  }

  /// Clear category selection and reset veg/non-veg filters
  void clearCategorySelection() {
    _selectedCategoryId = 0;
    _isVegFilter = null; // Reset veg/non-veg filter when clearing category
    notifyListeners();
  }

  /// Add item to cart
  void addToCart(ItemModel item) {
    final existingIndex = _cartItems.indexWhere(
      (cartItem) => cartItem.item.id == item.id,
    );

    if (existingIndex >= 0) {
      // Update quantity
      _cartItems[existingIndex] = _cartItems[existingIndex].copyWith(
        quantity: _cartItems[existingIndex].quantity + 1,
      );
    } else {
      // Add new item
      _cartItems.add(
        CartItemModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          item: item,
          modifiers: const [],
          quantity: 1,
          unitPrice: item.price,
        ),
      );
    }
    notifyListeners();
  }

  /// Remove item from cart
  void removeFromCart(String itemId) {
    _cartItems.removeWhere((cartItem) => cartItem.item.id == itemId);
    notifyListeners();
  }

  /// Update cart item quantity
  void updateCartItemQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(itemId);
      return;
    }

    final index = _cartItems.indexWhere(
      (cartItem) => cartItem.item.id == itemId,
    );
    if (index >= 0) {
      _cartItems[index] = _cartItems[index].copyWith(quantity: quantity);
      notifyListeners();
    }
  }

  /// Clear cart
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  /// Get modifiers for a specific product
  List<ModifierModel> getModifiersForProduct(int productId) {
    final item = _allItems.firstWhere(
      (item) => item.id == productId,
      orElse: () => throw Exception('Product not found'),
    );
    return _modifiers
        .where((modifier) => item.relatedModifiers.contains(modifier.id))
        .toList();
  }

  /// Get category by ID
  CategoryModel? getCategoryById(int categoryId) {
    try {
      return _categories.firstWhere((category) => category.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  /// Get current title based on selected category
  String getCurrentTitle(bool isEnglish) {
    if (_selectedCategoryId == 0) {
      return isEnglish ? 'All Items' : 'جميع الأصناف';
    } else {
      final category = getCategoryById(_selectedCategoryId);
      return category?.category.capitalizeFirst() ??
          (isEnglish ? 'All Items' : 'جميع الأصناف');
    }
  }

  /// Get item by ID
  ItemModel? getItemById(int itemId) {
    try {
      return _allItems.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  /// Check authentication status
  Future<bool> isAuthenticated() async {
    final accessToken = await LocalStorage.getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  /// Force re-authentication by clearing tokens and re-registering
  Future<void> forceReAuthentication() async {
    try {
      await LocalStorage.clearAuthData();
      _errorMessage =
          'Authentication expired. Please restart the app to re-authenticate.';
      notifyListeners();
    } catch (e) {
      appDebugLog('❌ Error during force re-authentication: $e');
    }
  }

  /// Refresh product list in background when product becomes unavailable
  /// This method silently refreshes the data without showing loading state
  /// Optimized to yield frames during parsing for smoother UI performance
  Future<void> refreshProductListSilently({String branchId = '1'}) async {
    try {
      appDebugLog('🔄 Refreshing product list silently...');

      final apiService = ApiService();

      // Check if we have a valid access token before making the request
      final accessToken = await LocalStorage.getAccessToken();
      if (accessToken == null) {
        appDebugLog('⚠️ No access token available for silent refresh');
        return;
      }

      final response = await apiService.getProductRelatedData(
        branchId: branchId,
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];

        // Yield to frame scheduler for smoother UI
        await Future.delayed(Duration.zero);

        // Parse categories
        _categories =
            (data['categories'] as List<dynamic>?)
                ?.map((item) => CategoryModel.fromJson(item))
                .toList() ??
            [];

        // Yield frame to keep UI responsive
        await Future.delayed(Duration.zero);

        // Parse products
        _allItems =
            (data['products'] as List<dynamic>?)
                ?.map((item) => ItemModel.fromJson(item))
                .toList() ??
            [];

        // Yield frame to keep UI responsive
        await Future.delayed(Duration.zero);

        // Parse modifiers
        _modifiers =
            (data['modifiers'] as List<dynamic>?)
                ?.map((item) => ModifierModel.fromJson(item))
                .toList() ??
            [];

        appDebugLog(
          '✅ Product list refreshed silently: ${_allItems.length} items',
        );

        // Notify listeners once at the end to batch updates
        notifyListeners();
      } else {
        appDebugLog('⚠️ Failed to refresh product list silently');
      }
    } catch (e) {
      appDebugLog('❌ Error during silent product list refresh: $e');
      // Don't show error message for silent refresh
    }
  }
}
