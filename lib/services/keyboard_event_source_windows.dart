import 'dart:async';
import 'dart:isolate';

import 'package:overkeys/services/keyboard_event_source.dart';
import 'package:overkeys/utils/hooks.dart';

class WindowsKeyboardEventSource implements KeyboardEventSource {
  WindowsKeyboardEventSource({
    required ReceivePort Function() createReceivePort,
  }) : _createReceivePort = createReceivePort;

  final ReceivePort Function() _createReceivePort;
  final _controller = StreamController<dynamic>.broadcast();

  ReceivePort? _receivePort;
  StreamSubscription<dynamic>? _receivePortSubscription;
  Isolate? _hookIsolate;
  bool _started = false;

  @override
  Stream<dynamic> get events => _controller.stream;

  @override
  Future<void> start() async {
    if (_started) return;

    final receivePort = _createReceivePort();
    _receivePort = receivePort;
    _receivePortSubscription = receivePort.listen(
      _controller.add,
      onError: _controller.addError,
    );

    try {
      _hookIsolate = await Isolate.spawn(setHook, receivePort.sendPort);
      _started = true;
    } catch (error, stackTrace) {
      await _receivePortSubscription?.cancel();
      receivePort.close();
      _receivePort = null;
      _controller.addError(error, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    _hookIsolate?.kill(priority: Isolate.immediate);
    _hookIsolate = null;
    await _receivePortSubscription?.cancel();
    _receivePortSubscription = null;
    _receivePort?.close();
    _receivePort = null;
    _started = false;
  }
}
