import 'item_model.dart';
import 'option_models.dart';

/// Model representing a modifier in the cart
class CartModifier {
  final int id;
  final String name;
  final double price;
  final int quantity;

  const CartModifier({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });

  /// Calculate total price for this modifier
  double get totalPrice => price * quantity;

  /// Create a copy with updated properties
  CartModifier copyWith({
    int? id,
    String? name,
    double? price,
    int? quantity,
  }) {
    return CartModifier(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartModifier && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CartModifier(id: $id, name: $name, price: $price, quantity: $quantity)';
  }
}

/// Model representing an item in the cart
class CartItemModel {
  final String id;
  final ItemModel item;
  final UnitPriceListModel? selectedUnit;
  final List<CartModifier> modifiers;
  final int quantity;
  final String? specialInstructions;
  final double unitPrice;
  double itemTotal ;

   CartItemModel({
    required this.id,
    required this.item,
    this.selectedUnit,
    required this.modifiers,
    required this.quantity,
    this.specialInstructions,
    required this.unitPrice,
    this.itemTotal= 0,
  });

  /// Calculate total price for this cart item (including modifiers)

  double get totalPrice {
     itemTotal = unitPrice * quantity;
     final modifierTotal = modifiers.fold<double>(
      0.0,
      (sum, modifier) => sum + modifier.totalPrice,
    );
    return itemTotal + modifierTotal;
  }

  /// Calculate price per unit (including modifiers)
  double get pricePerUnit {
    final modifiersTotal = modifiers.fold<double>(
      0.0,
      (sum, modifier) => sum + modifier.totalPrice,
    );
    return unitPrice + modifiersTotal;
  }

  /// Get display name for the selected unit
  String get unitDisplayName => selectedUnit?.unitName ?? 'Regular';

  /// Create a copy with updated properties
  CartItemModel copyWith({
    String? id,
    ItemModel? item,
    UnitPriceListModel? selectedUnit,
    List<CartModifier>? modifiers,
    int? quantity,
    String? specialInstructions,
    double? unitPrice,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      item: item ?? this.item,
      selectedUnit: selectedUnit ?? this.selectedUnit,
      modifiers: modifiers ?? this.modifiers,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItemModel && 
           other.id == id &&
           other.selectedUnit?.unitFkId == selectedUnit?.unitFkId &&
           _modifiersEqual(other.modifiers);
  }

  bool _modifiersEqual(List<CartModifier> otherModifiers) {
    if (modifiers.length != otherModifiers.length) return false;
    for (int i = 0; i < modifiers.length; i++) {
      if (modifiers[i] != otherModifiers[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    id,
    selectedUnit?.unitFkId,
    Object.hashAll(modifiers),
  );

  @override
  String toString() {
    return 'CartItemModel(id: $id, item: ${item.iname}, unit: $unitDisplayName, quantity: $quantity, modifiers: ${modifiers.length})';
  }
}
