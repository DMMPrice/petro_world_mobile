import 'package:flutter/foundation.dart';

/// Production-safe logging service.
/// Logs are only printed in debug/development builds, completely silent in release.
class LoggerService {
  static final LoggerService _instance = LoggerService._internal();

  factory LoggerService() => _instance;
  LoggerService._internal();

  /// Logs a debug message (only in debug mode)
  static void debug(String message) {
    if (kDebugMode) {
      print('[DEBUG] $message');
    }
  }

  /// Logs an info message (only in debug mode)
  static void info(String message) {
    if (kDebugMode) {
      print('[INFO] $message');
    }
  }

  /// Logs an error message (only in debug mode)
  static void error(String message,
      [Object? exception, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('[ERROR] $message');
      if (exception != null) print('[ERROR] Exception: $exception');
      if (stackTrace != null) print('[ERROR] StackTrace: $stackTrace');
    }
  }

  /// Logs a warning message (only in debug mode)
  static void warning(String message) {
    if (kDebugMode) {
      print('[WARNING] $message');
    }
  }
}
