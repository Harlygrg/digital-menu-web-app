import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:digital_menu_order/main.dart';
import 'package:digital_menu_order/providers/home_provider.dart';

void main() {
  // Note: OrderQrWidget tests are in test/order_qr_widget_test.dart
  // to avoid dart:html import issues from main.dart
  
  group('Digital Menu App Tests', () {
    testWidgets('App compiles and runs', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => HomeProvider(),
          child: const DigitalMenuApp(),
        ),
      );

      // Wait for initialization
      await tester.pumpAndSettle();

      // App should be running
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Language dropdown is present', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => HomeProvider(),
          child: const DigitalMenuApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Find language dropdown
      final languageDropdown = find.byType(DropdownButton<String>);
      expect(languageDropdown, findsOneWidget);
    });

    testWidgets('Search field is present', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => HomeProvider(),
          child: const DigitalMenuApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Find search field
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
    });

    testWidgets('Cart button is present', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => HomeProvider(),
          child: const DigitalMenuApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Find cart button
      final cartButton = find.byIcon(Icons.shopping_cart);
      expect(cartButton, findsOneWidget);
    });
  });
}
