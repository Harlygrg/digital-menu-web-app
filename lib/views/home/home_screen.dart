import 'dart:async';
import 'package:digital_menu_order/providers/language_provider.dart';
import 'package:digital_menu_order/providers/order_type_provider.dart';
import 'package:digital_menu_order/providers/table_provider.dart';
import 'package:digital_menu_order/services/extract_url_token_service.dart';
import 'package:digital_menu_order/utils/qr_gate_messages.dart';
import 'package:digital_menu_order/utils/rul_reader.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/branch_provider.dart';
import '../../providers/customer_provider.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../theme/theme.dart';
import '../../services/notification_service.dart';
import '../../firebase_options.dart';
import '../../routes/routes.dart';
import '../../utils/app_session.dart';
import '../../utils/currency_format.dart';
import '../../utils/qr_init_context.dart';
import '../../utils/scroll_behavior_utils.dart';
import '../../widgets/cart_price_sync_dialog.dart';
import 'widgets/app_bar_silver.dart';
import 'widgets/search_bar.dart';
import 'widgets/branch_dropdown.dart';
import 'widgets/veg_toggle.dart';
import 'widgets/category_chips.dart';
import 'widgets/grid_list_toggle.dart';
import 'widgets/items_grid.dart';
import 'widgets/items_list.dart';

// Conditional import for web
import 'dart:html' as html show window;
import 'package:digital_menu_order/utils/app_debug_log.dart';

