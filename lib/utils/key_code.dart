import 'dart:io';

import 'key_code_macos.dart' as macos;
import 'key_code_windows.dart' as windows;

export 'key_code_macos.dart'
    show macOSKeyCodeMap, macOSKeyCodeShiftMap, getMacOSKeyFromKeyCodeShift;
export 'key_code_windows.dart'
    show
        activeKeyCodeShiftMap,
        defaultKeyCodeMap,
        defaultKeyCodeShiftMap,
        getWindowsKeyFromKeyCodeShift,
        loadCustomKeys;

/// Converts the current platform's keyboard event key code into the display
/// key name consumed by the existing overlay and layer-switching logic.
String getKeyFromKeyCodeShift(int keyCode, bool isShiftDown) {
  if (Platform.isMacOS) {
    return macos.getMacOSKeyFromKeyCodeShift(keyCode, isShiftDown);
  }

  return windows.getWindowsKeyFromKeyCodeShift(keyCode, isShiftDown);
}
