// Firebase Cloud Messaging (FCM) Notification Service
// Handles notification permissions, token management, and message handling
// Optimized for Flutter Web with browser notification support
// Supports both browser and PWA installations

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:html' as html;
import '../firebase_options.dart';
import '../storage/local_storage.dart';
import './api/guest_user_api.dart';

/// Notification Service for managing Firebase Cloud Messaging
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  // Stream controllers for handling notification events
  final StreamController<String> _tokenStreamController = 
      StreamController<String>.broadcast();
  final StreamController<RemoteMessage> _messageStreamController = 
      StreamController<RemoteMessage>.broadcast();
  final StreamController<String> _navigationStreamController = 
      StreamController<String>.broadcast();
  
  String? _currentToken;
  String? _lastSentToken; // Track last token sent to API to avoid duplicates
  bool _isInitialized = false;
  BuildContext? _context;

  /// Stream to listen for FCM token updates
  Stream<String> get tokenStream => _tokenStreamController.stream;
  
  /// Stream to listen for foreground messages
  Stream<RemoteMessage> get messageStream => _messageStreamController.stream;
  
  /// Stream to listen for navigation requests
  Stream<String> get navigationStream => _navigationStreamController.stream;
  
  /// Get current FCM token (cached)
  String? get currentToken => _currentToken;
  
  /// Check if service is initialized
  bool get isInitialized => _isInitialized;
  
  /// Set the navigation context for showing dialogs and navigation
  void setContext(BuildContext context) {
    _context = context;
  }

  /// Initialize Firebase Messaging
  /// Must be called after Firebase.initializeApp()
  /// 
  /// [vapidKey] - Your web push certificate key from Firebase Console
  /// [context] - BuildContext for showing dialogs and navigation
  /// Returns the FCM token or null if failed
  Future<String?> initialize({String? vapidKey, BuildContext? context}) async {
    if (_isInitialized) {
      if (kDebugMode) {
        print('⚠️ NotificationService already initialized');
      }
      return _currentToken;
    }

    try {
      if (kDebugMode) {
        print('🔔 Initializing Firebase Messaging...');
      }

      // Store context for later use
      if (context != null) {
        _context = context;
      }

      // ✅ NEW APPROACH: Check browser permission dynamically first
      // This ensures we always check the real-time browser permission state
      // before requesting permission, avoiding unnecessary requests if already granted
      bool permission = false;
      
      if (kIsWeb) {
        final browserPermission = getBrowserNotificationPermission();
        if (kDebugMode) {
          print('🔍 Checking browser permission (live): $browserPermission');
        }
        
        if (browserPermission == 'granted') {
          // Permission already granted, no need to request again
          if (kDebugMode) {
            print('✅ Permission already granted, skipping request');
          }
          permission = true;
        } else if (browserPermission == 'denied') {
          // Permission explicitly denied by user
          if (kDebugMode) {
            print('❌ Permission denied by user in browser settings');
          }
          return null;
        } else {
          // Permission not yet requested (default state), request it now
          if (kDebugMode) {
            print('📱 Permission not yet requested, requesting now...');
          }
          permission = await requestPermission();
        }
      } else {
        // For non-web platforms, just request permission normally
        permission = await requestPermission();
      }
      
      if (!permission) {
        if (kDebugMode) {
          print('❌ Notification permission denied');
        }
        return null;
      }

      // Get FCM token (web requires VAPID key)
      if (kIsWeb && vapidKey != null) {
        _currentToken = await _firebaseMessaging.getToken(
          vapidKey: vapidKey,
        );
      } else {
        // For mobile platforms
        _currentToken = await _firebaseMessaging.getToken();
      }

      if (_currentToken != null) {
        if (kDebugMode) {
          print('✅ FCM Token obtained: $_currentToken');
        }
        _tokenStreamController.add(_currentToken!);
        
        // Automatically send token to server
        // Note: Always fetches fresh token from Firebase, no local storage
        await _sendTokenToServer();
      } else {
        if (kDebugMode) {
          print('❌ Failed to obtain FCM token');
        }
      }

      // Setup token refresh listener
      _setupTokenRefreshListener();

      // Setup foreground message handler
      _setupForegroundMessageHandler();
      
      // Setup background/terminated message handlers
      _setupBackgroundMessageHandler();
      
      // Check if app was opened from a notification (terminated state)
      await _checkInitialMessage();
      
      // Setup service worker message listener (for web)
      if (kIsWeb) {
        _setupServiceWorkerListener();
      }

      _isInitialized = true;
      
      if (kDebugMode) {
        print('✅ Firebase Messaging initialized successfully');
      }

      return _currentToken;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing Firebase Messaging: $e');
      }
      return null;
    }
  }

  /// Check browser notification permission dynamically (Web only)
  /// 
  /// This method fetches the REAL-TIME permission status from the browser,
  /// not from any locally stored value. This ensures we always have the 
  /// current permission state, even if the user changed it in browser settings.
  /// 
  /// Returns:
  /// - "granted": Permission is granted
  /// - "denied": Permission is explicitly denied
  /// - "default": Permission not yet requested
  /// 
  /// For non-web platforms, this returns "default"
  String getBrowserNotificationPermission() {
    if (kIsWeb) {
      try {
        // Access the browser's Notification.permission property
        // This is the LIVE permission status from the browser
        final permission = html.Notification.permission;
        debugPrint('🔍 Browser notification permission (live): $permission');
        return permission ?? 'default';
      } catch (e) {
        debugPrint('⚠️ Error getting browser notification permission: $e');
        return 'default';
      }
    }
    return 'default'; // For non-web platforms
  }

  /// Check if browser notification permission is already granted
  /// 
  /// This is a convenience method that checks the live browser permission.
  /// It does NOT rely on any locally stored value.
  /// 
  /// Returns true if permission is granted, false otherwise
  bool isBrowserNotificationPermissionGranted() {
    return getBrowserNotificationPermission() == 'granted';
  }

  /// Request notification permission from the user
  /// Returns true if permission granted, false otherwise
  Future<bool> requestPermission() async {
    try {
      debugPrint('📱 Requesting notification permission from browser...');

      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('🔔 Permission status: ${settings.authorizationStatus}');
      debugPrint('🔔 Permission details: alert=${settings.alert}, badge=${settings.badge}, sound=${settings.sound}');

      final granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      
      debugPrint(granted ? '✅ Permission GRANTED' : '❌ Permission DENIED');
      
      return granted;
    } catch (e, stackTrace) {
      debugPrint('❌ Error requesting permission: $e');
      debugPrint('📍 Stack trace: $stackTrace');
      return false;
    }
  }

  /// Setup listener for token refresh events
  void _setupTokenRefreshListener() {
    _firebaseMessaging.onTokenRefresh.listen(
      (newToken) async {
        if (kDebugMode) {
          print('🔄 FCM Token refreshed: $newToken');
        }
        _currentToken = newToken;
        _tokenStreamController.add(newToken);
        
        // Automatically send refreshed token to server
        // Note: Always fetches fresh token from Firebase, no local storage
        await _sendTokenToServer();
      },
      onError: (error) {
        if (kDebugMode) {
          print('❌ Error on token refresh: $error');
        }
      },
    );
  }

  /// Setup handler for foreground messages
  void _setupForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        if (kDebugMode) {
          print('📨 Foreground message received:');
          print('  Title: ${message.notification?.title}');
          print('  Body: ${message.notification?.body}');
          print('  Data: ${message.data}');
        }

        _messageStreamController.add(message);
        
        // Show in-app popup for foreground messages
        _showForegroundNotificationPopup(message);
      },
      onError: (error) {
        if (kDebugMode) {
          print('❌ Error receiving foreground message: $error');
        }
      },
    );
  }
  
  /// Setup handler for background message clicks
  void _setupBackgroundMessageHandler() {
    // Handle notification click when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        if (kDebugMode) {
          print('📨 Background notification clicked:');
          print('  Title: ${message.notification?.title}');
          print('  Body: ${message.notification?.body}');
          print('  Data: ${message.data}');
        }
        
        // Navigate to order tracking screen
        _navigateToOrderTracking();
      },
      onError: (error) {
        if (kDebugMode) {
          print('❌ Error handling background notification click: $error');
        }
      },
    );
  }
  
  /// Check if app was opened from a notification (terminated state)
  Future<void> _checkInitialMessage() async {
    try {
      final RemoteMessage? initialMessage = 
          await _firebaseMessaging.getInitialMessage();
      
      if (initialMessage != null) {
        if (kDebugMode) {
          print('📨 App opened from notification (terminated state):');
          print('  Title: ${initialMessage.notification?.title}');
          print('  Body: ${initialMessage.notification?.body}');
          print('  Data: ${initialMessage.data}');
        }
        
        // Delay navigation slightly to ensure app is fully initialized
        Future.delayed(const Duration(milliseconds: 500), () {
          _navigateToOrderTracking();
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking initial message: $e');
      }
    }
  }
  
  /// Setup service worker message listener for web
  void _setupServiceWorkerListener() {
    try {
      // Listen for messages from service worker
      html.window.navigator.serviceWorker?.addEventListener('message', (event) {
        final messageEvent = event as html.MessageEvent;
        final data = messageEvent.data;
        
        if (data is Map && data['type'] == 'NOTIFICATION_CLICK') {
          if (kDebugMode) {
            print('📨 Service worker notification click message received');
            print('  URL: ${data['url']}');
          }
          
          // Navigate to the specified route
          _navigateToOrderTracking();
        }
      });
      
      if (kDebugMode) {
        print('✅ Service worker listener setup complete');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error setting up service worker listener: $e');
      }
    }
  }
  
  /// Show a popup dialog for foreground notifications
  void _showForegroundNotificationPopup(RemoteMessage message) {
    if (_context == null || !_context!.mounted) {
      if (kDebugMode) {
        print('⚠️ Cannot show popup: context not available');
      }
      return;
    }
    
    final title = message.notification?.title ?? 'Notification';
    final body = message.notification?.body ?? 'You have a new notification';
    
    showDialog(
      context: _context!,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.notifications_active,
                color: Theme.of(dialogContext).primaryColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(dialogContext).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            body,
            style: Theme.of(dialogContext).textTheme.bodyLarge,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Dismiss',
                style: TextStyle(
                  color: Theme.of(dialogContext).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _navigateToOrderTracking();
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('View Orders'),
            ),
          ],
        );
      },
    );
  }
  
  /// Navigate to order tracking screen
  void _navigateToOrderTracking() {
    if (_context == null || !_context!.mounted) {
      if (kDebugMode) {
        print('⚠️ Cannot navigate: context not available');
      }
      // Emit navigation event for external listeners
      _navigationStreamController.add('/order-tracking');
      return;
    }
    
    try {
      if (kDebugMode) {
        print('🚀 Navigating to order tracking screen...');
      }
      
      // Push to order tracking screen
      Navigator.of(_context!).pushNamed('/order-tracking');
      
      if (kDebugMode) {
        print('✅ Navigation completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error navigating: $e');
      }
    }
  }

  /// Refresh and get new FCM token
  /// Useful when token needs to be updated on the backend
  Future<String?> refreshToken({String? vapidKey}) async {
    try {
      if (kDebugMode) {
        print('🔄 Refreshing FCM token...');
      }

      // Delete old token
      await _firebaseMessaging.deleteToken();

      // Get new token
      if (kIsWeb && vapidKey != null) {
        _currentToken = await _firebaseMessaging.getToken(
          vapidKey: vapidKey,
        );
      } else {
        _currentToken = await _firebaseMessaging.getToken();
      }

      if (_currentToken != null) {
        if (kDebugMode) {
          print('✅ Token refreshed: $_currentToken');
        }
        _tokenStreamController.add(_currentToken!);
        
        // Automatically send refreshed token to server
        // Note: Always fetches fresh token from Firebase, no local storage
        await _sendTokenToServer();
      }

      return _currentToken;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error refreshing token: $e');
      }
      return null;
    }
  }

  /// Delete FCM token (call on logout)
  Future<void> deleteToken() async {
    try {
      if (kDebugMode) {
        print('🗑️ Deleting FCM token...');
      }

      await _firebaseMessaging.deleteToken();
      _currentToken = null;

      if (kDebugMode) {
        print('✅ FCM token deleted');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting token: $e');
      }
    }
  }

  /// Subscribe to a topic for group notifications
  Future<void> subscribeToTopic(String topic) async {
    try {
      if (kDebugMode) {
        print('📢 Subscribing to topic: $topic');
      }

      await _firebaseMessaging.subscribeToTopic(topic);

      if (kDebugMode) {
        print('✅ Subscribed to topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error subscribing to topic: $e');
      }
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      if (kDebugMode) {
        print('📢 Unsubscribing from topic: $topic');
      }

      await _firebaseMessaging.unsubscribeFromTopic(topic);

      if (kDebugMode) {
        print('✅ Unsubscribed from topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error unsubscribing from topic: $e');
      }
    }
  }

  /// Get FCM token - ensures token is generated before returning
  /// Returns a Future<String> with the FCM token or empty string if failed
  Future<String> getFcmToken() async {
    try {
      debugPrint('🔍 getFcmToken: Starting...');

      if (_currentToken != null && _currentToken!.isNotEmpty) {
        debugPrint('✅ getFcmToken: Using cached token (${_currentToken!.length} chars)');
        return _currentToken!;
      }

      debugPrint('⏳ getFcmToken: No cached token, requesting permission...');

      final permission = await requestPermission();
      debugPrint('🔐 getFcmToken: Permission result: $permission');
      
      if (!permission) {
        debugPrint('❌ getFcmToken: Notification permission denied by user');
        return '';
      }

      debugPrint('📡 getFcmToken: Permission granted, requesting token from FCM...');
      
      if (kIsWeb) {
        debugPrint('🌐 getFcmToken: Web platform - using VAPID key');
        _currentToken = await _firebaseMessaging.getToken(
          vapidKey: DefaultFirebaseOptions.webVapidKey,
        );
      } else {
        _currentToken = await _firebaseMessaging.getToken();
      }

      debugPrint('📊 getFcmToken: Token result: ${_currentToken == null ? "NULL" : _currentToken!.isEmpty ? "EMPTY" : "Got token (${_currentToken!.length} chars)"}');

      if (_currentToken != null && _currentToken!.isNotEmpty) {
        debugPrint('✅ getFcmToken: Token obtained successfully');
        debugPrint('🔑 Token preview: ${_currentToken!.substring(0, 20)}...');
        _tokenStreamController.add(_currentToken!);
        
        // Automatically send token to server
        // Note: Always fetches fresh token from Firebase, no local storage
        await _sendTokenToServer();
        
        return _currentToken!;
      }

      debugPrint('⚠️ getFcmToken: First attempt returned null/empty, retrying in 500ms...');

      await Future.delayed(const Duration(milliseconds: 500));

      if (kIsWeb) {
        _currentToken = await _firebaseMessaging.getToken(
          vapidKey: DefaultFirebaseOptions.webVapidKey,
        );
      } else {
        _currentToken = await _firebaseMessaging.getToken();
      }

      if (_currentToken != null && _currentToken!.isNotEmpty) {
        debugPrint('✅ getFcmToken: Token obtained on retry');
        _tokenStreamController.add(_currentToken!);
        
        // Automatically send token to server
        // Note: Always fetches fresh token from Firebase, no local storage
        await _sendTokenToServer();
        
        return _currentToken!;
      }

      debugPrint('❌ getFcmToken: Failed to obtain token after retry');
      debugPrint('💡 Possible reasons: Service worker not active, browser blocked permission, or network issue');
      return '';
    } catch (e, stackTrace) {
      debugPrint('❌ getFcmToken: Error getting FCM token: $e');
      debugPrint('📍 Stack trace: $stackTrace');
      return '';
    }
  }

  /// Send FCM token to server
  /// 
  /// Automatically fetches the latest FCM token directly from Firebase
  /// and calls the API to register it with the backend.
  /// Prevents duplicate calls by checking if the token has changed.
  /// 
  /// Note: This method always fetches the token fresh from Firebase,
  /// never relying on locally stored values.
  Future<void> _sendTokenToServer() async {
    try {
      // Get device ID from local storage
      final deviceId = await LocalStorage.getDeviceId();
      
      if (deviceId == null || deviceId.isEmpty) {
        if (kDebugMode) {
          print('⚠️ Cannot send FCM token - device ID not available yet');
          print('ℹ️ Token will be sent after device registration');
        }
        return;
      }
      
      if (kDebugMode) {
        print('📤 Sending FCM token to server...');
        print('   Device ID: $deviceId');
      }
      
      // Fetch fresh token from Firebase before sending to API
      // This ensures we always use the latest valid token
      String? freshToken;
      if (kIsWeb) {
        freshToken = await _firebaseMessaging.getToken(
          vapidKey: DefaultFirebaseOptions.webVapidKey,
        );
      } else {
        freshToken = await _firebaseMessaging.getToken();
      }
      
      if (freshToken == null || freshToken.isEmpty) {
        if (kDebugMode) {
          print('⚠️ Cannot send FCM token - failed to fetch token from Firebase');
        }
        return;
      }
      
      // Prevent duplicate API calls if token hasn't changed
      if (_lastSentToken == freshToken) {
        if (kDebugMode) {
          print('⏭️ Skipping API call - token already sent to server');
        }
        return;
      }
      
      if (kDebugMode) {
        print('   Token (fresh from Firebase): ${freshToken.substring(0, 20)}...');
      }
      
      // Call the API to register the FCM token
      // Note: The API will also fetch fresh token internally for redundancy
      await GuestUserApi.callAddUserFcmToken(deviceId, freshToken);
      
      // Update last sent token
      _lastSentToken = freshToken;
      
      if (kDebugMode) {
        print('✅ FCM token successfully sent to server');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending FCM token to server: $e');
        print('ℹ️ This is not critical - token will be retried on next refresh');
      }
    }
  }

  /// Dispose streams and cleanup
  void dispose() {
    _tokenStreamController.close();
    _messageStreamController.close();
    _navigationStreamController.close();
    _isInitialized = false;
    _context = null;
  }
}

/// Background message handler
/// Must be a top-level function (not inside a class)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('📨 Background message received:');
    print('  Title: ${message.notification?.title}');
    print('  Body: ${message.notification?.body}');
    print('  Data: ${message.data}');
  }
}

