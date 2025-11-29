import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:digital_menu_order/services/notification_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../providers/home_provider.dart';
import '../providers/branch_provider.dart';
import '../models/category_model.dart';
import '../models/item_model.dart';
import '../models/cart_item_model.dart';
import '../services/api/guest_user_api.dart';
import '../storage/local_storage.dart';
import 'dart:io' show Platform;

/// Controller for home screen business logic
class HomeController {
  final HomeProvider _provider;
  Timer? _searchDebounceTimer;
  final BranchProvider? _branchProvider;

  HomeController(this._provider, {BranchProvider? branchProvider}) 
    : _branchProvider = branchProvider;

  /// Optimized initialization flow
  /// 
  /// Order of operations:
  /// 1. Register guest user (if needed) - ensures tokens are available first
  /// 2. Fetch product data (main content) - loads UI as fast as possible
  /// 3. Fetch branch list (background) - non-critical data loaded after main content
  /// 4. Register FCM token (background) - happens last, doesn't block UI
  Future<void> initialize({required BuildContext context}) async {
// debugPrint('🚀 HomeController: initialize started');
    
    try {
      // STEP 1: Register guest user FIRST (critical for token availability)
      // This must complete before any authenticated API calls
      await _ensureGuestUserRegistered();
      
      // STEP 2: Fetch product data immediately (main content, highest priority)
      // This is what users see first, so it should load ASAP
      final branchId = await LocalStorage.getBranchId() ?? '1';
// debugPrint('📦 Fetching product data for branch: $branchId');
      await _provider.fetchProductRelatedData(branchId: branchId);
// debugPrint('✅ Product data loaded successfully');
      
      // STEP 3: Fetch branch list in background (lower priority)
      // This can happen after the main UI is rendered
      if (_branchProvider != null) {
        _fetchBranchListInBackground();
      }
      
      // STEP 4: Register FCM token in background (lowest priority, non-blocking)
      // This happens last and doesn't affect UI rendering
      _registerFcmTokenInBackground();
      
// debugPrint('✅ Initialization complete');
    } catch (e) {
// debugPrint('❌ Error during initialization: $e');
      
      // Handle authentication errors with retry logic
      if (e.toString().contains('401') || 
          e.toString().contains('Unauthorized') || 
          e.toString().contains('Invalid access token') ||
          e.toString().contains('Access token missing')) {
// debugPrint('🔄 Authentication error detected. Attempting to re-register...');
        await _handleAuthenticationError();
      } else {
        // For other errors, try to load data without branch ID
// debugPrint('⚠️ Loading data with fallback...');
        await _provider.fetchProductRelatedData();
      }
    }
  }

  /// Ensures guest user is registered with valid tokens
  /// Returns immediately if already registered with valid tokens
  Future<void> _ensureGuestUserRegistered() async {
    final isRegistered = await LocalStorage.isGuestUserRegistered();
    final accessToken = await LocalStorage.getAccessToken();
    
    if (!isRegistered || accessToken == null || accessToken.isEmpty) {
// debugPrint('👤 Guest user not registered or no access token. Registering...');
      final deviceId = await generateDeviceId();
// debugPrint('📱 HomeController: Device ID: $deviceId');
      
      // Register without FCM token initially (FCM will be registered later)
      await GuestUserApi.registerGuestUser(
        deviceId,);
      
      // Verify tokens were saved
      final savedToken = await LocalStorage.getAccessToken();
      if (savedToken == null || savedToken.isEmpty) {
        throw Exception('Failed to save authentication tokens');
      }
      
// debugPrint('✅ Guest user registered successfully with access token');
    } else {
// debugPrint('✅ Guest user already registered with valid token');
    }
  }

  /// Fetch branch list in background (non-blocking)
  void _fetchBranchListInBackground() {
    // Run asynchronously without awaiting
    Future.microtask(() async {
      try {
// debugPrint('🏪 Fetching branch list in background...');
        await _branchProvider!.fetchBranchList();
// debugPrint('✅ Branch list fetched successfully');
      } catch (e) {
// debugPrint('⚠️ Error fetching branch list (non-critical): $e');
      }
    });
  }

  /// Register FCM token in background (non-blocking)
  void _registerFcmTokenInBackground() {
    // Run asynchronously without awaiting
    Future.microtask(() async {
      try {
// debugPrint('🔔 Registering FCM token in background...');
        final deviceId = await generateDeviceId();
        final fcmToken = await NotificationService().getFcmToken();
        
        if (fcmToken.isNotEmpty) {
          await GuestUserApi.callAddUserFcmToken(deviceId, fcmToken);
// debugPrint('✅ FCM token registered successfully');
        } else {
// debugPrint('⚠️ FCM token is empty, skipping registration');
        }
      } catch (e) {
// debugPrint('⚠️ Error registering FCM token (non-critical): $e');
      }
    });
  }

  /// Handle authentication errors by re-registering guest user
  Future<void> _handleAuthenticationError() async {
    try {
      // Clear old authentication data
      await LocalStorage.clearAuthData();
      
      // Re-register guest user
      await _ensureGuestUserRegistered();
      
      // Retry fetching data
// debugPrint('✅ Re-registration successful. Retrying data fetch...');
      final branchId = await LocalStorage.getBranchId() ?? '1';
      await _provider.fetchProductRelatedData(branchId: branchId);
      
      // Fetch branch list in background
      if (_branchProvider != null) {
        _fetchBranchListInBackground();
      }
    } catch (reRegisterError) {
// debugPrint('❌ Re-registration failed: $reRegisterError');
      // Last resort: load without authentication
      await _provider.fetchProductRelatedData();
    }
  }

