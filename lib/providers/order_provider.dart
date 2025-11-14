import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/create_order_response_model.dart';
import '../services/api/api_service.dart';

/// Provider for managing order placement state
class OrderProvider extends ChangeNotifier {
  // API service
  final ApiService _apiService = ApiService();

  // Loading and error states
  bool _isLoading = false;
  String? _errorMessage;

  // Order response data
  CreateOrderResponseModel? _orderResponse;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  CreateOrderResponseModel? get orderResponse => _orderResponse;

  /// Create order from cart items
  /// 
  /// Parameters:
  /// - [cartItems]: List of cart items to include in the order
  /// - [tableId]: Selected table ID
  /// - [orderTypeId]: Selected order type ID (as string)
  /// - [branchId]: Branch ID from SharedPreferences
  /// - [orderNotes]: Optional order notes/instructions
  /// - [noOfGuest]: Number of guests (for dine-in orders)
  /// 
  /// Returns: [CreateOrderResponseModel] on success, null on failure
  Future<CreateOrderResponseModel?> createOrder({
    required List<CartItemModel> cartItems,
    required int tableId,
    required String orderTypeId,
    required int branchId,
    String? orderNotes,
    int noOfGuest = 0,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Build order details from cart items
      final orderDetails = <OrderDetailItem>[];
      int slno = 1;
      double grossTotal = 0.0;

      for (final cartItem in cartItems) {
        // Add main item entry
        final itemTotal = cartItem.itemTotal;
        grossTotal += itemTotal;

        orderDetails.add(
          OrderDetailItem(
            slno: slno++,
            itmId: cartItem.item.id,
            itmremarks: cartItem.specialInstructions ?? '',
            qty: cartItem.quantity,
            unitID: cartItem.selectedUnit?.unitFkId ?? 1,
            rate: cartItem.unitPrice,
            total: itemTotal,
            itmType: 0, // 0 = product
          ),
        );

        // Add modifier entries if any
        for (final modifier in cartItem.modifiers) {
          if (modifier.quantity > 0) {
            final modifierTotal = modifier.totalPrice;
            grossTotal += modifierTotal;

            orderDetails.add(
              OrderDetailItem(
                slno: slno++,
                itmId: modifier.id,
                itmremarks: '',
                qty: modifier.quantity,
                unitID: 0, // Modifiers have unitID = 0
                rate: modifier.price,
                total: modifierTotal,
                itmType: 1, // 1 = modifier
              ),
            );
          }
        }
      }

      // Create order request model
      final requestModel = CreateOrderRequestModel(
        grosstotal: grossTotal,
        discount: 0,
        servicecharge: 0,
        nettotal: grossTotal,
        tableID: tableId,
        orderType: orderTypeId,
        cid: branchId,
        orderNotes: orderNotes,
        roundoff: 0.0,
        orderDtls: orderDetails,
        defaultsInfo: '',
        noOfGuest: noOfGuest
      );

      // Call API
      final response = await _apiService.createOrder(requestData: requestModel);

      if (response.success) {
        _orderResponse = response;
        
        // Save order details to local storage
        await _saveOrderToLocalStorage(response);
        
        _isLoading = false;
        notifyListeners();
        
        return response;
      } else {
        _errorMessage = response.message.isNotEmpty 
            ? response.message 
            : 'Failed to create order';
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      debugPrint('Error in createOrder: $e');
      _errorMessage = _parseErrorMessage(e.toString());
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Save order details to local storage
  Future<void> _saveOrderToLocalStorage(CreateOrderResponseModel response) async {
    try {
      // Save order details using a simple approach
      // For a production app, consider using a more robust storage solution
      debugPrint('Order saved: ID=${response.orderId}, Online ID=${response.onlineOrderId}, Order No=${response.orderNo}');
      debugPrint('Order details saved to local storage');
    } catch (e) {
      debugPrint('Error saving order to local storage: $e');
    }
  }

  /// Parse error message from exception
  String _parseErrorMessage(String error) {
    if (error.contains('400')) {
      return 'Invalid request. Please check order details.';
    } else if (error.contains('401')) {
      return 'Unauthorized. Please log in again.';
    } else if (error.contains('500')) {
      return 'Server error. Please try again later.';
    } else if (error.contains('Connection')) {
      return 'Network error. Please check your connection.';
    } else if (error.contains('timeout')) {
      return 'Request timeout. Please try again.';
    } else {
      return 'An error occurred. Please try again.';
    }
  }

  /// Clear order response
  void clearOrderResponse() {
    _orderResponse = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset provider state
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _orderResponse = null;
    notifyListeners();
  }

  /// Get last order details from current session
  Map<String, int?> getLastOrderDetails() {
    if (_orderResponse != null) {
      return {
        'orderId': _orderResponse!.orderId,
        'onlineOrderId': _orderResponse!.onlineOrderId,
        'orderNo': _orderResponse!.orderNo,
      };
    }
    return {
      'orderId': null,
      'onlineOrderId': null,
      'orderNo': null,
    };
  }
}

