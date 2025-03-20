import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:overkeys/services/config_service.dart';
import 'package:overkeys/services/kanata_service.dart';
import 'package:overkeys/utils/key_code.dart';
import 'utils/keyboard_layouts.dart';
import 'screens/keyboard_screen.dart';
import 'utils/hooks.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with TrayListener {
  static const double _defaultWindowWidth = 1000;
  static const double _defaultWindowHeight = 330;
  static const double _defaultTopRowExtraHeight = 80;
  static const double _defaultTopRowExtraWidth = 160;
  static const Duration _fadeDuration = Duration(milliseconds: 200);
  static const Duration _hideDelay = Duration(milliseconds: 300);

  // Services
  final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
  final KanataService _kanataService = KanataService();
  final Map<String, bool> _keyPressStates = {};

  // Window state
  bool _isWindowVisible = true;
  bool _ignoreMouseEvents = true;
  Timer? _autoHideTimer;
  bool autoHideBeforeMove = false;

  // General settings
  // ignore: unused_field
  bool _launchAtStartup = false;
  bool _autoHideEnabled = false;
  double _autoHideDuration = 2.0;
  KeyboardLayout _keyboardLayout = qwerty;
  KeyboardLayout? _initialKeyboardLayout;
  bool _useUserLayout = false;
  bool _kanataEnabled = false;

  // Appearance settings
  double _opacity = 0.6;
  double _lastOpacity = 0.6;
  Color _keyColorPressed = const Color.fromARGB(255, 30, 30, 30);
  Color _keyColorNotPressed = const Color.fromARGB(255, 119, 171, 255);
  Color _markerColor = Colors.white;
  Color _markerColorNotPressed = Colors.black;
  double _markerOffset = 10;
  double _markerWidth = 10;
  double _markerHeight = 2;
  double _markerBorderRadius = 10;

  // Keyboard settings
  String _keymapStyle = 'Staggered';
  bool _showTopRow = false;
  double _keySize = 48;
  double _keyBorderRadius = 12;
  double _keyPadding = 3;
  double _spaceWidth = 320;
  double _splitWidth = 100;

  // Text settings
  String _fontStyle = 'GeistMono';
  double _keyFontSize = 20;
  double _spaceFontSize = 14;
  FontWeight _fontWeight = FontWeight.w600;
  Color _keyTextColor = Colors.white;
  Color _keyTextColorNotPressed = Colors.black;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadPreferences();
    trayManager.addListener(this);
    _setupTray();
    _setupKeyListener();
    _setupMethodHandler();
    _initStartupSetting();
    await _loadKanataConfig();
    _setupKanataLayerChangeHandler();

    // Delayed initialization tasks
    Future.delayed(const Duration(seconds: 2), () {
      if (_useUserLayout) {
        _loadUserLayout();
      }
      if (_kanataEnabled) {
        _kanataService.connect();
      }
      if (_showTopRow) {
        _adjustWindowSize();
      }
    });
  }

  void _setupKanataLayerChangeHandler() {
    _kanataService.onLayerChange = (newLayout, isDefaultUserLayout) {
      setState(() {
        _keyboardLayout = newLayout;
        _updateAutoHideBasedOnLayer(isDefaultUserLayout);
      });
      _fadeIn();
    };
  }

  void _updateAutoHideBasedOnLayer(bool isDefaultUserLayout) {
    if (!isDefaultUserLayout && _autoHideEnabled) {
      // Disable auto-hide for non-default layers
      _autoHideEnabled = false;
      _autoHideTimer?.cancel();
      autoHideBeforeMove = true;
    } else if (isDefaultUserLayout && autoHideBeforeMove) {
      // Re-enable auto-hide when returning to default layer if it was enabled before
      _autoHideEnabled = true;
      _resetAutoHideTimer();
      autoHideBeforeMove = false;
    }
  }

  Future<void> _initStartupSetting() async {
    _launchAtStartup = await launchAtStartup.isEnabled();
    setState(() {});
  }

  Future<void> _handleStartupToggle(bool enable) async {
    if (enable) {
      await launchAtStartup.enable();
      if (kDebugMode) {
        print('On system startup: Enabled');
      }
    } else {
      await launchAtStartup.disable();
      if (kDebugMode) {
        print('On system startup: Disabled');
      }
    }
    await _initStartupSetting();
  }

  Future<void> _loadUserLayout() async {
    if (!_useUserLayout) return;

    final configService = ConfigService();
    final userLayout = await configService.getUserLayout();

    if (userLayout != null) {
      if (!_kanataEnabled) {
        setState(() {
          _keyboardLayout = userLayout;
        });
        if (kDebugMode) {
          print('Loaded user layout: ${userLayout.name}');
        }
        _fadeIn();
      }
    }
  }

  Future<void> _loadKanataConfig() async {
    final configService = ConfigService();
    final config = await configService.loadConfig();

    if (_kanataEnabled) {
      _kanataService.updateSettings(
          config.kanataHost, config.kanataPort, config.userLayouts);

      final defaultLayout =
          _kanataService.getLayoutByName(config.defaultUserLayout);
      if (defaultLayout != null) {
        setState(() {
          _keyboardLayout = defaultLayout;
        });
      }
    }
  }

  Future<void> _adjustWindowSize() async {
    _fadeIn();
    double height = _showTopRow
      ? _defaultWindowHeight + _defaultTopRowExtraHeight
      : _defaultWindowHeight;
    double width = _showTopRow
      ? _defaultWindowWidth + _defaultTopRowExtraWidth
      : _defaultWindowWidth;
    await windowManager.setSize(Size(width, height));
    await windowManager.setAlignment(Alignment.bottomCenter);
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    unhook();
    _autoHideTimer?.cancel();
    _kanataService.dispose();
    _savePreferences();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    // General settings
    bool autoHideEnabled = await asyncPrefs.getBool('autoHideEnabled') ?? false;
    double autoHideDuration =
        await asyncPrefs.getDouble('autoHideDuration') ?? 2.0;
    String keyboardLayoutName =
        await asyncPrefs.getString('layout') ?? 'QWERTY';
    bool useUserLayout = await asyncPrefs.getBool('useUserLayout') ?? false;
    bool kanataEnabled = await asyncPrefs.getBool('kanataEnabled') ?? false;

    // Appearance settings
    double opacity = await asyncPrefs.getDouble('opacity') ?? 0.6;
    Color keyColorPressed =
        Color(await asyncPrefs.getInt('keyColorPressed') ?? 0xFF1E1E1E);
    Color keyColorNotPressed =
        Color(await asyncPrefs.getInt('keyColorNotPressed') ?? 0xFF77ABFF);
    Color markerColor =
        Color(await asyncPrefs.getInt('markerColor') ?? 0xFFFFFFFF);
    Color markerColorNotPressed =
        Color(await asyncPrefs.getInt('markerColorNotPressed') ?? 0xFF000000);
    double markerOffset = await asyncPrefs.getDouble('markerOffset') ?? 10;
    double markerWidth = await asyncPrefs.getDouble('markerWidth') ?? 10;
    double markerHeight = await asyncPrefs.getDouble('markerHeight') ?? 2;
    double markerBorderRadius =
        await asyncPrefs.getDouble('markerBorderRadius') ?? 10;

    // Keyboard settings
    String keymapStyle =
        await asyncPrefs.getString('keymapStyle') ?? 'Staggered';
    bool showTopRow = await asyncPrefs.getBool('showTopRow') ?? false;
    double keySize = await asyncPrefs.getDouble('keySize') ?? 48;
    double keyBorderRadius =
        await asyncPrefs.getDouble('keyBorderRadius') ?? 12;
    double keyPadding = await asyncPrefs.getDouble('keyPadding') ?? 3;
    double spaceWidth = await asyncPrefs.getDouble('spaceWidth') ?? 320;
    double splitWidth = await asyncPrefs.getDouble('splitWidth') ?? 100;

    // Text settings
    String fontStyle = await asyncPrefs.getString('fontStyle') ?? 'GeistMono';
    double keyFontSize = await asyncPrefs.getDouble('keyFontSize') ?? 20;
    double spaceFontSize = await asyncPrefs.getDouble('spaceFontSize') ?? 14;
    FontWeight fontWeight = FontWeight
        .values[await asyncPrefs.getInt('fontWeight') ?? FontWeight.w600.index];
    Color keyTextColor =
        Color(await asyncPrefs.getInt('keyTextColor') ?? 0xFFFFFFFF);
    Color keyTextColorNotPressed =
        Color(await asyncPrefs.getInt('keyTextColorNotPressed') ?? 0xFF000000);

    setState(() {
      // General settings
      _autoHideEnabled = autoHideEnabled;
      _autoHideDuration = autoHideDuration;
      _keyboardLayout = availableLayouts
          .firstWhere((layout) => layout.name == keyboardLayoutName);
      _initialKeyboardLayout = _keyboardLayout;
      _useUserLayout = useUserLayout;
      _kanataEnabled = kanataEnabled;

      // Appearance settings
      _opacity = opacity;
      _keyColorPressed = keyColorPressed;
      _keyColorNotPressed = keyColorNotPressed;
      _markerColor = markerColor;
      _markerColorNotPressed = markerColorNotPressed;
      _markerOffset = markerOffset;
      _markerWidth = markerWidth;
      _markerHeight = markerHeight;
      _markerBorderRadius = markerBorderRadius;

      // Keyboard settings
      _keymapStyle = keymapStyle;
      _showTopRow = showTopRow;
      _keySize = keySize;
      _keyBorderRadius = keyBorderRadius;
      _keyPadding = keyPadding;
      _spaceWidth = spaceWidth;
      _splitWidth = splitWidth;

      // Text settings
      _fontStyle = fontStyle;
      _keyFontSize = keyFontSize;
      _spaceFontSize = spaceFontSize;
      _fontWeight = fontWeight;
      _keyTextColor = keyTextColor;
      _keyTextColorNotPressed = keyTextColorNotPressed;
    });
  }

  Future<void> _savePreferences() async {
    // General settings
    await asyncPrefs.setBool('autoHideEnabled', _autoHideEnabled);
    await asyncPrefs.setDouble('autoHideDuration', _autoHideDuration);
    await asyncPrefs.setString('layout', _initialKeyboardLayout!.name);
    await asyncPrefs.setBool('useUserLayout', _useUserLayout);
    await asyncPrefs.setBool('kanataEnabled', _kanataEnabled);

    // Appearance settings
    await asyncPrefs.setDouble('opacity', _opacity);
    await asyncPrefs.setInt('keyColorPressed', _keyColorPressed.toARGB32());
    await asyncPrefs.setInt(
        'keyColorNotPressed', _keyColorNotPressed.toARGB32());
    await asyncPrefs.setInt('markerColor', _markerColor.toARGB32());
    await asyncPrefs.setInt(
        'markerColorNotPressed', _markerColorNotPressed.toARGB32());
    await asyncPrefs.setDouble('markerOffset', _markerOffset);
    await asyncPrefs.setDouble('markerWidth', _markerWidth);
    await asyncPrefs.setDouble('markerHeight', _markerHeight);
    await asyncPrefs.setDouble('markerBorderRadius', _markerBorderRadius);

    // Keyboard settings
    await asyncPrefs.setString('keymapStyle', _keymapStyle);
    await asyncPrefs.setBool('showTopRow', _showTopRow);
    await asyncPrefs.setDouble('keySize', _keySize);
    await asyncPrefs.setDouble('keyBorderRadius', _keyBorderRadius);
    await asyncPrefs.setDouble('keyPadding', _keyPadding);
    await asyncPrefs.setDouble('spaceWidth', _spaceWidth);
    await asyncPrefs.setDouble('splitWidth', _splitWidth);

    // Text settings
    await asyncPrefs.setString('fontStyle', _fontStyle);
    await asyncPrefs.setDouble('keyFontSize', _keyFontSize);
    await asyncPrefs.setDouble('spaceFontSize', _spaceFontSize);
    await asyncPrefs.setInt('fontWeight', _fontWeight.index);
    await asyncPrefs.setInt('keyTextColor', _keyTextColor.toARGB32());
    await asyncPrefs.setInt(
        'keyTextColorNotPressed', _keyTextColorNotPressed.toARGB32());
  }

  void _setupMethodHandler() {
    DesktopMultiWindow.setMethodHandler((call, fromWindowId) async {
      switch (call.method) {
        // General settings
        case 'updateLaunchAtStartup':
          final launchAtStartupRet = call.arguments as bool;
          setState(() {
            _launchAtStartup = launchAtStartupRet;
            _handleStartupToggle(launchAtStartupRet);
          });
        case 'updateAutoHideEnabled':
          final autoHideEnabled = call.arguments as bool;
          setState(() {
            _autoHideEnabled = autoHideEnabled;
            if (_autoHideEnabled) {
              _resetAutoHideTimer();
            } else {
              _autoHideTimer?.cancel();
              if (!_isWindowVisible) {
                _fadeIn();
              }
            }
          });
          _setupTray();
        case 'updateAutoHideDuration':
          final autoHideDuration = call.arguments as double;
          setState(() => _autoHideDuration = autoHideDuration);
        case 'updateLayout':
          final layoutName = call.arguments as String;
          setState(() {
            if (_kanataEnabled) {
              _initialKeyboardLayout = availableLayouts
                  .firstWhere((layout) => layout.name == layoutName);
            } else {
              _keyboardLayout = availableLayouts
                  .firstWhere((layout) => layout.name == layoutName);
              _initialKeyboardLayout = _keyboardLayout;
            }
          });
          _fadeIn();
        case 'updateUseUserLayout':
          final useUserLayout = call.arguments as bool;
          setState(() {
            _useUserLayout = useUserLayout;
            if (useUserLayout) {
              _loadUserLayout();
            } else {
              // Revert back to the initial layout when turning off user layout
              setState(() {
                if (_initialKeyboardLayout != null && !_kanataEnabled) {
                  _keyboardLayout = _initialKeyboardLayout!;
                  if (kDebugMode) {
                    print(
                        'Reverted to initial layout: ${_initialKeyboardLayout!.name}');
                  }
                }
              });
              _fadeIn();
            }
          });
        case 'updateKanataEnabled':
          final kanataEnabled = call.arguments as bool;
          setState(() {
            if (kanataEnabled && !_kanataEnabled) {
              _initialKeyboardLayout = _keyboardLayout;
              _kanataEnabled = true;
              _loadKanataConfig().then((_) {
                _kanataService.connect();
              });
            } else if (!kanataEnabled && _kanataEnabled) {
              _kanataEnabled = false;
              _kanataService.disconnect();
              if (_initialKeyboardLayout != null) {
                _keyboardLayout = _initialKeyboardLayout!;
                _fadeIn();
              }
            }
          });

        // Appearance settings
        case 'updateOpacity':
          final opacity = call.arguments as double;
          setState(() {
            _opacity = opacity;
            _lastOpacity = opacity;
          });
        case 'updateKeyColorPressed':
          final keyColorPressed = call.arguments as int;
          setState(() => _keyColorPressed = Color(keyColorPressed));
        case 'updateKeyColorNotPressed':
          final keyColorNotPressed = call.arguments as int;
          setState(() => _keyColorNotPressed = Color(keyColorNotPressed));
        case 'updateMarkerColor':
          final markerColor = call.arguments as int;
          setState(() => _markerColor = Color(markerColor));
        case 'updateMarkerColorNotPressed':
          final markerColorNotPressed = call.arguments as int;
          setState(() => _markerColorNotPressed = Color(markerColorNotPressed));
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

        // Keyboard settings
        case 'updateKeymapStyle':
          final keymapStyle = call.arguments as String;
          setState(() => _keymapStyle = keymapStyle);
        case 'updateShowTopRow':
          final showTopRow = call.arguments as bool;
          setState(() => _showTopRow = showTopRow);
          _adjustWindowSize();
        case 'updateKeySize':
          final keySize = call.arguments as double;
          setState(() => _keySize = keySize);
        case 'updateKeyBorderRadius':
          final keyBorderRadius = call.arguments as double;
          setState(() => _keyBorderRadius = keyBorderRadius);
        case 'updateKeyPadding':
          final keyPadding = call.arguments as double;
          setState(() => _keyPadding = keyPadding);
        case 'updateSpaceWidth':
          final spaceWidth = call.arguments as double;
          setState(() => _spaceWidth = spaceWidth);
        case 'updateSplitWidth':
          final splitWidth = call.arguments as double;
          setState(() => _splitWidth = splitWidth);

        // Text settings
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

    receivePort.listen(_handleKeyEvent);
  }

  void _handleKeyEvent(dynamic message) {
    if (message[0] is! int) return;

    setState(() {
      int keyCode = message[0];
      bool isPressed = message[1];
      bool isShiftDown = message[2];

      if (kDebugMode) {
        print(
            'Key: ${getKeyFromKeyCodeShift(keyCode, isShiftDown).padRight(10)}\tKeyCode: ${keyCode.toString().padRight(5)}\tPressed: ${isPressed.toString().padRight(5)}\tShift: $isShiftDown');
      }

      _keyPressStates[getKeyFromKeyCodeShift(keyCode, isShiftDown)] = isPressed;
      _resetAutoHideTimer();

      if (_autoHideEnabled && !_isWindowVisible) {
        _fadeIn();
      }
    });
  }

  void _resetAutoHideTimer() {
    _autoHideTimer?.cancel();
    if (_autoHideEnabled) {
      _autoHideTimer = Timer(
          Duration(milliseconds: (_autoHideDuration * 1000).round()),
          _handleAutoHide);
    }
  }

  void _handleAutoHide() {
    if (_autoHideEnabled && _isWindowVisible) {
      _fadeOut();
    }
  }

  void _fadeOut() {
    setState(() {
      _lastOpacity = _opacity;
      _opacity = 0.0;
    });
    Timer(_hideDelay, () {
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
            if (!_ignoreMouseEvents) {
              autoHideBeforeMove = _autoHideEnabled;
              _autoHideEnabled = false;
              _autoHideTimer?.cancel();
              if (!_isWindowVisible) {
                _fadeIn();
              }
            } else {
              _autoHideEnabled = autoHideBeforeMove;
              if (_autoHideEnabled) {
                _resetAutoHideTimer();
              }
            }
          });
          _fadeIn();
        },
      ),
      MenuItem.separator(),
      MenuItem.checkbox(
        key: 'toggle_auto_hide',
        label: 'Auto Hide',
        checked: _autoHideEnabled,
        disabled: !_ignoreMouseEvents,
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
          key: 'reset_position',
          label: 'Reset Position',
          onClick: (menuItem) {
            windowManager.setAlignment(Alignment.bottomCenter);
          }),
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
      ),
    ]));
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (menuItem.key == 'toggle_auto_hide') {
      DesktopMultiWindow.getAllSubWindowIds().then((windowIds) {
        for (final id in windowIds) {
          DesktopMultiWindow.invokeMethod(
              id, 'updateAutoHideFromMainWindow', _autoHideEnabled);
        }
      });
    } else if (menuItem.key == 'exit') {
      DesktopMultiWindow.getAllSubWindowIds().then((windowIds) async {
        for (final id in windowIds) {
          await WindowController.fromWindowId(id).close();
        }
        await windowManager.close();
        exit(0);
      }).catchError((error) {
        if (kDebugMode) {
          print('Error closing windows: $error');
        }
        windowManager.close();
        exit(0);
      });
      return;
    }
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
    try {
      await DesktopMultiWindow.createWindow(jsonEncode({
        'name': 'preferences',
      }));
    } catch (e) {
      if (kDebugMode) {
        print('Error creating preferences window: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OverKeys',
      theme: ThemeData(
          fontFamily: _fontStyle,
          fontFamilyFallback: const ['GeistMono', 'Manrope', 'sans-serif']),
      home: Scaffold(
          backgroundColor: Colors.transparent,
          body: AnimatedOpacity(
            opacity: _opacity,
            duration: _fadeDuration,
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
                    markerColorNotPressed: _markerColorNotPressed,
                    markerOffset: _markerOffset,
                    markerWidth: _markerWidth,
                    markerHeight: _markerHeight,
                    markerBorderRadius: _markerBorderRadius,
                    spaceWidth: _spaceWidth,
                    keymapStyle: _keymapStyle,
                    splitWidth: _splitWidth,
                    showTopRow: _showTopRow,
                  ),
                ),
              ),
            ),
          )),
      debugShowCheckedModeBanner: false,
    );
  }
}
