/// Paths for restaurant branding assets.
///
/// **Web:** [webDeploymentLogoRelativePath] is resolved against the app origin
/// (`Uri.base`). Deployers add/replace the file under `web/branding/` in source
/// (copied into `build/web/branding/` on build) or paste the same path on the
/// server after deploy—no Dart changes or rebuild required for replacement.
///
/// **Non-web:** [bundledLogoAssetPath] is compiled into the app bundle.
class RestaurantAssets {
  RestaurantAssets._();

  /// Path relative to site root / app base URL (e.g. `/app/branding/...`).
  static const String webDeploymentLogoRelativePath =
      'branding/restaurant_logo.png';

  /// Bundled asset for iOS/Android/desktop (not post-deploy replaceable).
  static const String bundledLogoAssetPath = 'assets/images/rest_logo.jpg';
}
