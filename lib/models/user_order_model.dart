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

/// Order Detail Model
/// 
/// This model represents an individual item in the order_details array.
/// Each item can be a normal item (itmtype=0) or a modifier/addon (itmtype=1).
class OrderDetail {
  final int slno;
  final int itemId;
  final String itemname;
  final int itmtype; // 0 = normal item, 1 = modifier/addon
  final int qty;
  final double rate;
  final double total;
  final String? itmremarks;
  final int unitID;
  final String unitname;
  final int? mainItemSlno; // Reference to parent item's slno if this is a modifier
  
  const OrderDetail({
    required this.slno,
    required this.itemId,
    required this.itemname,
    required this.itmtype,
    required this.qty,
    required this.rate,
    required this.total,
    this.itmremarks,
    required this.unitID,
    required this.unitname,
    this.mainItemSlno,
  });
  
  /// Create OrderDetail from JSON
  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      slno: _safeToInt(json['slno']),
      itemId: _safeToInt(json['item_id']),
      itemname: _safeToString(json['itemname']),
      itmtype: _safeToInt(json['itmtype']),
      qty: _safeToInt(json['qty']),
      rate: _safeToDouble(json['rate']),
      total: _safeToDouble(json['total']),
      itmremarks: json['itmremarks'] != null ? _safeToString(json['itmremarks']) : null,
      unitID: _safeToInt(json['unitID']),
      unitname: _safeToString(json['unitname']),
      mainItemSlno: json['main_item_slno'] != null ? _safeToInt(json['main_item_slno']) : null,
    );
  }
  
  /// Convert OrderDetail to JSON
  Map<String, dynamic> toJson() {
    return {
      'slno': slno,
      'item_id': itemId,
      'itemname': itemname,
      'itmtype': itmtype,
      'qty': qty,
      'rate': rate,
      'total': total,
      'itmremarks': itmremarks,
      'unitID': unitID,
      'unitname': unitname,
      'main_item_slno': mainItemSlno,
    };
  }
  
  /// Check if this is a normal item
  bool get isNormalItem => itmtype == 0;
  
  /// Check if this is a modifier/addon
  bool get isModifier => itmtype == 1;
  
  /// Get formatted price
  String get formattedPrice {
    return 'QR ${rate.toStringAsFixed(2)}';
  }
  
  /// Get formatted total
  String get formattedTotal {
    return 'QR ${total.toStringAsFixed(2)}';
  }
  
  @override
  String toString() {
    return 'OrderDetail(slno: $slno, itemId: $itemId, itemname: $itemname, itmtype: $itmtype, qty: $qty)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderDetail && other.slno == slno && other.itemId == itemId;
  }
  
  @override
  int get hashCode => slno.hashCode ^ itemId.hashCode;
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
  final int noOfGuest;
  final List<OrderDetail> orderDetails;
  
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
    required this.tableName,
    required this.noOfGuest,
    required this.orderDetails,
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
      noOfGuest: _safeToInt(json['no_of_guest']),
      orderDetails: (json['order_details'] as List<dynamic>?)
          ?.map((detailJson) => OrderDetail.fromJson(detailJson as Map<String, dynamic>))
          .toList() ?? [],
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
      'tableName': tableName,
      'no_of_guest': noOfGuest,
      'order_details': orderDetails.map((detail) => detail.toJson()).toList(),
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
