import 'package:digital_menu_order/services/api/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../storage/local_storage.dart';
import '../../firebase_options.dart';

/// Guest User API Service
///
/// This class handles all API calls related to guest user registration and management.
/// It uses Dio for HTTP requests and includes an interceptor for automatic token injection.
class GuestUserApi {

  /// Gets or creates a singleton instance of Dio with interceptors

  /// Registers a guest user with the provided device ID
  ///
  /// Parameters:
  /// - [deviceId]: The unique device identifier
  /// - [fcmToken]: Optional FCM token to register with the server (can be empty)
  /// - [context]: Optional BuildContext for showing error messages
  ///
  /// Returns: A Future containing the API response or throws an exception on error
  ///
  /// Throws:
  /// - [DioException] on network errors
  /// - [Exception] on other errors
  /// 
  /// Note: FCM token can be registered later using callAddUserFcmToken()
  static Future<GuestUserResponse> registerGuestUser(
    String deviceId, {
    BuildContext? context,
  }) async {
    debugPrint('registerGuestUser called');
    debugPrint('Device ID: $deviceId');
    try {
      if (deviceId.isEmpty) {
        throw Exception('Device ID cannot be empty');
      }

      final apiService = ApiService();
      debugPrint('Calling registerGuestUserApiCall...');
      
      // Call API with FCM token (can be empty string)
      dynamic responseData = await apiService.registerGuestUserApiCall(
        deviceId: deviceId,);

      debugPrint('Guest user registration response received');

      final guestUserResponse = GuestUserResponse.fromJson(responseData);

      if (guestUserResponse.success && guestUserResponse.data != null) {
        final accessToken = guestUserResponse.data!.accessToken;
        final refreshToken = guestUserResponse.data!.refreshToken;

        // Validate and save tokens IMMEDIATELY
        if (accessToken != null && accessToken.isNotEmpty && 
            refreshToken != null && refreshToken.isNotEmpty) {
          
          // Save tokens first (critical for subsequent API calls)
          await LocalStorage.saveTokens(accessToken, refreshToken);
          debugPrint('✅ Access and refresh tokens saved successfully');
          
          // Save device ID
          await LocalStorage.saveDeviceId(deviceId);
          debugPrint('✅ Device ID saved successfully');
          
          // Mark user as registered
          await LocalStorage.setGuestUserRegistered(true);
          debugPrint('✅ Guest user marked as registered');
          
          // Note: FCM token is NOT stored locally
          // It will be fetched fresh from Firebase when needed
          // if (fcmToken.isNotEmpty) {
          //   debugPrint('ℹ️ FCM token provided during registration (will be registered separately)');
          // } else {
          //   debugPrint('ℹ️ FCM token not provided during registration (will be registered later)');
          // }
        } else {
          throw Exception('Invalid tokens received from server: accessToken or refreshToken is null/empty');
        }
      } else {
        throw Exception(guestUserResponse.data?.message ?? 'Registration failed: No data in response');
      }

      return guestUserResponse;
    } catch (e) {
      debugPrint('❌ Error during guest user registration: $e');
      rethrow;
    }
  }

  /// Add FCM token to server
  ///
  /// This method ALWAYS fetches the latest FCM token directly from Firebase
  /// before sending it to the server. It never relies on locally cached tokens.
  ///
  /// Parameters:
  /// - [deviceId]: The device identifier
  /// - [fcmToken]: DEPRECATED - This parameter is ignored. Token is always fetched fresh from Firebase.
  /// - [context]: Optional BuildContext for showing error messages
  ///
  /// Note: The fcmToken parameter is kept for backward compatibility but is not used.
  /// The method always fetches the latest token from Firebase Messaging.
  static Future<void> callAddUserFcmToken(
    String deviceId,
    String fcmToken, // Kept for backward compatibility, but not used
  ) async {
    try {
      debugPrint('🔄 callAddUserFcmToken: Fetching fresh FCM token from Firebase...');
      
      // IMPORTANT: Always fetch fresh token from Firebase, ignore the passed parameter
      final firebaseMessaging = FirebaseMessaging.instance;
      String? freshFcmToken;
      
      if (kIsWeb) {
        freshFcmToken = await firebaseMessaging.getToken(
          vapidKey: DefaultFirebaseOptions.webVapidKey,
        );
      } else {
        freshFcmToken = await firebaseMessaging.getToken();
      }
      
      if (freshFcmToken == null || freshFcmToken.isEmpty) {
        debugPrint('⚠️ Failed to fetch FCM token from Firebase');
        debugPrint('ℹ️ This may happen if notification permissions are not granted');
        return;
      }
      
      debugPrint('✅ Fresh FCM token fetched from Firebase');
      debugPrint('📤 Sending fresh token to server...');
      debugPrint('   Device ID: $deviceId');
      debugPrint('   Token preview: ${freshFcmToken.substring(0, 20)}...');
      
      final apiService = ApiService();
      final response = await apiService.addUserFcmToken(
        deviceId: deviceId,
        fcmToken: freshFcmToken, // Use fresh token from Firebase
      );
      
      if (response['success'] == true) {
        debugPrint('✅ FCM token registered successfully with server');
      } else {
        final errorMessage = response['message'] ?? 'Failed to register FCM token';
        debugPrint('❌ FCM token registration failed: $errorMessage');
      }
    } catch (e) {
      debugPrint('❌ Error adding FCM token: $e');
      debugPrint('ℹ️ This is not critical - notifications may not work until token is registered');
    }
  }

