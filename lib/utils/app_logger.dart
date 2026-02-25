// lib/utils/app_logger.dart
import 'package:flutter/foundation.dart';

/// Thin logging utility. All calls are no-ops in release builds.
/// Use prefixes: [API] [DB] [Auth] [Places] [Itinerary] [Prefs] [FATAL]
class AppLogger {
  static void info(String message) {
    debugPrint('[INFO] $message');
  }

  static void warn(String message) {
    debugPrint('[WARN] $message');
  }

  static void error(String message, {Object? error, StackTrace? stack}) {
    debugPrint('[ERROR] $message');
    if (error != null) debugPrint('  cause: $error');
    if (stack != null) debugPrint('  stack: $stack');
  }

  static void fatal(String message, {Object? error, StackTrace? stack}) {
    debugPrint('[FATAL] $message');
    if (error != null) debugPrint('  cause: $error');
    if (stack != null) debugPrint('  stack: $stack');
  }
}
