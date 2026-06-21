import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overkeys/models/keyboard_layouts.dart';
import 'package:overkeys/providers/app_state_provider.dart';
import 'package:overkeys/providers/keyboard_provider.dart';
import 'package:overkeys/providers/preferences_provider.dart';
import 'package:overkeys/services/key_event_service.dart';
import 'package:overkeys/services/keyboard_event_source.dart';
import 'package:win32/win32.dart';

void main() {
  group('KeyEventService event source seam', () {
    testWidgets('updates key press state from event source tuples', (
      tester,
    ) async {
      final ref = await _pumpRefProbe(tester);
      final source = _FakeKeyboardEventSource();
      final service = _setupService(ref, source);

      source.emit([_keyCodeA, true, false]);

      expect(source.started, true);
      expect(ref.read(keyboardProvider).keyPressStates['A'], true);

      service.dispose();
    });

    testWidgets('drives auto-hide callbacks from event source tuples', (
      tester,
    ) async {
      final ref = await _pumpRefProbe(tester);
      final source = _FakeKeyboardEventSource();
      var fadeInCalls = 0;
      var resetTimerCalls = 0;
      final service = _setupService(
        ref,
        source,
        fadeIn: () => fadeInCalls++,
        resetAutoHideTimer: () => resetTimerCalls++,
      );

      ref.read(preferencesProvider.notifier).updateAutoHideEnabled(true);
      ref.read(appStateProvider.notifier).updateIsWindowVisible(false);

      source.emit([_keyCodeA, true, false]);

      expect(fadeInCalls, 1);
      expect(resetTimerCalls, 0);

      service.dispose();
    });

    testWidgets('switches held layers from event source tuples', (
      tester,
    ) async {
      final ref = await _pumpRefProbe(tester);
      final source = _FakeKeyboardEventSource();
      final service = _setupService(ref, source);
      const defaultLayout = KeyboardLayout(
        name: 'Default',
        keys: [
          ['A'],
        ],
      );
      const heldLayout = KeyboardLayout(
        name: 'Held',
        keys: [
          ['B'],
        ],
        trigger: 'A',
        type: 'held',
      );

      ref.read(keyboardProvider.notifier).updateLayout(defaultLayout);
      ref.read(preferencesProvider.notifier)
        ..updateUserLayers([defaultLayout, heldLayout])
        ..updateDefaultUserLayout(defaultLayout.name)
        ..updateUseUserLayout(true)
        ..updateAdvancedSettingsEnabled(true);

      source.emit([_keyCodeA, true, false]);
      expect(ref.read(keyboardProvider).layout, heldLayout);

      source.emit([_keyCodeA, false, false]);
      expect(ref.read(keyboardProvider).layout, defaultLayout);

      service.dispose();
    });

    testWidgets('clears key press state on session lock and unlock', (
      tester,
    ) async {
      final ref = await _pumpRefProbe(tester);
      final source = _FakeKeyboardEventSource();
      final service = _setupService(ref, source);

      source.emit([_keyCodeA, true, false]);
      expect(ref.read(keyboardProvider).keyPressStates['A'], true);

      source.emit(['session_lock', true]);
      expect(ref.read(keyboardProvider).keyPressStates, isEmpty);

      source.emit([_keyCodeA, true, false]);
      expect(ref.read(keyboardProvider).keyPressStates['A'], true);

      source.emit(['session_unlock', true]);
      expect(ref.read(keyboardProvider).keyPressStates, isEmpty);

      service.dispose();
    });
  });
}

int get _keyCodeA => Platform.isMacOS ? 0x00 : VK_A;

Future<WidgetRef> _pumpRefProbe(WidgetTester tester) async {
  late WidgetRef ref;
  await tester.pumpWidget(
    ProviderScope(child: _RefProbe(onBuild: (value) => ref = value)),
  );
  return ref;
}

KeyEventService _setupService(
  WidgetRef ref,
  _FakeKeyboardEventSource source, {
  void Function()? fadeIn,
  void Function()? resetAutoHideTimer,
  void Function()? cancelAutoHideTimer,
}) {
  final service = KeyEventService(eventSource: source);
  service.setupKeyListener(
    () => ReceivePort(),
    (message) => service.handleKeyEvent(
      message,
      ref,
      fadeIn ?? () {},
      resetAutoHideTimer ?? () {},
      cancelAutoHideTimer ?? () {},
    ),
  );
  return service;
}

class _RefProbe extends ConsumerWidget {
  const _RefProbe({required this.onBuild});

  final void Function(WidgetRef ref) onBuild;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    onBuild(ref);
    return const SizedBox.shrink();
  }
}

class _FakeKeyboardEventSource implements KeyboardEventSource {
  final _controller = StreamController<dynamic>.broadcast(sync: true);
  var started = false;
  var stopped = false;

  @override
  Stream<dynamic> get events => _controller.stream;

  @override
  Future<void> start() async {
    started = true;
  }

  @override
  Future<void> stop() async {
    stopped = true;
    await _controller.close();
  }

  void emit(dynamic message) {
    _controller.add(message);
  }
}
