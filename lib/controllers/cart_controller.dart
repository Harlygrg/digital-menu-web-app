import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/item_model.dart';
import '../models/option_models.dart';
import '../models/cart_item_model.dart';
import '../services/api/api_service.dart';
import '../storage/local_storage.dart';
import '../models/cart_pricing/cart_price_sync_dtos.dart';
import 'package:digital_menu_order/utils/app_debug_log.dart';

/// Controller for managing cart state and operations
class CartController extends ChangeNotifier {
  final List<CartItemModel> _cartItems = [];

  bool _needsPriceSync = false;
  Future<void>? _inFlightPriceSync;

  /// Hive box for cart persistence
  Box<CartItemModel>? _cartBox;

  /// Hive box for order notes persistence
  Box? _orderNotesBox;

  /// Order notes for the current order
  String _orderNotes = '';

  /// Constructor - loads cart from Hive on initialization
  CartController() {
    _initializeCart();
  }

  /// Initialize cart and load persisted data from Hive
  Future<void> _initializeCart() async {
    try {
      await _loadCartFromHive();
      await _loadOrderNotesFromHive();
      await _loadNeedsPriceSyncFromStorage();
    } catch (e) {
      appDebugLog('Error initializing cart from Hive: $e');
    }
  }

  Future<void> _loadNeedsPriceSyncFromStorage() async {
    _needsPriceSync = await LocalStorage.getNeedsPriceSync();
    notifyListeners();
  }

  /// Get all cart items
  List<CartItemModel> get cartItems => List.unmodifiable(_cartItems);

  /// Get total number of items in cart
  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  /// Get total price of all items in cart
  double get totalPrice =>
      _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// Check if cart is empty
  bool get isEmpty => _cartItems.isEmpty;

  /// Check if cart is not empty
  bool get isNotEmpty => _cartItems.isNotEmpty;

  /// Whether the cart must be synced before checkout.
  bool get needsPriceSync => _needsPriceSync;

  /// True if any cart item/modifier is unavailable.
  bool get hasUnavailableItems {
    for (final item in _cartItems) {
      if (!item.isAvailable) return true;
      for (final mod in item.modifiers) {
        if (!mod.isAvailable) return true;
      }
    }
    return false;
  }

  /// Get order notes
  String get orderNotes => _orderNotes;

  /// Set order notes
  Future<void> setOrderNotes(String notes) async {
    _orderNotes = notes;
    await _saveOrderNotesToHive();
    notifyListeners();
  }

  /// Builds a [CartItemModel] from the add-to-cart popup payload (same rules as [addToCartFromPopup]).
  CartItemModel _buildCartItemModelFromPopupPayload({
    required ItemModel item,
    required Map<String, dynamic> payload,
    required int quantity,
    String? lineId,
  }) {
    final selectedSize = payload['size'] as String?;
    final addons = payload['addons'] as List<dynamic>? ?? [];
    final note = payload['note'] as String?;
    final unitPrice = payload['unitPrice'] as double? ?? item.price;

    UnitPriceListModel? selectedUnit;
    if (selectedSize != null && selectedSize.trim().isNotEmpty) {
      selectedUnit = item.unitPriceList.firstWhere(
        (u) => u.unitName == selectedSize,
        orElse: () => item.unitPriceList.isNotEmpty
            ? item.unitPriceList.first
            : const UnitPriceListModel(
                unitFkId: 0,
                price: 0,
                unitName: '',
                otherLang: '',
                isMainUnit: false,
              ),
      );
      if (selectedUnit.unitFkId == 0) {
        selectedUnit = null;
      }
    } else if (item.unitPriceList.isNotEmpty) {
      selectedUnit = item.unitPriceList.firstWhere(
        (u) => u.isMainUnit,
        orElse: () => item.unitPriceList.first,
      );
    }

    final modifiers = addons.map<CartModifier>((addon) {
      return CartModifier(
        id: addon['id'] as int? ?? 0,
        name: addon['title'] as String? ?? '',
        price: (addon['price'] as num?)?.toDouble() ?? 0.0,
        quantity: addon['qty'] as int? ?? 1,
      );
    }).toList();

    return CartItemModel(
      id:
          lineId ??
          '${item.id}_${selectedSize ?? 'default'}_${DateTime.now().millisecondsSinceEpoch}',
      item: item,
      selectedUnit: selectedUnit,
      modifiers: modifiers,
      quantity: quantity,
      specialInstructions: note,
      unitPrice: unitPrice,
    );
  }

