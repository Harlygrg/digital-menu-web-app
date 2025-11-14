import 'package:digital_menu_order/theme/theme.dart';
import 'package:flutter/material.dart';

class ItemInfoButton extends StatelessWidget {
  final VoidCallback? onTap;
  final double? buttonSize;
  const ItemInfoButton({super.key, this.onTap, this.buttonSize});

  @override
  Widget build(BuildContext context) {
   return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(2),
        child: Icon(
          Icons.info_rounded,
          size:buttonSize ?? 14,
          color: AppColors.grey600,
        ),
      ),
    );
  }
}
