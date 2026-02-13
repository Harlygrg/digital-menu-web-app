import 'dart:html' as html;

/// Dispatches a custom 'flutter-first-frame' event on the window.
/// The boot shell in index.html listens for this event and fades out.
void dispatchFlutterFirstFrame() {
  html.window.dispatchEvent(html.CustomEvent('flutter-first-frame'));
}
