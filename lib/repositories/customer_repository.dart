/// Customer Repository
/// 
/// This repository handles all customer-related operations including
/// API calls and local storage management for customer data.

import 'package:flutter/foundation.dart';
import '../services/api/api_service.dart';
import '../storage/local_storage.dart';
import '../models/customer_model.dart';

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
      debugPrint('CustomerRepository: Adding customer - name: $name, phone: $phone');
      int branchId  = 1;
      final request = CustomerAddRequest(
        name: name,
        phone: phone,
        cid: branchId
      );
      
      final response = await _apiService.addCustomer(request: request);
      
      debugPrint('CustomerRepository: Customer added successfully - ID: ${response.customerId}');
      
      return response;
    } catch (e) {
      debugPrint('CustomerRepository: Error adding customer: $e');
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
      debugPrint('CustomerRepository: Saving customer ID: $customerId');
      final result = await LocalStorage.saveCustomerId(customerId);
      
      if (result) {
        debugPrint('CustomerRepository: Customer ID saved successfully');
      } else {
        debugPrint('CustomerRepository: Failed to save customer ID');
      }
      
      return result;
    } catch (e) {
      debugPrint('CustomerRepository: Error saving customer ID: $e');
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
        debugPrint('CustomerRepository: Retrieved customer ID: $customerId');
      } else {
        debugPrint('CustomerRepository: No customer ID found in storage');
      }
      
      return customerId;
    } catch (e) {
      debugPrint('CustomerRepository: Error retrieving customer ID: $e');
      return null;
    }
  }

  /// Clear customer ID from local storage
  /// 
  /// Returns: Future<bool> indicating success or failure
  Future<bool> clearCustomerId() async {
    try {
      debugPrint('CustomerRepository: Clearing customer ID');
      final result = await LocalStorage.clearCustomerId();
      
      if (result) {
        debugPrint('CustomerRepository: Customer ID cleared successfully');
      } else {
        debugPrint('CustomerRepository: Failed to clear customer ID');
      }
      
      return result;
    } catch (e) {
      debugPrint('CustomerRepository: Error clearing customer ID: $e');
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
      debugPrint('CustomerRepository: Adding and saving customer');
      
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
        debugPrint('CustomerRepository: Warning - Failed to save customer ID to local storage');
      }
      
      return response.customerId!;
    } catch (e) {
      debugPrint('CustomerRepository: Error in addAndSaveCustomer: $e');
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
      debugPrint('CustomerRepository: Error checking if customer is registered: $e');
      return false;
    }
  }
}

