import 'dart:io';
import 'dart:isolate';

import 'keyboard_event_source_macos.dart';
import 'keyboard_event_source_windows.dart';

/// Source of platform-normalized keyboard messages.
///
/// Events use the existing OverKeys contract:
/// `[keyCode:int, isPressed:bool, isShiftDown:bool]`, plus session messages
/// such as `['session_lock', true]` and `['session_unlock', true]`.
abstract class KeyboardEventSource {
  Stream<dynamic> get events;

  Future<void> start();

  Future<void> stop();
}

class KeyboardEventSourceException implements Exception {
  KeyboardEventSourceException(this.message);

  final String message;

  @override
  String toString() => message;
}

KeyboardEventSource createPlatformKeyboardEventSource({
  ReceivePort Function() createReceivePort = ReceivePort.new,
}) {
  if (Platform.isMacOS) {
    return MacOSKeyboardEventSource();
  }
  if (Platform.isWindows) {
    return WindowsKeyboardEventSource(createReceivePort: createReceivePort);
  }

  throw UnsupportedError(
    'Platform ${Platform.operatingSystem} is not supported',
  );
}