enum _HomeInitState { loading, ready, failed }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeController? _controller;
  String? _lastShownErrorMessage;
  bool _didPromptCartPriceSync = false;
  _HomeInitState _initState = _HomeInitState.loading;
  String? _initErrorMessage;
  StreamSubscription? _popStateSub;

  HomeController get _activeController => _controller!;

  @override
  void initState() {
    super.initState();

    _init();

    // 🔥 Listen URL changes
    if (kIsWeb) {
      _popStateSub = html.window.onPopState.listen((event) {
        _handleUrlChange();
      });
    }
  }

  Future<void> _handleUrlChange() async {
    final newToken = readQrTokenFromEnvironment();

    if (newToken != QrInitContext.initialToken) {
      appDebugLog('🔄 New QR detected → $newToken');

      QrInitContext.setInitialToken(newToken);

      await _init();
    }
  }

  Future<void> _init() async {
    if (mounted) {
      setState(() {
        _initState = _HomeInitState.loading;
        _initErrorMessage = null;
      });
    }

    _controller?.dispose();
    _controller = null;

    try {
      appDebugLog('🚀 Starting QR-first initialization...');

      // STEP 1: Token + `qr/resolve` + persist only (circular progress).
      final qrResult = await resolveQrFromInitialToken();

      if (!mounted) return;

      if (QrInitContext.isResolved) {
        appDebugLog('🧹 Resetting provider state for new QR');

        context.read<OrderTypeProvider>().clearSelection();
        context.read<TableProvider>().clearAllSelections();
      }

      if (qrResult.shouldBlockUi) {
        setState(() {
          _initState = _HomeInitState.failed;
          _initErrorMessage =
              qrResult.errorMessage ??
              'We could not open this menu link. Please try again.';
        });
        return;
      }

      // STEP 2: Create controller; show home shell + shimmer while bootstrapping.
      final provider = context.read<HomeProvider>();
      final branchProvider = context.read<BranchProvider>();
      final customerProvider = context.read<CustomerProvider>();

      final controller = HomeController(
        provider,
        branchProvider: branchProvider,
        customerProvider: customerProvider,
      );
      _controller = controller;

      customerProvider.syncFromQrInitContext();

      if (!mounted) return;
      setState(() {
        _initState = _HomeInitState.ready;
        _initErrorMessage = null;
      });

      await controller.initialize(context: context);

      await _handleCartPricingContextIfNeeded();

      _initializeFirebaseMessagingInBackground();

      appDebugLog('✅ Full initialization complete');
    } catch (e) {
      appDebugLog('❌ Init error: $e');
      if (!mounted) return;

      final defaultMessage = QrInitContext.hasInitialToken
          ? 'We could not open this QR menu. Please scan again or contact staff.'
          : 'The app could not start. Please try again.';
      final message = QrInitContext.failureMessage?.trim().isNotEmpty == true
          ? QrInitContext.failureMessage!
          : defaultMessage;

      if (QrInitContext.hasInitialToken && !QrInitContext.isFailed) {
        QrInitContext.markFailed(message);
      }

      setState(() {
        _initState = _HomeInitState.failed;
        _initErrorMessage = message;
      });
    }
  }

  Future<void> _handleCartPricingContextIfNeeded() async {
    if (_didPromptCartPriceSync) return;
    final homeProvider = context.read<HomeProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;

    final cartController = context.read<CartController>();
    if (cartController.isEmpty) return;

    final isStale = await cartController.isCartPricingContextStale();
    if (!mounted) return;
    if (!isStale) return;

    _didPromptCartPriceSync = true;
    await cartController.markNeedsPriceSync();
    if (!mounted) return;
    final proceed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          CartPriceSyncDialog(isEnglish: homeProvider.isEnglish),
    );

    if (proceed == true && mounted) {
      try {
        await cartController.syncCartPrices();
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              homeProvider.isEnglish ? 'Cart updated.' : 'تم تحديث السلة.',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              homeProvider.isEnglish
                  ? 'Failed to update cart. Please try again.'
                  : 'فشل تحديث السلة. حاول مرة أخرى.',
            ),
            backgroundColor: errorColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Initialize Firebase Messaging in background (non-blocking)
  /// This runs asynchronously and doesn't block the main UI thread
  void _initializeFirebaseMessagingInBackground() {
    // Run in background without blocking
    Future.microtask(() async {
      try {
        appDebugLog('🔔 Starting FCM initialization...');

        // Setup background message handler
        FirebaseMessaging.onBackgroundMessage(
          firebaseMessagingBackgroundHandler,
        );

        // Wait for service worker on web
        if (kIsWeb) {
          appDebugLog('⏳ Waiting for service worker...');
          await _waitForServiceWorkerReady();
          appDebugLog('✅ Service worker ready');

          // Small delay to ensure service worker is fully active
          await Future.delayed(const Duration(milliseconds: 500));
        }

        // Initialize notification service
        final notificationService = NotificationService();

        // ✅ NEW APPROACH: Check LIVE browser permission dynamically
        // This fetches the real-time permission status from the browser,
        // not from any locally stored value. This ensures we always have
        // the current permission state, even if user changed it in browser settings.
        final browserPermission = notificationService
            .getBrowserNotificationPermission();
        appDebugLog(
          '📱 Browser notification permission (live): $browserPermission',
        );

        // DEPRECATED: Old approach that relied on locally stored permission state
        // This caused mismatches when users changed browser settings
        // final wasGranted = await LocalStorage.wasNotificationPermissionGranted();
        // appDebugLog('📱 Notification permission previously granted: $wasGranted');

        if (kIsWeb) {
          if (browserPermission == 'granted') {
            // Permission already granted - skip dialog and get token directly
            appDebugLog(
              '✅ Browser permission already granted, getting FCM token...',
            );
            await notificationService.initialize(
              vapidKey: DefaultFirebaseOptions.webVapidKey,
              context: context,
            );
          } else if (browserPermission == 'denied') {
            // Permission explicitly denied by user in browser
            appDebugLog('❌ Browser permission explicitly denied by user');
            appDebugLog(
              'ℹ️ User must enable notifications in browser settings to receive updates',
            );
            return; // Exit early - can't request permission if denied
          } else {
            // Permission not yet requested (default state)
            appDebugLog('📱 Permission not yet requested, showing dialog...');

            // DEPRECATED: Old approach saved permission to local storage
            // await LocalStorage.setNotificationPermissionAsked(true);

            // Show permission dialog (non-blocking for UI, happens after content is visible)
            final shouldRequestPermission =
                await _showNotificationPermissionDialog();

            if (!shouldRequestPermission) {
              appDebugLog(
                'ℹ️ User declined notification permission from app dialog',
              );

              // DEPRECATED: Old approach saved declined state to local storage
              // await LocalStorage.setNotificationPermissionGranted(false);

              return; // Exit early without FCM token
            }

            // User accepted app dialog, now request browser permission
            appDebugLog(
              '✅ User accepted app dialog, initializing FCM (will trigger browser prompt)...',
            );
            await notificationService.initialize(
              vapidKey: DefaultFirebaseOptions.webVapidKey,
              context: context,
            );
          }
        } else {
          // For non-web platforms, just initialize directly
          await notificationService.initialize(
            vapidKey: DefaultFirebaseOptions.webVapidKey,
            context: context,
          );
        }

        // Get FCM token
        // Note: The token is fetched from Firebase but NOT stored locally
        // It will be automatically registered with the server via NotificationService
        appDebugLog('🔍 Getting FCM token...');
        final String fcmToken = await notificationService.getFcmToken();

        if (fcmToken.isNotEmpty) {
          appDebugLog('✅ FCM Token obtained: ${fcmToken.substring(0, 20)}...');

          // DEPRECATED: Old approach saved permission state to local storage
          // This caused mismatches when users changed browser settings later
          // await LocalStorage.setNotificationPermissionGranted(true);

          appDebugLog(
            '✅ FCM token automatically registered with server via NotificationService',
          );
        } else {
          appDebugLog('⚠️ FCM token is empty');

          // DEPRECATED: Old approach saved permission state to local storage
          // await LocalStorage.setNotificationPermissionGranted(false);
        }

        // Setup token refresh listener
        // Note: Token is NOT saved to local storage - it's automatically sent to server
        notificationService.tokenStream.listen((newToken) async {
          appDebugLog('🔄 Token refreshed: $newToken');
          appDebugLog(
            'ℹ️ Token will be automatically sent to server via NotificationService',
          );
        });

        // Setup message listener
        notificationService.messageStream.listen((message) {
          appDebugLog('📨 Message received:');
          appDebugLog('  Title: ${message.notification?.title}');
          appDebugLog('  Body: ${message.notification?.body}');
        });

        appDebugLog('✅ FCM initialization complete');
      } catch (e) {
        appDebugLog('⚠️ Error during FCM initialization (non-critical): $e');
        // FCM errors are non-critical - app should still work without notifications
      }
    });
  }

  /// Show a dialog asking user for notification permission
  Future<bool> _showNotificationPermissionDialog() async {
    if (!mounted) return false;

    final provider = context.read<HomeProvider>();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
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
                  provider.isEnglish
                      ? 'Enable Notifications'
                      : 'تفعيل الإشعارات',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                provider.isEnglish
                    ? 'Get real-time updates about your orders!'
                    : 'احصل على تحديثات فورية حول طلباتك!',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _buildPermissionFeature(
                dialogContext,
                Icons.shopping_bag,
                provider.isEnglish
                    ? 'Order status updates'
                    : 'تحديثات حالة الطلب',
              ),
              _buildPermissionFeature(
                dialogContext,
                Icons.check_circle,
                provider.isEnglish
                    ? 'Order ready notifications'
                    : 'إشعارات جاهزية الطلب',
              ),
              _buildPermissionFeature(
                dialogContext,
                Icons.local_offer,
                provider.isEnglish
                    ? 'Special offers & promotions'
                    : 'عروض خاصة وترويجات',
              ),
              const SizedBox(height: 16),
              Text(
                provider.isEnglish
                    ? 'You can change this in your browser settings anytime.'
                    : 'يمكنك تغيير هذا في إعدادات المتصفح في أي وقت.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: Text(
                provider.isEnglish ? 'Not Now' : 'ليس الآن',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(
                provider.isEnglish ? 'Enable' : 'تفعيل',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  /// Build a feature row for the permission dialog
  Widget _buildPermissionFeature(
    BuildContext context,
    IconData icon,
    String text,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  /// Wait for service worker to be ready before initializing FCM
  Future<void> _waitForServiceWorkerReady() async {
    if (!kIsWeb) return;

    try {
      final serviceWorker = html.window.navigator.serviceWorker;
      if (serviceWorker == null) {
        appDebugLog('⚠️ Service Worker API not available');
        return;
      }

      appDebugLog('🔍 Checking for service worker registration...');

      // Wait for service worker to be ready (up to 10 seconds)
      final completer = Completer<void>();
      var attempts = 0;
      const maxAttempts = 20; // 10 seconds (20 * 500ms)

      Timer.periodic(const Duration(milliseconds: 500), (timer) async {
        attempts++;

        try {
          final registration = await serviceWorker.getRegistration();

          timer.cancel();
          final isActive = registration.active != null;

          if (isActive) {
            appDebugLog('✅ Service worker found and registered');
            appDebugLog('   Scope: ${registration.scope}');
          } else {
            appDebugLog('⚠️ Service worker registered but not active yet');
            if (attempts >= maxAttempts) {
              appDebugLog(
                '⚠️ Service worker not active after ${maxAttempts * 500}ms, proceeding anyway',
              );
            }
          }

          if (!completer.isCompleted) completer.complete();
        } catch (e) {
          appDebugLog(
            '⚠️ Error checking service worker (attempt $attempts/$maxAttempts): $e',
          );
          if (attempts >= maxAttempts) {
            timer.cancel();
            appDebugLog('⚠️ Proceeding without service worker confirmation');
            if (!completer.isCompleted) completer.complete();
          }
        }
      });

      await completer.future;
    } catch (e) {
      appDebugLog('❌ Error waiting for service worker: $e');
    }
  }

  /// Handle pull-to-refresh
  Future<void> _handleRefresh() async {
    final provider = context.read<HomeProvider>();
    final branchId = (await AppSession.getBranchId())?.toString() ?? '1';

    // Use silentRefresh to prevent loading state flashing
    await provider.fetchProductRelatedData(
      branchId: branchId,
      silentRefresh: true,
    );
  }

  @override
  void dispose() {
    _popStateSub?.cancel();   // 🔥 stop URL listener
    _controller?.dispose();   // 🔥 clean your controller
    super.dispose();
  }

  /// Token read + `qr/resolve` + persist only (no app chrome, no shimmer).
  Widget _buildTokenPhaseLoading() {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initState == _HomeInitState.failed) {
      return _buildStartupErrorScaffold();
    }

    if (_initState == _HomeInitState.loading) {
      return _buildTokenPhaseLoading();
    }

    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        _showErrorSnackBarIfNeeded(provider);
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: const AppBarSilver(),
          body: Responsive.isDesktop(context)
              ? _buildDesktopLayout(provider)
              : _buildMobileLayout(provider),
          // Cart button moved to Floating Action Button for better UX
          floatingActionButton: _buildCartFab(context),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }

  Widget _buildStartupErrorScaffold() {
    final isEnglish = context.watch<LanguageProvider>().isEnglish;
    final isQrLaunch = QrInitContext.hasInitialToken;
    final rawMessage = _initErrorMessage;
    final bodyText = _localizedStartupErrorBody(rawMessage, isEnglish);

    final String title;
    if (rawMessage == QrGateMessages.missingTokenEn) {
      title = QrGateMessages.startupTitleMissingToken(isEnglish);
    } else if (rawMessage == QrGateMessages.saveContextFailedEn) {
      title = QrGateMessages.startupTitleTokenFailed(isEnglish);
    } else if (isQrLaunch || QrInitContext.isFailed) {
      title = QrGateMessages.startupTitleTokenFailed(isEnglish);
    } else {
      title = QrGateMessages.startupTitleGeneric(isEnglish);
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.qr_code_2_rounded,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    bodyText ??
                        (isEnglish
                            ? 'The app could not start. Please try again.'
                            : 'تعذر تشغيل التطبيق. حاول مرة أخرى.'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _init,
                      child: Text(QrGateMessages.retryButton(isEnglish)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _localizedStartupErrorBody(String? raw, bool isEnglish) {
    if (raw == null) return null;
    if (raw == QrGateMessages.missingTokenEn) {
      return QrGateMessages.missingToken(isEnglish);
    }
    if (raw == QrGateMessages.saveContextFailedEn) {
      return QrGateMessages.saveContextFailed(isEnglish);
    }
    return raw;
  }

  /// Shows error snackbar once per unique provider message.
  void _showErrorSnackBarIfNeeded(HomeProvider provider) {
    final message = provider.errorMessage;
    if (message == null || message.isEmpty) {
      return;
    }
    if (_lastShownErrorMessage == message) {
      return;
    }

    _lastShownErrorMessage = message;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 4),
        ),
      );
    });
  }

  /// Build Floating Action Button for cart
  /// Displays cart total price with a badge showing item count
  Widget _buildCartFab(BuildContext context) {
    return Consumer<CartController>(
      builder: (context, cartController, child) {
        final total = cartController.totalPrice;
        final itemCount = cartController.itemCount;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.cart);
              },
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              elevation: 6,
              icon: Icon(
                Icons.shopping_cart,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 24,
              ),
              label: Text(
                formatCurrencyAmount(total),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            // Badge showing cart item count
            if (itemCount > 0)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 2,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                  child: Center(
                    child: Text(
                      '$itemCount',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onError,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Build mobile/tablet layout
  Widget _buildMobileLayout(HomeProvider provider) {
    final controller = _activeController;
    final scrollView = CustomScrollView(
      physics: ScrollBehaviorUtils.getScrollPhysics(),
      // Reduced cache extent — preloads fewer off-screen items to lower
      // memory pressure and speed up initial layout on low-end devices.
      cacheExtent: 250.0,
      slivers: [
        // Search bar section
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(Responsive.padding(context, 16)),
            child: SearchBarWidget(controller: controller),
          ),
        ),

        // Branch dropdown and Orders button
        // SliverToBoxAdapter(
        //   child: Padding(
        //     padding: EdgeInsets.symmetric(
        //       horizontal: Responsive.padding(context, 16),
        //     ),
        //     child: Row(
        //       children: [
        //         const BranchDropdownWidget(),
        //         const Spacer(),
        //         TextButton.icon(
        //           onPressed: () {
        //             Navigator.pushNamed(context, '/order-tracking');
        //           },
        //           icon: Icon(
        //             Icons.receipt_long,
        //             size: Responsive.fontSize(context, 20),
        //             color: Theme.of(context).colorScheme.primary,
        //           ),
        //           label: Text(
        //             provider.isEnglish ? 'Orders' : 'الطلبات',
        //             style: TextStyle(
        //               color: Theme.of(context).colorScheme.primary,
        //               fontSize: Responsive.fontSize(context, 14),
        //               fontWeight: FontWeight.w600,
        //             ),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),

        // SizedBox(height: Responsive.padding(context, 16)).toSliverBox(),

        // Veg/Non-veg toggle section
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.padding(context, 16),
            ),
            child: Row(
              children: [
                VegToggleWidget(controller: controller),
                const Spacer(),
                GridListToggleWidget(controller: controller),
              ],
            ),
          ),
        ),

        SizedBox(height: Responsive.padding(context, 16)).toSliverBox(),

        // Category chips section
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.padding(context, 16),
            ),
            child: CategoryChipsWidget(controller: controller),
          ),
        ),

        SizedBox(height: Responsive.padding(context, 16)).toSliverBox(),

        // Selected category name display
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.padding(context, 16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    provider.getCurrentTitle(provider.isEnglish),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Text(
                  '${provider.filteredItems.length} ${provider.isEnglish ? 'items' : 'صنف'}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: Responsive.fontSize(context, 14),
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: Responsive.padding(context, 12)).toSliverBox(),

        // Items grid or list based on view mode
        if (provider.isGridView)
          ItemsGridWidget(controller: controller)
        else
          ItemsListWidget(controller: controller),

        // Bottom padding
        SizedBox(height: Responsive.padding(context, 80)).toSliverBox(),
      ],
    );

    if (kIsWeb) {
      return scrollView;
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: Theme.of(context).colorScheme.primary,
      child: scrollView,
    );
  }

  /// Build desktop layout with centered content
  Widget _buildDesktopLayout(HomeProvider provider) {
    final controller = _activeController;
    final scrollView = Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: Responsive.maxContentWidth(context),
        ),
        child: CustomScrollView(
          physics: ScrollBehaviorUtils.getScrollPhysics(),
          // Reduced cache extent — see mobile layout comment
          cacheExtent: 250.0,
          slivers: [
            // Search bar section
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(Responsive.padding(context, 16)),
                child: SearchBarWidget(controller: controller),
              ),
            ),

            // Branch dropdown and Orders button
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.padding(context, 16),
                ),
                child: Row(
                  children: [
                    const BranchDropdownWidget(),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/order-tracking');
                      },
                      icon: Icon(
                        Icons.receipt_long,
                        size: Responsive.fontSize(context, 20),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      label: Text(
                        provider.isEnglish ? 'Orders' : 'الطلبات',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: Responsive.fontSize(context, 14),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: Responsive.padding(context, 16)).toSliverBox(),

            // Veg/Non-veg toggle section
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.padding(context, 16),
                ),
                child: Row(
                  children: [
                    VegToggleWidget(controller: controller),
                    const Spacer(),
                    GridListToggleWidget(controller: controller),
                  ],
                ),
              ),
            ),

            SizedBox(height: Responsive.padding(context, 16)).toSliverBox(),

            // Category chips section
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.padding(context, 16),
                ),
                child: CategoryChipsWidget(controller: controller),
              ),
            ),

            SizedBox(height: Responsive.padding(context, 16)).toSliverBox(),

            // Selected category name display
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.padding(context, 16),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 4,
                      width: 32,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        provider.getCurrentTitle(provider.isEnglish),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: Responsive.fontSize(context, 18),
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      '${provider.filteredItems.length} ${provider.isEnglish ? 'items' : 'صنف'}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: Responsive.fontSize(context, 14),
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: Responsive.padding(context, 12)).toSliverBox(),

            // Items grid or list based on view mode
            if (provider.isGridView)
              ItemsGridWidget(controller: controller)
            else
              ItemsListWidget(controller: controller),

            // Bottom padding
            SizedBox(height: Responsive.padding(context, 80)).toSliverBox(),
          ],
        ),
      ),
    );

    if (kIsWeb) {
      return scrollView;
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: Theme.of(context).colorScheme.primary,
      child: scrollView,
    );
  }
}

/// Extension to convert SizedBox to SliverToBoxAdapter
extension SizedBoxExtension on SizedBox {
  Widget toSliverBox() {
    return SliverToBoxAdapter(child: this);
  }
}
