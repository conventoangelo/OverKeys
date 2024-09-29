import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ffi' hide Size;
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:win32/win32.dart';
import 'package:ffi/ffi.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'keyboard_layouts.dart';
import 'preferences_window.dart';

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

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (args.firstOrNull == 'multi_window') {
    final windowId = int.parse(args[1]);
    final arguments = args[2].isEmpty
        ? const {}
        : jsonDecode(args[2]) as Map<String, dynamic>;

    Map windows = {
      "preferences": PreferencesWindow(
        windowController: WindowController.fromWindowId(windowId),
      ),
    };
    runApp(windows[arguments["name"]]);
  } else {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    launchAtStartup.setup(
      appName: packageInfo.appName,
      appPath: Platform.resolvedExecutable,
      packageName: packageInfo.packageName,
    );
    await windowManager.ensureInitialized();
    double windowWidth = 960;
    double windowHeight = 320;

    WindowOptions windowOptions = const WindowOptions(
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
      await windowManager.setAlignment(Alignment.bottomCenter);
      await windowManager.show();
    });
    runApp(const MainApp());
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with TrayListener {
  final Map<int, bool> _keyPressStates = {};
  KeyboardLayout _keyboardLayout = qwerty;
  Timer? _autoHideTimer;
  bool _isWindowVisible = true;
  bool _ignoreMouseEvents = true;

  final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();

  String _fontStyle = 'GeistMono';
  double _keyFontSize = 20;
  double _spaceFontSize = 14;
  FontWeight _fontWeight = FontWeight.w600;
  Color _keyTextColor = Colors.white;
  Color _keyTextColorNotPressed = Colors.black;
  Color _keyColorPressed = const Color.fromARGB(255, 30, 30, 30);
  Color _keyColorNotPressed = const Color.fromARGB(255, 119, 171, 255);
  double _keySize = 48;
  double _keyBorderRadius = 12;
  double _keyPadding = 3;
  Color _markerColor = Colors.black54;
  double _markerOffset = 10;
  double _markerWidth = 10;
  double _markerHeight = 2;
  double _markerBorderRadius = 10;
  double _spaceWidth = 320;
  double _opacity = 0.6;
  double _lastOpacity = 0.6;
  int _autoHideDuration = 2;
  bool _autoHideEnabled = false;
  bool _launchAtStartup = false;

  @override
  void initState() {
    super.initState();
    // asyncPrefs.clear();
    _loadPreferences();
    trayManager.addListener(this);
    _setupTray();
    _setupKeyListener();
    _setupMethodHandler();
    _init();
  }

  _init() async {
    _launchAtStartup = await launchAtStartup.isEnabled();
    setState(() {});
  }

  _handleEnable() async {
    await launchAtStartup.enable();
    if (kDebugMode) {
      print('On system startup: Enabled');
    }
    await _init();
  }

  _handleDisable() async {
    await launchAtStartup.disable();
    if (kDebugMode) {
      print('On system startup: Disabled');
    }
    await _init();
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    unhook();
    _autoHideTimer?.cancel();
    _savePreferences();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    String keyboardLayoutName =
        await asyncPrefs.getString('layout') ?? 'QWERTY';
    String fontStyle = await asyncPrefs.getString('fontStyle') ?? 'GeistMono';
    double keyFontSize = await asyncPrefs.getDouble('keyFontSize') ?? 20;
    double spaceFontSize = await asyncPrefs.getDouble('spaceFontSize') ?? 14;
    FontWeight fontWeight = FontWeight
        .values[await asyncPrefs.getInt('fontWeight') ?? FontWeight.w600.index];
    Color keyTextColor =
        Color(await asyncPrefs.getInt('keyTextColor') ?? 0xFFFFFFFF);
    Color keyTextColorNotPressed =
        Color(await asyncPrefs.getInt('keyTextColorNotPressed') ?? 0xFF000000);
    Color keyColorPressed =
        Color(await asyncPrefs.getInt('keyColorPressed') ?? 0xFF1E1E1E);
    Color keyColorNotPressed =
        Color(await asyncPrefs.getInt('keyColorNotPressed') ?? 0xFF77ABFF);
    double keySize = await asyncPrefs.getDouble('keySize') ?? 48;
    double keyBorderRadius =
        await asyncPrefs.getDouble('keyBorderRadius') ?? 12;
    double keyPadding = await asyncPrefs.getDouble('keyPadding') ?? 3;
    Color markerColor =
        Color(await asyncPrefs.getInt('markerColor') ?? 0xFF000000);
    double markerOffset = await asyncPrefs.getDouble('markerOffset') ?? 10;
    double markerWidth = await asyncPrefs.getDouble('markerWidth') ?? 10;
    double markerHeight = await asyncPrefs.getDouble('markerHeight') ?? 2;
    double markerBorderRadius =
        await asyncPrefs.getDouble('markerBorderRadius') ?? 10;
    double spaceWidth = await asyncPrefs.getDouble('spaceWidth') ?? 320;
    double opacity = await asyncPrefs.getDouble('opacity') ?? 0.6;
    int autoHideDuration = await asyncPrefs.getInt('autoHideDuration') ?? 2;
    bool autoHideEnabled = await asyncPrefs.getBool('autoHideEnabled') ?? false;

    setState(() {
      _keyboardLayout = availableLayouts
          .firstWhere((layout) => layout.name == keyboardLayoutName);
      _fontStyle = fontStyle;
      _keyFontSize = keyFontSize;
      _spaceFontSize = spaceFontSize;
      _fontWeight = fontWeight;
      _keyTextColor = keyTextColor;
      _keyTextColorNotPressed = keyTextColorNotPressed;
      _keyColorPressed = keyColorPressed;
      _keyColorNotPressed = keyColorNotPressed;
      _keySize = keySize;
      _keyBorderRadius = keyBorderRadius;
      _keyPadding = keyPadding;
      _markerColor = markerColor;
      _markerOffset = markerOffset;
      _markerWidth = markerWidth;
      _markerHeight = markerHeight;
      _markerBorderRadius = markerBorderRadius;
      _spaceWidth = spaceWidth;
      _opacity = opacity;
      _autoHideDuration = autoHideDuration;
      _autoHideEnabled = autoHideEnabled;
    });
  }

  Future<void> _savePreferences() async {
    await asyncPrefs.setString('layout', _keyboardLayout.name);
    await asyncPrefs.setString('fontStyle', _fontStyle);
    await asyncPrefs.setDouble('keyFontSize', _keyFontSize);
    await asyncPrefs.setDouble('spaceFontSize', _spaceFontSize);
    await asyncPrefs.setInt('fontWeight', _fontWeight.index);
    await asyncPrefs.setInt('keyTextColor', _keyTextColor.value);
    await asyncPrefs.setInt(
        'keyTextColorNotPressed', _keyTextColorNotPressed.value);
    await asyncPrefs.setInt('keyColorPressed', _keyColorPressed.value);
    await asyncPrefs.setInt('keyColorNotPressed', _keyColorNotPressed.value);
    await asyncPrefs.setDouble('keySize', _keySize);
    await asyncPrefs.setDouble('keyBorderRadius', _keyBorderRadius);
    await asyncPrefs.setDouble('keyPadding', _keyPadding);
    await asyncPrefs.setInt('markerColor', _markerColor.value);
    await asyncPrefs.setDouble('markerOffset', _markerOffset);
    await asyncPrefs.setDouble('markerWidth', _markerWidth);
    await asyncPrefs.setDouble('markerHeight', _markerHeight);
    await asyncPrefs.setDouble('markerBorderRadius', _markerBorderRadius);
    await asyncPrefs.setDouble('spaceWidth', _spaceWidth);
    await asyncPrefs.setDouble('opacity', _opacity);
    await asyncPrefs.setInt('autoHideDuration', _autoHideDuration);
    await asyncPrefs.setBool('autoHideEnabled', _autoHideEnabled);
  }

  void _setupMethodHandler() {
    DesktopMultiWindow.setMethodHandler((call, fromWindowId) async {
      switch (call.method) {
        case 'updateLayout':
          final layoutName = call.arguments as String;
          setState(() {
            _keyboardLayout = availableLayouts
                .firstWhere((layout) => layout.name == layoutName);
          });
          _fadeIn();
        case 'updateFontStyle':
          final fontStyle = call.arguments as String;
          setState(() => _fontStyle = fontStyle);
        case 'updateKeyFontSize':
          final keyFontSize = call.arguments as double;
          setState(() => _keyFontSize = keyFontSize);
        case 'updateSpaceFontSize':
          final spaceFontSize = call.arguments as double;
          setState(() => _spaceFontSize = spaceFontSize);
        case 'updateFontWeight':
          final fontWeightIndex = call.arguments as int;
          setState(() => _fontWeight = FontWeight.values[fontWeightIndex]);
        case 'updateKeyTextColor':
          final keyTextColor = call.arguments as int;
          setState(() => _keyTextColor = Color(keyTextColor));
        case 'updateKeyTextColorNotPressed':
          final keyTextColorNotPressed = call.arguments as int;
          setState(
              () => _keyTextColorNotPressed = Color(keyTextColorNotPressed));
        case 'updateKeyColorPressed':
          final keyColorPressed = call.arguments as int;
          setState(() => _keyColorPressed = Color(keyColorPressed));
        case 'updateKeyColorNotPressed':
          final keyColorNotPressed = call.arguments as int;
          setState(() => _keyColorNotPressed = Color(keyColorNotPressed));
        case 'updateKeySize':
          final keySize = call.arguments as double;
          setState(() => _keySize = keySize);
        case 'updateKeyBorderRadius':
          final keyBorderRadius = call.arguments as double;
          setState(() => _keyBorderRadius = keyBorderRadius);
        case 'updateKeyPadding':
          final keyPadding = call.arguments as double;
          setState(() => _keyPadding = keyPadding);
        case 'updateMarkerColor':
          final markerColor = call.arguments as int;
          setState(() => _markerColor = Color(markerColor));
        case 'updateMarkerOffset':
          final markerOffset = call.arguments as double;
          setState(() => _markerOffset = markerOffset);
        case 'updateMarkerWidth':
          final markerWidth = call.arguments as double;
          setState(() => _markerWidth = markerWidth);
        case 'updateMarkerHeight':
          final markerHeight = call.arguments as double;
          setState(() => _markerHeight = markerHeight);
        case 'updateMarkerBorderRadius':
          final markerBorderRadius = call.arguments as double;
          setState(() => _markerBorderRadius = markerBorderRadius);
        case 'updateSpaceWidth':
          final spaceWidth = call.arguments as double;
          setState(() => _spaceWidth = spaceWidth);
        case 'updateOpacity':
          final opacity = call.arguments as double;
          setState(() => _opacity = opacity);
        case 'updateAutoHideDuration':
          final autoHideDuration = call.arguments as int;
          setState(() => _autoHideDuration = autoHideDuration);
        case 'updateLaunchAtStartup':
          final launchAtStartupRet = call.arguments as bool;
          setState(() {
            _launchAtStartup = launchAtStartupRet;
            if (launchAtStartupRet) {
              _handleEnable();
            } else {
              _handleDisable();
            }
          });
        default:
          throw UnimplementedError('Unimplemented method ${call.method}');
      }
      return null;
    });
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
      });
    });
  }

  void _resetAutoHideTimer() {
    _autoHideTimer?.cancel();
    if (_autoHideEnabled) {
      _autoHideTimer = Timer(Duration(seconds: _autoHideDuration), () {
        if (_autoHideEnabled && _isWindowVisible) {
          _fadeOut();
        }
      });
    }
  }

  void _fadeOut() {
    setState(() {
      _lastOpacity = _opacity;
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
        _opacity = _lastOpacity;
      });
    });
    _resetAutoHideTimer();
  }

  Future<void> _setupTray() async {
    String iconPath = Platform.isWindows
        ? 'assets/images/app_icon.ico'
        : 'assets/images/app_icon.png';
    await trayManager.setIcon(iconPath);
    trayManager.setToolTip('OverKeys');
    trayManager.setContextMenu(Menu(items: [
      MenuItem.checkbox(
        key: 'toggle_mouse_events',
        label: 'Move',
        checked: !_ignoreMouseEvents,
        onClick: (menuItem) {
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
      MenuItem(
        key: 'preferences',
        label: 'Preferences',
        onClick: (menuItem) {
          if (kDebugMode) {
            print('Preferences Window Opened');
          }
          _showPreferences();
        },
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
    }
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  Future<void> _showPreferences() async {
    final window = await DesktopMultiWindow.createWindow(jsonEncode({
      'name': 'preferences',
    }));
    window
      ..setFrame(const Offset(0, 0) & const Size(1280, 760))
      ..center()
      ..show();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OverKeys',
      theme: ThemeData(
          fontFamily: _fontStyle,
          fontFamilyFallback: const ['Geist Mono', 'sans-serif']),
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
                    keyPressStates: _keyPressStates,
                    layout: _keyboardLayout,
                    fontStyle: _fontStyle,
                    keyFontSize: _keyFontSize,
                    spaceFontSize: _spaceFontSize,
                    fontWeight: _fontWeight,
                    keyTextColor: _keyTextColor,
                    keyTextColorNotPressed: _keyTextColorNotPressed,
                    keyColorPressed: _keyColorPressed,
                    keyColorNotPressed: _keyColorNotPressed,
                    keySize: _keySize,
                    keyBorderRadius: _keyBorderRadius,
                    keyPadding: _keyPadding,
                    markerColor: _markerColor,
                    markerOffset: _markerOffset,
                    markerWidth: _markerWidth,
                    markerHeight: _markerHeight,
                    markerBorderRadius: _markerBorderRadius,
                    spaceWidth: _spaceWidth,
                  ),
                ),
              ),
            ),
          )),
      debugShowCheckedModeBanner: false,
    );
  }
}

