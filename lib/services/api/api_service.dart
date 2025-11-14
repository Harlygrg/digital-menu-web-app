
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../constants/api_constants.dart';
import '../../storage/local_storage.dart';
import '../../models/table_model.dart';
import '../../models/order_type_model.dart';
import '../../models/branch_model.dart';
import '../../models/create_order_response_model.dart';
import '../../models/customer_model.dart';
import '../../models/user_order_model.dart';

/// API Service for handling HTTP requests
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Dio? _dio;
  bool _isInitialized = false;

  /// Initialize the Dio client
  void initialize() {
    if (_isInitialized) {
      print('API service already initialized, skipping...');
      return;
    }
    
    print('Initializing API service...');
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: Duration(milliseconds: ApiConstants.connectionTimeout),
      receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add token interceptor for authentication
    _dio!.interceptors.add(TokenInterceptor());
    
    // Add retry interceptor for failed requests
    _dio!.interceptors.add(RetryInterceptor());
    
    _isInitialized = true;
    print('API service initialized successfully');
  }

  /// Ensure the API service is initialized before use
  void _ensureInitialized() {
    if (!_isInitialized) {
      initialize();
    }
  }
  void setupDioLogging() {
    debugPrint('setupDioLogging called');
    if (_dio != null) {
      _dio!.interceptors.add(
        LogInterceptor(
          request: true,           // Logs request method + URL
          requestHeader: true,     // Logs request headers
          requestBody: true,       // Logs request body (data)
          responseHeader: false,   // Headers can be long — optional
          responseBody: true,      // Logs response data
          error: true,             // Logs errors
          logPrint: (obj) => print(obj), // You can replace this with custom logger
        ),
      );
    }
  }

  /// Get product related data
  Future<Map<String, dynamic>> getProductRelatedData({required String branchId}) async {
    try {
      _ensureInitialized();
      final response = await _dio!.get(
       ApiConstants.getProduct,
        queryParameters: {'branch_id': branchId},
      );
      debugPrint('getProducts:${response.data}');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load product data: ${response.statusCode}');
      }
    } on DioException catch (e) {
      setupDioLogging();
      print('DioException during fetch product: ${e.message}');
      _handleDioError(e);
      rethrow;
    } catch (e) {
      print('Error fetching product related data: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> registerGuestUserApiCall({
    required String deviceId,
  }) async {
    print('registerGuestUserApiCall');
    print('Device ID: $deviceId');
    try {
      _ensureInitialized();
      
      debugPrint('Making POST request to ${ApiConstants.guestUserRegister}');
      var data = {
        "device":  deviceId,
        "login_type": "from web",
      };
      debugPrint('registerGuestUserApiCall data: ${data}');
      final response = await _dio!.post(
        ApiConstants.guestUserRegister,
        data: data,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to register guest user: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException during guest user registration: ${e.message}');
      _handleDioError(e);
      rethrow;
    } catch (e) {
      print('Error registering guest user: $e');
      rethrow;
    }
  }

  /// Refresh access token
  ///
  /// This method calls the refresh token API to get a new access token.
  /// It automatically uses the refresh token stored in local storage.
  ///
  /// Returns: A Map containing the response data with new tokens
  ///
  /// Throws:
  /// - [DioException] on network errors
  /// - [Exception] on token refresh failures
  Future<Map<String, dynamic>> refreshTokenApiCall() async {
    debugPrint('🔄 refreshTokenApiCall - calling refresh token endpoint');
    
    try {
      _ensureInitialized();
      
      debugPrint('Making POST request to ${ApiConstants.refreshToken}');
      
      // The refresh token will be automatically injected by TokenInterceptor
      final response = await _dio!.post(
        ApiConstants.refreshToken,
        options: Options(
          extra: {
            'skipTokenRefresh': true, // Skip automatic refresh for this call
          },
        ),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Refresh token API call successful');
        return response.data;
      } else {
        throw Exception('Failed to refresh token: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('❌ DioException during token refresh: ${e.message}');
      _handleDioError(e);
      rethrow;
    } catch (e) {
      debugPrint('❌ Error refreshing token: $e');
      rethrow;
    }
  }

  /// Add user FCM token
    Future<Map<String, dynamic>> addUserFcmToken({
    required String deviceId,
    required String fcmToken,
  }) async {
    print('addUserFcmToken called');
    try {
      _ensureInitialized();
      var bodyParams = {
        "device": deviceId,
        "token": fcmToken,
        "usertype": "user",
      };
      
      print('Making POST request to ${ApiConstants.addUserFcm}::${bodyParams}');
      final response = await _dio!.post(
        ApiConstants.addUserFcm,
        data: bodyParams,
      );

      if (response.statusCode == 200) {
        print('FCM token added successfully: ${response.data}');
        return response.data;
      } else {
        throw Exception('Failed to add FCM token: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException during FCM token addition: ${e.message}');
      _handleDioError(e);
      rethrow;
    } catch (e) {
      print('Error adding FCM token: $e');
      rethrow;
    }
  }

  /// Get table list for a specific branch
  /// 
  /// [branchId] - The branch ID to fetch tables for
  /// Returns a [TableListResponse] containing floors and tables data
  Future<TableListResponse> getTableList({required String branchId}) async {
    try {
      _ensureInitialized();
      
      debugPrint('Fetching table list for branch: $branchId');
      final response = await _dio!.get(
        'getTableList',
        queryParameters: {'branch_id': branchId},
      );
      
      debugPrint('Table list API response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        debugPrint('Table list API response data: ${response.data}');
        return TableListResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load table list: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('DioException during table list fetch: ${e.message}');
      _handleDioError(e);
      rethrow;
    } catch (e) {
      debugPrint('Error fetching table list: $e');
      rethrow;
    }
  }

  /// Get order types (service types like DINE-IN, TAKE-AWAY)
  /// 
  /// Returns an [OrderTypesResponse] containing available order types
  Future<OrderTypesResponse> getOrderTypes() async {
    try {
      _ensureInitialized();
      
      debugPrint('Fetching order types...');
      final response = await _dio!.get(ApiConstants.getOrderTypes);
      
      debugPrint('Order types API response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        debugPrint('Order types API response data: ${response.data}');
        return OrderTypesResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load order types: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('DioException during order types fetch: ${e.message}');
      _handleDioError(e);
      rethrow;
    } catch (e) {
      debugPrint('Error fetching order types: $e');
      rethrow;
    }
  }

  /// Get branch list
  /// 
  /// Returns a [BranchListResponse] containing available branches
  Future<BranchListResponse> getBranchList() async {
    try {
      _ensureInitialized();
      
      debugPrint('Fetching branch list...');
      final response = await _dio!.get(ApiConstants.getBranchList);
      
      debugPrint('Branch list API response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        debugPrint('Branch list API response data: ${response.data}');
        return BranchListResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load branch list: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('DioException during branch list fetch: ${e.message}');
      _handleDioError(e);
      rethrow;
    } catch (e) {
      debugPrint('Error fetching branch list: $e');
      rethrow;
    }
  }

  /// Create order
  /// 
  /// [requestData] - The order request data containing cart items, table info, etc.
  /// Returns a [CreateOrderResponseModel] containing order details
  Future<CreateOrderResponseModel> createOrder({
    required CreateOrderRequestModel requestData,
  }) async {
    try {
      _ensureInitialized();
      
      debugPrint('Creating order...');
      debugPrint('Order request data: ${requestData.toJson()}');
      
      final response = await _dio!.post(
        ApiConstants.createOrder,
        data: requestData.toJson(),
      );
      
      debugPrint('Create order API response status: ${response.statusCode}');
      debugPrint('Create order API response data: ${response.data}');
      
      if (response.statusCode == 200) {
        return CreateOrderResponseModel.fromJson(response.data);
      } else {
        throw Exception('Failed to create order: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('DioException during order creation: ${e.message}');
      _handleDioError(e);
      rethrow;
    } catch (e) {
      debugPrint('Error creating order: $e');
      rethrow;
    }
  }

  /// Add customer
  /// 
  /// [request] - The customer request data containing name and phone
  /// Returns a [CustomerAddResponse] containing customer ID
  Future<CustomerAddResponse> addCustomer({
    required CustomerAddRequest request,
  }) async {
    try {
      _ensureInitialized();
      
      debugPrint('Adding customer...');
      debugPrint('Customer request data: ${request.toJson()}');
      
      final response = await _dio!.post(
        ApiConstants.addCustomer,
        data: request.toJson(),
      );
      
      debugPrint('Add customer API response status: ${response.statusCode}');
      debugPrint('Add customer API response data: ${response.data}');
      
      if (response.statusCode == 200) {
        return CustomerAddResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to add customer: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('DioException during customer addition: ${e.message}');
      _handleDioError(e);
      rethrow;
    } catch (e) {
      debugPrint('Error adding customer: $e');
      rethrow;
    }
  }

  /// Check product availability
  /// 
  /// [productId] - The product ID to check availability for
  /// Returns true if product is available, false otherwise
  Future<bool> checkProductAvailability({required int productId}) async {
    try {
      _ensureInitialized();
      
      debugPrint('Checking product availability for product ID: $productId');
      
      final response = await _dio!.get(
        ApiConstants.checkProductAvailability,
        queryParameters: {
          'product_id': productId,
        },
      )     ;
      
      debugPrint('Check product availability API response status: ${response.statusCode}');
      debugPrint('Check product availability API response data: ${response.data}');
      
      if (response.statusCode == 200) {
        // Success response means product is available.
        return true;
      } else {
        // Any other status code means product is not available.
        return false;
      }
    } on DioException catch (e) {
      debugPrint('DioException during product availability check: ${e.message}');
      
      // Handle specific error cases
      if (e.response?.statusCode == 400) {
        throw Exception('Product ID missing — please try again.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      } else if (e.response?.statusCode == 404) {
        print('e.response:${e.response}');
        print('e.message:${e.message}');
        throw Exception('⚠️ This item is no longer available. Refreshing menu...');
      } else {
        throw Exception('Unable to check item availability. Please try again.');
      }
    } catch (e) {
      debugPrint('Error checking product availability: $e');
      throw Exception('Unable to check item availability. Please try again.');
    }
  }

  /// Get user orders
  /// 
  /// Returns a [UserOrdersResponse] containing user's orders
  Future<UserOrdersResponse> getUserOrders() async {
    try {
      _ensureInitialized();
      
      debugPrint('Fetching user orders...');
      final response = await _dio!.get(ApiConstants.getUserOrders);
      
      debugPrint('Get user orders API response status: ${response.statusCode}');
      debugPrint('Get user orders API response data: ${response.data}');
      
      if (response.statusCode == 200) {
        return UserOrdersResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load user orders: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('DioException during user orders fetch: ${e.message}');
      _handleDioError(e);
      rethrow;
    } catch (e) {
      debugPrint('Error fetching user orders: $e');
      rethrow;
    }
  }

  /// Cancel order
  /// 
  /// [orderId] - The order ID to cancel
  /// Returns a Map containing the response data with success status
  /// Throws specific exceptions for different error cases (400, 401, 404)
  Future<Map<String, dynamic>> cancelOrder({required int orderId}) async {
    try {
      _ensureInitialized();
      
      debugPrint('Cancelling order: $orderId');
      final response = await _dio!.post(
        ApiConstants.cancelOrder,
        data: {
          'order_id': orderId,
        },
      );
      
      debugPrint('Cancel order API response status: ${response.statusCode}');
      debugPrint('Cancel order API response data: ${response.data}');
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to cancel order: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('DioException during order cancellation: ${e.message}');
      
      // Handle specific error cases for cancel order
      if (e.response?.statusCode == 400) {
        throw Exception('Order ID is required');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Order not found.');
      } else {
        _handleDioError(e);
        rethrow;
      }
    } catch (e) {
      debugPrint('Error cancelling order: $e');
      rethrow;
    }
  }

  /// Handles Dio errors and throws appropriate exceptions
  static void _handleDioError(DioException error) {
    print('DioException details: ${error.toString()}');
    print('Error type: ${error.type}');
    print('Error message: ${error.message}');
    print('Response data: ${error.response?.data}');
    print('Response status code: ${error.response?.statusCode}');

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        throw Exception('Connection timeout. Please check your internet connection.');
      case DioExceptionType.sendTimeout:
        throw Exception('Send timeout. Please try again.');
      case DioExceptionType.receiveTimeout:
        throw Exception('Receive timeout. Please try again.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        
        if (statusCode == 400) {
          throw Exception('Bad request. Please check your input.');
        } else if (statusCode == 401) {
          // 401 errors with invalid tokens are now handled automatically by TokenInterceptor
          // This error will only be thrown if token refresh also fails
          throw Exception('Authentication failed. Please restart the app.');
        } else if (statusCode == 404) {
          throw Exception('Resource not found.');
        } else if (statusCode == 500) {
          throw Exception('Server error. Please try again later.');
        } else {
          throw Exception('Server error (${statusCode}). Please try again.');
        }
      case DioExceptionType.cancel:
        throw Exception('Request cancelled.');
      case DioExceptionType.connectionError:
        throw Exception('Connection error. Please check your internet connection and server availability.');
      case DioExceptionType.unknown:
        if (error.message?.contains('XMLHttpRequest') == true) {
          throw Exception('Network error. Please check your internet connection and try again.');
        }
        throw Exception('Unknown network error: ${error.message}');
      default:
        throw Exception('Network error. Please try again.');
    }
  }
}

/// Retry Interceptor
///
/// This interceptor automatically retries failed requests with exponential backoff
class RetryInterceptor extends Interceptor {
  static const int maxRetries = 3;
  static const List<Duration> retryDelays = [
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 3),
  ];

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;

      if (retryCount < maxRetries) {
        print('Retrying request (${retryCount + 1}/$maxRetries) after ${retryDelays[retryCount]}');

        await Future.delayed(retryDelays[retryCount]);

        err.requestOptions.extra['retryCount'] = retryCount + 1;

        try {
          final apiService = ApiService();
          if (apiService._dio != null) {
            final response = await apiService._dio!.fetch(err.requestOptions);
            return handler.resolve(response);
          } else {
            return handler.next(err);
          }
        } catch (e) {
          return handler.next(err);
        }
      }
    }

    return handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.sendTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.type == DioExceptionType.connectionError ||
           (err.type == DioExceptionType.unknown &&
            err.message?.contains('XMLHttpRequest') == true);
  }
}

/// Token Interceptor
///
/// This interceptor automatically:
/// 1. Injects access and refresh tokens into request headers
/// 2. Detects "Invalid access token" errors (401 responses)
/// 3. Automatically refreshes expired tokens
/// 4. Retries failed requests with the new token
///
/// Excluded endpoints (no automatic refresh):
/// - Guest user registration endpoint
/// - Refresh token endpoint itself
/// - Add FCM token endpoint
class TokenInterceptor extends Interceptor {
  static bool _isRefreshing = false;
  static final List<Function> _requestsWaitingForRefresh = [];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip token injection for guest user registration endpoint
    if (options.path.contains(ApiConstants.guestUserRegister)) {
      return handler.next(options);
    }

    // Get tokens from local storage
    final accessToken = await LocalStorage.getAccessToken();
    final refreshToken = await LocalStorage.getRefreshToken();

    // Inject tokens into headers if available
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    if (refreshToken != null) {
      options.headers['X-Refresh-Token'] = refreshToken;
    }

    print('Request headers: ${options.headers}');

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Check if this is a 401 error with invalid token message
    if (err.response?.statusCode == 401) {
      final responseData = err.response?.data;
      final message = responseData is Map ? responseData['message']?.toString() ?? '' : '';
      
      debugPrint('🔴 Received 401 error. Message: $message');

      // Check if this error is due to an invalid/expired access token
      final isInvalidToken = message.toLowerCase().contains('invalid access token') || 
                             message.toLowerCase().contains('access token');

      // Exclude refresh token endpoint and FCM token endpoint from auto-refresh
      final isRefreshEndpoint = err.requestOptions.path.contains(ApiConstants.refreshToken);
      final isFcmEndpoint = err.requestOptions.path.contains(ApiConstants.addUserFcm);
      final skipRefresh = err.requestOptions.extra['skipTokenRefresh'] == true;

      // Determine if we should attempt token refresh
      final shouldRefreshToken = isInvalidToken && 
                                 !isRefreshEndpoint && 
                                 !isFcmEndpoint && 
                                 !skipRefresh;

      if (shouldRefreshToken) {
        debugPrint('🔄 Invalid access token detected. Attempting to refresh...');

        try {
          // If already refreshing, wait for the current refresh to complete
          if (_isRefreshing) {
            debugPrint('⏳ Token refresh already in progress. Queuing request...');
            
            // Wait for refresh to complete
            await _waitForTokenRefresh();
            
            // Retry the request with new token
            return _retryRequest(err.requestOptions, handler);
          }

          // Set refreshing flag
          _isRefreshing = true;

          // Import the GuestUserApi dynamically to avoid circular dependency
          // Call the refresh token method
          debugPrint('🔄 Calling refreshAccessToken...');
          
          // We need to call the refresh through the guest_user_api
          // This will be imported at the top of the file
          final refreshResponse = await _performTokenRefresh();
          
          if (refreshResponse) {
            debugPrint('✅ Token refreshed successfully. Retrying original request...');
            
            // Notify all waiting requests
            _notifyWaitingRequests();
            
            // Retry the original request with new token
            return _retryRequest(err.requestOptions, handler);
          } else {
            debugPrint('❌ Token refresh failed');
            await LocalStorage.clearAuthData();
            _notifyWaitingRequests();
            return handler.next(err);
          }
        } catch (e) {
          debugPrint('❌ Error during token refresh: $e');
          _isRefreshing = false;
          await LocalStorage.clearAuthData();
          _notifyWaitingRequests();
          return handler.next(err);
        } finally {
          _isRefreshing = false;
        }
      } else {
        // Not an invalid token error or excluded endpoint
        if (isRefreshEndpoint) {
          debugPrint('🔴 Refresh token endpoint failed. Clearing auth data.');
          await LocalStorage.clearAuthData();
        }
        return handler.next(err);
      }
    }

    return handler.next(err);
  }

  /// Performs the actual token refresh by calling the API
  Future<bool> _performTokenRefresh() async {
    try {
      final apiService = ApiService();
      final responseData = await apiService.refreshTokenApiCall();
      
      // Check if refresh was successful
      if (responseData['success'] == true && responseData['data'] != null) {
        final data = responseData['data'];
        final newAccessToken = data['access_token'];
        final newRefreshToken = data['refresh_token'];
        
        if (newAccessToken != null && newRefreshToken != null) {
          // Save new tokens
          await LocalStorage.saveTokens(newAccessToken, newRefreshToken);
          debugPrint('✅ Tokens saved successfully after refresh');
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('❌ Token refresh failed: $e');
      return false;
    }
  }

  /// Retries the original request with the new access token
  Future<void> _retryRequest(
    RequestOptions requestOptions,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      debugPrint('🔄 Retrying original request: ${requestOptions.path}');
      
      // Get the new access token
      final newAccessToken = await LocalStorage.getAccessToken();
      
      if (newAccessToken != null) {
        // Update the request headers with new token
        requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        
        // Retry the request
        final apiService = ApiService();
        if (apiService._dio != null) {
          final response = await apiService._dio!.fetch(requestOptions);
          return handler.resolve(response);
        }
      }
      
      // If we can't retry, return the original error
      return handler.reject(
        DioException(
          requestOptions: requestOptions,
          error: 'Failed to retry request after token refresh',
        ),
      );
    } catch (e) {
      debugPrint('❌ Error retrying request: $e');
      return handler.reject(
        DioException(
          requestOptions: requestOptions,
          error: e,
        ),
      );
    }
  }

  /// Waits for ongoing token refresh to complete
  Future<void> _waitForTokenRefresh() async {
    int attempts = 0;
    const maxAttempts = 50; // 5 seconds max wait
    const waitDuration = Duration(milliseconds: 100);

    while (_isRefreshing && attempts < maxAttempts) {
      await Future.delayed(waitDuration);
      attempts++;
    }

    if (attempts >= maxAttempts) {
      debugPrint('⚠️ Token refresh wait timeout');
    }
  }

  /// Notifies all waiting requests that token refresh is complete
  void _notifyWaitingRequests() {
    for (var callback in _requestsWaitingForRefresh) {
      callback();
    }
    _requestsWaitingForRefresh.clear();
  }
}


