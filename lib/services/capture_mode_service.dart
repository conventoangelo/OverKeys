import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import '../utils/logger.dart';

/// Service for the "Only visible in recordings" mode.
///
/// When enabled, the main OverKeys window is "cloaked" via the Desktop Window
/// Manager (DWMWA_CLOAK). A cloaked window is not shown on the physical screen
/// but is still composed by DWM, so capture tools that record the window
/// itself (e.g. OBS "Window Capture" with the Windows 10/11 capture method,
/// clipping software in window mode) still receive its content.
///
/// Note: Display/monitor capture only records what is on screen, so it will
/// not contain the cloaked window. Add OverKeys as its own window source.
class CaptureModeService {
  final _log = SimplePrintLogger('CaptureModeService');

  static const int _dwmwaCloak = 13;
  static const String _windowClass = 'FLUTTER_RUNNER_WIN32_WINDOW';
  static const String _windowTitle = 'OverKeys';

  /// Cloaks (true) or uncloaks (false) the main OverKeys window.
  /// Returns true if the call succeeded.
  bool apply(bool captureOnly) {
    if (!Platform.isWindows) return false;

    final className = _windowClass.toNativeUtf16();
    final title = _windowTitle.toNativeUtf16();
    final value = calloc<Int32>();
    try {
      final user32 = DynamicLibrary.open('user32.dll');
      final dwmapi = DynamicLibrary.open('dwmapi.dll');

      final findWindow = user32.lookupFunction<
          IntPtr Function(Pointer<Utf16>, Pointer<Utf16>),
          int Function(Pointer<Utf16>, Pointer<Utf16>)>('FindWindowW');
      final dwmSetWindowAttribute = dwmapi.lookupFunction<
          Int32 Function(IntPtr, Uint32, Pointer<Void>, Uint32),
          int Function(
              int, int, Pointer<Void>, int)>('DwmSetWindowAttribute');

      final hwnd = findWindow(className, title);
      if (hwnd == 0) {
        _log.warning('Main window not found, capture-only mode not applied');
        return false;
      }

      value.value = captureOnly ? 1 : 0;
      final hr = dwmSetWindowAttribute(
          hwnd, _dwmwaCloak, value.cast<Void>(), sizeOf<Int32>());
      if (hr != 0) {
        _log.warning('DwmSetWindowAttribute(DWMWA_CLOAK) failed: HRESULT $hr');
        return false;
      }
      return true;
    } catch (e) {
      _log.error('Failed to apply capture-only mode', error: e);
      return false;
    } finally {
      calloc.free(className);
      calloc.free(title);
      calloc.free(value);
    }
  }
}
