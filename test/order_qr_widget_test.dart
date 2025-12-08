import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:digital_menu_order/widgets/order_qr.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  group('OrderQrWidget Tests', () {
    testWidgets('displays QR widget when orderId and pin present', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: OrderQrWidget(
                orderId: 'TEST-ORDER-123',
                pin: '1234',
                isEnglish: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // QR widget should be present
      expect(find.byType(QrImageView), findsOneWidget);
    });

    testWidgets('displays orderId text visible', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: OrderQrWidget(
                orderId: 'TEST-ORDER-456',
                pin: '5678',
                isEnglish: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Order ID should be visible
      expect(find.text('TEST-ORDER-456'), findsOneWidget);
      expect(find.text('Order ID'), findsOneWidget);
    });

    testWidgets('displays fallback PIN text and copy button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: OrderQrWidget(
                orderId: 'TEST-ORDER-789',
                pin: '9999',
                isEnglish: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // PIN text should be visible
      expect(find.text('9999'), findsOneWidget);
      expect(find.text('PIN'), findsOneWidget);
      
      // Copy button should be present
      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
    });

    testWidgets('supports Arabic localization', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: OrderQrWidget(
                orderId: 'TEST-ORDER-AR',
                pin: '1111',
                isEnglish: false,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Arabic labels should be visible
      expect(find.text('رقم الطلب'), findsOneWidget);
      expect(find.text('رقم التعريف'), findsOneWidget);
    });

    testWidgets('copy button triggers clipboard and snackbar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: OrderQrWidget(
                orderId: 'TEST-COPY',
                pin: '4321',
                isEnglish: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the copy button
      await tester.tap(find.byIcon(Icons.copy_rounded));
      await tester.pumpAndSettle();

      // Snackbar should appear
      expect(find.text('PIN copied to clipboard'), findsOneWidget);
    });

    testWidgets('QR code is responsive to available width', (WidgetTester tester) async {
      // Test with constrained width
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: SingleChildScrollView(
                child: OrderQrWidget(
                  orderId: 'RESPONSIVE-TEST',
                  pin: '5555',
                  isEnglish: true,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // QR should still render
      expect(find.byType(QrImageView), findsOneWidget);
    });

    testWidgets('has proper semantics for accessibility', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: OrderQrWidget(
                orderId: 'ACCESSIBILITY-TEST',
                pin: '6666',
                isEnglish: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check that Semantics widget is present with proper label
      final semanticsFinder = find.byWidgetPredicate(
        (widget) => widget is Semantics && 
                    widget.properties.label == 'Order QR code for order ACCESSIBILITY-TEST',
      );
      expect(semanticsFinder, findsOneWidget);
    });
  });
}

