import 'dart:io';
import 'dart:isolate';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:win32/win32.dart';

final keyboardProc = Pointer.fromFunction<HOOKPROC>(lowLevelKeyboardProc, 0);
final sessionProc = Pointer.fromFunction<WNDPROC>(sessionNotificationProc, 0);
late int hookId;
late int sessionWindowHandle;
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
    int keyCode = keyStruct.vkCode;
    bool isPressed = !((keyStruct.flags & LLKHF_UP) != 0);
    bool isShiftDown = GetKeyState(VK_SHIFT) & 0x8000 != 0;

    sendPort?.send([keyCode, isPressed, isShiftDown]);

    if (!isPressed) {
      if (!isShiftDown) {
        sendPort?.send([keyCode, false, true]);
      } else {
        sendPort?.send([keyCode, false, false]);
      }
    }
  }
  return CallNextHookEx(hookId, nCode, wParam, lParam);
}

int sessionNotificationProc(int hwnd, int message, int wParam, int lParam) {
  if (message == WM_WTSSESSION_CHANGE) {
    switch (wParam) {
      case WTS_SESSION_LOCK:
        sendPort?.send(['session_lock', true]);
        break;
      case WTS_SESSION_UNLOCK:
        sendPort?.send(['session_unlock', true]);
        break;
    }
  }
  return DefWindowProc(hwnd, message, wParam, lParam);
}

void registerSessionNotification(int hwnd) {
  final result = WTSRegisterSessionNotification(hwnd, NOTIFY_FOR_THIS_SESSION);
  if (result == 0) {
    if (kDebugMode) {
      print('Failed to register session notification');
    }
    exit(1);
  }
}

bool unregisterSessionNotification(int hwnd) {
  return WTSUnRegisterSessionNotification(hwnd) != 0;
}

int createSessionNotificationWindow() {
  final wc = calloc<WNDCLASS>();
  try {
    wc.ref.lpfnWndProc = sessionProc;
    wc.ref.hInstance = GetModuleHandle(nullptr);
    wc.ref.lpszClassName = TEXT('SessionNotificationWindow');

    RegisterClass(wc);
    final hwnd = CreateWindowEx(
      0,
      TEXT('SessionNotificationWindow'),
      TEXT('Session Notification Window'),
      0,
      0,
      0,
      0,
      0,
      HWND_MESSAGE,
      NULL,
      GetModuleHandle(nullptr),
      nullptr,
    );

    if (hwnd == 0) {
      if (kDebugMode) {
        print('Failed to create notification window: ${GetLastError()}');
      }
      exit(1);
    }

    return hwnd;
  } finally {
    calloc.free(wc);
  }
}

void setHook(SendPort port) {
  sendPort = port;

  // Set up ke yboard hook
  hookId = SetWindowsHookEx(
      WH_KEYBOARD_LL, keyboardProc, GetModuleHandle(nullptr), 0);
  if (hookId == 0) {
    if (kDebugMode) {
      print('Failed to install hook.');
    }
    exit(1);
  }

  // Set up session notification window
  sessionWindowHandle = createSessionNotificationWindow();
  registerSessionNotification(sessionWindowHandle);

  final msg = calloc<MSG>();
  try {
    while (GetMessage(msg, NULL, 0, 0) != 0) {
      TranslateMessage(msg);
      DispatchMessage(msg);
      sendPort?.send(msg);
    }
  } finally {
    calloc.free(msg);
  }
}

void unhook() {
  UnhookWindowsHookEx(hookId);
  unregisterSessionNotification(sessionWindowHandle);
  DestroyWindow(sessionWindowHandle);
  UnregisterClass(TEXT('SessionNotificationWindow'), GetModuleHandle(nullptr));
}