  /// Generate a unique device ID for the current device
  Future<String> generateDeviceId() async {
    try {
      // 1️⃣ If running on Web (PWA)
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        final storedId = prefs.getString('web_device_id');

        if (storedId != null && storedId.isNotEmpty) {
          // Return the same ID stored previously
// debugPrint('✅ Using existing web device ID: $storedId');
          return storedId;
        }

        // Generate a new unique but fixed ID
        final newId = 'web_${const Uuid().v4()}';
        await prefs.setString('web_device_id', newId);
// debugPrint('🆕 Generated and saved new web device ID: $newId');
        return newId;
      }

      // 2️⃣ For Android, iOS, macOS, Windows, Linux (native apps)
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return '${androidInfo.id}_${androidInfo.model}_${androidInfo.brand}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return '${iosInfo.identifierForVendor}_${iosInfo.model}_${iosInfo.systemName}';
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        return '${windowsInfo.deviceId}_${windowsInfo.computerName}';
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfo.macOsInfo;
        return '${macInfo.systemGUID}_${macInfo.computerName}';
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        return '${linuxInfo.machineId}_${linuxInfo.name}';
      }

      // 3️⃣ Fallback for unknown platforms
      return 'unknown_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
// debugPrint('⚠️ Error generating device ID: $e');
      // 4️⃣ Final fallback — still stored persistently
      final prefs = await SharedPreferences.getInstance();
      final fallback = prefs.getString('fallback_device_id');
      if (fallback != null) return fallback;

      final newFallback = 'fallback_${const Uuid().v4()}';
      await prefs.setString('fallback_device_id', newFallback);
      return newFallback;
    }
  }

  /// Toggle language between English and Arabic
  void toggleLanguage() {
    _provider.toggleLanguage();
  }

  /// Set specific language
  void setLanguage(String language) {
    _provider.setLanguage(language);
  }

  /// Toggle between grid and list view
  void toggleView() {
    _provider.toggleView();
  }

  /// Set view mode
  void setGridView(bool isGrid) {
    _provider.setGridView(isGrid);
  }

  /// Toggle veg filter
  void toggleVegFilter() {
    _provider.toggleVegFilter();
  }

  /// Set veg filter
  void setVegFilter(bool? isVeg) {
    _provider.setVegFilter(isVeg);
  }

  /// Toggle veg filter specifically (for veg button)
  void toggleVegOnly() {
    _provider.toggleVegOnly();
  }

  /// Toggle non-veg filter specifically (for non-veg button)
  void toggleNonVegOnly() {
    _provider.toggleNonVegOnly();
  }

  /// Update search query with debounce
  void updateSearchQuery(String query) {
    // Cancel previous timer
    _searchDebounceTimer?.cancel();
    
    // Set new timer for debounce (300ms)
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      _provider.updateSearchQuery(query);
    });
  }

  /// Select category
  void selectCategory(int categoryId) {
    _provider.selectCategory(categoryId);
  }

  /// Clear category selection
  void clearCategorySelection() {
    _provider.clearCategorySelection();
  }

  /// Add item to cart
  void addToCart(int itemId) {
    final item = _provider.allItems.firstWhere(
      (item) => item.id == itemId,
      orElse: () => throw Exception('Item not found'),
    );
    _provider.addToCart(item);
  }

  /// Remove item from cart
  void removeFromCart(int itemId) {
    _provider.removeFromCart(itemId.toString());
  }

  /// Update cart item quantity
  void updateCartItemQuantity(int itemId, int quantity) {
    _provider.updateCartItemQuantity(itemId.toString(), quantity);
  }

  /// Clear cart
  void clearCart() {
    _provider.clearCart();
  }

  /// Get localized text based on current language
  String getLocalizedText(String englishText, String arabicText) {
    return _provider.isEnglish ? englishText : arabicText;
  }

  /// Get localized category name
  String getCategoryName(int categoryId) {
    final category = _provider.categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => const CategoryModel(
        id: 0,
        category: 'Unknown',
        inOl: '',
        kot: 0,
        date: '',
        usrid: 0,
        categoryindex: 0,
      ),
    );
    return category.category;
  }

  /// Get localized item name
  String getItemName(ItemModel item) {
    return item.getProductName(_provider.language);
  }

  /// Get localized item description
  String getItemDescription(ItemModel item) {
    return item.getDescription(_provider.language);
  }

  /// Check if item is in cart
  bool isItemInCart(int itemId) {
    return _provider.cartItems.any((cartItem) => cartItem.item.id == itemId);
  }

  /// Get cart item quantity
  int getCartItemQuantity(int itemId) {
    final cartItem = _provider.cartItems.firstWhere(
      (cartItem) => cartItem.item.id == itemId,
      orElse: () => CartItemModel(
        id: '',
        item: const ItemModel(
          id: 0,
          iname: '',
          icode: '',
          categoryId: 0,
          disabled: 0,
          nameinol: '',
          fkUnit: 0,
          multiUnit: 0,
          price: 0.0,
          cost: 0.0,
          image: '',
          invPrdct: 0,
          opqty: 0,
          kot: '',
          date: '',
          userid: 0,
          modifiedBy: 0,
          modifiedDate: '',
          btnColor: '',
          shortName: '',
          isUploaded: 0,
          cid: 0,
          isVeg: 0,
          isAvailableInOnline: 0,
          descriptionEn: '',
          descriptionOtherLang: '',
          unitPriceList: [],
          productdetails: [],
          relatedModifiers: [],
          preparationtime: ''
        ),
        modifiers: const [],
        quantity: 0,
        unitPrice: 0.0,
      ),
    );
    return cartItem.quantity;
  }

  /// Dispose resources
  void dispose() {
    _searchDebounceTimer?.cancel();
  }
}
