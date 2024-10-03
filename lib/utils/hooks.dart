import 'dart:io';
import 'dart:isolate';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:win32/win32.dart';

final keyboardProc = Pointer.fromFunction<HOOKPROC>(lowLevelKeyboardProc, 0);
late int hookId;
SendPort? sendPort;

int lowLevelKeyboardProc(
  int nCode,
  int wParam,
  int lParam,
) {
  if (nCode >= 0 && wParam == WM_KEYDOWN || wParam == WM_KEYUP) {
    final keyStruct = Pointer<KBDLLHOOKSTRUCT>.fromAddress(lParam).ref;
    int key = keyStruct.vkCode;
    bool isKeyDown = (wParam == WM_KEYDOWN);

    sendPort?.send([key, isKeyDown]);
  }
  return CallNextHookEx(hookId, nCode, wParam, lParam);
}

void setHook(SendPort port) {
  sendPort = port;
  hookId = SetWindowsHookEx(WINDOWS_HOOK_ID.WH_KEYBOARD_LL, keyboardProc,
      GetModuleHandle(nullptr), 0);
  if (hookId == 0) {
    if (kDebugMode) {
      print('Failed to install hook.');
    }
    exit(1);
  }
  final msg = calloc<MSG>();
  while (GetMessage(msg, NULL, 0, 0) != 0) {
    TranslateMessage(msg);
    DispatchMessage(msg);
    sendPort?.send(msg);
  }
  calloc.free(msg);
}

void unhook() {
  UnhookWindowsHookEx(hookId);
}