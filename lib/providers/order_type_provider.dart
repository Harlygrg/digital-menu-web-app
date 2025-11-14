import 'package:flutter/foundation.dart';
import '../models/order_type_model.dart';
import '../services/api/api_service.dart';

/// Order Type Provider
/// 
/// This provider manages the state for order types (service types like DINE-IN, TAKE-AWAY)
/// It handles fetching order types from the API and managing the selected order type
class OrderTypeProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  /// List of available order types
  List<OrderTypeModel> _orderTypes = [];

  /// Currently selected order type
  OrderTypeModel? _selectedOrderType;

  /// Loading state for fetching order types
  bool _isLoading = false;

  /// Error message if fetching order types fails
  String? _errorMessage;

  /// Getters
  List<OrderTypeModel> get orderTypes => _orderTypes;
  OrderTypeModel? get selectedOrderType => _selectedOrderType;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Check if any order types are available
  bool get hasOrderTypes => _orderTypes.isNotEmpty;

  /// Check if an order type is currently selected
  bool get hasSelectedOrderType => _selectedOrderType != null;

  /// Get only active order types
  List<OrderTypeModel> get activeOrderTypes {
    return _orderTypes.where((orderType) => orderType.isActive).toList();
  }

  /// Fetch order types from the API
  Future<void> fetchOrderTypes() async {
    try {
      _setLoading(true);
      _clearError();

      debugPrint('OrderTypeProvider: Fetching order types...');
      final response = await _apiService.getOrderTypes();

      if (response.success && response.orderTypes.isNotEmpty) {
        _orderTypes = response.activeOrderTypes; // Only get active order types
        debugPrint('OrderTypeProvider: Successfully fetched ${_orderTypes.length} order types');
      } else {
        _setError(response.message.isNotEmpty 
            ? response.message 
            : 'No order types available');
      }
    } catch (e) {
      debugPrint('OrderTypeProvider: Error fetching order types: $e');
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Select an order type
  void selectOrderType(OrderTypeModel orderType) {
    _selectedOrderType = orderType;
    debugPrint('OrderTypeProvider: Selected order type: ${orderType.displayName}');
    notifyListeners();
  }

  /// Clear the selected order type
  void clearSelection() {
    _selectedOrderType = null;
    debugPrint('OrderTypeProvider: Cleared order type selection');
    notifyListeners();
  }

  /// Clear all data and reset the provider state
  void clear() {
    _orderTypes.clear();
    _selectedOrderType = null;
    _errorMessage = null;
    _isLoading = false;
    debugPrint('OrderTypeProvider: Cleared all data');
    notifyListeners();
  }

  /// Refresh order types (useful for retry functionality)
  Future<void> refresh() async {
    await fetchOrderTypes();
  }

  /// Private method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Private method to set error message
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Private method to clear error message
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Private method to extract user-friendly error message from exception
  String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      final message = error.toString();
      if (message.contains('Connection timeout')) {
        return 'Connection timeout. Please check your internet connection.';
      } else if (message.contains('Unauthorized')) {
        return 'Session expired. Please restart the app.';
      } else if (message.contains('Server error')) {
        return 'Server error. Please try again later.';
      } else if (message.contains('Network error')) {
        return 'Network error. Please check your internet connection.';
      } else {
        return message.replaceFirst('Exception: ', '');
      }
    }
    return 'An unexpected error occurred. Please try again.';
  }

  @override
  void dispose() {
    debugPrint('OrderTypeProvider: Disposing provider');
    super.dispose();
  }
}
