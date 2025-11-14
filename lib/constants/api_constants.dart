/// API Constants
/// 
/// This class contains all the API-related constants used throughout the application.
/// It centralizes the base URL and any other API configuration constants.
class ApiConstants {
  /// Base URL for all API endpoints
  static const String baseUrl = "https://msibusinesssolutions.com/digitalmenu/api/v1/";//"https://msibusinesssolutions.com/johny_web_qr/api/v1/";
  
  /// Guest user registration endpoint
  static const String guestUserRegister = "guestuserregister";

  /// Get product end point
  static const String getProduct = "getProductRelatedData";
  
  /// Get order types endpoint
  static const String getOrderTypes = "getOrderTypes";
  
  /// Get branch list endpoint
  static const String getBranchList = "getBranchList";
  
  /// Create order endpoint
  static const String createOrder = "createOrder";
  
  /// Add customer endpoint
  static const String addCustomer = "addOrderCustomer";
  
  /// Check product availability endpoint
  static const String checkProductAvailability = "checkProductAvailability";
  
  /// Get user orders endpoint
  static const String getUserOrders = "getUserOrders";
  
  /// Cancel order endpoint
  static const String cancelOrder = "cancelOrder";
  
  /// Add user FCM token endpoint
  static const String addUserFcm = "adduserfcm";
  
  /// Refresh token endpoint
  static const String refreshToken = "refreshToken";
  
  /// Connection timeout duration in milliseconds
  static const int connectionTimeout = 30000;
  
  /// Receive timeout duration in milliseconds
  static const int receiveTimeout = 30000;
}

