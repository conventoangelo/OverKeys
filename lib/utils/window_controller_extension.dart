import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

/// Extension methods for WindowController to simplify multi-window management
extension WindowControllerExtension on WindowController {
  /// Initialize the window controller with custom method handlers
  Future<void> initializeWindowMethods() async {
    return await setWindowMethodHandler((call) async {
      switch (call.method) {
        case 'window_close':
          return await windowManager.close();
        default:
          throw MissingPluginException(
              'Not implemented method: ${call.method}');
      }
    });
  }

  /// Close the window
  Future<void> close() {
    return invokeMethod('window_close');
  }
}
