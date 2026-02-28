import 'package:flutter/foundation.dart';

/// Simple print-based logger with timestamps and log levels
class SimplePrintLogger {
  final String name;

  SimplePrintLogger(this.name);

  String _timestamp() => DateTime.now().toString().substring(11, 23);

  void debug(String message) {
    if (kDebugMode) {
      print('[${_timestamp()}] [$name] $message');
    }
  }

  void info(String message) {
    if (kDebugMode) {
      print('[${_timestamp()}] [$name] ℹ️ $message');
    }
  }

  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('[${_timestamp()}] [$name] 🚧 $message');
      if (error != null) print('[${_timestamp()}] [$name] 🚧 Error: $error');
      if (stackTrace != null) {
        print('[${_timestamp()}] [$name] 🚧 StackTrace: $stackTrace');
      }
    }
  }

  void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('[${_timestamp()}] [$name] ❌ $message');
      if (error != null) print('[${_timestamp()}] [$name] ❌ Error: $error');
      if (stackTrace != null) {
        print('[${_timestamp()}] [$name] ❌ StackTrace: $stackTrace');
      }
    }
  }
}
