/// Customer Repository
///
/// This repository handles all customer-related operations including
/// API calls and local storage management for customer data.

import '../services/api/api_service.dart';
import '../storage/local_storage.dart';
import '../models/customer_model.dart';
import 'package:digital_menu_order/utils/app_debug_log.dart';

/// Repository for managing customer data
class CustomerRepository {
  // API service instance
  final ApiService _apiService = ApiService();

  /// Add a new customer via API
  ///
  /// Parameters:
  /// - [name]: Customer's name
  /// - [phone]: Customer's phone number
  ///
  /// Returns: [CustomerAddResponse] on success
  /// Throws: Exception on failure
  Future<CustomerAddResponse> addCustomer({
    required String name,
    required String phone,
  }) async {
    try {
      appDebugLog(
        'CustomerRepository: Adding customer - name: $name, phone: $phone',
      );
      int branchId = 1;
      final request = CustomerAddRequest(
        name: name,
        phone: phone,
        cid: branchId,
      );

      final response = await _apiService.addCustomer(request: request);

      appDebugLog(
        'CustomerRepository: Customer added successfully - ID: ${response.customerId}',
      );

      return response;
    } catch (e) {
      appDebugLog('CustomerRepository: Error adding customer: $e');
      rethrow;
    }
  }

  /// Save customer ID to local storage
  ///
  /// Parameters:
  /// - [customerId]: The customer ID to save
  ///
  /// Returns: Future<bool> indicating success or failure
  Future<bool> saveCustomerId(int customerId) async {
    try {
      appDebugLog('CustomerRepository: Saving customer ID: $customerId');
      final result = await LocalStorage.saveCustomerId(customerId);

      if (result) {
        appDebugLog('CustomerRepository: Customer ID saved successfully');
      } else {
        appDebugLog('CustomerRepository: Failed to save customer ID');
      }

      return result;
    } catch (e) {
      appDebugLog('CustomerRepository: Error saving customer ID: $e');
      return false;
    }
  }

  /// Get customer ID from local storage
  ///
  /// Returns: Future<int?> containing the customer ID or null if not found
  Future<int?> getCustomerId() async {
    try {
      final customerId = await LocalStorage.getCustomerId();

      if (customerId != null) {
        appDebugLog('CustomerRepository: Retrieved customer ID: $customerId');
      } else {
        appDebugLog('CustomerRepository: No customer ID found in storage');
      }

      return customerId;
    } catch (e) {
      appDebugLog('CustomerRepository: Error retrieving customer ID: $e');
      return null;
    }
  }

  /// Clear customer ID from local storage
  ///
  /// Returns: Future<bool> indicating success or failure
  Future<bool> clearCustomerId() async {
    try {
      appDebugLog('CustomerRepository: Clearing customer ID');
      final result = await LocalStorage.clearCustomerId();

      if (result) {
        appDebugLog('CustomerRepository: Customer ID cleared successfully');
      } else {
        appDebugLog('CustomerRepository: Failed to clear customer ID');
      }

      return result;
    } catch (e) {
      appDebugLog('CustomerRepository: Error clearing customer ID: $e');
      return false;
    }
  }

  /// Add customer and save ID in one operation
  ///
  /// Parameters:
  /// - [name]: Customer's name
  /// - [phone]: Customer's phone number
  ///
  /// Returns: [int] customer ID on success
  /// Throws: Exception on failure
  Future<int> addAndSaveCustomer({
    required String name,
    required String phone,
  }) async {
    try {
      appDebugLog('CustomerRepository: Adding and saving customer');

      // Add customer via API
      final response = await addCustomer(name: name, phone: phone);

      if (!response.success) {
        throw Exception(response.message);
      }

      if (response.customerId == null) {
        throw Exception('Customer ID not returned from API');
      }

      // Save customer ID to local storage
      final saved = await saveCustomerId(response.customerId!);

      if (!saved) {
        appDebugLog(
          'CustomerRepository: Warning - Failed to save customer ID to local storage',
        );
      }

      return response.customerId!;
    } catch (e) {
      appDebugLog('CustomerRepository: Error in addAndSaveCustomer: $e');
      rethrow;
    }
  }

  /// Check if customer is already registered (has saved customer ID)
  ///
  /// Returns: Future<bool> indicating if customer is registered
  Future<bool> isCustomerRegistered() async {
    try {
      final customerId = await getCustomerId();
      return customerId != null;
    } catch (e) {
      appDebugLog(
        'CustomerRepository: Error checking if customer is registered: $e',
      );
      return false;
    }
  }
}
