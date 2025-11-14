/// Customer Provider
/// 
/// This provider manages customer state and handles customer-related operations.
/// It uses the CustomerRepository for API calls and local storage.

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../repositories/customer_repository.dart';
import '../services/api/guest_user_api.dart';
import '../storage/local_storage.dart';
import '../firebase_options.dart';

/// Provider for managing customer state
class CustomerProvider extends ChangeNotifier {
  // Repository instance
  final CustomerRepository _repository = CustomerRepository();

  // Loading and error states
  bool _isLoading = false;
  String? _errorMessage;

  // Customer data
  int? _customerId;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get customerId => _customerId;
  bool get isCustomerRegistered => _customerId != null;

  /// Initialize customer provider by loading saved customer ID
  /// 
  /// This should be called when the app starts
  Future<void> initialize() async {
    try {
      debugPrint('CustomerProvider: Initializing...');
      _customerId = await _repository.getCustomerId();
      
      if (_customerId != null) {
        debugPrint('CustomerProvider: Found saved customer ID: $_customerId');
      } else {
        debugPrint('CustomerProvider: No saved customer ID found');
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('CustomerProvider: Error during initialization: $e');
    }
  }

  /// Add a new customer
  /// 
  /// Parameters:
  /// - [name]: Customer's name
  /// - [phone]: Customer's phone number
  /// 
  /// Returns: [int] customer ID on success, null on failure
  Future<int?> addCustomer({
    required String name,
    required String phone,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      debugPrint('CustomerProvider: Adding customer - name: $name, phone: $phone');

      // Ensure we have a valid access token before making the request
      await _ensureAuthentication();

      // Call repository to add and save customer
      final customerId = await _repository.addAndSaveCustomer(
        name: name,
        phone: phone,
      );

      _customerId = customerId;
      _isLoading = false;
      
      debugPrint('CustomerProvider: Customer added successfully - ID: $customerId');
      
      notifyListeners();
      return customerId;
    } catch (e) {
      debugPrint('CustomerProvider: Error adding customer: $e');
      _errorMessage = _parseErrorMessage(e.toString());
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Ensure user is authenticated (has valid access token)
  /// 
  /// If no token exists, this will trigger guest user registration
  Future<void> _ensureAuthentication() async {
    try {
      // Check if we already have an access token
      final accessToken = await LocalStorage.getAccessToken();
      
      if (accessToken != null && accessToken.isNotEmpty) {
        debugPrint('CustomerProvider: Access token already exists');
        return;
      }
      
      debugPrint('CustomerProvider: No access token found, registering as guest user...');
      
      // Generate or retrieve device ID
      final deviceId = await _getDeviceId();
      
      // Fetch FCM token directly from Firebase (never from local storage)
      debugPrint('CustomerProvider: Fetching fresh FCM token from Firebase...');
      final firebaseMessaging = FirebaseMessaging.instance;
      String? fcmToken;
      
      try {
        if (kIsWeb) {
          fcmToken = await firebaseMessaging.getToken(
            vapidKey: DefaultFirebaseOptions.webVapidKey,
          );
        } else {
          fcmToken = await firebaseMessaging.getToken();
        }
        
        if (fcmToken != null && fcmToken.isNotEmpty) {
          debugPrint('CustomerProvider: Fresh FCM token obtained from Firebase');
        } else {
          debugPrint('CustomerProvider: FCM token is empty (notification permissions may not be granted)');
          fcmToken = ''; // Use empty string if token is not available
        }
      } catch (e) {
        debugPrint('CustomerProvider: Error fetching FCM token from Firebase: $e');
        fcmToken = ''; // Use empty string on error
      }
      
      // Register as guest user to get tokens
      final response = await GuestUserApi.registerGuestUser(
        deviceId,
      );
      
      if (response.success && response.data?.accessToken != null) {
        debugPrint('CustomerProvider: Guest user registration successful');
      } else {
        throw Exception('Failed to register guest user');
      }
    } catch (e) {
      debugPrint('CustomerProvider: Error during authentication: $e');
      throw Exception('Authentication failed. Please restart the app.');
    }
  }

  /// Get or generate device ID
  Future<String> _getDeviceId() async {
    try {
      // Check if we already have a device ID saved
      final savedDeviceId = await LocalStorage.getDeviceId();
      if (savedDeviceId != null && savedDeviceId.isNotEmpty) {
        return savedDeviceId;
      }
      
      // Generate new device ID based on timestamp and random component
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final deviceId = 'web_customer_$timestamp';
      
      debugPrint('CustomerProvider: Generated device ID: $deviceId');
      return deviceId;
    } catch (e) {
      debugPrint('CustomerProvider: Error getting device ID: $e');
      // Fallback to timestamp-based ID
      return 'fallback_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Clear customer data
  /// 
  /// This will remove the customer ID from both memory and local storage
  Future<void> clearCustomer() async {
    try {
      debugPrint('CustomerProvider: Clearing customer data');
      
      await _repository.clearCustomerId();
      _customerId = null;
      _errorMessage = null;
      
      debugPrint('CustomerProvider: Customer data cleared');
      
      notifyListeners();
    } catch (e) {
      debugPrint('CustomerProvider: Error clearing customer: $e');
    }
  }

  /// Refresh customer ID from storage
  /// 
  /// This can be used to reload customer data if needed
  Future<void> refreshCustomerId() async {
    try {
      debugPrint('CustomerProvider: Refreshing customer ID');
      
      _customerId = await _repository.getCustomerId();
      
      debugPrint('CustomerProvider: Customer ID refreshed: $_customerId');
      
      notifyListeners();
    } catch (e) {
      debugPrint('CustomerProvider: Error refreshing customer ID: $e');
    }
  }

  /// Parse error message from exception
  /// 
  /// Provides user-friendly error messages based on the error
  String _parseErrorMessage(String error) {
    debugPrint('CustomerProvider: Parsing error: $error');
    
    if (error.contains('400')) {
      return 'Invalid information provided. Please check your details.';
    } else if (error.contains('401') || error.contains('Unauthorized')) {
      return 'Authentication required. The app will register you automatically. Please try again.';
    } else if (error.contains('404')) {
      return 'Service not found. Please contact support.';
    } else if (error.contains('500') || error.contains('Server error')) {
      return 'Server error. Our system is having trouble. Please try again in a few moments.';
    } else if (error.contains('Connection') || error.contains('connection')) {
      return 'No internet connection. Please check your network and try again.';
    } else if (error.contains('timeout') || error.contains('Timeout')) {
      return 'Request timed out. Please check your connection and try again.';
    } else if (error.contains('Invalid access token') || error.contains('Authentication failed')) {
      return 'Authentication issue. Please restart the app.';
    } else if (error.contains('Failed to register guest user')) {
      return 'Could not connect to server. Please check your internet and try again.';
    } else {
      return 'Something went wrong. Please try again or contact support if the issue persists.';
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset provider state
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Check if customer needs to be registered
  /// 
  /// Returns true if no customer ID is saved
  Future<bool> needsRegistration() async {
    try {
      if (_customerId != null) {
        return false;
      }
      
      // Double check with repository
      final isRegistered = await _repository.isCustomerRegistered();
      
      if (isRegistered) {
        // Refresh customer ID
        await refreshCustomerId();
        return false;
      }
      
      return true;
    } catch (e) {
      debugPrint('CustomerProvider: Error checking registration status: $e');
      return true; // Assume registration needed on error
    }
  }
}

