// Order Tracking Controller
// Manages order state, periodic polling, and real-time updates
// Implements Provider pattern for reactive UI updates

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import '../models/user_order_model.dart';
import '../services/api/api_service.dart';
import '../services/notification_service.dart';
import '../utils/visibility_listener_stub.dart'
    if (dart.library.html) '../utils/visibility_listener_web.dart'
    if (dart.library.io) '../utils/visibility_listener_mobile.dart';

/// Controller for managing order tracking state and operations
class OrderTrackingController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();

  // State variables
  List<UserOrder> _userOrders = [];
  bool _isLoading = false;
  String? _error;
  Timer? _pollingTimer;
  String? _userId;
  DateTime? _lastRefreshTime;
  bool _mounted = true;

  // Configuration
  static const Duration _pollingInterval = Duration(seconds: 30);

  // Getters
  List<UserOrder> get userOrders => _userOrders;
  List<UserOrder> get activeOrders => 
      _userOrders.where((order) => !order.isOrderCompleted).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasOrders => _userOrders.isNotEmpty;
  bool get hasActiveOrders => activeOrders.isNotEmpty;
  DateTime? get lastRefreshTime => _lastRefreshTime;

  /// Initialize the controller
  /// 
  /// [userId] - Unique identifier for the user/device
  /// [startPolling] - Whether to start automatic polling
  Future<void> initialize(String userId, {bool startPolling = true}) async {
    _userId = userId;
    
    if (kDebugMode) {
      print('🎯 Initializing OrderTrackingController for user: $userId');
    }

    // Initial fetch
    await refreshOrders();

    // Setup notification listener
    _setupNotificationListener();

    // Setup visibility change listener (web)
    if (kIsWeb) {
      _setupVisibilityListener();
    }

    // Start periodic polling
    if (startPolling) {
      startPeriodicPolling();
    }
  }

  /// Refresh orders from API
  /// 
  /// [showLoading] - Whether to show loading state
  Future<void> refreshOrders({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
      _error = null;
      _safeNotifyListeners();
    }

    try {
      if (kDebugMode) {
        print('🔄 Refreshing user orders...');
      }

      final response = await _apiService.getUserOrders();

      // Check for status changes
      _checkForOrderUpdates(response.orders);

      _userOrders = response.orders;
      _lastRefreshTime = DateTime.now();
      _error = null;

      if (kDebugMode) {
        print('✅ User orders refreshed: ${response.orders.length} orders');
        print('   Active: ${activeOrders.length}');
      }
    } catch (e) {
      _error = 'Failed to fetch orders: $e';
      if (kDebugMode) {
        print('❌ Error refreshing orders: $e');
      }
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  /// Safely notify listeners, avoiding build-time issues
  void _safeNotifyListeners() {
    // Use post-frame callback to avoid calling notifyListeners during build
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_mounted) {
        notifyListeners();
      }
    });
  }

  /// Fetch a specific order by ID
  Future<UserOrder?> fetchOrderById(String orderId) async {
    try {
      if (kDebugMode) {
        print('🔍 Fetching order: $orderId');
      }

      // For now, return from local list since we don't have individual order fetch API
      final order = _userOrders.firstWhere(
        (o) => o.onlineOrderId == orderId,
        orElse: () => throw Exception('Order not found'),
      );
      
      return order;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching order: $e');
      }
      return null;
    }
  }

  /// Start periodic polling for order updates
  void startPeriodicPolling() {
    stopPeriodicPolling(); // Stop existing timer if any

    if (kDebugMode) {
      print('⏰ Starting periodic polling (every ${_pollingInterval.inSeconds}s)');
    }

    _pollingTimer = Timer.periodic(_pollingInterval, (_) {
      refreshOrders(showLoading: false);
    });
  }

  /// Stop periodic polling
  void stopPeriodicPolling() {
    if (_pollingTimer != null) {
      if (kDebugMode) {
        print('⏸️ Stopping periodic polling');
      }
      _pollingTimer?.cancel();
      _pollingTimer = null;
    }
  }

  /// Setup notification listener for real-time updates
  void _setupNotificationListener() {
    _notificationService.messageStream.listen((message) {
      if (kDebugMode) {
        print('🔔 Notification received: ${message.data}');
      }

      // Check if it's an order update notification
      if (message.data.containsKey('orderId')) {
        final orderId = message.data['orderId'];
        final status = message.data['status'];

        if (kDebugMode) {
          print('📦 Order update: $orderId -> $status');
        }

        // Refresh orders to get latest data
        refreshOrders(showLoading: false);
      }
    });
  }

  /// Setup visibility change listener for web
  /// Refreshes orders when tab becomes visible
  void _setupVisibilityListener() {
    if (!kIsWeb) return;

    setupVisibilityChangeListener(() {
      // Tab became visible, refresh orders
      refreshOrders(showLoading: false);
    });
  }

  /// Check for order status changes and show notifications
  void _checkForOrderUpdates(List<UserOrder> newOrders) {
    if (_userOrders.isEmpty) return;

    for (final newOrder in newOrders) {
      final oldOrder = _userOrders.firstWhere(
        (o) => o.onlineOrderId == newOrder.onlineOrderId,
        orElse: () => newOrder,
      );

      // Check if status changed (using integer orderStatus field)
      if (oldOrder.onlineOrderId == newOrder.onlineOrderId && 
          oldOrder.orderStatus != newOrder.orderStatus) {
        if (kDebugMode) {
          print('🔔 Order status changed:');
          print('   Order: ${newOrder.onlineOrderId}');
          print('   Old Status: ${oldOrder.statusDisplayName} (${oldOrder.orderStatus})');
          print('   New Status: ${newOrder.statusDisplayName} (${newOrder.orderStatus})');
        }

        // Note: In-app notification will be shown by UI layer
      }
    }
  }

  /// Get order by ID from local list
  UserOrder? getOrderById(String orderId) {
    try {
      return _userOrders.firstWhere((order) => order.onlineOrderId == orderId);
    } catch (e) {
      return null;
    }
  }

  /// Get orders by completion status (backward compatible)
  List<UserOrder> getOrdersByStatus(bool isCompleted) {
    return _userOrders.where((order) => order.isOrderCompleted == isCompleted).toList();
  }
  
  /// Get orders by specific integer status
  /// 0 = Pending, 1 = Accepted, 2 = Cancelled, 3 = Completed
  List<UserOrder> getOrdersByIntStatus(int status) {
    return _userOrders.where((order) => order.orderStatus == status).toList();
  }

  /// Clear all orders (useful for logout)
  void clearOrders() {
    if (kDebugMode) {
      print('🗑️ Clearing all orders');
    }
    
    _userOrders = [];
    _error = null;
    _userId = null;
    _lastRefreshTime = null;
    _safeNotifyListeners();
  }

  /// Set user ID and refresh
  Future<void> setUserId(String userId) async {
    if (_userId == userId) return;

    if (kDebugMode) {
      print('👤 Setting user ID: $userId');
    }

    _userId = userId;
    await refreshOrders();
  }


  /// Cancel order
  /// 
  /// [orderId] - The online order ID to cancel
  /// Returns true if successful, false otherwise
  /// Throws exception with specific error message for different cases
  Future<bool> cancelOrder(String orderId) async {
    try {
      if (kDebugMode) {
        print('❌ Cancelling order: $orderId');
      }
      
      // Find the order to get the numeric ID
      final order = getOrderById(orderId);
      if (order == null) {
        throw Exception('Order not found in local list');
      }
      
      // Call the API to cancel the order
      final response = await _apiService.cancelOrder(orderId: order.id);
      
      if (kDebugMode) {
        print('✅ Order cancelled successfully: ${response['message']}');
      }
      
      // Refresh orders to get updated list
      await refreshOrders(showLoading: false);
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error cancelling order: $e');
      }
      rethrow; // Re-throw to let the UI handle the error message
    }
  }

  /// Retry failed request
  Future<void> retry() async {
    _error = null;
    await refreshOrders();
  }

  /// Get time since last refresh (formatted)
  String getTimeSinceLastRefresh() {
    if (_lastRefreshTime == null) return 'Never';

    final difference = DateTime.now().difference(_lastRefreshTime!);
    
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${difference.inHours}h ago';
    }
  }

  @override
  void dispose() {
    if (kDebugMode) {
      print('♻️ Disposing OrderTrackingController');
    }

    _mounted = false;
    stopPeriodicPolling();
    super.dispose();
  }
}

