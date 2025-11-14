/// Customer Model
/// 
/// This file contains models for customer-related API requests and responses.

/// Customer Add Request Model
/// 
/// Request model for adding a new customer
class CustomerAddRequest {
  final String phone;
  final String name;
  final int cid;

  CustomerAddRequest({
    required this.phone,
    required this.name,
    required this.cid
  });

  /// Convert request to JSON format
  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'name': name,
      'cid': cid
    };
  }
}

/// Customer Add Response Model
/// 
/// Response model for customer addition
class CustomerAddResponse {
  final bool success;
  final String message;
  final int? customerId;

  CustomerAddResponse({
    required this.success,
    required this.message,
    this.customerId,
  });

  /// Create instance from JSON
  factory CustomerAddResponse.fromJson(Map<String, dynamic> json) {
    return CustomerAddResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      customerId: json['customer_id'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'customer_id': customerId,
    };
  }
}

