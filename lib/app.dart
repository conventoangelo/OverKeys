import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import 'utils/keyboard_layouts.dart';
import 'screens/keyboard_screen.dart';
import 'utils/hooks.dart';

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
  String _keymapStyle = 'Staggered';
  double _splitWidth = 100;
  double _opacity = 0.6;
  double _lastOpacity = 0.6;
  int _autoHideDuration = 2;
  bool _autoHideEnabled = false;
  // ignore: unused_field
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
    String keymapStyle =
        await asyncPrefs.getString('keymapStyle') ?? 'Staggered';
    double splitWidth = await asyncPrefs.getDouble('splitWidth') ?? 100;
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
      _keymapStyle = keymapStyle;
      _splitWidth = splitWidth;
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
    await asyncPrefs.setString('keymapStyle', _keymapStyle);
    await asyncPrefs.setDouble('splitWidth', _splitWidth);
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
            _lastOpacity = _opacity;
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
        case 'updateKeymapStyle':
          final keymapStyle = call.arguments as String;
          setState(() => _keymapStyle = keymapStyle);
        case 'updateSplitWidth':
          final splitWidth = call.arguments as double;
          setState(() => _splitWidth = splitWidth);
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
    Isolate.spawn(setHook, receivePort.sendPort)
        .then((_) {})
        .catchError((error) {
      if (kDebugMode) {
        print('Error spawning Isolate: $error');
      }
    });

    receivePort.listen((message) {
      setState(() {
        if (message[0] is int) {
          int key = message[0];
          bool isPressed = message[1];
          if (kDebugMode) {
            print('Received message: $message');
          }

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
          fontFamilyFallback: const ['GeistMono', 'Manrope' 'sans-serif']),
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
                    keymapStyle: _keymapStyle,
                    splitWidth: _splitWidth,
                  ),
                ),
              ),
            ),
          )),
      debugShowCheckedModeBanner: false,
    );
  }
}
