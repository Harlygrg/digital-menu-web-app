import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../constants/restaurant_assets.dart';
import '../theme/theme.dart';

/// Restaurant logo: on **web**, loads from [RestaurantAssets.webDeploymentLogoRelativePath]
/// (static URL under the app base; replaceable on server without rebuild). On other
/// platforms, uses [RestaurantAssets.bundledLogoAssetPath]. Fallback UI if load fails.
class RestaurantLogo extends StatelessWidget {
  const RestaurantLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = Responsive.padding(context, 40);
    final borderRadius = BorderRadius.circular(8);
    final borderSide = BorderSide(
      color: theme.colorScheme.outline.withValues(alpha: 0.22),
      width: 1,
    );

    Widget fallback() {
      return ColoredBox(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.35,
        ),
        child: Center(
          child: Icon(
            Icons.restaurant_menu,
            color: theme.colorScheme.primary,
            size: Responsive.fontSize(context, 24),
          ),
        ),
      );
    }

    return Semantics(
      label: 'Restaurant logo',
      image: true,
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.fromBorderSide(borderSide),
          ),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: kIsWeb
                ? Image.network(
                    Uri.base
                        .resolve(RestaurantAssets.webDeploymentLogoRelativePath)
                        .toString(),
                    width: size,
                    height: size,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                    errorBuilder: (context, error, stackTrace) => fallback(),
                  )
                : Image.asset(
                    RestaurantAssets.bundledLogoAssetPath,
                    width: size,
                    height: size,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                    errorBuilder: (context, error, stackTrace) => fallback(),
                  ),
          ),
        ),
      ),
    );
  }
}
