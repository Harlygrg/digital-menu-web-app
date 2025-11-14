import 'package:digital_menu_order/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/home_provider.dart';

class AddItemButton extends StatelessWidget {
  final Function()? onTap;
  final bool isListItem ;
   const AddItemButton({super.key, this.onTap, this.isListItem = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        return InkWell(
          onTap: onTap,
          child: Container(
            margin: EdgeInsets.only(right: Responsive.padding(context, 2)),
            padding: EdgeInsets.symmetric(
              vertical: Responsive.padding(context, 2),
              horizontal: Responsive.padding(context, 10),
            ),
            alignment: Alignment.center,
            decoration: ShapeDecoration(
              color: Theme.of(context).colorScheme.onPrimary,
              shape: StadiumBorder(),
              shadows: [
                BoxShadow(
                  color: AppColors.grey400,
                  blurRadius: 5,
                  spreadRadius: -1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/shopping-bag.png',
                  color: Theme.of(context).colorScheme.primary,
                  width: isListItem ? 20 : 15,
                  height: isListItem ? 15 : 12,
                ),
                SizedBox(width: Responsive.padding(context, 8)),
                Text(
                  provider.isEnglish ? 'Add' : 'إضافة',
                  style: isListItem
                      ? Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        )
                      : Theme.of(context).textTheme.labelSmall!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
