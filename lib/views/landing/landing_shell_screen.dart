import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../home/home_screen.dart';

// Conditional import for web — used to dispatch first-frame event
import 'landing_shell_web_stub.dart'
    if (dart.library.html) 'landing_shell_web.dart';

/// Landing shell screen that renders the first meaningful frame fast,
/// then signals the HTML boot shell to fade out.
///
/// This screen:
/// 1. Renders a lightweight shimmer skeleton matching HomeScreen dimensions
///    (avoids CLS when HomeScreen loads)
/// 2. Dispatches a `flutter-first-frame` JS event so the HTML boot shell
///    can be removed
/// 3. Immediately navigates to [HomeScreen] after the first frame
///
/// The route replaces itself so the user never sees a back button.
class LandingShellScreen extends StatefulWidget {
  const LandingShellScreen({super.key});

  @override
  State<LandingShellScreen> createState() => _LandingShellScreenState();
}

class _LandingShellScreenState extends State<LandingShellScreen> {
  @override
  void initState() {
    super.initState();
    // After the first frame is painted, dispatch the JS event and navigate
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onFirstFrame();
    });
  }

  void _onFirstFrame() {
    // Signal HTML boot shell removal on web
    if (kIsWeb) {
      dispatchFlutterFirstFrame();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Render the actual HomeScreen immediately — the boot shell in HTML
    // covers the screen until Flutter paints its first frame.
    return const HomeScreen();
  }
}