  /// Refreshes the access token using the refresh token
  ///
  /// This method calls the refreshToken API endpoint to get a new access token.
  /// It automatically updates both the access token and refresh token in local storage.
  ///
  /// Returns: A Future containing the RefreshTokenResponse or throws an exception on error
  ///
  /// Throws:
  /// - [DioException] on network errors
  /// - [Exception] on token refresh failures
  ///
  /// Note: This method should be called automatically by the API interceptor
  /// when an "Invalid access token" error is detected.
  static Future<RefreshTokenResponse> refreshAccessToken() async {
    debugPrint('🔄 refreshAccessToken called - attempting to refresh tokens');
    
    try {
      final apiService = ApiService();
      debugPrint('Calling refreshTokenApiCall...');
      
      // Call the refresh token API
      dynamic responseData = await apiService.refreshTokenApiCall();
      debugPrint('Refresh token response received');

      final refreshTokenResponse = RefreshTokenResponse.fromJson(responseData);

      if (refreshTokenResponse.success && refreshTokenResponse.data != null) {
        final newAccessToken = refreshTokenResponse.data!.accessToken;
        final newRefreshToken = refreshTokenResponse.data!.refreshToken;

        // Validate and update tokens
        if (newAccessToken != null && newAccessToken.isNotEmpty && 
            newRefreshToken != null && newRefreshToken.isNotEmpty) {
          
          // Save new tokens to local storage
          await LocalStorage.saveTokens(newAccessToken, newRefreshToken);
          debugPrint('✅ New access and refresh tokens saved successfully');
          
          return refreshTokenResponse;
        } else {
          throw Exception('Invalid tokens received from refresh endpoint: tokens are null/empty');
        }
      } else {
        // If refresh fails, clear auth data and throw exception
        await LocalStorage.clearAuthData();
        throw Exception(refreshTokenResponse.data?.message ?? 'Token refresh failed: No data in response');
      }
    } catch (e) {
      debugPrint('❌ Error during token refresh: $e');
      // Clear invalid tokens on failure
      await LocalStorage.clearAuthData();
      rethrow;
    }
  }

}

/// Guest User Response Model
///
/// Represents the response from the guest user registration API
class GuestUserResponse {
  final bool success;
  final GuestUserData? data;

  GuestUserResponse({
    required this.success,
    this.data,
  });

  factory GuestUserResponse.fromJson(Map<String, dynamic> json) {
    return GuestUserResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? GuestUserData.fromJson(json['data']) : null,
    );
  }
}

/// Guest User Data Model
///
/// Contains the user data and tokens from the registration response
class GuestUserData {
  final String? message;
  final String? accessToken;
  final String? refreshToken;
  final UserInfo? userInfo;

  GuestUserData({
    this.message,
    this.accessToken,
    this.refreshToken,
    this.userInfo,
  });

  factory GuestUserData.fromJson(Map<String, dynamic> json) {
    return GuestUserData(
      message: json['message'],
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      userInfo: json['data'] != null ? UserInfo.fromJson(json['data']) : null,
    );
  }
}

/// User Information Model
///
/// Contains basic user information from the registration response
class UserInfo {
  final String? firstName;
  final String? loginType;
  final String? status;
  final String? device;

  UserInfo({
    this.firstName,
    this.loginType,
    this.status,
    this.device,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      firstName: json['first_name'],
      loginType: json['login_type'],
      status: json['status'],
      device: json['device'],
    );
  }
}

/// Refresh Token Response Model
///
/// Represents the response from the refresh token API
class RefreshTokenResponse {
  final bool success;
  final RefreshTokenData? data;

  RefreshTokenResponse({
    required this.success,
    this.data,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? RefreshTokenData.fromJson(json['data']) : null,
    );
  }
}

/// Refresh Token Data Model
///
/// Contains the refreshed tokens and user data from the refresh token response
class RefreshTokenData {
  final String? message;
  final String? accessToken;
  final String? refreshToken;
  final UserInfo? userInfo;

  RefreshTokenData({
    this.message,
    this.accessToken,
    this.refreshToken,
    this.userInfo,
  });

  factory RefreshTokenData.fromJson(Map<String, dynamic> json) {
    return RefreshTokenData(
      message: json['message'],
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      userInfo: json['data'] != null ? UserInfo.fromJson(json['data']) : null,
    );
  }
}