class KeyboardScreen extends StatelessWidget {
  final Map<int, bool> keyPressStates;
  final KeyboardLayout layout;
  final String fontStyle;
  final double keyFontSize;
  final double spaceFontSize;
  final FontWeight fontWeight;
  final Color keyTextColor;
  final Color keyTextColorNotPressed;
  final Color keyColorPressed;
  final Color keyColorNotPressed;
  final double keySize;
  final double keyBorderRadius;
  final double keyPadding;
  final Color markerColor;
  final double markerOffset;
  final double markerWidth;
  final double markerHeight;
  final double markerBorderRadius;
  final double spaceWidth;

  const KeyboardScreen(
      {super.key,
      required this.keyPressStates,
      required this.layout,
      required this.fontStyle,
      required this.keyFontSize,
      required this.spaceFontSize,
      required this.fontWeight,
      required this.keyTextColor,
      required this.keyTextColorNotPressed,
      required this.keyColorPressed,
      required this.keyColorNotPressed,
      required this.keySize,
      required this.keyBorderRadius,
      required this.keyPadding,
      required this.markerColor,
      required this.markerOffset,
      required this.markerWidth,
      required this.markerHeight,
      required this.markerBorderRadius,
      required this.spaceWidth});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: layout.keys.asMap().entries.map((entry) {
          int rowIndex = entry.key;
          List<String> row = entry.value;
          return buildRow(rowIndex, row);
        }).toList(),
      ),
    );
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

    Color keyColor = isPressed ? keyColorPressed : keyColorNotPressed;
    Color textColor = isPressed ? keyTextColor : keyTextColorNotPressed;

    Widget keyWidget = Padding(
      padding: EdgeInsets.all(keyPadding),
      child: Container(
        width: key == " " ? spaceWidth : keySize,
        height: keySize,
        decoration: BoxDecoration(
          color: keyColor,
          borderRadius: BorderRadius.circular(keyBorderRadius),
        ),
        child: Center(
          child: key == " "
              ? Text(
                  layout.name.toLowerCase(),
                  style: TextStyle(
                    color: textColor,
                    fontSize: spaceFontSize,
                    fontWeight: fontWeight,
                  ),
                )
              : Text(
                  key,
                  style: TextStyle(
                    color: textColor,
                    fontSize: keyFontSize,
                    fontWeight: fontWeight,
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
            bottom: markerOffset,
            child: Container(
              width: markerWidth,
              height: markerHeight,
              decoration: BoxDecoration(
                color: markerColor,
                borderRadius: BorderRadius.circular(markerBorderRadius),
              ),
            ),
          ),
        ],
      );
    }

    return keyWidget;
  }
}
