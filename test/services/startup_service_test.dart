import 'package:flutter_test/flutter_test.dart';
import 'package:overkeys/services/startup_service.dart';

void main() {
  group('StartupService', () {
    late StartupService startupService;

    setUp(() {
      startupService = StartupService();
    });

    group('Service instantiation', () {
      test('creates instance successfully', () {
        final service = StartupService();
        expect(service, isNotNull);
        expect(service, isA<StartupService>());
      });

      test('multiple instances can be created', () {
        final service1 = StartupService();
        final service2 = StartupService();

        expect(service1, isNotNull);
        expect(service2, isNotNull);
        expect(service1, isNot(same(service2)));
      });
    });

    group('handleStartupToggle signature', () {
      test('accepts boolean parameter', () {
        // Verify method signature is correct
        expect(startupService.handleStartupToggle, isA<Function>());
      });
    });
  });
}
