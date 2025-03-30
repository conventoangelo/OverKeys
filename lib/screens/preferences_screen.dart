import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:overkeys/widgets/tabs/hotkeys_tab.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:window_manager/window_manager.dart';
import 'package:overkeys/utils/theme_manager.dart';
import 'package:overkeys/services/preferences_service.dart';
import 'package:overkeys/widgets/tabs/general_tab.dart';
import 'package:overkeys/widgets/tabs/appearance_tab.dart';
import 'package:overkeys/widgets/tabs/keyboard_tab.dart';
import 'package:overkeys/widgets/tabs/text_tab.dart';
import 'package:overkeys/widgets/tabs/about_tab.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key, required this.windowController});

  final WindowController windowController;

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen>
    with WindowListener {
  final PreferencesService _prefsService = PreferencesService();

  // UI state
  Brightness _brightness = Brightness.dark;
  String _appVersion = '';
  String _currentTab = 'General';

  // General settings
  bool _launchAtStartup = false;
  bool _autoHideEnabled = false;
  double _autoHideDuration = 2.0;
  String _keyboardLayoutName = 'QWERTY';
  bool _enableAdvancedSettings = false;
  bool _useUserLayout = false;
  bool _showAltLayout = false;
  bool _kanataEnabled = false;

  // Appearance settings
  double _opacity = 0.6;
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
  bool _showGraveKey = false;
  double _keySize = 48;
  double _keyBorderRadius = 12;
  double _keyPadding = 3;
  double _spaceWidth = 320;
  double _splitWidth = 100;

  // Text settings
  String _fontFamily = 'GeistMono';
  double _keyFontSize = 20;
  double _spaceFontSize = 14;
  FontWeight _fontWeight = FontWeight.w600;
  Color _keyTextColor = Colors.white;
  Color _keyTextColorNotPressed = Colors.black;

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
      _keyboardLayoutName = prefs['keyboardLayoutName'];
      _enableAdvancedSettings = prefs['enableAdvancedSettings'];
      _useUserLayout = prefs['useUserLayout'];
      _showAltLayout = prefs['showAltLayout'];
      _kanataEnabled = prefs['kanataEnabled'];

      // Appearance settings
      _opacity = prefs['opacity'];
      _keyColorPressed = prefs['keyColorPressed'];
      _keyColorNotPressed = prefs['keyColorNotPressed'];
      _markerColor = prefs['markerColor'];
      _markerColorNotPressed = prefs['markerColorNotPressed'];
      _markerOffset = prefs['markerOffset'];
      _markerWidth = prefs['markerWidth'];
      _markerHeight = prefs['markerHeight'];
      _markerBorderRadius = prefs['markerBorderRadius'];

      // Keyboard settings
      _keymapStyle = prefs['keymapStyle'];
      _showTopRow = prefs['showTopRow'];
      _showGraveKey = prefs['showGraveKey'];
      _keySize = prefs['keySize'];
      _keyBorderRadius = prefs['keyBorderRadius'];
      _keyPadding = prefs['keyPadding'];
      _spaceWidth = prefs['spaceWidth'];
      _splitWidth = prefs['splitWidth'];

      // Text settings
      _fontFamily = prefs['fontFamily'];
      _keyFontSize = prefs['keyFontSize'];
      _spaceFontSize = prefs['spaceFontSize'];
      _fontWeight = prefs['fontWeight'];
      _keyTextColor = prefs['keyTextColor'];
      _keyTextColorNotPressed = prefs['keyTextColorNotPressed'];

      // HotKey settings
      _hotKeysEnabled = prefs['hotKeysEnabled'];
      _visibilityHotKey = prefs['visibilityHotKey'];
      _autoHideHotKey = prefs['autoHideHotKey'];
    });
  }

  Future<void> _savePreferences() async {
    final prefs = {
      // General settings
      'launchAtStartup': _launchAtStartup,
      'autoHideEnabled': _autoHideEnabled,
      'autoHideDuration': _autoHideDuration,
      'keyboardLayoutName': _keyboardLayoutName,
      'enableAdvancedSettings': _enableAdvancedSettings,
      'useUserLayout': _useUserLayout,
      'showAltLayout': _showAltLayout,
      'kanataEnabled': _kanataEnabled,

      // Appearance settings
      'opacity': _opacity,
      'keyColorPressed': _keyColorPressed,
      'keyColorNotPressed': _keyColorNotPressed,
      'markerColor': _markerColor,
      'markerColorNotPressed': _markerColorNotPressed,
      'markerOffset': _markerOffset,
      'markerWidth': _markerWidth,
      'markerHeight': _markerHeight,
      'markerBorderRadius': _markerBorderRadius,

      // Keyboard settings
      'keymapStyle': _keymapStyle,
      'showTopRow': _showTopRow,
      'showGraveKey': _showGraveKey,
      'keySize': _keySize,
      'keyBorderRadius': _keyBorderRadius,
      'keyPadding': _keyPadding,
      'spaceWidth': _spaceWidth,
      'splitWidth': _splitWidth,

      // Text settings
      'fontFamily': _fontFamily,
      'keyFontSize': _keyFontSize,
      'spaceFontSize': _spaceFontSize,
      'fontWeight': _fontWeight,
      'keyTextColor': _keyTextColor,
      'keyTextColorNotPressed': _keyTextColorNotPressed,

      // HotKey settings
      'hotKeysEnabled': _hotKeysEnabled,
      'visibilityHotKey': _visibilityHotKey,
      'autoHideHotKey': _autoHideHotKey,
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
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 100,
            title: Padding(
              padding: const EdgeInsets.symmetric(vertical: 100),
              child: _buildTabBar(),
            ),
            automaticallyImplyLeading: false,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60.0),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20.0, 0, 16.0, 20.0),
              child: _buildCurrentTabContent(),
            ),
          ),
        );
      }),
      debugShowCheckedModeBanner: false,
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          'General',
          'Appearance',
          'Keyboard',
          'Text',
          'About',
          'Hotkeys'
        ].map((tab) => _buildTabButton(tab)).toList(),
      ),
    );
  }

  Widget _buildTabButton(String tabName) {
    final colorScheme = ThemeManager.getTheme(_brightness).colorScheme;
    bool isActive = _currentTab == tabName;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ElevatedButton(
        onPressed: () => setState(() => _currentTab = tabName),
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? colorScheme.primary : colorScheme.surface,
          foregroundColor:
              isActive ? colorScheme.onPrimary : colorScheme.primary,
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          side: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        child: Text(
          tabName,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTabContent() {
    switch (_currentTab) {
      case 'General':
        return GeneralTab(
          launchAtStartup: _launchAtStartup,
          autoHideEnabled: _autoHideEnabled,
          autoHideDuration: _autoHideDuration,
          keyboardLayoutName: _keyboardLayoutName,
          enableAdvancedSettings: _enableAdvancedSettings,
          useUserLayout: _useUserLayout,
          showAltLayout: _showAltLayout,
          kanataEnabled: _kanataEnabled,
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
          updateKeyboardLayoutName: (value) {
            setState(() => _keyboardLayoutName = value);
            _updateMainWindow('updateLayout', value);
          },
          updateEnableAdvancedSettings: (value) {
            setState(() => _enableAdvancedSettings = value);
            _updateMainWindow('updateEnableAdvancedSettings', value);
          },
          updateUseUserLayout: (value) {
            setState(() => _useUserLayout = value);
            _updateMainWindow('updateUseUserLayout', value);
          },
          updateShowAltLayout: (value) {
            setState(() => _showAltLayout = value);
            _updateMainWindow('updateShowAltLayout', value);
          },
          updateKanataEnabled: (value) {
            setState(() => _kanataEnabled = value);
            _updateMainWindow('updateKanataEnabled', value);
          },
        );
      case 'Appearance':
        return AppearanceTab(
          opacity: _opacity,
          keyColorPressed: _keyColorPressed,
          keyColorNotPressed: _keyColorNotPressed,
          markerColor: _markerColor,
          markerColorNotPressed: _markerColorNotPressed,
          markerOffset: _markerOffset,
          markerWidth: _markerWidth,
          markerHeight: _markerHeight,
          markerBorderRadius: _markerBorderRadius,
          showAltLayout: _showAltLayout,
          updateOpacity: (value) {
            setState(() => _opacity = value);
            _updateMainWindow('updateOpacity', value);
          },
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
      case 'Keyboard':
        return KeyboardTab(
          keymapStyle: _keymapStyle,
          showTopRow: _showTopRow,
          showGraveKey: _showGraveKey,
          keySize: _keySize,
          keyBorderRadius: _keyBorderRadius,
          keyPadding: _keyPadding,
          spaceWidth: _spaceWidth,
          splitWidth: _splitWidth,
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
        );
      case 'Text':
        return TextTab(
          fontFamily: _fontFamily,
          keyFontSize: _keyFontSize,
          spaceFontSize: _spaceFontSize,
          fontWeight: _fontWeight,
          keyTextColor: _keyTextColor,
          keyTextColorNotPressed: _keyTextColorNotPressed,
          updateFontFamily: (value) {
            setState(() => _fontFamily = value);
            _updateMainWindow('updateFontFamily', value);
          },
          updateKeyFontSize: (value) {
            setState(() => _keyFontSize = value);
            _updateMainWindow('updateKeyFontSize', value);
          },
          updateSpaceFontSize: (value) {
            setState(() => _spaceFontSize = value);
            _updateMainWindow('updateSpaceFontSize', value);
          },
          updateFontWeight: (value) {
            setState(() => _fontWeight = value);
            _updateMainWindow('updateFontWeight', value);
          },
          updateKeyTextColor: (value) {
            setState(() => _keyTextColor = value);
            _updateMainWindow('updateKeyTextColor', value);
          },
          updateKeyTextColorNotPressed: (value) {
            setState(() => _keyTextColorNotPressed = value);
            _updateMainWindow('updateKeyTextColorNotPressed', value);
          },
        );
      case 'About':
        return AboutTab(appVersion: _appVersion);
      case 'Hotkeys':
        return HotKeysTab(
          hotKeysEnabled: _hotKeysEnabled,
          visibilityHotKey: _visibilityHotKey,
          autoHideHotKey: _autoHideHotKey,
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
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
