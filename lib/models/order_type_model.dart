/// Order Type Model
/// 
/// This model represents an order type (service type) such as DINE-IN or TAKE-AWAY
/// It maps the response fields from the getOrderTypes API endpoint.
class OrderTypeModel {
  /// Unique identifier for the order type
  final int id;
  
  /// The name of the order type (e.g., "DINE-IN", "TAKE-AWAY")
  final String orderType;
  
  /// Whether this order type is inactive (0 = active, 1 = inactive)
  final int inactive;
  
  /// Company/Branch ID this order type belongs to
  final int cid;

  const OrderTypeModel({
    required this.id,
    required this.orderType,
    required this.inactive,
    required this.cid,
  });

  /// Factory constructor to create OrderTypeModel from JSON
  factory OrderTypeModel.fromJson(Map<String, dynamic> json) {
    return OrderTypeModel(
      id: json['ID'] ?? 0,
      orderType: json['OrderType'] ?? '',
      inactive: json['inactive'] ?? 0,
      cid: json['CID'] ?? 0,
    );
  }

  /// Convert OrderTypeModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'OrderType': orderType,
      'inactive': inactive,
      'CID': cid,
    };
  }

  /// Check if this order type is active
  bool get isActive => inactive == 0;

  /// Get a user-friendly display name for the order type
  String get displayName {
    switch (orderType.toUpperCase()) {
      case 'DINE-IN':
        return 'Dine-In';
      case 'TAKE-AWAY':
        return 'Take-Away';
      default:
        return orderType;
    }
  }

  /// Get an appropriate icon for the order type
  String get iconName {
    switch (orderType.toUpperCase()) {
      case 'DINE-IN':
        return 'restaurant';
      case 'TAKE-AWAY':
        return 'takeaway_bag';
      default:
        return 'shopping_bag';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderTypeModel &&
        other.id == id &&
        other.orderType == orderType &&
        other.inactive == inactive &&
        other.cid == cid;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        orderType.hashCode ^
        inactive.hashCode ^
        cid.hashCode;
  }

  @override
  String toString() {
    return 'OrderTypeModel(id: $id, orderType: $orderType, inactive: $inactive, cid: $cid)';
  }
}

/// Order Types Response Model
/// 
/// This model represents the complete response from the getOrderTypes API endpoint
class OrderTypesResponse {
  /// Whether the API call was successful
  final bool success;
  
  /// The message from the API response
  final String message;
  
  /// List of order types returned from the API
  final List<OrderTypeModel> orderTypes;

  const OrderTypesResponse({
    required this.success,
    required this.message,
    required this.orderTypes,
  });

  /// Factory constructor to create OrderTypesResponse from JSON
  factory OrderTypesResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    
    return OrderTypesResponse(
      success: json['success'] ?? false,
      message: data?['message'] ?? '',
      orderTypes: data?['order_types'] != null
          ? (data!['order_types'] as List)
              .map((item) => OrderTypeModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : <OrderTypeModel>[],
    );
  }

  /// Convert OrderTypesResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': {
        'message': message,
        'order_types': orderTypes.map((orderType) => orderType.toJson()).toList(),
      },
    };
  }

  /// Get only active order types
  List<OrderTypeModel> get activeOrderTypes {
    return orderTypes.where((orderType) => orderType.isActive).toList();
  }

  @override
  String toString() {
    return 'OrderTypesResponse(success: $success, message: $message, orderTypes: $orderTypes)';
  }
}
