import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';

/// Log entry representing a single log record
class LogEntry {
  final DateTime timestamp;
  final String loggerName;
  final Level level;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  LogEntry({
    required this.timestamp,
    required this.loggerName,
    required this.level,
    required this.message,
    this.error,
    this.stackTrace,
  });

  String get formattedTimestamp {
    final str = timestamp.toString();
    if (str.length >= 23) {
      return str.substring(11, 23);
    }
    return str.length > 11 ? str.substring(11) : str;
  }

  String get levelEmoji {
    if (level == Level.INFO) return 'ℹ️ ';
    if (level == Level.WARNING) return '🚧 ';
    if (level == Level.SEVERE) return '❌ ';
    return '';
  }

  String get formattedMessage {
    StringBuffer buffer = StringBuffer();
    buffer.write('[$formattedTimestamp] [$loggerName] $levelEmoji$message');

    if (error != null) {
      buffer.write('\n[$formattedTimestamp] [$loggerName] $levelEmoji');
      buffer.write('Error: $error');
    }

    if (stackTrace != null) {
      buffer.write('\n[$formattedTimestamp] [$loggerName] $levelEmoji');
      buffer.write('StackTrace: $stackTrace');
    }

    return buffer.toString();
  }
}

/// Singleton class to capture and store logs
class LogCapture {
  static final LogCapture _instance = LogCapture._internal();
  factory LogCapture() => _instance;

  final List<LogEntry> _logs = [];
  final List<LogEntry> _receivedLogs =
      []; // For logs received from other windows
  static const int _maxLogs =
      1000; // Keep last 1000 combined logs across both buffers

  // Cache for combined logs
  List<LogEntry>? _cachedCombinedLogs;
  bool _isCacheValid = false;

  LogCapture._internal() {
    Logger.root.level = kDebugMode ? Level.ALL : Level.INFO;
    Logger.root.onRecord.listen(_handleLogRecord);
  }

  void _trimLogsToLimit() {
    while (_logs.length + _receivedLogs.length > _maxLogs) {
      // Remove the oldest entry from either buffer
      if (_logs.isEmpty) {
        _receivedLogs.removeAt(0);
      } else if (_receivedLogs.isEmpty) {
        _logs.removeAt(0);
      } else {
        // Both have entries, remove from the one with the older timestamp
        if (_logs.first.timestamp.isBefore(_receivedLogs.first.timestamp)) {
          _logs.removeAt(0);
        } else {
          _receivedLogs.removeAt(0);
        }
      }
    }
  }

  void _handleLogRecord(LogRecord record) {
    final entry = LogEntry(
      timestamp: record.time,
      loggerName: record.loggerName,
      level: record.level,
      message: record.message,
      error: record.error,
      stackTrace: record.stackTrace,
    );

    _logs.add(entry);
    _trimLogsToLimit();
    _isCacheValid = false;

    // Print to console
    if (kDebugMode) {
      print(entry.formattedMessage);
    }

    // Broadcast to other windows for cross-isolate log viewing
    _broadcastLog(entry);
  }

  void _broadcastLog(LogEntry entry) async {
    try {
      final logMap = {
        'timestamp': entry.timestamp.toIso8601String(),
        'loggerName': entry.loggerName,
        'level': entry.level.value,
        'message': entry.message,
        'error': entry.error?.toString(),
        'stackTrace': entry.stackTrace?.toString(),
      };

      final controllers = await WindowController.getAll();
      for (final controller in controllers) {
        controller.invokeMethod('receiveLog', logMap).catchError((_) => null);
      }
    } catch (_) {
      // Silently ignore broadcast errors
    }
  }

  void addReceivedLog(Map<String, dynamic> logData) {
    try {
      // Validate required fields
      final timestamp = logData['timestamp'] as String?;
      final loggerName = logData['loggerName'] as String?;
      final levelValue = logData['level'] as int?;
      final message = logData['message'] as String?;

      if (timestamp == null ||
          loggerName == null ||
          levelValue == null ||
          message == null) {
        return;
      }

      final parsedTimestamp = DateTime.parse(timestamp);
      final level = Level.LEVELS.firstWhere(
        (l) => l.value == levelValue,
        orElse: () => Level.INFO,
      );

      // Check if this log already exists in _logs or _receivedLogs to avoid duplicates
      // This happens when a window broadcasts to all windows including itself
      // or when the same remote log is received multiple times
      final isDuplicate = _logs.any((log) =>
              log.timestamp == parsedTimestamp &&
              log.loggerName == loggerName &&
              log.level == level &&
              log.message == message) ||
          _receivedLogs.any((log) =>
              log.timestamp == parsedTimestamp &&
              log.loggerName == loggerName &&
              log.level == level &&
              log.message == message);

      if (isDuplicate) {
        return; // Skip adding duplicate from broadcast
      }

      final entry = LogEntry(
        timestamp: parsedTimestamp,
        loggerName: loggerName,
        level: level,
        message: message,
        error: logData['error'],
        stackTrace:
            logData['stackTrace'] != null && logData['stackTrace'] != 'null'
                ? StackTrace.fromString(logData['stackTrace'])
                : null,
      );

      _receivedLogs.add(entry);
      _trimLogsToLimit();
      _isCacheValid = false;
    } catch (_) {
      // Silently ignore malformed log data
    }
  }

  List<LogEntry> get logs {
    if (_isCacheValid && _cachedCombinedLogs != null) {
      return _cachedCombinedLogs!;
    }

    // Combine and sort logs from both sources
    final combined = [..._logs, ..._receivedLogs];
    combined.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    _cachedCombinedLogs = List.unmodifiable(combined);
    _isCacheValid = true;
    return _cachedCombinedLogs!;
  }

  int get logCount => _logs.length + _receivedLogs.length;

  void clear() {
    _logs.clear();
    _receivedLogs.clear();
    _isCacheValid = false;
  }
}

// Initialize LogCapture immediately when this file is loaded
// This ensures the listener is set up before any loggers are created
// ignore: unused_element
final _logCaptureInitializer = LogCapture();

/// Simple wrapper around standard Dart Logger for backwards compatibility
class SimplePrintLogger {
  final Logger _logger;

  SimplePrintLogger(String name) : _logger = Logger(name);

  void debug(String message) {
    _logger.fine(message);
  }

  void info(String message) {
    _logger.info(message);
  }

  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.warning(message, error, stackTrace);
  }

  void error(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.severe(message, error, stackTrace);
  }
}