  /// True when edit would not change unit, notes (trimmed), or positive-qty modifiers (order-insensitive).
  bool _isEditNoop(CartItemModel existing, CartItemModel candidate) {
    if (existing.selectedUnit?.unitFkId != candidate.selectedUnit?.unitFkId) {
      return false;
    }
    final n1 = existing.specialInstructions?.trim() ?? '';
    final n2 = candidate.specialInstructions?.trim() ?? '';
    if (n1 != n2) return false;

    final ea = existing.modifiers.where((m) => m.quantity > 0).toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    final ca = List<CartModifier>.from(candidate.modifiers)
      ..sort((a, b) => a.id.compareTo(b.id));
    if (ea.length != ca.length) return false;
    for (var i = 0; i < ea.length; i++) {
      if (ea[i].id != ca[i].id || ea[i].quantity != ca[i].quantity)
        return false;
    }
    return true;
  }

  /// Update an existing cart line from the same popup payload used by [addToCartFromPopup].
  /// Preserves [existing.quantity], replaces or merges using [_findExistingItemIndex], and reuses [existing.id] when inserting in place.
  /// Returns `false` when nothing changed (no-op), `true` when the cart was updated.
  Future<bool> updateCartItemFromPopup({
    required CartItemModel existing,
    required ItemModel item,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final oldIndex = _cartItems.indexWhere((e) => e.id == existing.id);
      if (oldIndex == -1) {
        throw Exception('Cart line not found');
      }

      final apiService = ApiService();
      final isAvailable = await apiService.checkProductAvailability(
        productId: item.id,
      );
      if (!isAvailable) {
        throw Exception(
          '⚠️ This item is no longer available. Refreshing menu...',
        );
      }

      final candidate = _buildCartItemModelFromPopupPayload(
        item: item,
        payload: payload,
        quantity: existing.quantity,
      );

      if (_isEditNoop(_cartItems[oldIndex], candidate)) {
        return false;
      }

      _cartItems.removeAt(oldIndex);

      final mergeIndex = _findExistingItemIndex(candidate);
      if (mergeIndex != -1) {
        _cartItems[mergeIndex] = _cartItems[mergeIndex].copyWith(
          quantity: _cartItems[mergeIndex].quantity + candidate.quantity,
        );
      } else {
        final inserted = candidate.copyWith(id: existing.id);
        _cartItems.insert(oldIndex, inserted);
      }

      await _saveCartToHive();
      notifyListeners();
      return true;
    } catch (e) {
      rethrow;
    }
  }

  /// Add item to cart from popup payload with availability check
  Future<void> addToCartFromPopup({
    required ItemModel item,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final wasEmpty = _cartItems.isEmpty;
      // First check product availability
      final apiService = ApiService();
      final isAvailable = await apiService.checkProductAvailability(
        productId: item.id,
      );

      if (!isAvailable) {
        throw Exception(
          '⚠️ This item is no longer available. Refreshing menu...',
        );
      }

      final quantity = payload['quantity'] as int? ?? 1;
      final cartItem = _buildCartItemModelFromPopupPayload(
        item: item,
        payload: payload,
        quantity: quantity,
      );

      // Check if similar item already exists
      final existingIndex = _findExistingItemIndex(cartItem);

      if (existingIndex != -1) {
        // Update existing item quantity
        _cartItems[existingIndex] = _cartItems[existingIndex].copyWith(
          quantity: _cartItems[existingIndex].quantity + quantity,
        );
      } else {
        // Add new item
        _cartItems.add(cartItem);
      }

      // Persist cart to Hive after adding item
      await _saveCartToHive();

      if (wasEmpty && _cartItems.isNotEmpty) {
        await _setCartPricingContextToCurrentAndClearStale();
      }

      notifyListeners();
    } catch (e) {
      appDebugLog('Error adding item to cart: $e');
      rethrow;
    }
  }

