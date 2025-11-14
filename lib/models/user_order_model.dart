/// Helper function to safely convert dynamic values to double
double _safeToDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    return double.tryParse(value) ?? 0.0;
  }
  return 0.0;
}

/// Helper function to safely convert dynamic values to int
int _safeToInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}

/// Helper function to safely convert dynamic values to String
String _safeToString(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  if (value is int) return value.toString();
  if (value is double) return value.toString();
  if (value is bool) return value.toString();
  return value.toString();
}

/// Helper function to safely convert dynamic values to bool
bool _safeToBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) {
    return value.toLowerCase() == 'true' || value == '1';
  }
  return false;
}

/// Helper function to safely parse DateTime
DateTime _safeParseDateTime(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is DateTime) return value;
  if (value is String) {
    if (value.isEmpty) return DateTime.now();
    try {
      return DateTime.parse(value);
    } catch (e) {
      return DateTime.now();
    }
  }
  return DateTime.now();
}

/// User Order Model
/// 
/// This model represents a user order from the getUserOrders API response.
/// It contains all the fields returned by the API endpoint.
/// 
/// Order Status Values:
/// - 0 = Pending (order is pending acceptance)
/// - 1 = Accepted (order has been accepted)
/// - 2 = Cancelled (order has been cancelled)
/// - 3 = Completed (order has been completed)
class UserOrder {
  final int id;
  final int orderNo;
  final String onlineOrderId;
  final double grosstotal;
  final double discount;
  final double servicecharge;
  final double nettotal;
  final double taxamnt;
  final double roundoff;
  final String orderType;
  final int tableId;
  final String tableName;
  final int custid;
  final int onlineuserid;
  final bool isdeleted;
  final bool isOnlineOrder;
  final String orderNotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  /// Order status: 0 = Pending, 1 = Accepted, 2 = Cancelled, 3 = Completed
  final int orderStatus;

  const UserOrder({
    required this.id,
    required this.orderNo,
    required this.onlineOrderId,
    required this.grosstotal,
    required this.discount,
    required this.servicecharge,
    required this.nettotal,
    required this.taxamnt,
    required this.roundoff,
    required this.orderType,
    required this.tableId,
    required this.custid,
    required this.onlineuserid,
    required this.isdeleted,
    required this.isOnlineOrder,
    required this.orderNotes,
    required this.createdAt,
    required this.updatedAt,
    required this.orderStatus,
    required this.tableName
  });

  /// Create UserOrder from JSON
  factory UserOrder.fromJson(Map<String, dynamic> json) {
    return UserOrder(
      id: _safeToInt(json['id']),
      orderNo: _safeToInt(json['OrderNo']),
      onlineOrderId: _safeToString(json['online_order_id']),
      grosstotal: _safeToDouble(json['grosstotal']),
      discount: _safeToDouble(json['discount']),
      servicecharge: _safeToDouble(json['servicecharge']),
      nettotal: _safeToDouble(json['nettotal']),
      taxamnt: _safeToDouble(json['taxamnt']),
      roundoff: _safeToDouble(json['roundoff']),
      orderType: _safeToString(json['OrderType']),
      tableId: _safeToInt(json['tableID']),
      custid: _safeToInt(json['custid']),
      onlineuserid: _safeToInt(json['onlineuserid']),
      isdeleted: _safeToBool(json['isdeleted']),
      isOnlineOrder: _safeToBool(json['is_online_order']),
      orderNotes: _safeToString(json['orderNotes']),
      createdAt: _safeParseDateTime(json['created_at']),
      updatedAt: _safeParseDateTime(json['updated_at']),
      orderStatus: _safeToInt(json['order_status']),
      tableName: _safeToString(json['tableName']),
    );
  }

  /// Convert UserOrder to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'OrderNo': orderNo,
      'online_order_id': onlineOrderId,
      'grosstotal': grosstotal,
      'discount': discount,
      'servicecharge': servicecharge,
      'nettotal': nettotal,
      'taxamnt': taxamnt,
      'roundoff': roundoff,
      'OrderType': orderType,
      'tableID': tableId,
      'custid': custid,
      'onlineuserid': onlineuserid,
      'isdeleted': isdeleted,
      'is_online_order': isOnlineOrder,
      'orderNotes': orderNotes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'order_status': orderStatus,
    };
  }

  /// Get order status as a readable string
  /// 0 = Pending, 1 = Accepted, 2 = Cancelled, 3 = Completed
  String get statusDisplayName {
    switch (orderStatus) {
      case 0:
        return 'Pending';
      case 1:
        return 'Accepted';
      case 2:
        return 'Cancelled';
      case 3:
        return 'Completed';
      default:
        return 'Unknown';
    }
  }
  
  /// Check if order is completed
  bool get isOrderCompleted => orderStatus == 3;
  
  /// Check if order is pending
  bool get isPending => orderStatus == 0;
  
  /// Check if order is accepted
  bool get isAccepted => orderStatus == 1;
  
  /// Check if order is cancelled
  bool get isCancelled => orderStatus == 2;

  /// Get formatted total amount
  String get formattedTotal {
    return 'QR${grosstotal.toStringAsFixed(2)}';
  }

  /// Get formatted creation date
  String get formattedCreatedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  /// Get formatted creation time
  String get formattedCreatedTime {
    return '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'UserOrder(id: $id, orderNo: $orderNo, onlineOrderId: $onlineOrderId, grosstotal: $grosstotal, orderStatus: $orderStatus)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserOrder && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// User Orders Response Model
/// 
/// This model represents the complete response from the getUserOrders API.
class UserOrdersResponse {
  final bool success;
  final String orderType;
  final int totalOrders;
  final List<UserOrder> orders;

  const UserOrdersResponse({
    required this.success,
    required this.orderType,
    required this.totalOrders,
    required this.orders,
  });

  /// Create UserOrdersResponse from JSON
  factory UserOrdersResponse.fromJson(Map<String, dynamic> json) {
    return UserOrdersResponse(
      success: _safeToBool(json['success']),
      orderType: _safeToString(json['order_type']),
      totalOrders: _safeToInt(json['total_orders']),
      orders: (json['orders'] as List<dynamic>?)
          ?.map((orderJson) => UserOrder.fromJson(orderJson as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  /// Convert UserOrdersResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'order_type': orderType,
      'total_orders': totalOrders,
      'orders': orders.map((order) => order.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'UserOrdersResponse(success: $success, orderType: $orderType, totalOrders: $totalOrders, orders: ${orders.length})';
  }
}
