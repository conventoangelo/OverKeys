import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:window_manager/window_manager.dart';
import 'package:overkeys/utils/theme_manager.dart';
import 'package:overkeys/services/preferences_service.dart';
import 'package:overkeys/widgets/tabs/general_tab.dart';
import 'package:overkeys/widgets/tabs/keyboard_tab.dart';
import 'package:overkeys/widgets/tabs/text_tab.dart';
import 'package:overkeys/widgets/tabs/markers_tab.dart';
import 'package:overkeys/widgets/tabs/colors_tab.dart';
import 'package:overkeys/widgets/tabs/animations_tab.dart';
import 'package:overkeys/widgets/tabs/hotkeys_tab.dart';
import 'package:overkeys/widgets/tabs/learn_tab.dart';
import 'package:overkeys/widgets/tabs/advanced_tab.dart';
import 'package:overkeys/widgets/tabs/about_tab.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key, required this.windowController});

  final WindowController windowController;

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> with WindowListener {
  final PreferencesService _prefsService = PreferencesService();

  // UI state
  Brightness _brightness = Brightness.dark;
  String _appVersion = '';
  String _currentTab = 'General';

  // General settings
  bool _launchAtStartup = false;
  bool _autoHideEnabled = false;
  double _autoHideDuration = 2.0;
  double _opacity = 0.6;
  String _keyboardLayoutName = 'QWERTY';

  // Keyboard settings
  String _keymapStyle = 'Staggered';
  bool _showTopRow = false;
  bool _showGraveKey = false;
  double _keySize = 48;
  double _keyBorderRadius = 12;
  double _keyBorderThickness = 0;
  double _keyPadding = 3;
  double _spaceWidth = 320;
  double _splitWidth = 100;
  double _lastRowSplitWidth = 100;
  double _keyShadowBlurRadius = 0;
  double _keyShadowOffsetX = 2;
  double _keyShadowOffsetY = 2;

  // Text settings
  String _fontFamily = 'GeistMono';
  FontWeight _fontWeight = FontWeight.w600;
  double _keyFontSize = 20;
  double _spaceFontSize = 14;

  // Markers settings
  double _markerOffset = 10;
  double _markerWidth = 10;
  double _markerHeight = 2;
  double _markerBorderRadius = 10;

  // Colors settings
  Color _keyColorPressed = const Color.fromARGB(255, 30, 30, 30);
  Color _keyColorNotPressed = const Color.fromARGB(255, 119, 171, 255);
  Color _markerColor = Colors.white;
  Color _markerColorNotPressed = Colors.black;
  Color _keyTextColor = Colors.white;
  Color _keyTextColorNotPressed = Colors.black;
  Color _keyBorderColorPressed = Colors.black;
  Color _keyBorderColorNotPressed = Colors.white;

  // Animations settings
  bool _animationEnabled = true;
  String _animationStyle = 'Raise';
  double _animationDuration = 100;
  double _animationScale = 2.0;

  // HotKey settings
  bool _hotKeysEnabled = true;
  HotKey _visibilityHotKey = HotKey(
    key: PhysicalKeyboardKey.keyQ,
    modifiers: [HotKeyModifier.alt, HotKeyModifier.control],
  );
  HotKey _autoHideHotKey = HotKey(
    key: PhysicalKeyboardKey.keyW,
    modifiers: [HotKeyModifier.alt, HotKeyModifier.control],
  );
  HotKey _toggleMoveHotKey = HotKey(
    key: PhysicalKeyboardKey.keyE,
    modifiers: [HotKeyModifier.alt, HotKeyModifier.control],
  );
  HotKey _preferencesHotKey = HotKey(
    key: PhysicalKeyboardKey.keyR,
    modifiers: [HotKeyModifier.alt, HotKeyModifier.control],
  );
  HotKey _increaseOpacityHotKey = HotKey(
    key: PhysicalKeyboardKey.arrowUp,
    modifiers: [HotKeyModifier.alt, HotKeyModifier.control],
  );
  HotKey _decreaseOpacityHotKey = HotKey(
    key: PhysicalKeyboardKey.arrowDown,
    modifiers: [HotKeyModifier.alt, HotKeyModifier.control],
  );
  bool _enableVisibilityHotKey = true;
  bool _enableAutoHideHotKey = true;
  bool _enableToggleMoveHotKey = true;
  bool _enablePreferencesHotKey = true;
  bool _enableIncreaseOpacityHotKey = true;
  bool _enableDecreaseOpacityHotKey = true;

  // Learn settings
  bool _learningModeEnabled = false;
  Color _pinkyLeftColor = const Color(0xFFED3345);
  Color _ringLeftColor = const Color(0xFFFAA71D);
  Color _middleLeftColor = const Color(0xFF70C27B);
  Color _indexLeftColor = const Color(0xFF00AFEB);
  Color _indexRightColor = const Color(0xFF5985BF);
  Color _middleRightColor = const Color(0xFF97D6F5);
  Color _ringRightColor = const Color(0xFFFFE8A0);
  Color _pinkyRightColor = const Color(0xFFBDE0BF);

  // Advanced settings
  bool _advancedSettingsEnabled = false;
  bool _useUserLayout = false;
  bool _showAltLayout = false;
  bool _customFontEnabled = false;
  bool _use6ColLayout = false;
  bool _kanataEnabled = false;
  bool _keyboardFollowsMouse = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _loadPreferences();
    _setupMethodHandler();
    _detectSystemTheme();
    _loadAppVersion();
  }

  void _detectSystemTheme() {
    final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
    _brightness = platformDispatcher.platformBrightness;

    platformDispatcher.onPlatformBrightnessChanged = () {
      if (mounted) {
        setState(() {
          _brightness = platformDispatcher.platformBrightness;
        });
      }
    };
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = packageInfo.version;
      });
    }
  }

  @override
  void dispose() {
    _savePreferences();
    windowManager.removeListener(this);
    super.dispose();
  }

  void _setupMethodHandler() {
    DesktopMultiWindow.setMethodHandler((call, fromWindowId) async {
      if (call.method == 'getWindowType') {
        return jsonEncode({'type': 'preferences'});
      }

      if (call.method == 'updateOpacityFromMainWindow' && mounted) {
        setState(() => _opacity = call.arguments as double);
        await _prefsService.setOpacity(_opacity);
      }

      if (call.method == 'updateAutoHideFromMainWindow' && mounted) {
        setState(() => _autoHideEnabled = call.arguments as bool);
        await _prefsService.setAutoHideEnabled(_autoHideEnabled);
      }

      if (call.method == 'requestFocus') {
        await windowManager.focus();
      }
      return null;
    });
  }

  Future<void> _loadPreferences() async {
    final prefs = await _prefsService.loadAllPreferences();

    setState(() {
      // General settings
      _launchAtStartup = prefs['launchAtStartup'];
      _autoHideEnabled = prefs['autoHideEnabled'];
      _autoHideDuration = prefs['autoHideDuration'];
      _opacity = prefs['opacity'];
      _keyboardLayoutName = prefs['keyboardLayoutName'];

      // Keyboard settings
      _keymapStyle = prefs['keymapStyle'];
      _showTopRow = prefs['showTopRow'];
      _showGraveKey = prefs['showGraveKey'];
      _keySize = prefs['keySize'];
      _keyBorderRadius = prefs['keyBorderRadius'];
      _keyBorderThickness = prefs['keyBorderThickness'];
      _keyPadding = prefs['keyPadding'];
      _spaceWidth = prefs['spaceWidth'];
      _splitWidth = prefs['splitWidth'];
      _lastRowSplitWidth = prefs['lastRowSplitWidth'];
      _keyShadowBlurRadius = prefs['keyShadowBlurRadius'];
      _keyShadowOffsetX = prefs['keyShadowOffsetX'];
      _keyShadowOffsetY = prefs['keyShadowOffsetY'];

      // Text settings
      _fontFamily = prefs['fontFamily'];
      _fontWeight = prefs['fontWeight'];
      _keyFontSize = prefs['keyFontSize'];
      _spaceFontSize = prefs['spaceFontSize'];

      // Markers settings
      _markerOffset = prefs['markerOffset'];
      _markerWidth = prefs['markerWidth'];
      _markerHeight = prefs['markerHeight'];
      _markerBorderRadius = prefs['markerBorderRadius'];

      // Colors settings
      _keyColorPressed = prefs['keyColorPressed'];
      _keyColorNotPressed = prefs['keyColorNotPressed'];
      _markerColor = prefs['markerColor'];
      _markerColorNotPressed = prefs['markerColorNotPressed'];
      _keyTextColor = prefs['keyTextColor'];
      _keyTextColorNotPressed = prefs['keyTextColorNotPressed'];
      _keyBorderColorPressed = prefs['keyBorderColorPressed'];
      _keyBorderColorNotPressed = prefs['keyBorderColorNotPressed'];

      // Animations settings
      _animationEnabled = prefs['animationEnabled'];
      _animationStyle = prefs['animationStyle'];
      _animationDuration = prefs['animationDuration'];
      _animationScale = prefs['animationScale'];

      // HotKey settings
      _hotKeysEnabled = prefs['hotKeysEnabled'];
      _visibilityHotKey = prefs['visibilityHotKey'];
      _autoHideHotKey = prefs['autoHideHotKey'];
      _toggleMoveHotKey = prefs['toggleMoveHotKey'];
      _preferencesHotKey = prefs['preferencesHotKey'];
      _increaseOpacityHotKey = prefs['increaseOpacityHotKey'];
      _decreaseOpacityHotKey = prefs['decreaseOpacityHotKey'];
      _enableVisibilityHotKey = prefs['enableVisibilityHotKey'] ?? true;
      _enableAutoHideHotKey = prefs['enableAutoHideHotKey'] ?? true;
      _enableToggleMoveHotKey = prefs['enableToggleMoveHotKey'] ?? true;
      _enablePreferencesHotKey = prefs['enablePreferencesHotKey'] ?? true;
      _enableIncreaseOpacityHotKey = prefs['enableIncreaseOpacityHotKey'] ?? true;
      _enableDecreaseOpacityHotKey = prefs['enableDecreaseOpacityHotKey'] ?? true;

      // Learn settings
      _learningModeEnabled = prefs['learningModeEnabled'] ?? false;
      _pinkyLeftColor = prefs['pinkyLeftColor'];
      _ringLeftColor = prefs['ringLeftColor'];
      _middleLeftColor = prefs['middleLeftColor'];
      _indexLeftColor = prefs['indexLeftColor'];
      _indexRightColor = prefs['indexRightColor'];
      _middleRightColor = prefs['middleRightColor'];
      _ringRightColor = prefs['ringRightColor'];
      _pinkyRightColor = prefs['pinkyRightColor'];

      // Advanced settings
      _advancedSettingsEnabled = prefs['advancedSettingsEnabled'];
      _useUserLayout = prefs['useUserLayout'];
      _showAltLayout = prefs['showAltLayout'];
      _customFontEnabled = prefs['customFontEnabled'];
      _use6ColLayout = prefs['use6ColLayout'];
      _kanataEnabled = prefs['kanataEnabled'];
      _keyboardFollowsMouse = prefs['keyboardFollowsMouse'] ?? false;
    });
  }

  Future<void> _savePreferences() async {
    final prefs = {
      // General settings
      'launchAtStartup': _launchAtStartup,
      'autoHideEnabled': _autoHideEnabled,
      'autoHideDuration': _autoHideDuration,
      'opacity': _opacity,
      'keyboardLayoutName': _keyboardLayoutName,

      // Keyboard settings
      'keymapStyle': _keymapStyle,
      'showTopRow': _showTopRow,
      'showGraveKey': _showGraveKey,
      'keySize': _keySize,
      'keyBorderRadius': _keyBorderRadius,
      'keyBorderThickness': _keyBorderThickness,
      'keyPadding': _keyPadding,
      'spaceWidth': _spaceWidth,
      'splitWidth': _splitWidth,
      'lastRowSplitWidth': _lastRowSplitWidth,
      'keyShadowBlurRadius': _keyShadowBlurRadius,
      'keyShadowOffsetX': _keyShadowOffsetX,
      'keyShadowOffsetY': _keyShadowOffsetY,

      // Text settings
      'fontFamily': _fontFamily,
      'fontWeight': _fontWeight,
      'keyFontSize': _keyFontSize,
      'spaceFontSize': _spaceFontSize,

      // Markers settings
      'markerOffset': _markerOffset,
      'markerWidth': _markerWidth,
      'markerHeight': _markerHeight,
      'markerBorderRadius': _markerBorderRadius,

      // Colors settings
      'keyColorPressed': _keyColorPressed,
      'keyColorNotPressed': _keyColorNotPressed,
      'markerColor': _markerColor,
      'markerColorNotPressed': _markerColorNotPressed,
      'keyTextColor': _keyTextColor,
      'keyTextColorNotPressed': _keyTextColorNotPressed,
      'keyBorderColorPressed': _keyBorderColorPressed,
      'keyBorderColorNotPressed': _keyBorderColorNotPressed,

      // Animations settings
      'animationEnabled': _animationEnabled,
      'animationStyle': _animationStyle,
      'animationDuration': _animationDuration,
      'animationScale': _animationScale,

      // HotKey settings
      'hotKeysEnabled': _hotKeysEnabled,
      'visibilityHotKey': _visibilityHotKey,
      'autoHideHotKey': _autoHideHotKey,
      'toggleMoveHotKey': _toggleMoveHotKey,
      'preferencesHotKey': _preferencesHotKey,
      'increaseOpacityHotKey': _increaseOpacityHotKey,
      'decreaseOpacityHotKey': _decreaseOpacityHotKey,
      'enableVisibilityHotKey': _enableVisibilityHotKey,
      'enableAutoHideHotKey': _enableAutoHideHotKey,
      'enableToggleMoveHotKey': _enableToggleMoveHotKey,
      'enablePreferencesHotKey': _enablePreferencesHotKey,
      'enableIncreaseOpacityHotKey': _enableIncreaseOpacityHotKey,
      'enableDecreaseOpacityHotKey': _enableDecreaseOpacityHotKey,

      // Learn settings
      'learningModeEnabled': _learningModeEnabled,
      'pinkyLeftColor': _pinkyLeftColor,
      'ringLeftColor': _ringLeftColor,
      'middleLeftColor': _middleLeftColor,
      'indexLeftColor': _indexLeftColor,
      'indexRightColor': _indexRightColor,
      'middleRightColor': _middleRightColor,
      'ringRightColor': _ringRightColor,
      'pinkyRightColor': _pinkyRightColor,

      // Advanced settings
      'advancedSettingsEnabled': _advancedSettingsEnabled,
      'useUserLayout': _useUserLayout,
      'showAltLayout': _showAltLayout,
      'customFontEnabled': _customFontEnabled,
      'use6ColLayout': _use6ColLayout,
      'kanataEnabled': _kanataEnabled,
      'keyboardFollowsMouse': _keyboardFollowsMouse,
    };

    await _prefsService.saveAllPreferences(prefs);
  }

  void _updateMainWindow(dynamic method, dynamic value) async {
    if (value is Color) {
      value = value.toARGB32();
    } else if (value is FontWeight) {
      value = value.index;
    } else if (value is HotKey) {
      value = jsonEncode(value.toJson());
    }
    await DesktopMultiWindow.invokeMethod(0, method, value);
    _savePreferences();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeManager.getTheme(_brightness);
    final FocusNode keyboardFocusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      keyboardFocusNode.requestFocus();
    });

    return MaterialApp(
      theme: theme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
      ],
      home: Builder(builder: (context) {
        return KeyboardListener(
          focusNode: keyboardFocusNode,
          onKeyEvent: (KeyEvent keyEvent) {
            if (keyEvent is KeyDownEvent && keyEvent.logicalKey == LogicalKeyboardKey.escape) {
              DesktopMultiWindow.invokeMethod(0, 'closePreferencesWindow');
            }
          },
          child: Scaffold(
            body: Row(
              children: [
                _buildNavigationPanel(context),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 20.0),
                          child: _buildCurrentTabContent(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
      debugShowCheckedModeBanner: false,
    );
  }

  Widget _buildNavigationPanel(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final double drawerWidth = 200;

    return Container(
      width: drawerWidth,
      color: Theme.of(context).drawerTheme.backgroundColor ?? colorScheme.surfaceContainer,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Image.asset(
              'assets/images/app_icon.png',
              width: 60,
              height: 60,
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                'General',
                'Keyboard',
                'Text',
                'Markers',
                'Colors',
                'Animations',
                'Hotkeys',
                'Learn',
                'Advanced',
                'About',
              ].map((tab) => _buildDrawerItem(context, tab)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String tabName) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isSelected = _currentTab == tabName;

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? colorScheme.surface : Colors.transparent,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: ListTile(
          leading: Icon(
            _getIconForTab(tabName).icon,
            color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant.withAlpha(192),
          ),
          title: Text(
            tabName,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 16,
              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant.withAlpha(192),
            ),
          ),
          onTap: () {
            setState(() => _currentTab = tabName);
          },
          selected: isSelected,
        ),
      ),
    );
  }

  Icon _getIconForTab(String tabName) {
    switch (tabName) {
      case 'General':
        return const Icon(LucideIcons.settings2);
      case 'Keyboard':
        return const Icon(LucideIcons.keyboard);
      case 'Text':
        return const Icon(LucideIcons.type);
      case 'Markers':
        return const Icon(LucideIcons.mapPin);
      case 'Colors':
        return const Icon(LucideIcons.palette);
      case 'Animations':
        return const Icon(LucideIcons.sparkles);
      case 'Hotkeys':
        return const Icon(LucideIcons.zap);
      case 'Learn':
        return const Icon(LucideIcons.graduationCap);
      case 'Advanced':
        return const Icon(LucideIcons.userCog2);
      case 'About':
        return const Icon(LucideIcons.info);
      default:
        return const Icon(LucideIcons.menu);
    }
  }

  Widget _buildCurrentTabContent() {
    switch (_currentTab) {
      case 'General':
        return GeneralTab(
          launchAtStartup: _launchAtStartup,
          autoHideEnabled: _autoHideEnabled,
          autoHideDuration: _autoHideDuration,
          keyboardLayoutName: _keyboardLayoutName,
          opacity: _opacity,
          updateLaunchAtStartup: (value) {
            setState(() => _launchAtStartup = value);
            _updateMainWindow('updateLaunchAtStartup', value);
          },
          updateAutoHideEnabled: (value) {
            setState(() => _autoHideEnabled = value);
            _updateMainWindow('updateAutoHideEnabled', value);
          },
          updateAutoHideDuration: (value) {
            double roundedValue = (value * 2).round() / 2;
            setState(() => _autoHideDuration = roundedValue);
            _updateMainWindow('updateAutoHideDuration', roundedValue);
          },
          updateOpacity: (value) {
            setState(() => _opacity = value);
            _updateMainWindow('updateOpacity', value);
          },
          updateKeyboardLayoutName: (value) {
            setState(() => _keyboardLayoutName = value);
            _updateMainWindow('updateLayout', value);
          },
        );
      case 'Keyboard':
        return KeyboardTab(
          keymapStyle: _keymapStyle,
          showTopRow: _showTopRow,
          showGraveKey: _showGraveKey,
          keySize: _keySize,
          keyBorderRadius: _keyBorderRadius,
          keyBorderThickness: _keyBorderThickness,
          keyPadding: _keyPadding,
          spaceWidth: _spaceWidth,
          splitWidth: _splitWidth,
          lastRowSplitWidth: _lastRowSplitWidth,
          keyShadowBlurRadius: _keyShadowBlurRadius,
          keyShadowOffsetX: _keyShadowOffsetX,
          keyShadowOffsetY: _keyShadowOffsetY,
          updateKeymapStyle: (value) {
            setState(() => _keymapStyle = value);
            _updateMainWindow('updateKeymapStyle', value);
          },
          updateShowTopRow: (value) {
            setState(() => _showTopRow = value);
            _updateMainWindow('updateShowTopRow', value);
          },
          updateShowGraveKey: (value) {
            setState(() => _showGraveKey = value);
            _updateMainWindow('updateShowGraveKey', value);
          },
          updateKeySize: (value) {
            setState(() => _keySize = value);
            _updateMainWindow('updateKeySize', value);
          },
          updateKeyBorderRadius: (value) {
            setState(() => _keyBorderRadius = value);
            _updateMainWindow('updateKeyBorderRadius', value);
          },
          updateKeyBorderThickness: (value) {
            setState(() => _keyBorderThickness = value);
            _updateMainWindow('updateKeyBorderThickness', value);
          },
          updateKeyPadding: (value) {
            setState(() => _keyPadding = value);
            _updateMainWindow('updateKeyPadding', value);
          },
          updateSpaceWidth: (value) {
            setState(() => _spaceWidth = value);
            _updateMainWindow('updateSpaceWidth', value);
          },
          updateSplitWidth: (value) {
            setState(() => _splitWidth = value);
            _updateMainWindow('updateSplitWidth', value);
          },
          updateLastRowSplitWidth: (value) {
            setState(() => _lastRowSplitWidth = value);
            _updateMainWindow('updateLastRowSplitWidth', value);
          },
          updateKeyShadowBlurRadius: (value) {
            setState(() => _keyShadowBlurRadius = value);
            _updateMainWindow('updateKeyShadowBlurRadius', value);
          },
          updateKeyShadowOffsetX: (value) {
            setState(() => _keyShadowOffsetX = value);
            _updateMainWindow('updateKeyShadowOffsetX', value);
          },
          updateKeyShadowOffsetY: (value) {
            setState(() => _keyShadowOffsetY = value);
            _updateMainWindow('updateKeyShadowOffsetY', value);
          },
        );
      case 'Text':
        return TextTab(
          fontFamily: _fontFamily,
          fontWeight: _fontWeight,
          keyFontSize: _keyFontSize,
          spaceFontSize: _spaceFontSize,
          updateFontFamily: (value) {
            setState(() => _fontFamily = value);
            _updateMainWindow('updateFontFamily', value);
          },
          updateFontWeight: (value) {
            setState(() => _fontWeight = value);
            _updateMainWindow('updateFontWeight', value);
          },
          updateKeyFontSize: (value) {
            setState(() => _keyFontSize = value);
            _updateMainWindow('updateKeyFontSize', value);
          },
          updateSpaceFontSize: (value) {
            setState(() => _spaceFontSize = value);
            _updateMainWindow('updateSpaceFontSize', value);
          },
        );
      case 'Markers':
        return MarkersTab(
          markerOffset: _markerOffset,
          markerWidth: _markerWidth,
          markerHeight: _markerHeight,
          markerBorderRadius: _markerBorderRadius,
          showAltLayout: _showAltLayout,
          updateMarkerOffset: (value) {
            setState(() => _markerOffset = value);
            _updateMainWindow('updateMarkerOffset', value);
          },
          updateMarkerWidth: (value) {
            setState(() => _markerWidth = value);
            _updateMainWindow('updateMarkerWidth', value);
          },
          updateMarkerHeight: (value) {
            setState(() => _markerHeight = value);
            _updateMainWindow('updateMarkerHeight', value);
          },
          updateMarkerBorderRadius: (value) {
            setState(() => _markerBorderRadius = value);
            _updateMainWindow('updateMarkerBorderRadius', value);
          },
        );
      case 'Colors':
        return ColorsTab(
          keyColorPressed: _keyColorPressed,
          keyColorNotPressed: _keyColorNotPressed,
          markerColor: _markerColor,
          markerColorNotPressed: _markerColorNotPressed,
          keyTextColor: _keyTextColor,
          keyTextColorNotPressed: _keyTextColorNotPressed,
          keyBorderColorPressed: _keyBorderColorPressed,
          keyBorderColorNotPressed: _keyBorderColorNotPressed,
          updateKeyColorPressed: (value) {
            setState(() => _keyColorPressed = value);
            _updateMainWindow('updateKeyColorPressed', value);
          },
          updateKeyColorNotPressed: (value) {
            setState(() => _keyColorNotPressed = value);
            _updateMainWindow('updateKeyColorNotPressed', value);
          },
          updateMarkerColor: (value) {
            setState(() => _markerColor = value);
            _updateMainWindow('updateMarkerColor', value);
          },
          updateMarkerColorNotPressed: (value) {
            setState(() => _markerColorNotPressed = value);
            _updateMainWindow('updateMarkerColorNotPressed', value);
          },
          updateKeyTextColor: (value) {
            setState(() => _keyTextColor = value);
            _updateMainWindow('updateKeyTextColor', value);
          },
          updateKeyTextColorNotPressed: (value) {
            setState(() => _keyTextColorNotPressed = value);
            _updateMainWindow('updateKeyTextColorNotPressed', value);
          },
          updateKeyBorderColorPressed: (value) {
            setState(() => _keyBorderColorPressed = value);
            _updateMainWindow('updateKeyBorderColorPressed', value);
          },
          updateKeyBorderColorNotPressed: (value) {
            setState(() => _keyBorderColorNotPressed = value);
            _updateMainWindow('updateKeyBorderColorNotPressed', value);
          },
        );
      case 'Animations':
        return AnimationsTab(
          animationEnabled: _animationEnabled,
          animationStyle: _animationStyle,
          animationDuration: _animationDuration,
          animationScale: _animationScale,
          updateAnimationEnabled: (value) {
            setState(() => _animationEnabled = value);
            _updateMainWindow('updateAnimationEnabled', value);
          },
          updateAnimationStyle: (value) {
            setState(() => _animationStyle = value);
            _updateMainWindow('updateAnimationStyle', value);
          },
          updateAnimationDuration: (value) {
            setState(() => _animationDuration = value);
            _updateMainWindow('updateAnimationDuration', value);
          },
          updateAnimationScale: (value) {
            setState(() => _animationScale = value);
            _updateMainWindow('updateAnimationScale', value);
          },
        );
      case 'Hotkeys':
        return HotKeysTab(
          hotKeysEnabled: _hotKeysEnabled,
          visibilityHotKey: _visibilityHotKey,
          autoHideHotKey: _autoHideHotKey,
          toggleMoveHotKey: _toggleMoveHotKey,
          preferencesHotKey: _preferencesHotKey,
          increaseOpacityHotKey: _increaseOpacityHotKey,
          decreaseOpacityHotKey: _decreaseOpacityHotKey,
          enableVisibilityHotKey: _enableVisibilityHotKey,
          enableAutoHideHotKey: _enableAutoHideHotKey,
          enableToggleMoveHotKey: _enableToggleMoveHotKey,
          enablePreferencesHotKey: _enablePreferencesHotKey,
          enableIncreaseOpacityHotKey: _enableIncreaseOpacityHotKey,
          enableDecreaseOpacityHotKey: _enableDecreaseOpacityHotKey,
          updateHotKeysEnabled: (value) {
            setState(() => _hotKeysEnabled = value);
            _updateMainWindow('updateHotKeysEnabled', value);
          },
          updateVisibilityHotKey: (value) {
            setState(() => _visibilityHotKey = value);
            _updateMainWindow('updateVisibilityHotKey', value);
          },
          updateAutoHideHotKey: (value) {
            setState(() => _autoHideHotKey = value);
            _updateMainWindow('updateAutoHideHotKey', value);
          },
          updateToggleMoveHotKey: (value) {
            setState(() => _toggleMoveHotKey = value);
            _updateMainWindow('updateToggleMoveHotKey', value);
          },
          updatePreferencesHotKey: (value) {
            setState(() => _preferencesHotKey = value);
            _updateMainWindow('updatePreferencesHotKey', value);
          },
          updateIncreaseOpacityHotKey: (value) {
            setState(() => _increaseOpacityHotKey = value);
            _updateMainWindow('updateIncreaseOpacityHotKey', value);
          },
          updateDecreaseOpacityHotKey: (value) {
            setState(() => _decreaseOpacityHotKey = value);
            _updateMainWindow('updateDecreaseOpacityHotKey', value);
          },
          updateEnableVisibilityHotKey: (value) {
            setState(() => _enableVisibilityHotKey = value);
            _updateMainWindow('updateEnableVisibilityHotKey', value);
          },
          updateEnableAutoHideHotKey: (value) {
            setState(() => _enableAutoHideHotKey = value);
            _updateMainWindow('updateEnableAutoHideHotKey', value);
          },
          updateEnableToggleMoveHotKey: (value) {
            setState(() => _enableToggleMoveHotKey = value);
            _updateMainWindow('updateEnableToggleMoveHotKey', value);
          },
          updateEnablePreferencesHotKey: (value) {
            setState(() => _enablePreferencesHotKey = value);
            _updateMainWindow('updateEnablePreferencesHotKey', value);
          },
          updateEnableIncreaseOpacityHotKey: (value) {
            setState(() => _enableIncreaseOpacityHotKey = value);
            _updateMainWindow('updateEnableIncreaseOpacityHotKey', value);
          },
          updateEnableDecreaseOpacityHotKey: (value) {
            setState(() => _enableDecreaseOpacityHotKey = value);
            _updateMainWindow('updateEnableDecreaseOpacityHotKey', value);
          },
        );
      case 'Learn':
        return LearnTab(
          learningModeEnabled: _learningModeEnabled,
          pinkyLeftColor: _pinkyLeftColor,
          ringLeftColor: _ringLeftColor,
          middleLeftColor: _middleLeftColor,
          indexLeftColor: _indexLeftColor,
          indexRightColor: _indexRightColor,
          middleRightColor: _middleRightColor,
          ringRightColor: _ringRightColor,
          pinkyRightColor: _pinkyRightColor,
          updateLearningModeEnabled: (value) {
            setState(() => _learningModeEnabled = value);
            _updateMainWindow('updateLearningModeEnabled', value);
          },
          updatePinkyLeftColor: (value) {
            setState(() => _pinkyLeftColor = value);
            _updateMainWindow('updatePinkyLeftColor', value);
          },
          updateRingLeftColor: (value) {
            setState(() => _ringLeftColor = value);
            _updateMainWindow('updateRingLeftColor', value);
          },
          updateMiddleLeftColor: (value) {
            setState(() => _middleLeftColor = value);
            _updateMainWindow('updateMiddleLeftColor', value);
          },
          updateIndexLeftColor: (value) {
            setState(() => _indexLeftColor = value);
            _updateMainWindow('updateIndexLeftColor', value);
          },
          updateIndexRightColor: (value) {
            setState(() => _indexRightColor = value);
            _updateMainWindow('updateIndexRightColor', value);
          },
          updateMiddleRightColor: (value) {
            setState(() => _middleRightColor = value);
            _updateMainWindow('updateMiddleRightColor', value);
          },
          updateRingRightColor: (value) {
            setState(() => _ringRightColor = value);
            _updateMainWindow('updateRingRightColor', value);
          },
          updatePinkyRightColor: (value) {
            setState(() => _pinkyRightColor = value);
            _updateMainWindow('updatePinkyRightColor', value);
          },
        );
      case 'Advanced':
        return AdvancedTab(
          advancedSettingsEnabled: _advancedSettingsEnabled,
          useUserLayout: _useUserLayout,
          showAltLayout: _showAltLayout,
          customFontEnabled: _customFontEnabled,
          use6ColLayout: _use6ColLayout,
          kanataEnabled: _kanataEnabled,
          keyboardFollowsMouse: _keyboardFollowsMouse,
          updateAdvancedSettingsEnabled: (value) {
            setState(() => _advancedSettingsEnabled = value);
            _updateMainWindow('updateAdvancedSettingsEnabled', value);
          },
          updateUseUserLayout: (value) {
            setState(() => _useUserLayout = value);
            if (value && _kanataEnabled) {
              setState(() => _kanataEnabled = false);
              _updateMainWindow('updateKanataEnabled', false);
            }
            _updateMainWindow('updateUseUserLayout', value);
          },
          updateShowAltLayout: (value) {
            setState(() => _showAltLayout = value);
            _updateMainWindow('updateShowAltLayout', value);
          },
          updateCustomFontEnabled: (value) {
            setState(() => _customFontEnabled = value);
            _updateMainWindow('updateCustomFontEnabled', value);
          },
          updateUse6ColLayout: (value) {
            setState(() => _use6ColLayout = value);
            _updateMainWindow('updateUse6ColLayout', value);
          },
          updateKanataEnabled: (value) {
            setState(() => _kanataEnabled = value);
            if (value && _useUserLayout) {
              setState(() => _useUserLayout = false);
              _updateMainWindow('updateUseUserLayout', false);
            }
            _updateMainWindow('updateKanataEnabled', value);
          },
          updateKeyboardFollowsMouse: (value) {
            setState(() => _keyboardFollowsMouse = value);
            _updateMainWindow('updateKeyboardFollowsMouse', value);
          },
        );
      case 'About':
        return AboutTab(appVersion: _appVersion);
      default:
        return const SizedBox.shrink();
    }
  }
}
