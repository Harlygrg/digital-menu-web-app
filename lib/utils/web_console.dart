// Use `dart:html` availability to detect Flutter Web reliably (debug & release).
export 'web_console_stub.dart' if (dart.library.html) 'web_console_web.dart';

