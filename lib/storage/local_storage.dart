import 'package:shared_preferences/shared_preferences.dart';

/// Local Storage Manager
/// 
/// This class handles all local storage operations using SharedPreferences.
/// It provides methods to save and retrieve authentication tokens and other data.
class LocalStorage {
  // Keys for storing data
  static const String _accessTokenKey = "access_token";
  static const String _refreshTokenKey = "refresh_token";
  static const String _deviceIdKey = "device_id";
  static const String _isGuestUserRegisteredKey = "is_guest_user_registered";
  static const String _branchIdKey = "branch_id";
  static const String _customerIdKey = "customer_id";
  static const String _fcmTokenKey = "fcm_token";
  static const String _notificationPermissionAskedKey = "notification_permission_asked";
  // DEPRECATED: No longer used - always check browser permission dynamically instead
  // static const String _notificationPermissionGrantedKey = "notification_permission_granted";

  /// Saves authentication tokens to local storage
  /// 
  /// Parameters:
  /// - [accessToken]: The access token received from the API
  /// - [refreshToken]: The refresh token received from the API
  /// 
  /// Returns: Future<bool> indicating success or failure
  static Future<bool> saveTokens(String accessToken, String refreshToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accessTokenKey, accessToken);
      await prefs.setString(_refreshTokenKey, refreshToken);
      return true;
    } catch (e) {
      print("Error saving tokens: $e");
      return false;
    }
  }

  /// Retrieves the access token from local storage
  /// 
  /// Returns: Future<String?> containing the access token or null if not found
  static Future<String?> getAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_accessTokenKey);
    } catch (e) {
      print("Error getting access token: $e");
      return null;
    }
  }

  /// Retrieves the refresh token from local storage
  /// 
  /// Returns: Future<String?> containing the refresh token or null if not found
  static Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_refreshTokenKey);
    } catch (e) {
      print("Error getting refresh token: $e");
      return null;
    }
  }

  /// Saves the device ID to local storage
  /// 
  /// Parameters:
  /// - [deviceId]: The unique device identifier
  /// 
  /// Returns: Future<bool> indicating success or failure
  static Future<bool> saveDeviceId(String deviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_deviceIdKey, deviceId);
      return true;
    } catch (e) {
      print("Error saving device ID: $e");
      return false;
    }
  }

  /// Retrieves the device ID from local storage
  /// 
  /// Returns: Future<String?> containing the device ID or null if not found
  static Future<String?> getDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_deviceIdKey);
    } catch (e) {
      print("Error getting device ID: $e");
      return null;
    }
  }

  /// Marks the guest user as registered
  /// 
  /// Returns: Future<bool> indicating success or failure
  static Future<bool> setGuestUserRegistered(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isGuestUserRegisteredKey, value);
      return true;
    } catch (e) {
      print("Error setting guest user registered status: $e");
      return false;
    }
  }

  /// Checks if the guest user is already registered
  /// 
  /// Returns: Future<bool> indicating if the user is registered
  static Future<bool> isGuestUserRegistered() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isGuestUserRegisteredKey) ?? false;
    } catch (e) {
      print("Error checking guest user registered status: $e");
      return false;
    }
  }

  /// Clears all stored authentication data
  /// 
  /// Returns: Future<bool> indicating success or failure
  static Future<bool> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_accessTokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_isGuestUserRegisteredKey);
      return true;
    } catch (e) {
      print("Error clearing auth data: $e");
      return false;
    }
  }

  /// Saves the selected branch ID to local storage
  /// 
  /// Parameters:
  /// - [branchId]: The branch ID to save
  /// 
  /// Returns: Future<bool> indicating success or failure
  static Future<bool> saveBranchId(String branchId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_branchIdKey, branchId);
      return true;
    } catch (e) {
      print("Error saving branch ID: $e");
      return false;
    }
  }

  /// Retrieves the selected branch ID from local storage
  /// 
  /// Returns: Future<String?> containing the branch ID or null if not found
  static Future<String?> getBranchId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_branchIdKey);
    } catch (e) {
      print("Error getting branch ID: $e");
      return null;
    }
  }

  /// Removes the stored branch ID
  /// 
  /// Returns: Future<bool> indicating success or failure
  static Future<bool> clearBranchId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_branchIdKey);
      return true;
    } catch (e) {
      print("Error clearing branch ID: $e");
      return false;
    }
  }

  /// Saves the customer ID to local storage
  /// 
  /// Parameters:
  /// - [customerId]: The customer ID to save
  /// 
  /// Returns: Future<bool> indicating success or failure
  static Future<bool> saveCustomerId(int customerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_customerIdKey, customerId);
      return true;
    } catch (e) {
      print("Error saving customer ID: $e");
      return false;
    }
  }

  /// Retrieves the customer ID from local storage
  /// 
  /// Returns: Future<int?> containing the customer ID or null if not found
  static Future<int?> getCustomerId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_customerIdKey);
    } catch (e) {
      print("Error getting customer ID: $e");
      return null;
    }
  }

  /// Removes the stored customer ID
  /// 
  /// Returns: Future<bool> indicating success or failure
  static Future<bool> clearCustomerId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_customerIdKey);
      return true;
    } catch (e) {
      print("Error clearing customer ID: $e");
      return false;
    }
  }

  /// @DEPRECATED - DO NOT USE
  /// 
  /// Saves the FCM token to local storage
  /// 
  /// ⚠️ WARNING: This method is deprecated and should NOT be used.
  /// 
  /// FCM tokens should NEVER be stored in local storage because:
  /// 1. Firebase can rotate/refresh tokens at any time
  /// 2. Locally cached tokens can become stale and invalid
  /// 3. Using stale tokens causes push notifications to fail
  /// 
  /// Instead, always fetch the FCM token directly from Firebase using:
  /// - FirebaseMessaging.instance.getToken() for mobile
  /// - FirebaseMessaging.instance.getToken(vapidKey: key) for web
  /// 
  /// This method is kept only for backward compatibility.
  /// 
  /// Parameters:
  /// - [fcmToken]: The FCM token to save
  /// 
  /// Returns: Future<bool> indicating success or failure
  @Deprecated('Do not store FCM tokens locally. Always fetch from Firebase.')
  static Future<bool> saveFcmToken(String fcmToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_fcmTokenKey, fcmToken);
      print("⚠️ WARNING: Storing FCM token locally is deprecated. Always fetch from Firebase.");
      return true;
    } catch (e) {
      print("Error saving FCM token: $e");
      return false;
    }
  }

  /// @DEPRECATED - DO NOT USE
  /// 
  /// Retrieves the FCM token from local storage
  /// 
  /// ⚠️ WARNING: This method is deprecated and should NOT be used.
  /// 
  /// FCM tokens should NEVER be retrieved from local storage because:
  /// 1. Locally cached tokens can be stale or invalid
  /// 2. Firebase may have rotated the token since it was cached
  /// 3. Using stale tokens causes push notifications to fail
  /// 
  /// Instead, always fetch the FCM token directly from Firebase using:
  /// - FirebaseMessaging.instance.getToken() for mobile
  /// - FirebaseMessaging.instance.getToken(vapidKey: key) for web
  /// 
  /// This method is kept only for backward compatibility.
  /// 
  /// Returns: Future<String?> containing the FCM token or null if not found
  @Deprecated('Do not retrieve FCM tokens from local storage. Always fetch from Firebase.')
  static Future<String?> getFcmToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      print("⚠️ WARNING: Retrieving FCM token from local storage is deprecated. Always fetch from Firebase.");
      return prefs.getString(_fcmTokenKey);
    } catch (e) {
      print("Error getting FCM token: $e");
      return null;
    }
  }

  /// Removes the stored FCM token
  /// 
  /// Note: This method can be used to clean up old cached tokens.
  /// However, remember that FCM tokens should never be stored locally in the first place.
  /// 
  /// Returns: Future<bool> indicating success or failure
  static Future<bool> clearFcmToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_fcmTokenKey);
      return true;
    } catch (e) {
      print("Error clearing FCM token: $e");
      return false;
    }
  }

  /// Saves notification permission asked status
  /// 
  /// Parameters:
  /// - [asked]: Whether the permission was asked
  /// 
  /// Returns: Future<bool> indicating success or failure
  static Future<bool> setNotificationPermissionAsked(bool asked) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationPermissionAskedKey, asked);
      return true;
    } catch (e) {
      print("Error saving notification permission asked status: $e");
      return false;
    }
  }

  /// Checks if notification permission was asked before
  /// 
  /// Returns: Future<bool> true if asked before, false otherwise
  static Future<bool> wasNotificationPermissionAsked() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_notificationPermissionAskedKey) ?? false;
    } catch (e) {
      print("Error getting notification permission asked status: $e");
      return false;
    }
  }

  /// @DEPRECATED - DO NOT USE
  /// 
  /// Saves notification permission granted status
  /// 
  /// ⚠️ WARNING: This method is deprecated and should NOT be used.
  /// 
  /// Storing notification permission locally causes a mismatch between the 
  /// real browser permission and the app state. If the user changes the 
  /// notification setting in browser settings later, the app will still 
  /// rely on the outdated local value.
  /// 
  /// Instead, always check the browser permission dynamically using:
  /// - NotificationService().getBrowserNotificationPermission() for web
  /// - NotificationService().isBrowserNotificationPermissionGranted() for boolean check
  /// 
  /// This method is commented out but kept for future reference.
  /// 
  /// Parameters:
  /// - [granted]: Whether the permission was granted
  /// 
  /// Returns: Future<bool> indicating success or failure
  // static Future<bool> setNotificationPermissionGranted(bool granted) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.setBool(_notificationPermissionGrantedKey, granted);
  //     return true;
  //   } catch (e) {
  //     print("Error saving notification permission granted status: $e");
  //     return false;
  //   }
  // }

  /// @DEPRECATED - DO NOT USE
  /// 
  /// Checks if notification permission was granted
  /// 
  /// ⚠️ WARNING: This method is deprecated and should NOT be used.
  /// 
  /// This method reads from local storage which can be outdated.
  /// Always check the browser permission dynamically instead using:
  /// - NotificationService().getBrowserNotificationPermission() for web
  /// - NotificationService().isBrowserNotificationPermissionGranted() for boolean check
  /// 
  /// This method is commented out but kept for future reference.
  /// 
  /// Returns: Future<bool> true if granted, false otherwise
  // static Future<bool> wasNotificationPermissionGranted() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     return prefs.getBool(_notificationPermissionGrantedKey) ?? false;
  //   } catch (e) {
  //     print("Error getting notification permission granted status: $e");
  //     return false;
  //   }
  // }

  /// Clears all stored data
  /// 
  /// Returns: Future<bool> indicating success or failure
  static Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      return true;
    } catch (e) {
      print("Error clearing all data: $e");
      return false;
    }
  }
}