  /// Add item to cart with explicit parameters
  Future<void> addToCart({
    required ItemModel product,
    UnitPriceListModel? unit,
    required List<ModifierModel> modifiers,
    int quantity = 1,
    String? specialInstructions,
  }) async {
    try {
      final wasEmpty = _cartItems.isEmpty;
      // Convert ModifierModel to CartModifier
      final cartModifiers = modifiers
          .where((modifier) => modifier.price > 0)
          .map<CartModifier>((modifier) {
            return CartModifier(
              id: modifier.id,
              name: modifier.modifier,
              price: modifier.price,
              quantity: 1, // Default quantity for modifiers
            );
          })
          .toList();

      // Calculate unit price
      final unitPrice = unit?.price ?? product.price;

      // Create cart item
      final cartItem = CartItemModel(
        id: '${product.id}_${unit?.unitFkId ?? 'default'}_${DateTime.now().millisecondsSinceEpoch}',
        item: product,
        selectedUnit: unit,
        modifiers: cartModifiers,
        quantity: quantity,
        specialInstructions: specialInstructions,
        unitPrice: unitPrice,
      );

      // Check if similar item already exists
      final existingIndex = _findExistingItemIndex(cartItem);

      if (existingIndex != -1) {
        // Update existing item quantity
        _cartItems[existingIndex] = _cartItems[existingIndex].copyWith(
          quantity: _cartItems[existingIndex].quantity + quantity,
        );
      } else {
        // Add new item
        _cartItems.add(cartItem);
      }

      // Persist cart to Hive after adding item
      await _saveCartToHive();

      if (wasEmpty && _cartItems.isNotEmpty) {
        await _setCartPricingContextToCurrentAndClearStale();
      }

      notifyListeners();
    } catch (e) {
      appDebugLog('Error adding item to cart: $e');
      rethrow;
    }
  }

  /// Increase quantity of a cart item
  Future<void> increaseQuantity(CartItemModel item) async {
    final index = _cartItems.indexWhere((cartItem) => cartItem.id == item.id);
    if (index != -1) {
      _cartItems[index] = _cartItems[index].copyWith(
        quantity: _cartItems[index].quantity + 1,
      );
      // Persist cart to Hive after quantity change
      await _saveCartToHive();
      notifyListeners();
    }
  }

  /// Decrease quantity of a cart item
  Future<void> decreaseQuantity(CartItemModel item) async {
    final index = _cartItems.indexWhere((cartItem) => cartItem.id == item.id);
    if (index != -1) {
      final newQuantity = _cartItems[index].quantity - 1;
      if (newQuantity <= 0) {
        await removeItem(item);
      } else {
        _cartItems[index] = _cartItems[index].copyWith(quantity: newQuantity);
        // Persist cart to Hive after quantity change
        await _saveCartToHive();
        notifyListeners();
      }
    }
  }

  /// Update quantity of a cart item
  Future<void> updateQuantity(CartItemModel item, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeItem(item);
      return;
    }

