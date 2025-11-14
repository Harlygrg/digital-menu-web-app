/// Model for Create Order Response
/// 
/// This model represents the response data received from the Create Order API endpoint.
/// It includes the order ID, online order ID, order number, and response message.
class CreateOrderResponseModel {
  final bool success;
  final String message;
  final int? orderId;
  final int? onlineOrderId;
  final int? orderNo;

  const CreateOrderResponseModel({
    required this.success,
    required this.message,
    this.orderId,
    this.onlineOrderId,
    this.orderNo,
  });

  /// Create from JSON response
  factory CreateOrderResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    
    return CreateOrderResponseModel(
      success: json['success'] ?? false,
      message: data?['message'] ?? '',
      orderId: data?['orderid'],
      onlineOrderId: data?['online_order_id'],
      orderNo: data?['OrderNo'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': {
        'message': message,
        'orderid': orderId,
        'online_order_id': onlineOrderId,
        'OrderNo': orderNo,
      },
    };
  }

  /// Create a copy with updated properties
  CreateOrderResponseModel copyWith({
    bool? success,
    String? message,
    int? orderId,
    int? onlineOrderId,
    int? orderNo,
  }) {
    return CreateOrderResponseModel(
      success: success ?? this.success,
      message: message ?? this.message,
      orderId: orderId ?? this.orderId,
      onlineOrderId: onlineOrderId ?? this.onlineOrderId,
      orderNo: orderNo ?? this.orderNo,
    );
  }

  @override
  String toString() {
    return 'CreateOrderResponseModel(success: $success, message: $message, orderId: $orderId, onlineOrderId: $onlineOrderId, orderNo: $orderNo)';
  }
}

/// Model for order detail item (used in the POST body)
class OrderDetailItem {
  final int slno;
  final int itmId;
  final String itmremarks;
  final int qty;
  final int unitID;
  final double rate;
  final double total;
  final int itmType;

  const OrderDetailItem({
    required this.slno,
    required this.itmId,
    required this.itmremarks,
    required this.qty,
    required this.unitID,
    required this.rate,
    required this.total,
    required this.itmType,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'slno': slno,
      'itmId': itmId,
      'itmremarks': itmremarks,
      'qty': qty,
      'unitID': unitID,
      'rate': rate,
      'total': total,
      'itmType': itmType,
    };
  }

  @override
  String toString() {
    return 'OrderDetailItem(slno: $slno, itmId: $itmId, qty: $qty, rate: $rate, total: $total, itmType: $itmType)';
  }
}

/// Model for create order request body
class CreateOrderRequestModel {
  final double grosstotal;
  final double discount;
  final double servicecharge;
  final double nettotal;
  final int tableID;
  final String orderType;
  final int cid;
  final String? orderNotes;
  final double roundoff;
  final int noOfGuest;
  final List<OrderDetailItem> orderDtls;
  final String defaultsInfo;

  const CreateOrderRequestModel({
    required this.grosstotal,
    required this.discount,
    required this.servicecharge,
    required this.nettotal,
    required this.tableID,
    required this.orderType,
    required this.cid,
    this.orderNotes,
    required this.roundoff,
    required this.orderDtls,
    required this.defaultsInfo,
    required this.noOfGuest
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'grosstotal': grosstotal,
      'discount': discount,
      'servicecharge': servicecharge,
      'nettotal': nettotal,
      'tableID': tableID,
      'OrderType': orderType,
      'cid': cid,
      'orderNotes': orderNotes,
      'roundoff': roundoff,
      'orderDtls': orderDtls.map((item) => item.toJson()).toList(),
      'defaults_info': defaultsInfo,
      'no_of_guest': noOfGuest
    };
  }

  @override
  String toString() {
    return 'CreateOrderRequestModel(grosstotal: $grosstotal, nettotal: $nettotal, tableID: $tableID, orderType: $orderType, cid: $cid, orderDtls: ${orderDtls.length} items)';
  }
}

