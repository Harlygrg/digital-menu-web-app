import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// AppConfig - External Runtime Configuration
///
/// This class loads configuration from an external config.json file at deployment time.
/// This allows clients to change the API base URL WITHOUT rebuilding the Flutter app.
///
/// ## How It Works:
/// 1. The config.json file is loaded from /config.json at app startup
/// 2. If the file is missing or invalid, it falls back to a hardcoded default URL
/// 3. All API services use AppConfig.apiBase for their base URL
///
/// ## For Clients (Post-Deployment Configuration):
/// After running `flutter build web`, you can edit the API URL without rebuilding:
/// 1. Navigate to: build/web/config.json
/// 2. Edit the "apiBase" field to your server URL
/// 3. Deploy the build/web folder to your web server
/// 4. The app will automatically use your custom URL
///
/// ## Example config.json:
/// ```json
/// {
///   "apiBase": "https://your-custom-api-url.com/api/v1/"
/// }
/// ```
///
/// Note: Always include a trailing slash in the API base URL
class AppConfig {
  /// The API base URL loaded from config.json or using the fallback default
  static String apiBase = _defaultApiBase;

  /// Default/Fallback API base URL
  /// This is used if config.json is missing or fails to load
  static const String _defaultApiBase = 
      "https://msibusinesssolutions.com/waraq_api_qrmenu/api/v1/";

  /// Loads configuration from /config.json
  ///
  /// This method should be called ONCE during app initialization,
  /// before any API calls are made (before runApp() in main.dart).
  ///
  /// Features:
  /// - Fetches /config.json from the web server
  /// - Parses the JSON and extracts the apiBase field
  /// - Falls back to default URL if file is missing or invalid
  /// - Never crashes - always provides a working URL
  ///
  /// Returns: Future<void> (completes when config is loaded)
  static Future<void> load() async {
    try {
      // debugPrint('🔧 AppConfig: Loading external configuration from /config.json...');
      
      // Fetch config.json from the web root
      // Note: This uses an absolute path from the deployed web root
      final response = await http.get(
        Uri.parse('/config.json'),
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          // debugPrint('⚠️ AppConfig: Timeout loading config.json, using default URL');
          throw Exception('Config load timeout');
        },
      );

      if (response.statusCode == 200) {
        // Parse JSON
        final configData = json.decode(response.body) as Map<String, dynamic>;
        
        // Extract apiBase field
        if (configData.containsKey('apiBase') && configData['apiBase'] is String) {
          final loadedApiBase = configData['apiBase'] as String;
          
          if (loadedApiBase.isNotEmpty) {
            apiBase = loadedApiBase;
            // debugPrint('✅ AppConfig: Successfully loaded API base URL from config.json');
            // // debugPrint('   📡 API Base: $apiBase');
          } else {
            // debugPrint('⚠️ AppConfig: apiBase is empty in config.json, using default');
          }
        } else {
          // debugPrint('⚠️ AppConfig: apiBase field not found in config.json, using default');
        }
      } else {
        // debugPrint('⚠️ AppConfig: Failed to load config.json (HTTP ${response.statusCode}), using default URL');
      }
    } catch (e) {
      // Gracefully handle any errors - never crash the app
      // debugPrint('⚠️ AppConfig: Error loading config.json: $e');
      // debugPrint('ℹ️ AppConfig: Using default API base URL: $_defaultApiBase');
    }
    
    // Always log the final URL being used
    // debugPrint('🌐 AppConfig: Final API Base URL: $apiBase');
  }

  /// Resets the configuration to default values
  /// Useful for testing purposes
  static void reset() {
    apiBase = _defaultApiBase;
    // debugPrint('🔄 AppConfig: Reset to default configuration');
  }
}






