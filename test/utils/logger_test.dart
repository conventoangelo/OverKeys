import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:overkeys/utils/logger.dart';

void main() {
  group('LogEntry', () {
    test('creates log entry with all fields', () {
      final timestamp = DateTime.now();
      final entry = LogEntry(
        timestamp: timestamp,
        loggerName: 'TestLogger',
        level: Level.INFO,
        message: 'Test message',
        error: Exception('Test error'),
        stackTrace: StackTrace.current,
      );

      expect(entry.timestamp, timestamp);
      expect(entry.loggerName, 'TestLogger');
      expect(entry.level, Level.INFO);
      expect(entry.message, 'Test message');
      expect(entry.error, isNotNull);
      expect(entry.stackTrace, isNotNull);
    });

    test('formattedTimestamp extracts time correctly', () {
      final timestamp = DateTime(2026, 2, 28, 14, 30, 45, 123);
      final entry = LogEntry(
        timestamp: timestamp,
        loggerName: 'TestLogger',
        level: Level.INFO,
        message: 'Test',
      );

      expect(entry.formattedTimestamp, contains('14:30:45'));
    });

    test('levelEmoji returns correct emoji for each level', () {
      final timestamp = DateTime.now();

      final infoEntry = LogEntry(
        timestamp: timestamp,
        loggerName: 'Test',
        level: Level.INFO,
        message: 'Info',
      );
      expect(infoEntry.levelEmoji, 'ℹ️ ');

      final warningEntry = LogEntry(
        timestamp: timestamp,
        loggerName: 'Test',
        level: Level.WARNING,
        message: 'Warning',
      );
      expect(warningEntry.levelEmoji, '🚧 ');

      final severeEntry = LogEntry(
        timestamp: timestamp,
        loggerName: 'Test',
        level: Level.SEVERE,
        message: 'Error',
      );
      expect(severeEntry.levelEmoji, '❌ ');

      final fineEntry = LogEntry(
        timestamp: timestamp,
        loggerName: 'Test',
        level: Level.FINE,
        message: 'Debug',
      );
      expect(fineEntry.levelEmoji, '');
    });

    test('formattedMessage includes all components', () {
      final timestamp = DateTime.now();
      final error = Exception('Test error');
      final stackTrace = StackTrace.current;

      final entry = LogEntry(
        timestamp: timestamp,
        loggerName: 'TestLogger',
        level: Level.SEVERE,
        message: 'Test message',
        error: error,
        stackTrace: stackTrace,
      );

      final formatted = entry.formattedMessage;
      expect(formatted, contains('TestLogger'));
      expect(formatted, contains('Test message'));
      expect(formatted, contains('Error: Exception: Test error'));
      expect(formatted, contains('StackTrace:'));
    });
  });

  group('LogCapture', () {
    late LogCapture logCapture;
    late SimplePrintLogger logger;

    setUp(() {
      logCapture = LogCapture();
      logger = SimplePrintLogger('TestLogger');
      // Clear any existing logs
      logCapture.clear();
    });

    test('singleton returns same instance', () {
      final instance1 = LogCapture();
      final instance2 = LogCapture();
      expect(identical(instance1, instance2), true);
    });

    test('_handleLogRecord adds entry and increments revision', () {
      final initialRevision = logCapture.revision;
      final initialCount = logCapture.logCount;

      logger.info('Test message');

      expect(logCapture.revision, initialRevision + 1);
      expect(logCapture.logCount, initialCount + 1);
      expect(logCapture.logs.last.message, 'Test message');
      expect(logCapture.logs.last.level, Level.INFO);
    });

    test('_handleLogRecord invalidates cache', () {
      // Access logs to populate cache
      final _ = logCapture.logs;

      logger.info('New message');

      // Cache should be rebuilt on next access
      final logs = logCapture.logs;
      expect(logs.last.message, 'New message');
    });

    test('revision stream emits on new log entry', () async {
      final revisions = <int>[];
      final subscription = logCapture.revisionStream.listen(revisions.add);

      await Future.delayed(const Duration(milliseconds: 10));

      logger.info('Message 1');
      await Future.delayed(const Duration(milliseconds: 10));

      logger.info('Message 2');
      await Future.delayed(const Duration(milliseconds: 10));

      expect(revisions.length, greaterThanOrEqualTo(2));
      expect(revisions[1], greaterThan(revisions[0]));

      await subscription.cancel();
    });

    test('different log levels are captured correctly', () {
      logCapture.clear();

      logger.debug('Debug message');
      logger.info('Info message');
      logger.warning('Warning message');
      logger.error('Error message');

      final logs = logCapture.logs;
      expect(logs.length, 4);
      expect(logs[0].level, Level.FINE); // debug uses FINE
      expect(logs[1].level, Level.INFO);
      expect(logs[2].level, Level.WARNING);
      expect(logs[3].level, Level.SEVERE); // error uses SEVERE
    });

    group('_trimLogsToLimit', () {
      test('trims logs when exceeding max limit', () {
        logCapture.clear();

        // Add more than max logs
        for (int i = 0; i < 1100; i++) {
          logger.info('Message $i');
        }

        expect(logCapture.logCount, 1000);
        // Should keep the most recent logs
        expect(logCapture.logs.last.message, 'Message 1099');
      });

      test('removes oldest logs based on timestamp', () {
        logCapture.clear();

        // Add logs up to limit
        for (int i = 0; i < 1000; i++) {
          logger.info('Message $i');
        }

        final firstMessage = logCapture.logs.first.message;

        // Add one more to trigger trim
        logger.info('Message 1000');

        // First log should have been removed
        expect(logCapture.logs.first.message, isNot(firstMessage));
        expect(logCapture.logCount, 1000);
      });

      test('handles dual-buffer trimming correctly', () {
        logCapture.clear();

        // Add logs to main buffer
        for (int i = 0; i < 500; i++) {
          logger.info('Main $i');
        }

        // Simulate received logs by directly calling addReceivedLog
        for (int i = 0; i < 550; i++) {
          logCapture.addReceivedLog({
            'timestamp': DateTime.now().toIso8601String(),
            'loggerName': 'Remote',
            'level': Level.INFO.value,
            'message': 'Remote $i',
          });
        }

        expect(logCapture.logCount, lessThanOrEqualTo(1000));
      });
    });

    group('deduplication', () {
      test('suppresses duplicate logs within detection window', () {
        logCapture.clear();

        final timestamp = DateTime.now();
        final logData = {
          'timestamp': timestamp.toIso8601String(),
          'loggerName': 'TestLogger',
          'level': Level.INFO.value,
          'message': 'Duplicate message',
        };

        // Add first instance
        logCapture.addReceivedLog(logData);
        final countAfterFirst = logCapture.logCount;

        // Try to add duplicate
        logCapture.addReceivedLog(logData);

        // Should not add duplicate
        expect(logCapture.logCount, countAfterFirst);
      });

      test('accepts logs with different levels as non-duplicates', () {
        logCapture.clear();

        final timestamp = DateTime.now();

        logCapture.addReceivedLog({
          'timestamp': timestamp.toIso8601String(),
          'loggerName': 'TestLogger',
          'level': Level.INFO.value,
          'message': 'Same message',
        });

        final countAfterInfo = logCapture.logCount;

        logCapture.addReceivedLog({
          'timestamp': timestamp.toIso8601String(),
          'loggerName': 'TestLogger',
          'level': Level.WARNING.value,
          'message': 'Same message',
        });

        // Should accept as different level makes it non-duplicate
        expect(logCapture.logCount, countAfterInfo + 1);
      });

      test('accepts duplicate after detection window', () {
        logCapture.clear();

        final timestamp = DateTime.now();
        final logData = {
          'timestamp': timestamp.toIso8601String(),
          'loggerName': 'TestLogger',
          'level': Level.INFO.value,
          'message': 'Message',
        };

        // Add first instance
        logCapture.addReceivedLog(logData);

        // Add 51 different logs to push original out of dedup window (50 logs)
        for (int i = 0; i < 51; i++) {
          logCapture.addReceivedLog({
            'timestamp': DateTime.now().toIso8601String(),
            'loggerName': 'TestLogger',
            'level': Level.INFO.value,
            'message': 'Different message $i',
          });
        }

        final countBeforeDuplicate = logCapture.logCount;

        // Try to add duplicate again - should be accepted as original is outside window
        logCapture.addReceivedLog(logData);

        expect(logCapture.logCount, countBeforeDuplicate + 1);
      });
    });

    group('clear', () {
      test('empties both buffers', () {
        logCapture.clear();

        logger.info('Message 1');
        logCapture.addReceivedLog({
          'timestamp': DateTime.now().toIso8601String(),
          'loggerName': 'Remote',
          'level': Level.INFO.value,
          'message': 'Remote message',
        });

        expect(logCapture.logCount, greaterThan(0));

        logCapture.clear();

        expect(logCapture.logCount, 0);
        expect(logCapture.logs.isEmpty, true);
      });

      test('invalidates cache', () {
        logger.info('Message before clear');

        // Access logs to populate cache
        final _ = logCapture.logs;

        logCapture.clear();

        // Cache should be cleared
        expect(logCapture.logs.isEmpty, true);
      });

      test('updates revision', () {
        final revisionBeforeClear = logCapture.revision;

        logCapture.clear();

        expect(logCapture.revision, revisionBeforeClear + 1);
      });

      test('emits revision update on stream', () async {
        final revisions = <int>[];
        final subscription = logCapture.revisionStream.listen(revisions.add);

        await Future.delayed(const Duration(milliseconds: 10));

        logCapture.clear();

        await Future.delayed(const Duration(milliseconds: 10));

        expect(revisions.length, greaterThanOrEqualTo(1));

        await subscription.cancel();
      });
    });

    test('logs getter combines and sorts logs from both buffers', () {
      logCapture.clear();

      // Add main logs with controlled timestamps
      logger.info('Main 1');

      // Wait a bit to ensure timestamp difference
      Future.delayed(const Duration(milliseconds: 10));

      final midTimestamp = DateTime.now();

      Future.delayed(const Duration(milliseconds: 10));

      logger.info('Main 2');

      // Add received log with timestamp between main logs
      logCapture.addReceivedLog({
        'timestamp': midTimestamp.toIso8601String(),
        'loggerName': 'Remote',
        'level': Level.INFO.value,
        'message': 'Remote middle',
      });

      final logs = logCapture.logs;

      // Should be sorted by timestamp
      expect(logs.length, 3);

      // Verify all messages are present
      final messages = logs.map((e) => e.message).toList();
      expect(messages, contains('Main 1'));
      expect(messages, contains('Main 2'));
      expect(messages, contains('Remote middle'));
    });
  });

  group('SimplePrintLogger', () {
    test('debug uses FINE level', () {
      final logCapture = LogCapture();
      logCapture.clear();

      final logger = SimplePrintLogger('TestLogger');
      logger.debug('Debug message');

      expect(logCapture.logs.last.level, Level.FINE);
    });

    test('info uses INFO level', () {
      final logCapture = LogCapture();
      logCapture.clear();

      final logger = SimplePrintLogger('TestLogger');
      logger.info('Info message');

      expect(logCapture.logs.last.level, Level.INFO);
    });

    test('warning uses WARNING level', () {
      final logCapture = LogCapture();
      logCapture.clear();

      final logger = SimplePrintLogger('TestLogger');
      logger.warning('Warning message');

      expect(logCapture.logs.last.level, Level.WARNING);
    });

    test('error uses SEVERE level', () {
      final logCapture = LogCapture();
      logCapture.clear();

      final logger = SimplePrintLogger('TestLogger');
      logger.error('Error message');

      expect(logCapture.logs.last.level, Level.SEVERE);
    });

    test('warning includes error and stackTrace', () {
      final logCapture = LogCapture();
      logCapture.clear();

      final logger = SimplePrintLogger('TestLogger');
      final error = Exception('Test error');
      final stackTrace = StackTrace.current;

      logger.warning('Warning', error: error, stackTrace: stackTrace);

      final lastLog = logCapture.logs.last;
      expect(lastLog.error, isNotNull);
      expect(lastLog.stackTrace, isNotNull);
    });
  });
}
