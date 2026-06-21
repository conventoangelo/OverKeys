import 'dart:async';

import 'package:flutter/services.dart';
import 'package:overkeys/services/keyboard_event_source.dart';

class MacOSKeyboardEventSource implements KeyboardEventSource {
  static const _eventChannel = EventChannel('overkeys/keyboard_events');
  static const _methodChannel = MethodChannel('overkeys/keyboard_monitor');

  final _controller = StreamController<dynamic>.broadcast();
  StreamSubscription<dynamic>? _nativeSubscription;
  bool _started = false;

  @override
  Stream<dynamic> get events => _controller.stream;

  @override
  Future<void> start() async {
    if (_started) return;

    final permissions = await _readPermissionStatus();
    if (!permissions.hasAllPermissions) {
      await _methodChannel.invokeMethod<void>('requestPermissions');
      final error = KeyboardEventSourceException(permissions.message);
      _controller.addError(error);
      throw error;
    }

    _nativeSubscription = _eventChannel.receiveBroadcastStream().listen(
          _controller.add,
          onError: _controller.addError,
        );
    _started = true;
  }

  @override
  Future<void> stop() async {
    await _nativeSubscription?.cancel();
    _nativeSubscription = null;
    await _methodChannel.invokeMethod<void>('stopMonitoring');
    _started = false;
  }

  Future<_MacOSKeyboardPermissionStatus> _readPermissionStatus() async {
    final raw = await _methodChannel.invokeMapMethod<String, Object?>(
      'checkPermissions',
    );
    final status = raw ?? const <String, Object?>{};
    final hasAccessibility = status['accessibility'] == true;
    final hasInputMonitoring = status['inputMonitoring'] == true;

    return _MacOSKeyboardPermissionStatus(
      hasAccessibility: hasAccessibility,
      hasInputMonitoring: hasInputMonitoring,
    );
  }
}

class _MacOSKeyboardPermissionStatus {
  const _MacOSKeyboardPermissionStatus({
    required this.hasAccessibility,
    required this.hasInputMonitoring,
  });

  final bool hasAccessibility;
  final bool hasInputMonitoring;

  bool get hasAllPermissions => hasAccessibility && hasInputMonitoring;

  String get message {
    final missing = <String>[
      if (!hasAccessibility) 'Accessibility',
      if (!hasInputMonitoring) 'Input Monitoring',
    ].join(' and ');

    return 'OverKeys needs $missing permission to monitor global keyboard '
        'events. Grant permission in System Settings > Privacy & Security, '
        'then restart OverKeys.';
  }
}
