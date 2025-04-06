import 'dart:io';
import 'dart:isolate';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:win32/win32.dart';

const int xButton1 = 0x0001;

final keyboardProc = Pointer.fromFunction<HOOKPROC>(lowLevelKeyboardProc, 0);
final mouseProc = Pointer.fromFunction<HOOKPROC>(lowLevelMouseProc, 0);
late int keyboardHookId;
late int mouseHookId;
SendPort? sendPort;

int lowLevelMouseProc(
  int nCode,
  int wParam,
  int lParam,
) {
  if (nCode >= 0) {
    final mouseStruct = Pointer<MSLLHOOKSTRUCT>.fromAddress(lParam).ref;
    // Only handle button events, ignore mouse movement and wheel events.
    if (wParam == WM_MOUSEMOVE || wParam == WM_MOUSEWHEEL) {
      return CallNextHookEx(mouseHookId, nCode, wParam, lParam);
    }

    final Map<int, List<dynamic>> buttonMap = {
      WM_LBUTTONDOWN: [0, true],
      WM_LBUTTONUP: [0, false],
      WM_RBUTTONDOWN: [1, true],
      WM_RBUTTONUP: [1, false],
      WM_MBUTTONDOWN: [2, true],
      WM_MBUTTONUP: [2, false],
    };

    int? buttonCode;
    bool? isPressed;

    if (buttonMap.containsKey(wParam)) {
      buttonCode = buttonMap[wParam]![0];
      isPressed = buttonMap[wParam]![1];
    } else if (wParam == WM_XBUTTONDOWN || wParam == WM_XBUTTONUP) {
      buttonCode = HIWORD(mouseStruct.mouseData) == xButton1 ? 3 : 4;
      isPressed = wParam == WM_XBUTTONDOWN;
    }

    if (buttonCode != null && isPressed != null) {
      sendPort?.send(['mouse', buttonCode, isPressed]);
    }
  }

  return CallNextHookEx(mouseHookId, nCode, wParam, lParam);
}

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
    sendPort?.send(['keyboard', keyCode, isPressed, isShiftDown]);
    // }

    // For key release events, also send update for shifted variant
    // Due to Kanata releasing shift key before sending key release event
    if (!isPressed) {
      if (!isShiftDown) {
        // If shift is not down, send shifted variant
        sendPort?.send(['keyboard', keyCode, false, true]);
      } else {
        // If shift is down, send non-shifted variant
        sendPort?.send(['keyboard', keyCode, false, false]);
      }
    }
  }
  return CallNextHookEx(keyboardHookId, nCode, wParam, lParam);
}

void setHook(SendPort port) {
  sendPort = port;

  // Set up keyboard hook
  keyboardHookId = SetWindowsHookEx(
      WH_KEYBOARD_LL, keyboardProc, GetModuleHandle(nullptr), 0);
  if (keyboardHookId == 0) {
    if (kDebugMode) {
      print('Failed to install keyboard hook.');
    }
    exit(1);
  }

  // Set up mouse hook
  mouseHookId =
      SetWindowsHookEx(WH_MOUSE_LL, mouseProc, GetModuleHandle(nullptr), 0);
  if (mouseHookId == 0) {
    if (kDebugMode) {
      print('Failed to install mouse hook.');
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
  UnhookWindowsHookEx(keyboardHookId);
  UnhookWindowsHookEx(mouseHookId);
}
