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
  if (nCode >= 0 &&
      (wParam == WM_KEYDOWN ||
          wParam == WM_KEYUP ||
          wParam == WM_SYSKEYDOWN ||
          wParam == WM_SYSKEYUP)) {
    final keyStruct = Pointer<KBDLLHOOKSTRUCT>.fromAddress(lParam).ref;
    // if (kDebugMode) {
    //   print('KBDLLHOOKSTRUCT: {');
    //   print('  vkCode: ${keyStruct.vkCode},');
    //   print('  LLKHF_INJECTED: ${(keyStruct.flags & LLKHF_INJECTED) != 0},');
    //   print('  LLKHF_UP: ${(keyStruct.flags & LLKHF_UP) != 0},');
    //   print('}');
    // }
    int keyCode = keyStruct.vkCode;
    bool isPressed = !((keyStruct.flags & LLKHF_UP) != 0);
    bool isShiftDown = GetKeyState(VK_SHIFT) & 0x8000 != 0;

    // Pros: Would fix behavior when OK opened after Kanata
    // Cons: Would make app non-responsive when not using Kanata
    // if ((keyStruct.flags & LLKHF_INJECTED) != 0) {
    sendPort?.send([keyCode, isPressed, isShiftDown]);
    // }

    // For key release events, also send update for shifted variant
    // Due to Kanata releasing shift key before sending key release event
    if (!isPressed) {
      if (!isShiftDown) {
        // If shift is not down, send shifted variant
        sendPort?.send([keyCode, false, true]);
      } else {
        // If shift is down, send non-shifted variant
        sendPort?.send([keyCode, false, false]);
      }
    }
  }
  return CallNextHookEx(hookId, nCode, wParam, lParam);
}

void setHook(SendPort port) {
  sendPort = port;
  hookId = SetWindowsHookEx(
      WH_KEYBOARD_LL, keyboardProc, GetModuleHandle(nullptr), 0);
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
