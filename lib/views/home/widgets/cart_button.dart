import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/home_controller.dart';
import '../../../theme/theme.dart';
import '../../../routes/routes.dart';

/// Cart button widget with badge showing item count
class CartButtonWidget extends StatelessWidget {
  final HomeController controller;

  const CartButtonWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CartController>(
      builder: (context, cartController, child) {
        final total = cartController.totalPrice;
        final itemCount = cartController.itemCount;
        
        return Stack(
          children: [
            InkWell(
              onTap: () => _navigateToCartScreen(context),
              child: Container(
                height:MediaQuery.of(context).size.width > 1200 ? 38 : 30,
                padding: EdgeInsets.all(Responsive.padding(context, 5)),
                constraints: BoxConstraints(
                  minWidth: 80, // minimum width
                ),
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  shape: StadiumBorder(),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shopping_cart,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 18,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'QR ${total.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w500
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            // Badge showing cart count
            if (itemCount > 0)
              Positioned(
                right: 5,
                top: 0,
                child: Container(
                  padding: EdgeInsets.all(Responsive.padding(context, 2)),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: BoxConstraints(
                    minWidth: Responsive.padding(context, 16),
                    minHeight: Responsive.padding(context, 16),
                  ),
                  child: Text(
                    '$itemCount',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onError,
                      fontSize: Responsive.fontSize(context, 10),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Navigate to cart screen
  void _navigateToCartScreen(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.cart);
  }
}
