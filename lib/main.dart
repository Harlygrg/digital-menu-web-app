import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'theme/theme.dart';
import 'routes/routes.dart';
import 'providers/home_provider.dart';
import 'providers/language_provider.dart';
import 'providers/table_provider.dart';
import 'providers/order_type_provider.dart';
import 'providers/branch_provider.dart';
import 'providers/order_provider.dart';
import 'providers/customer_provider.dart';
import 'controllers/cart_controller.dart';
import 'controllers/order_tracking_controller.dart';
import 'utils/scroll_behavior_utils.dart';
import 'utils/category_icon_helper.dart';
import 'storage/local_storage.dart';
import 'models/hive_adapters.dart';
import 'models/cart_item_model.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'services/api/api_service.dart';
import 'config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load external runtime configuration FIRST (before any API calls)
  // This allows clients to change the API URL by editing build/web/config.json
  // without rebuilding the Flutter app
  await AppConfig.load();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  ApiService().initialize();
  
  await CategoryIconHelper.loadCategoryData();
  
  await Hive.initFlutter();
  
  Hive.registerAdapter(CartModifierAdapter());
  Hive.registerAdapter(UnitPriceListModelAdapter());
  Hive.registerAdapter(UnitMasterModelAdapter());
  Hive.registerAdapter(ProductDetailsModelAdapter());
  Hive.registerAdapter(ItemModelAdapter());
  Hive.registerAdapter(CartItemModelAdapter());
  
  await Hive.openBox<CartItemModel>('cartBox');
  
  await _extractAndSaveBranchId();
  
  ScrollBehaviorUtils.initializeWebScrollbarHiding();
  
  runApp(const DigitalMenuApp());
}

/// Extracts branch_id from URL parameters (web/PWA) and saves it to local storage
Future<void> _extractAndSaveBranchId() async {
// debugPrint('🔍 _extractAndSaveBranchId: Starting extraction...');
  String? branchId;
  try {
    // Check URL parameters
    if (Uri.base.hasQuery) {
      branchId = Uri.base.queryParameters['branch_id'];
// debugPrint('🔍 URL has query parameters: ${Uri.base.query}');
    } else {
// debugPrint('ℹ️ URL has no query parameters');
    }
    
    if (branchId != null && branchId.isNotEmpty) {
// debugPrint('✅ Branch ID found in URL: $branchId');
      final success = await LocalStorage.saveBranchId(branchId);
      
      if (success) {
// debugPrint('✅ Branch ID successfully saved to local storage: $branchId');
      } else {
// debugPrint('❌ Failed to save branch ID to local storage');
      }
    } else {
// debugPrint('ℹ️ No branch_id parameter found in URL');
      
      // Check if we have a previously saved branch ID
      final savedBranchId = await LocalStorage.getBranchId();
      if (savedBranchId != null && savedBranchId.isNotEmpty) {
// debugPrint('✅ Using previously saved branch ID: $savedBranchId');
      } else {
// debugPrint('ℹ️ No previously saved branch ID found');
      }
    }
  } catch (e) {
// debugPrint('❌ Error extracting branch ID from URL: $e');
  }
}

/// Main application widget
class DigitalMenuApp extends StatefulWidget {
  const DigitalMenuApp({super.key});

  @override
  State<DigitalMenuApp> createState() => _DigitalMenuAppState();
}

class _DigitalMenuAppState extends State<DigitalMenuApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _setupNotificationNavigation();
  }

  /// Setup notification navigation listener
  void _setupNotificationNavigation() {
    // Listen to navigation stream from notification service
    _notificationService.navigationStream.listen((route) {
      if (_navigatorKey.currentState != null) {
// debugPrint('🚀 Navigating to: $route');
        _navigatorKey.currentState!.pushNamed(route);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => TableProvider()),
        ChangeNotifierProvider(create: (_) => OrderTypeProvider()),
        ChangeNotifierProvider(create: (_) => BranchProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => CartController()),
        ChangeNotifierProvider(create: (_) => OrderTrackingController()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()..initialize()),
      ],
      // Selector listens ONLY to the language-relevant tuple, preventing
      // full tree rebuilds when HomeProvider state (items, cart, etc.) changes.
      child: Selector<LanguageProvider, ({bool isEnglish, TextDirection dir})>(
        selector: (_, lang) => (isEnglish: lang.isEnglish, dir: lang.textDirection),
        builder: (context, langState, cachedChild) {
          return MaterialApp(
            navigatorKey: _navigatorKey,
            title: 'Digital Menu Order',
            debugShowCheckedModeBanner: false,
            
            // Enhanced scroll behavior for cross-platform support
            scrollBehavior: ScrollBehaviorUtils.createCrossPlatformScrollBehavior(),
            
            // Theme configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.lightTheme,
            themeMode: ThemeMode.system,
            
            // Localization configuration
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('ar', 'SA'),
            ],
            locale: langState.isEnglish 
                ? const Locale('en', 'US')
                : const Locale('ar', 'SA'),
            
            // Route configuration
            onGenerateRoute: AppRoutes.onGenerateRoute,
            initialRoute: AppRoutes.home,
            
            // RTL support
            builder: (context, child) {
              // Update notification service context after first frame
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_navigatorKey.currentContext != null) {
                  _notificationService.setContext(_navigatorKey.currentContext!);
                }
              });
              
              return Directionality(
                textDirection: langState.dir,
                child: child!,
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    // Clean up notification service
    _notificationService.dispose();
    super.dispose();
  }
}
