import 'dart:async';
import 'dart:ui';
import 'dart:io';
import 'dart:ffi' hide Size;
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:win32/win32.dart';
import 'package:ffi/ffi.dart';

import 'keyboard_layouts.dart';

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

FlutterView view = WidgetsBinding.instance.platformDispatcher.views.first;
double dpr = view.devicePixelRatio;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // Device size getters inconsistent
  // Size size = view.physicalSize;
  // Size screenSize = await windowManager.getSize();

  // Default size set to 1920x1080
  Size screenSize = const Size(1920.0, 1080.0);
  double windowWidth = 850 / dpr;
  double windowHeight = 290 / dpr;
  Size windowSize = Size(windowWidth, windowHeight);

  double left = ((screenSize.width / dpr) - (windowWidth)) / 2;
  double top = ((screenSize.height / dpr) - (windowHeight)) - 50 / dpr;

  WindowOptions windowOptions = WindowOptions(
    size: windowSize,
    backgroundColor: Colors.transparent,
    skipTaskbar: true,
    title: "OverKeys",
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setAsFrameless();
    await windowManager.setSize(Size(windowWidth, windowHeight));
    await windowManager.setIgnoreMouseEvents(true);
    await windowManager.setPosition(Offset(left, top));
    Offset position = await windowManager.getPosition();
    if (kDebugMode) {
      print('Window Position: $position');
    }
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
  bool _ignoreMouseEvents = true;
  bool _isWindowVisible = true;
  bool _autoHideEnabled = false;
  Timer? _autoHideTimer;
  double _opacity = 0.6;
  final Map<int, bool> _keyPressStates = {};
  KeyboardLayout _keyboardLayout = canary;

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
    _resetAutoHideTimer();
  }

  void _changeLayout(KeyboardLayout newLayout) {
    setState(() {
      _keyboardLayout = newLayout;
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
        checked: !_ignoreMouseEvents,
        onClick: (menuItem) {
          // TODO: Window does not appear when toggled off during hidden
          setState(() {
            if (kDebugMode) {
              print('Mouse Events Toggled');
            }
            _ignoreMouseEvents = !_ignoreMouseEvents;
            windowManager.setIgnoreMouseEvents(_ignoreMouseEvents);
          });
          _fadeIn();
        },
      ),
      MenuItem.separator(),
      MenuItem.checkbox(
        key: 'toggle_auto_hide',
        label: 'Auto Hide',
        checked: _autoHideEnabled,
        onClick: (menuItem) {
          setState(() {
            if (kDebugMode) {
              print('Auto Hide Toggled');
            }
            _autoHideEnabled = !_autoHideEnabled;
            if (_autoHideEnabled) {
              _resetAutoHideTimer();
            } else {
              _autoHideTimer?.cancel();
              if (!_isWindowVisible) {
                _fadeIn();
              }
            }
          });
        },
      ),
      MenuItem.separator(),
      MenuItem.submenu(
        label: 'Layout',
        submenu: Menu(
          items: availableLayouts
              .map((layout) => MenuItem.checkbox(
                    key: layout.name.toLowerCase(),
                    label: layout.name,
                    checked: layout == _keyboardLayout ? true : false,
                    onClick: (menuItem) {
                      _changeLayout(layout);
                      _fadeIn();
                    },
                  ))
              .toList(),
        ),
      ),
      MenuItem.separator(),
      MenuItem(
        key: 'exit',
        label: 'Exit',
        onClick: (menuItem) {
          windowManager.close();
        },
      ),
    ]));
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    _setupTray();
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
                child: KeyboardScreen(
                    keyPressStates: _keyPressStates, layout: _keyboardLayout),
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
  final KeyboardLayout layout;

  const KeyboardScreen(
      {super.key, required this.keyPressStates, required this.layout});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: layout.keys.asMap().entries.map((entry) {
            int rowIndex = entry.key;
            List<String> row = entry.value;
            return buildRow(rowIndex, row);
          }).toList(),
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
        return VIRTUAL_KEY.VK_SPACE;
      case ',':
        return VIRTUAL_KEY.VK_OEM_COMMA;
      case '.':
        return VIRTUAL_KEY.VK_OEM_PERIOD;
      case ';':
        return VIRTUAL_KEY.VK_OEM_1;
      case '/':
        return VIRTUAL_KEY.VK_OEM_2;
      case '?':
        return VIRTUAL_KEY.VK_OEM_2;
      // No virtual key code for number sign
      case '#':
        return VIRTUAL_KEY.VK_3;
      case '[':
        return VIRTUAL_KEY.VK_OEM_4;
      case ']':
        return VIRTUAL_KEY.VK_OEM_6;
      // No separate keycode for single and double quotes
      case "'":
        return VIRTUAL_KEY.VK_OEM_7;
      case '"':
        return VIRTUAL_KEY.VK_OEM_7;
      case '=':
        return VIRTUAL_KEY.VK_OEM_PLUS;
      case '-':
        return VIRTUAL_KEY.VK_OEM_MINUS;
      default:
        return 0;
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
        width: key == " " ? 399 / dpr : 60 / dpr,
        height: 60 / dpr,
        decoration: BoxDecoration(
          color: keyColor,
          borderRadius: BorderRadius.circular(15.0 / dpr),
        ),
        child: Center(
          child: key == " "
              ? Text(
                  layout.name.toLowerCase(),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18 / dpr,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : Text(
                  key,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 25 / dpr,
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
            bottom: 15 / dpr,
            child: Container(
              width: 12.5 / dpr,
              height: 2.5 / dpr,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12.5 / dpr),
              ),
            ),
          ),
        ],
      );
    }

    return keyWidget;
  }
}