    final index = _cartItems.indexWhere((cartItem) => cartItem.id == item.id);
    if (index != -1) {
      _cartItems[index] = _cartItems[index].copyWith(quantity: newQuantity);
      // Persist cart to Hive after quantity change
      await _saveCartToHive();
      notifyListeners();
    }
  }

  /// Increase quantity of a modifier
  Future<void> increaseModifierQuantity(
    CartItemModel item,
    int modifierId,
  ) async {
    final index = _cartItems.indexWhere((cartItem) => cartItem.id == item.id);
    if (index != -1) {
      final updatedModifiers = _cartItems[index].modifiers.map((modifier) {
        if (modifier.id == modifierId) {
          return modifier.copyWith(quantity: modifier.quantity + 1);
        }
        return modifier;
      }).toList();

      _cartItems[index] = _cartItems[index].copyWith(
        modifiers: updatedModifiers,
      );
      // Persist cart to Hive after modifier change
      await _saveCartToHive();
      notifyListeners();
    }
  }

  /// Decrease quantity of a modifier
  Future<void> decreaseModifierQuantity(
    CartItemModel item,
    int modifierId,
  ) async {
    final index = _cartItems.indexWhere((cartItem) => cartItem.id == item.id);
    if (index != -1) {
      final updatedModifiers = _cartItems[index].modifiers.map((modifier) {
        if (modifier.id == modifierId) {
          final newQuantity = modifier.quantity - 1;
          // Keep modifier even if quantity becomes 0, so customer can add it back
          return modifier.copyWith(quantity: newQuantity < 0 ? 0 : newQuantity);
        }
        return modifier;
      }).toList();

      _cartItems[index] = _cartItems[index].copyWith(
        modifiers: updatedModifiers,
      );
      // Persist cart to Hive after modifier change
      await _saveCartToHive();
      notifyListeners();
    }
  }

  /// Update special instructions for a cart item
  Future<void> updateSpecialInstructions(
    CartItemModel item,
    String newInstructions,
  ) async {
    final index = _cartItems.indexWhere((cartItem) => cartItem.id == item.id);
    if (index != -1) {
      // Create a new cart item with updated special instructions
      final updatedItem = CartItemModel(
        id: _cartItems[index].id,
        item: _cartItems[index].item,
        selectedUnit: _cartItems[index].selectedUnit,
        modifiers: _cartItems[index].modifiers,
        quantity: _cartItems[index].quantity,
        specialInstructions: newInstructions.isEmpty ? null : newInstructions,
        unitPrice: _cartItems[index].unitPrice,
      );

      _cartItems[index] = updatedItem;
      // Persist cart to Hive after updating instructions
      await _saveCartToHive();
      notifyListeners();
    }
  }

  /// Remove item from cart
  Future<void> removeItem(CartItemModel item) async {
    _cartItems.removeWhere((cartItem) => cartItem.id == item.id);
    // Persist cart to Hive after removing item
    await _saveCartToHive();
    notifyListeners();
  }

  /// Clear all items from cart
  Future<void> clearCart() async {
    _cartItems.clear();
    _orderNotes = '';
    // Clear cart from Hive storage (persist cleared state)
    await _clearCartFromHive();
    await _clearOrderNotesFromHive();
    await _setNeedsPriceSync(false);
    await LocalStorage.clearCartPricingContext();
    notifyListeners();
  }

  Future<void> _setNeedsPriceSync(bool value) async {
    _needsPriceSync = value;
    await LocalStorage.setNeedsPriceSync(value);
    notifyListeners();
  }

  /// Returns the *current* order context normalized for comparisons and API payloads.
  ///
  /// - Missing `table_id` defaults to `"0"` (takeaway / non-table context).
  Future<({String branchId, String orderTypeId, String tableId})>
  getCurrentOrderContext() async {
    final branchId = (await LocalStorage.getBranchId())?.trim() ?? '';
    final orderTypeId = (await LocalStorage.getOrderType())?.trim() ?? '';
    final tableIdRaw = (await LocalStorage.getTableId())?.trim();
    final tableId = (tableIdRaw == null || tableIdRaw.isEmpty)
        ? '0'
        : tableIdRaw;
    return (branchId: branchId, orderTypeId: orderTypeId, tableId: tableId);
  }

  /// Returns true if the cart context differs from the last successful pricing context.
  Future<bool> isCartPricingContextStale() async {
    if (_cartItems.isEmpty) return false;
    final current = await getCurrentOrderContext();
    final saved = await LocalStorage.getCartPricingContext();

    final savedTable = (saved.tableId == null || saved.tableId!.trim().isEmpty)
        ? '0'
        : saved.tableId!.trim();
    final savedBranch = saved.branchId?.trim() ?? '';
    final savedOrderType = saved.orderTypeId?.trim() ?? '';

    return savedBranch != current.branchId ||
        savedOrderType != current.orderTypeId ||
        savedTable != current.tableId;
  }

  /// Mark the cart as needing a price sync (persisted).
  Future<void> markNeedsPriceSync() async {
    await _setNeedsPriceSync(true);
  }

  Future<void> _setCartPricingContextToCurrentAndClearStale() async {
    final current = await getCurrentOrderContext();
    await LocalStorage.saveCartPricingContext(
      branchId: current.branchId,
      orderTypeId: current.orderTypeId,
      tableId: current.tableId,
    );
    await _setNeedsPriceSync(false);
  }

  /// Sync cart prices + availability via backend `getCartPrices`.
  ///
  /// Single-flight: rapid calls will await the in-flight sync.
  Future<void> syncCartPrices() async {
    if (_inFlightPriceSync != null) return _inFlightPriceSync!;

    _inFlightPriceSync = _syncCartPricesInternal().whenComplete(() {
      _inFlightPriceSync = null;
    });

    return _inFlightPriceSync!;
  }

  Future<void> _syncCartPricesInternal() async {
    if (_cartItems.isEmpty) {
      await _setNeedsPriceSync(false);
      return;
    }

    final context = await getCurrentOrderContext();
    final branchId = int.tryParse(context.branchId) ?? 0;
    final orderTypeId = int.tryParse(context.orderTypeId) ?? 0;
    final tableId = int.tryParse(context.tableId) ?? 0;

    final request = CartPriceSyncRequestDto(
      branchId: branchId,
      orderTypeId: orderTypeId,
      tableId: tableId,
      items: _cartItems.map((line) {
        final unitId = _resolveUnitIdForLine(line);
        final modifierIds = line.modifiers
            .where((m) => m.quantity > 0)
            .map((m) => m.id)
            .toList();
        return CartPriceSyncRequestItemDto(
          productId: line.item.id,
          unitId: unitId,
          qty: line.quantity,
          modifierIds: modifierIds,
        );
      }).toList(),
    );

    final response = await ApiService().getCartPrices(request: request);
    if (!response.success || response.data == null) {
      await _setNeedsPriceSync(true);
      throw Exception(
        response.message.isNotEmpty
            ? response.message
            : 'Failed to fetch cart prices',
      );
    }

    final data = response.data!;

    final itemPriceMap = <String, CartPriceSyncItemPriceDto>{};
    for (final p in data.itemPrices) {
      itemPriceMap['${p.productId}:${p.unitId}'] = p;
    }

    final modifierPriceMap = <String, CartPriceSyncModifierPriceDto>{};
    for (final m in data.modifierPrices) {
      modifierPriceMap['${m.productId}:${m.unitId}:${m.modifierId}'] = m;
    }

    for (var i = 0; i < _cartItems.length; i++) {
      final line = _cartItems[i];
      final unitId = _resolveUnitIdForLine(line);
      final itemKey = '${line.item.id}:$unitId';
      final itemPrice = itemPriceMap[itemKey];

      final itemIsAvailable = itemPrice?.isAvailable ?? false;
      final itemReason =
          itemPrice?.reason ??
          (itemPrice == null ? 'Pricing not returned' : null);
      final updatedUnitPrice = itemPrice?.unitPrice ?? 0.0;

      final updatedModifiers = line.modifiers.map((mod) {
        final key = '${line.item.id}:$unitId:${mod.id}';
        final mp = modifierPriceMap[key];
        final modIsAvailable = mp?.isAvailable ?? false;
        final modReason =
            mp?.reason ?? (mp == null ? 'Pricing not returned' : null);
        final modPrice = mp?.unitPrice ?? 0.0;
        return mod.copyWith(
          price: modPrice,
          isAvailable: modIsAvailable,
          unavailableReason: modReason,
        );
      }).toList();

      _cartItems[i] = line.copyWith(
        unitPrice: updatedUnitPrice,
        modifiers: updatedModifiers,
        isAvailable: itemIsAvailable,
        unavailableReason: itemReason,
      );
    }

    await _setCartPricingContextToCurrentAndClearStale();
    await _saveCartToHive();
  }

  int _resolveUnitIdForLine(CartItemModel line) {
    final selected = line.selectedUnit?.unitFkId;
    if (selected != null && selected > 0) return selected;
    final itemUnit = line.item.fkUnit;
    if (itemUnit > 0) return itemUnit;
    // Last-resort fallback to avoid invalid 0; keeps previous behavior but only when necessary.
    return 1;
  }

  /// Find index of existing similar item
  int _findExistingItemIndex(CartItemModel newItem) {
    return _cartItems.indexWhere((existingItem) {
      // Check if same product and unit
      if (existingItem.item.id != newItem.item.id) return false;
      if (existingItem.selectedUnit?.unitFkId !=
          newItem.selectedUnit?.unitFkId) {
        return false;
      }

      // Check if modifiers are the same
      if (existingItem.modifiers.length != newItem.modifiers.length)
        return false;

      for (int i = 0; i < existingItem.modifiers.length; i++) {
        final existingModifier = existingItem.modifiers[i];
        final newModifier = newItem.modifiers[i];
        if (existingModifier.id != newModifier.id ||
            existingModifier.quantity != newModifier.quantity) {
          return false;
        }
      }

      return true;
    });
  }

  /// Get cart summary for display
  Map<String, dynamic> getCartSummary() {
    return {
      'itemCount': itemCount,
      'totalPrice': totalPrice,
      'isEmpty': isEmpty,
      'items': _cartItems
          .map(
            (item) => {
              'id': item.id,
              'name': item.item.iname,
              'unit': item.unitDisplayName,
              'quantity': item.quantity,
              'unitPrice': item.unitPrice,
              'totalPrice': item.totalPrice,
              'modifiers': item.modifiers
                  .map(
                    (mod) => {
                      'name': mod.name,
                      'price': mod.price,
                      'quantity': mod.quantity,
                    },
                  )
                  .toList(),
            },
          )
          .toList(),
    };
  }

  /// Save current cart state to Hive for persistence
  Future<void> _saveCartToHive() async {
    try {
      // Get or open the cart box
      _cartBox ??= await Hive.openBox<CartItemModel>('cartBox');

      // Clear existing data
      await _cartBox!.clear();

      // Save all cart items
      for (var i = 0; i < _cartItems.length; i++) {
        await _cartBox!.put('cart_item_$i', _cartItems[i]);
      }

      appDebugLog('Cart saved to Hive: ${_cartItems.length} items');
    } catch (e) {
      appDebugLog('Error saving cart to Hive: $e');
    }
  }

  /// Load cart data from Hive on startup/refresh
  Future<void> _loadCartFromHive() async {
    try {
      // Get or open the cart box
      _cartBox ??= await Hive.openBox<CartItemModel>('cartBox');

      // Clear current in-memory cart
      _cartItems.clear();

      // Load all saved cart items
      for (var key in _cartBox!.keys) {
        final cartItem = _cartBox!.get(key);
        if (cartItem != null) {
          _cartItems.add(cartItem);
        }
      }

      appDebugLog('Cart loaded from Hive: ${_cartItems.length} items');

      // Notify listeners to update UI
      notifyListeners();
    } catch (e) {
      appDebugLog('Error loading cart from Hive: $e');
      // On error (likely corrupted data from schema changes), clear and start fresh
      _cartItems.clear();
      await _clearCorruptedCartData();
    }
  }

  /// Clear corrupted cart data from Hive storage
  /// This is called when deserialization fails due to schema changes
  Future<void> _clearCorruptedCartData() async {
    try {
      // Close the box if it's open
      if (_cartBox != null && _cartBox!.isOpen) {
        await _cartBox!.close();
      }
      _cartBox = null;

      // Delete the corrupted box and recreate it
      await Hive.deleteBoxFromDisk('cartBox');
      _cartBox = await Hive.openBox<CartItemModel>('cartBox');

      appDebugLog('Corrupted cart data cleared, starting fresh');
    } catch (e) {
      appDebugLog('Error clearing corrupted cart data: $e');
    }
  }

  /// Clear cart data from Hive (used when clearing cart or changing branch)
  Future<void> _clearCartFromHive() async {
    try {
      _cartBox ??= await Hive.openBox<CartItemModel>('cartBox');
      await _cartBox!.clear();
      appDebugLog('Cart cleared from Hive');
    } catch (e) {
      appDebugLog('Error clearing cart from Hive: $e');
    }
  }

  /// Save order notes to Hive for persistence
  Future<void> _saveOrderNotesToHive() async {
    try {
      _orderNotesBox ??= await Hive.openBox('orderNotesBox');
      await _orderNotesBox!.put('order_notes', _orderNotes);
      appDebugLog('Order notes saved to Hive: $_orderNotes');
    } catch (e) {
      appDebugLog('Error saving order notes to Hive: $e');
    }
  }

  /// Load order notes from Hive on startup
  Future<void> _loadOrderNotesFromHive() async {
    try {
      _orderNotesBox ??= await Hive.openBox('orderNotesBox');
      _orderNotes =
          _orderNotesBox!.get('order_notes', defaultValue: '') as String;
      appDebugLog('Order notes loaded from Hive: $_orderNotes');
      notifyListeners();
    } catch (e) {
      appDebugLog('Error loading order notes from Hive: $e');
      _orderNotes = '';
    }
  }

  /// Clear order notes from Hive
  Future<void> _clearOrderNotesFromHive() async {
    try {
      _orderNotesBox ??= await Hive.openBox('orderNotesBox');
      await _orderNotesBox!.delete('order_notes');
      appDebugLog('Order notes cleared from Hive');
    } catch (e) {
      appDebugLog('Error clearing order notes from Hive: $e');
    }
  }
}
