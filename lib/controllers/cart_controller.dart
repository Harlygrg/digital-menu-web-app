import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/item_model.dart';
import '../models/option_models.dart';
import '../models/cart_item_model.dart';
import '../services/api/api_service.dart';

/// Controller for managing cart state and operations
class CartController extends ChangeNotifier {
  final List<CartItemModel> _cartItems = [];
  
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
    } catch (e) {
      debugPrint('Error initializing cart from Hive: $e');
    }
  }

  /// Get all cart items
  List<CartItemModel> get cartItems => List.unmodifiable(_cartItems);

  /// Get total number of items in cart
  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  /// Get total price of all items in cart
  double get totalPrice => _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// Check if cart is empty
  bool get isEmpty => _cartItems.isEmpty;

  /// Check if cart is not empty
  bool get isNotEmpty => _cartItems.isNotEmpty;
  
  /// Get order notes
  String get orderNotes => _orderNotes;
  
  /// Set order notes
  Future<void> setOrderNotes(String notes) async {
    _orderNotes = notes;
    await _saveOrderNotesToHive();
    notifyListeners();
  }

  /// Add item to cart from popup payload with availability check
  Future<void> addToCartFromPopup({
    required ItemModel item,
    required Map<String, dynamic> payload,
  }) async {
    try {
      // First check product availability
      final apiService = ApiService();
      final isAvailable = await apiService.checkProductAvailability(productId: item.id);
      
      if (!isAvailable) {
        throw Exception('⚠️ This item is no longer available. Refreshing menu...');
      }

      // Extract data from payload
      final selectedSize = payload['size'] as String?;
      final quantity = payload['quantity'] as int? ?? 1;
      final addons = payload['addons'] as List<dynamic>? ?? [];
      final note = payload['note'] as String?;
      final unitPrice = payload['unitPrice'] as double? ?? item.price;

      // Find the selected unit (if any)
      UnitPriceListModel? selectedUnit;
      // Note: In a real implementation, you'd need to pass the available units
      // and find the matching one based on the selectedSize

      // Convert addons to CartModifier objects
      final modifiers = addons.map<CartModifier>((addon) {
        return CartModifier(
          id: addon['id'] as int? ?? 0,
          name: addon['title'] as String? ?? '',
          price: (addon['price'] as num?)?.toDouble() ?? 0.0,
          quantity: addon['qty'] as int? ?? 1,
        );
      }).toList();

      // Create cart item
      final cartItem = CartItemModel(
        id: '${item.id}_${selectedSize ?? 'default'}_${DateTime.now().millisecondsSinceEpoch}',
        item: item,
        selectedUnit: selectedUnit,
        modifiers: modifiers,
        quantity: quantity,
        specialInstructions: note,
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

      notifyListeners();
    } catch (e) {
      debugPrint('Error adding item to cart: $e');
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
      }).toList();

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

      notifyListeners();
    } catch (e) {
      debugPrint('Error adding item to cart: $e');
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
        _cartItems[index] = _cartItems[index].copyWith(
          quantity: newQuantity,
        );
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
      _cartItems[index] = _cartItems[index].copyWith(
        quantity: newQuantity,
      );
      // Persist cart to Hive after quantity change
      await _saveCartToHive();
      notifyListeners();
    }
  }

  /// Increase quantity of a modifier
  Future<void> increaseModifierQuantity(CartItemModel item, int modifierId) async {
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
  Future<void> decreaseModifierQuantity(CartItemModel item, int modifierId) async {
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
  Future<void> updateSpecialInstructions(CartItemModel item, String newInstructions) async {
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
    notifyListeners();
  }

  /// Find index of existing similar item
  int _findExistingItemIndex(CartItemModel newItem) {
    return _cartItems.indexWhere((existingItem) {
      // Check if same product and unit
      if (existingItem.item.id != newItem.item.id) return false;
      if (existingItem.selectedUnit?.unitFkId != newItem.selectedUnit?.unitFkId) {
        return false;
      }

      // Check if modifiers are the same
      if (existingItem.modifiers.length != newItem.modifiers.length) return false;
      
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
      'items': _cartItems.map((item) => {
        'id': item.id,
        'name': item.item.iname,
        'unit': item.unitDisplayName,
        'quantity': item.quantity,
        'unitPrice': item.unitPrice,
        'totalPrice': item.totalPrice,
        'modifiers': item.modifiers.map((mod) => {
          'name': mod.name,
          'price': mod.price,
          'quantity': mod.quantity,
        }).toList(),
      }).toList(),
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
      
      debugPrint('Cart saved to Hive: ${_cartItems.length} items');
    } catch (e) {
      debugPrint('Error saving cart to Hive: $e');
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
      
      debugPrint('Cart loaded from Hive: ${_cartItems.length} items');
      
      // Notify listeners to update UI
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading cart from Hive: $e');
      // On error, start with empty cart
      _cartItems.clear();
    }
  }

  /// Clear cart data from Hive (used when clearing cart or changing branch)
  Future<void> _clearCartFromHive() async {
    try {
      _cartBox ??= await Hive.openBox<CartItemModel>('cartBox');
      await _cartBox!.clear();
      debugPrint('Cart cleared from Hive');
    } catch (e) {
      debugPrint('Error clearing cart from Hive: $e');
    }
  }

  /// Save order notes to Hive for persistence
  Future<void> _saveOrderNotesToHive() async {
    try {
      _orderNotesBox ??= await Hive.openBox('orderNotesBox');
      await _orderNotesBox!.put('order_notes', _orderNotes);
      debugPrint('Order notes saved to Hive: $_orderNotes');
    } catch (e) {
      debugPrint('Error saving order notes to Hive: $e');
    }
  }

  /// Load order notes from Hive on startup
  Future<void> _loadOrderNotesFromHive() async {
    try {
      _orderNotesBox ??= await Hive.openBox('orderNotesBox');
      _orderNotes = _orderNotesBox!.get('order_notes', defaultValue: '') as String;
      debugPrint('Order notes loaded from Hive: $_orderNotes');
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading order notes from Hive: $e');
      _orderNotes = '';
    }
  }

  /// Clear order notes from Hive
  Future<void> _clearOrderNotesFromHive() async {
    try {
      _orderNotesBox ??= await Hive.openBox('orderNotesBox');
      await _orderNotesBox!.delete('order_notes');
      debugPrint('Order notes cleared from Hive');
    } catch (e) {
      debugPrint('Error clearing order notes from Hive: $e');
    }
  }
}
