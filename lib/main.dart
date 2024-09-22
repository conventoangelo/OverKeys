import 'dart:async';
import 'dart:io';
import 'dart:ffi' hide Size;
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:win32/win32.dart';
import 'package:ffi/ffi.dart';

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
    // if (kDebugMode) {
    //   print('Key Pressed: $key');
    //   print('Key State: $isKeyDown');
    // }
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    center: true,
    size: Size(700, 260),
    backgroundColor: Colors.transparent,
    skipTaskbar: true,
    title: "OverKeys",
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setAsFrameless();
    await windowManager.setIgnoreMouseEvents(false);
    await windowManager.show();
  });

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with TrayListener {
  bool _ignoreMouseEvents = false;
  bool _isWindowVisible = true;
  bool _autoHideEnabled = false;
  Timer? _autoHideTimer;
  double _opacity = 0.6;
  final Map<int, bool> _keyPressStates = {};

  @override
  void initState() {
    super.initState();
    trayManager.addListener(this);
    _setupTray();
    _setupKeyListener();
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    unhook();
    _autoHideTimer?.cancel();
    super.dispose();
  }

  void _setupKeyListener() {
    ReceivePort receivePort = ReceivePort();
    if (kDebugMode) {
      print('_setupKeyListener called');
    }
    Isolate.spawn(setHook, receivePort.sendPort).then((_) {
      if (kDebugMode) {
        print('Isolate spawned successfully');
      }
    }).catchError((error) {
      if (kDebugMode) {
        print('Error spawning Isolate: $error');
      }
    });

    receivePort.listen((message) {
      if (kDebugMode) {
        print('Received message: $message');
      }
      setState(() {
        if (message[0] is int) {
          int key = message[0];
          bool isPressed = message[1];

          _keyPressStates[key] = isPressed;
          _resetAutoHideTimer();
          if (_autoHideEnabled && !_isWindowVisible) {
            _fadeIn();
          }
        }
        // if (kDebugMode) {
        //   print('Key press state updated: $_keyPressStates');
        // }
      });
    });
  }

  void _resetAutoHideTimer() {
    _autoHideTimer?.cancel();
    if (_autoHideEnabled) {
      _autoHideTimer = Timer(const Duration(seconds: 2), () {
        if (_autoHideEnabled && _isWindowVisible) {
          _fadeOut();
        }
      });
    }
  }

  void _fadeOut() {
    setState(() {
      _opacity = 0.0;
    });
    Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _isWindowVisible = false;
      });
      windowManager.hide();
    });
  }

  void _fadeIn() {
    windowManager.show().then((_) {
      setState(() {
        _isWindowVisible = true;
        _opacity = 0.6;
      });
    });
  }

  Future<void> _setupTray() async {
    String iconPath = Platform.isWindows
        ? 'assets/images/tray_icon.ico'
        : 'assets/images/tray_icon.png';

    await trayManager.setIcon(iconPath);
    trayManager.setToolTip('OverKeys');
    trayManager.setContextMenu(Menu(items: [
      MenuItem.checkbox(
        key: 'toggle_mouse_events',
        label: 'Move',
        checked: true,
      ),
      MenuItem.separator(),
      MenuItem.checkbox(
        key: 'toggle_auto_hide',
        label: 'Auto Hide',
        checked: false,
      ),
      MenuItem.separator(),
      MenuItem(
        key: 'exit',
        label: 'Exit',
      ),
    ]));
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'toggle_auto_hide':
        setState(() {
          if (kDebugMode) {
            print('Auto Hide Toggled');
          }
          _autoHideEnabled = !_autoHideEnabled;
          menuItem.checked = _autoHideEnabled;
          if (_autoHideEnabled) {
            _resetAutoHideTimer();
          } else {
            _autoHideTimer?.cancel();
            if (!_isWindowVisible) {
              _fadeIn();
            }
          }
        });
      case 'toggle_mouse_events':
        //TODO: Window does not appear when toggled off during hidden
        setState(() {
          if (kDebugMode) {
            print('Mouse Events Toggled');
          }
          _ignoreMouseEvents = !_ignoreMouseEvents;
          menuItem.checked = !_ignoreMouseEvents;
          windowManager.setIgnoreMouseEvents(_ignoreMouseEvents);
        });
      case 'exit':
        windowManager.close();
    }
  }

  @override
  void onTrayIconMouseDown() {
    if (_isWindowVisible) {
      _fadeOut();
    } else {
      _fadeIn();
      _resetAutoHideTimer();
    }
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OverKeys',
      theme: ThemeData(fontFamily: 'GeistMono'),
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 200),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanStart: (details) {
              windowManager.startDragging();
            },
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: KeyboardScreen(keyPressStates: _keyPressStates),
              ),
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class KeyboardScreen extends StatelessWidget {
  final Map<int, bool> keyPressStates;

  const KeyboardScreen({super.key, required this.keyPressStates});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildRow(0,
                ["W", "L", "Y", "P", "K", "Z", "X", "O", "U", ";", "[", "]"]),
            buildRow(
                1, ["C", "R", "S", "T", "B", "F", "N", "E", "I", "A", "'"]),
            buildRow(2, ["J", "V", "D", "G", "Q", "M", "H", "/", ",", "."]),
            buildRow(3, [" "]),
          ],
        ),
      ),
    ]);
  }

  Widget buildRow(int rowIndex, List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.asMap().entries.map((entry) {
        int keyIndex = entry.key;
        String key = entry.value;
        return buildKeys(rowIndex, key, keyIndex);
      }).toList(),
    );
  }

  int getVirtualKeyCode(String key) {
    switch (key) {
      case 'A':
        return VIRTUAL_KEY.VK_A;
      case 'B':
        return VIRTUAL_KEY.VK_B;
      case 'C':
        return VIRTUAL_KEY.VK_C;
      case 'D':
        return VIRTUAL_KEY.VK_D;
      case 'E':
        return VIRTUAL_KEY.VK_E;
      case 'F':
        return VIRTUAL_KEY.VK_F;
      case 'G':
        return VIRTUAL_KEY.VK_G;
      case 'H':
        return VIRTUAL_KEY.VK_H;
      case 'I':
        return VIRTUAL_KEY.VK_I;
      case 'J':
        return VIRTUAL_KEY.VK_J;
      case 'K':
        return VIRTUAL_KEY.VK_K;
      case 'L':
        return VIRTUAL_KEY.VK_L;
      case 'M':
        return VIRTUAL_KEY.VK_M;
      case 'N':
        return VIRTUAL_KEY.VK_N;
      case 'O':
        return VIRTUAL_KEY.VK_O;
      case 'P':
        return VIRTUAL_KEY.VK_P;
      case 'Q':
        return VIRTUAL_KEY.VK_Q;
      case 'R':
        return VIRTUAL_KEY.VK_R;
      case 'S':
        return VIRTUAL_KEY.VK_S;
      case 'T':
        return VIRTUAL_KEY.VK_T;
      case 'U':
        return VIRTUAL_KEY.VK_U;
      case 'V':
        return VIRTUAL_KEY.VK_V;
      case 'W':
        return VIRTUAL_KEY.VK_W;
      case 'X':
        return VIRTUAL_KEY.VK_X;
      case 'Y':
        return VIRTUAL_KEY.VK_Y;
      case 'Z':
        return VIRTUAL_KEY.VK_Z;
      case ' ':
        return VIRTUAL_KEY.VK_SPACE; // Space bar
      case "'":
        return VIRTUAL_KEY
            .VK_OEM_7; // Typically corresponds to the single quote
      case ',':
        return VIRTUAL_KEY.VK_OEM_COMMA;
      case '.':
        return VIRTUAL_KEY.VK_OEM_PERIOD;
      case '/':
        return VIRTUAL_KEY.VK_OEM_2; // Typically corresponds to the slash
      case ';':
        return VIRTUAL_KEY.VK_OEM_1; // Typically corresponds to the semicolon
      case '[':
        return VIRTUAL_KEY
            .VK_OEM_4; // Typically corresponds to the opening bracket
      case ']':
        return VIRTUAL_KEY
            .VK_OEM_6; // Typically corresponds to the closing bracket
      default:
        return 0; // Return 0 for unmapped keys
    }
  }

  Widget buildKeys(int rowIndex, String key, int keyIndex) {
    int virtualKeyCode = getVirtualKeyCode(key);
    bool isPressed = keyPressStates[virtualKeyCode] ?? false;

    Color keyColor = isPressed
        ? const Color.fromARGB(255, 30, 30, 30)
        : const Color.fromARGB(255, 119, 171, 255);
    Color textColor = isPressed
        ? const Color.fromARGB(255, 255, 255, 255)
        : const Color.fromARGB(255, 0, 0, 0);

    Widget keyWidget = Padding(
      padding: const EdgeInsets.all(3.0),
      child: Container(
        width: key == " " ? 319 : 48,
        height: 48,
        decoration: BoxDecoration(
          color: keyColor,
          // border: Border.all(
          //   color: const Color.fromARGB(255, 0, 67, 174),
          //   width: 2,
          // ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Center(
          child: Text(
            key,
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );

    // Tactile Markers
    if (rowIndex == 1 && (keyIndex == 3 || keyIndex == 6)) {
      keyWidget = Stack(
        alignment: Alignment.bottomCenter,
        children: [
          keyWidget,
          Positioned(
            bottom: 12,
            child: Container(
              width: 10,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      );
    }

    return keyWidget;
  }
}
