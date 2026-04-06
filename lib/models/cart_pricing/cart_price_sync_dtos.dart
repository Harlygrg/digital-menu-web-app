/// DTOs for cart price sync (`getCartPrices`).
///
/// Important: The backend shape is not confirmed yet in this project.
/// Keep all JSON key mapping centralized here so swapping field names later
/// does not touch controller/UI/business logic.
class CartPriceSyncRequestItemDto {
  final int productId;
  final int unitId;
  final int qty;
  final List<int> modifierIds;

  const CartPriceSyncRequestItemDto({
    required this.productId,
    required this.unitId,
    required this.qty,
    required this.modifierIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'unit_id': unitId,
      'qty': qty,
      'modifier_ids': modifierIds,
    };
  }
}

class CartPriceSyncRequestDto {
  final int branchId;
  final int orderTypeId;
  final int tableId;
  final List<CartPriceSyncRequestItemDto> items;

  const CartPriceSyncRequestDto({
    required this.branchId,
    required this.orderTypeId,
    required this.tableId,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'branch_id': branchId,
      'order_type_id': orderTypeId,
      'table_id': tableId,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class CartPriceSyncItemPriceDto {
  final int productId;
  final int unitId;
  final double? unitPrice;
  final bool isAvailable;
  final String? reason;

  const CartPriceSyncItemPriceDto({
    required this.productId,
    required this.unitId,
    required this.unitPrice,
    required this.isAvailable,
    required this.reason,
  });

  static double? _toDoubleOrNull(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static bool _toBool(dynamic v) {
    if (v is bool) return v;
    if (v is int) return v != 0;
    if (v is String) {
      final s = v.toLowerCase();
      return s == '1' || s == 'true' || s == 'yes';
    }
    return false;
  }

  factory CartPriceSyncItemPriceDto.fromJson(Map<String, dynamic> json) {
    return CartPriceSyncItemPriceDto(
      productId: (json['product_id'] as num?)?.toInt() ?? 0,
      unitId: (json['unit_id'] as num?)?.toInt() ?? 0,
      unitPrice: _toDoubleOrNull(json['unit_price']),
      isAvailable: _toBool(json['is_available']),
      reason: json['reason']?.toString(),
    );
  }
}

class CartPriceSyncModifierPriceDto {
  final int productId;
  final int unitId;
  final int modifierId;
  final double? unitPrice;
  final bool isAvailable;
  final String? reason;

  const CartPriceSyncModifierPriceDto({
    required this.productId,
    required this.unitId,
    required this.modifierId,
    required this.unitPrice,
    required this.isAvailable,
    required this.reason,
  });

  static double? _toDoubleOrNull(dynamic v) =>
      CartPriceSyncItemPriceDto._toDoubleOrNull(v);
  static bool _toBool(dynamic v) => CartPriceSyncItemPriceDto._toBool(v);

  factory CartPriceSyncModifierPriceDto.fromJson(Map<String, dynamic> json) {
    return CartPriceSyncModifierPriceDto(
      productId: (json['product_id'] as num?)?.toInt() ?? 0,
      unitId: (json['unit_id'] as num?)?.toInt() ?? 0,
      modifierId: (json['modifier_id'] as num?)?.toInt() ?? 0,
      unitPrice: _toDoubleOrNull(json['unit_price']),
      isAvailable: _toBool(json['is_available']),
      reason: json['reason']?.toString(),
    );
  }
}

class CartPriceSyncDataDto {
  final int branchId;
  final int orderTypeId;
  final int tableId;
  final String? pricingVersion;
  final List<CartPriceSyncItemPriceDto> itemPrices;
  final List<CartPriceSyncModifierPriceDto> modifierPrices;

  const CartPriceSyncDataDto({
    required this.branchId,
    required this.orderTypeId,
    required this.tableId,
    required this.pricingVersion,
    required this.itemPrices,
    required this.modifierPrices,
  });

  factory CartPriceSyncDataDto.fromJson(Map<String, dynamic> json) {
    final itemPricesRaw = json['item_prices'];
    final modifierPricesRaw = json['modifier_prices'];

    return CartPriceSyncDataDto(
      branchId: (json['branch_id'] as num?)?.toInt() ?? 0,
      orderTypeId: (json['order_type_id'] as num?)?.toInt() ?? 0,
      tableId: (json['table_id'] as num?)?.toInt() ?? 0,
      pricingVersion: json['pricing_version']?.toString(),
      itemPrices: itemPricesRaw is List
          ? itemPricesRaw
                .whereType<Map>()
                .map(
                  (e) => CartPriceSyncItemPriceDto.fromJson(
                    e.cast<String, dynamic>(),
                  ),
                )
                .toList()
          : const [],
      modifierPrices: modifierPricesRaw is List
          ? modifierPricesRaw
                .whereType<Map>()
                .map(
                  (e) => CartPriceSyncModifierPriceDto.fromJson(
                    e.cast<String, dynamic>(),
                  ),
                )
                .toList()
          : const [],
    );
  }
}

class CartPriceSyncResponseDto {
  final bool success;
  final String message;
  final CartPriceSyncDataDto? data;

  const CartPriceSyncResponseDto({
    required this.success,
    required this.message,
    required this.data,
  });

  static bool _toBool(dynamic v) => CartPriceSyncItemPriceDto._toBool(v);

  factory CartPriceSyncResponseDto.fromJson(Map<String, dynamic> json) {
    final dataRaw = json['data'];
    return CartPriceSyncResponseDto(
      success: _toBool(json['success']),
      message: json['message']?.toString() ?? '',
      data: dataRaw is Map
          ? CartPriceSyncDataDto.fromJson(dataRaw.cast<String, dynamic>())
          : null,
    );
  }
}
