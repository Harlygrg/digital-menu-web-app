import 'dart:html' as html;

import 'logging_flags.dart';

/// Web implementation: always logs to the browser console (works in production).
class WebConsole {
  static void log(String message) {
    if (!LoggingFlags.consoleLoggingEnabled) return;
    html.window.console.log(message);
  }

  static void info(String message) {
    if (!LoggingFlags.consoleLoggingEnabled) return;
    html.window.console.info(message);
  }

  static void debug(String message) {
    if (!LoggingFlags.consoleLoggingEnabled) return;
    html.window.console.debug(message);
  }

  static void warn(String message) {
    if (!LoggingFlags.consoleLoggingEnabled) return;
    html.window.console.warn(message);
  }

  static void error(String message) {
    if (!LoggingFlags.consoleLoggingEnabled) return;
    html.window.console.error(message);
  }
}
