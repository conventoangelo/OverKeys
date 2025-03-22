import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';
import 'package:overkeys/models/user_config.dart';
import 'package:overkeys/models/keyboard_layouts.dart';
import 'package:overkeys/utils/theme_manager.dart';
import 'package:overkeys/services/config_service.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key, required this.windowController});

  final WindowController windowController;

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen>
    with WindowListener {
  final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();

  // UI state
  Brightness _brightness = Brightness.dark;
  String _currentTab = 'General';

  // General settings
  bool _launchAtStartup = false;
  bool _autoHideEnabled = false;
  double _autoHideDuration = 2.0;
  String _keyboardLayoutName = 'QWERTY';
  bool _showAdvancedSettings = false;
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

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _loadPreferences();
    _setupMethodHandler();
    _detectSystemTheme();
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

  @override
  void dispose() {
    _savePreferences();
    windowManager.removeListener(this);
    super.dispose();
  }

  void _setupMethodHandler() {
    DesktopMultiWindow.setMethodHandler((call, fromWindowId) async {
      if (call.method == 'updateAutoHideFromMainWindow' && mounted) {
        setState(() => _autoHideEnabled = call.arguments as bool);
        await asyncPrefs.setBool('autoHideEnabled', _autoHideEnabled);
      }
      return null;
    });
  }

  Future<void> _loadPreferences() async {
    // General settings
    bool launchAtStartup = await asyncPrefs.getBool('launchAtStartup') ?? false;
    bool autoHideEnabled = await asyncPrefs.getBool('autoHideEnabled') ?? false;
    double autoHideDuration =
        await asyncPrefs.getDouble('autoHideDuration') ?? 2.0;
    String keyboardLayoutName =
        await asyncPrefs.getString('layout') ?? 'QWERTY';
    bool showAdvancedSettings =
        await asyncPrefs.getBool('showAdvancedSettings') ?? false;
    bool useUserLayout = await asyncPrefs.getBool('useUserLayout') ?? false;
    bool showAltLayout = await asyncPrefs.getBool('showAltLayout') ?? false;
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
    bool showGraveKey = await asyncPrefs.getBool('showGraveKey') ?? false;
    double keySize = await asyncPrefs.getDouble('keySize') ?? 48;
    double keyBorderRadius =
        await asyncPrefs.getDouble('keyBorderRadius') ?? 12;
    double keyPadding = await asyncPrefs.getDouble('keyPadding') ?? 3;
    double spaceWidth = await asyncPrefs.getDouble('spaceWidth') ?? 320;
    double splitWidth = await asyncPrefs.getDouble('splitWidth') ?? 100;

    // Text settings
    String fontFamily = await asyncPrefs.getString('fontFamily') ?? 'GeistMono';
    double keyFontSize = await asyncPrefs.getDouble('keyFontSize') ?? 20;
    double spaceFontSize = await asyncPrefs.getDouble('spaceFontSize') ?? 14;
    FontWeight fontWeight = FontWeight
        .values[await asyncPrefs.getInt('fontWeight') ?? FontWeight.w500.index];
    Color keyTextColor =
        Color(await asyncPrefs.getInt('keyTextColor') ?? 0xFFFFFFFF);
    Color keyTextColorNotPressed =
        Color(await asyncPrefs.getInt('keyTextColorNotPressed') ?? 0xFF000000);

    setState(() {
      // General settings
      _launchAtStartup = launchAtStartup;
      _autoHideEnabled = autoHideEnabled;
      _autoHideDuration = autoHideDuration;
      _keyboardLayoutName = keyboardLayoutName;
      _showAdvancedSettings = showAdvancedSettings;
      _useUserLayout = useUserLayout;
      _showAltLayout = showAltLayout;
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
      _showGraveKey = showGraveKey;
      _keySize = keySize;
      _keyBorderRadius = keyBorderRadius;
      _keyPadding = keyPadding;
      _spaceWidth = spaceWidth;
      _splitWidth = splitWidth;

      // Text settings
      _fontFamily = fontFamily;
      _keyFontSize = keyFontSize;
      _spaceFontSize = spaceFontSize;
      _fontWeight = fontWeight;
      _keyTextColor = keyTextColor;
      _keyTextColorNotPressed = keyTextColorNotPressed;
    });
  }

  Future<void> _savePreferences() async {
    // General settings
    await asyncPrefs.setBool('launchAtStartup', _launchAtStartup);
    await asyncPrefs.setBool('autoHideEnabled', _autoHideEnabled);
    await asyncPrefs.setDouble('autoHideDuration', _autoHideDuration);
    await asyncPrefs.setString('layout', _keyboardLayoutName);
    await asyncPrefs.setBool('showAdvancedSettings', _showAdvancedSettings);
    await asyncPrefs.setBool('useUserLayout', _useUserLayout);
    await asyncPrefs.setBool('showAltLayout', _showAltLayout);
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
    await asyncPrefs.setBool('showGraveKey', _showGraveKey);
    await asyncPrefs.setDouble('keySize', _keySize);
    await asyncPrefs.setDouble('keyBorderRadius', _keyBorderRadius);
    await asyncPrefs.setDouble('keyPadding', _keyPadding);
    await asyncPrefs.setDouble('spaceWidth', _spaceWidth);
    await asyncPrefs.setDouble('splitWidth', _splitWidth);

    // Text settings
    await asyncPrefs.setString('fontFamily', _fontFamily);
    await asyncPrefs.setDouble('keyFontSize', _keyFontSize);
    await asyncPrefs.setDouble('spaceFontSize', _spaceFontSize);
    await asyncPrefs.setInt('fontWeight', _fontWeight.index);
    await asyncPrefs.setInt('keyTextColor', _keyTextColor.toARGB32());
    await asyncPrefs.setInt(
        'keyTextColorNotPressed', _keyTextColorNotPressed.toARGB32());
  }

  void _updateMainWindow(dynamic method, dynamic value) async {
    if (value is Color) {
      value = value.toARGB32();
    } else if (value is FontWeight) {
      value = value.index;
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
        children: ['General', 'Appearance', 'Keyboard', 'Text', 'About']
            .map((tab) => _buildTabButton(tab))
            .toList(),
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
        return _buildGeneralTab();
      case 'Appearance':
        return _buildAppearanceTab();
      case 'Text':
        return _buildTextTab();
      case 'Keyboard':
        return _buildKeyboardTab();
      case 'About':
        return _buildAboutTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildGeneralTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildSectionTitle('General Settings'),
        _buildToggleOption('Open on system startup', _launchAtStartup, (value) {
          setState(() => _launchAtStartup = value);
          _updateMainWindow('updateLaunchAtStartup', value);
        }),
        _buildToggleOption('Auto-hide keyboard', _autoHideEnabled, (value) {
          setState(() => _autoHideEnabled = value);
          _updateMainWindow('updateAutoHideEnabled', value);
        }),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          firstChild: const SizedBox.shrink(),
          secondChild: _buildSliderOption(
              'Auto-hide duration (seconds)', _autoHideDuration, 0.5, 5.0, 9,
              (value) {
            double roundedValue = (value * 2).round() / 2;
            setState(() => _autoHideDuration = roundedValue);
            _updateMainWindow('updateAutoHideDuration', roundedValue);
          }, valueDisplayFormatter: (value) => value.toStringAsFixed(1)),
          crossFadeState: _autoHideEnabled
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          sizeCurve: Curves.easeInOut,
        ),
        _buildDropdownOption('Layout', _keyboardLayoutName,
            availableLayouts.map((layout) => (layout.name)).toList(),
            subtitle: _autoHideEnabled
                ? 'OverKeys must remain visible to avoid losing focus when typing in the dropdown. You may turn off auto-hide under General settings.'
                : null, (value) {
          setState(() => _keyboardLayoutName = value!);
          _updateMainWindow('updateLayout', value);
        }),
        _buildToggleOption('Show advanced settings', _showAdvancedSettings,
            (value) {
          setState(() => _showAdvancedSettings = value);
          _savePreferences();
        }),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: [
              _buildToggleOption(
                  'Use custom layout from config', _useUserLayout,
                  subtitle:
                      'Sets layout to user-defined defaultUserLayout. Make sure that the layout is saved in the config file.',
                  (value) {
                if (value && _kanataEnabled) {
                  // If turning on useUserLayout, turn off kanataEnabled
                  setState(() {
                    _useUserLayout = value;
                    _kanataEnabled = false;
                  });
                  _updateMainWindow('updateKanataEnabled', false);
                } else {
                  setState(() => _useUserLayout = value);
                }
                _updateMainWindow('updateUseUserLayout', value);
              }),
              _buildToggleOption('Show alternative layout', _showAltLayout,
                  (value) {
                setState(() => _showAltLayout = value);
                _updateMainWindow('updateShowAltLayout', value);
              }),
              _buildToggleOption('Connect to Kanata', _kanataEnabled,
                  subtitle:
                      'Make sure that Kanata and OverKeys are using the same port. Restart OverKeys if config file changes were made to apply changes.',
                  (value) {
                if (value && _useUserLayout) {
                  // If turning on kanataEnabled, turn off useUserLayout
                  setState(() {
                    _kanataEnabled = value;
                    _useUserLayout = false;
                  });
                  _updateMainWindow('updateUseUserLayout', false);
                } else {
                  setState(() => _kanataEnabled = value);
                }
                _updateMainWindow('updateKanataEnabled', value);
              }),
              _buildOpenConfigButton(),
            ],
          ),
          crossFadeState: _showAdvancedSettings
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          sizeCurve: Curves.easeInOut,
        ),
      ],
    );
  }

  Widget _buildAppearanceTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildSectionTitle('Appearance Settings'),
        _buildSliderOption('Opacity', _opacity, 0.1, 1.0, 18, (value) {
          setState(() => _opacity = value);
          _updateMainWindow('updateOpacity', value);
        }),
        _buildColorOption('Key color (pressed)', _keyColorPressed, (color) {
          setState(() => _keyColorPressed = color);
          _updateMainWindow('updateKeyColorPressed', color);
        }),
        _buildColorOption('Key color (not pressed)', _keyColorNotPressed,
            (color) {
          setState(() => _keyColorNotPressed = color);
          _updateMainWindow('updateKeyColorNotPressed', color);
        }),
        _buildSectionTitle('Tactile Markers'),
        _buildColorOption('Marker color (pressed)', _markerColor, (color) {
          setState(() => _markerColor = color);
          _updateMainWindow('updateMarkerColor', color);
        }),
        _buildColorOption('Marker color (not pressed)', _markerColorNotPressed,
            (color) {
          setState(() => _markerColorNotPressed = color);
          _updateMainWindow('updateMarkerColorNotPressed', color);
        }),
        _buildSliderOption('Marker offset', _markerOffset, 0, 20, 20, (value) {
          setState(() => _markerOffset = value);
          _updateMainWindow('updateMarkerOffset', value);
        }),
        _buildSliderOption('Marker width', _markerWidth, 0, 20, 20,
            subtitle: _showAltLayout
                ? 'When alternative layout is shown, marker width appear at half the size (width × 0.5)'
                : null, (value) {
          setState(() => _markerWidth = value);
          _updateMainWindow('updateMarkerWidth', value);
        }),
        _buildSliderOption('Marker height', _markerHeight, 0, 10, 10,
            subtitle: _showAltLayout
                ? 'When alternative layout is shown, marker height is not used and instead equals the marker width after computation'
                : null, (value) {
          setState(() => _markerHeight = value);
          _updateMainWindow('updateMarkerHeight', value);
        }),
        _buildSliderOption(
            'Marker border radius', _markerBorderRadius, 0, 10, 10, (value) {
          setState(() => _markerBorderRadius = value);
          _updateMainWindow('updateMarkerBorderRadius', value);
        }),
      ],
    );
  }

  Widget _buildKeyboardTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildSectionTitle('Keyboard Layout'),
        _buildDropdownOption('Keymap style', _keymapStyle,
            ['Staggered', 'Matrix', 'Split Matrix'], (value) {
          if (value == 'Split Matrix' && _spaceWidth > 300) {
            _updateMainWindow('updateSpaceWidth', 220.0);
            setState(() => _spaceWidth = 220);
          }
          setState(() => _keymapStyle = value!);
          _updateMainWindow('updateKeymapStyle', value);
        }),
        _buildToggleOption('Show top row', _showTopRow,
            subtitle:
                'Recommended to toggle when keyboard is visible or auto-hide is off. Toggling while hidden may cause rendering errors.',
            (value) {
          setState(() => _showTopRow = value);
          _updateMainWindow('updateShowTopRow', value);
        }),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          firstChild: const SizedBox.shrink(),
          secondChild:
              _buildToggleOption('Show grave key', _showGraveKey, (value) {
            setState(() => _showGraveKey = value);
            _updateMainWindow('updateShowGraveKey', value);
          }),
          crossFadeState: _showTopRow
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          sizeCurve: Curves.easeInOut,
        ),
        _buildSectionTitle('Key Dimensions'),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          firstChild: const SizedBox.shrink(),
          secondChild: _buildSliderOption(
              'Split width', _splitWidth, 30, 200, 34, (value) {
            setState(() => _splitWidth = value);
            _updateMainWindow('updateSplitWidth', value);
          }),
          crossFadeState: _keymapStyle == 'Split Matrix'
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          sizeCurve: Curves.easeInOut,
        ),
        _buildSliderOption('Key size', _keySize, 40, 60, 40, (value) {
          setState(() => _keySize = value);
          _updateMainWindow('updateKeySize', value);
        }),
        _buildSliderOption('Key border radius', _keyBorderRadius, 0, 30, 30,
            (value) {
          setState(() => _keyBorderRadius = value);
          _updateMainWindow('updateKeyBorderRadius', value);
        }),
        _buildSliderOption('Key padding', _keyPadding, 0, 10, 20, (value) {
          setState(() => _keyPadding = value);
          _updateMainWindow('updateKeyPadding', value);
        }),
        _buildSliderOption(
            'Space width',
            _spaceWidth,
            120,
            (_keymapStyle == 'Split Matrix') ? 300 : 500,
            (_keymapStyle == 'Split Matrix') ? 90 : 190, (value) {
          setState(() => _spaceWidth = value);
          _updateMainWindow('updateSpaceWidth', value);
        }),
      ],
    );
  }

  Widget _buildTextTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildSectionTitle('Text Settings'),
        _buildDropdownOption('Font style', _fontFamily, [
          'Berkeley Mono',
          'Cascadia Mono',
          'Comic Mono',
          'CommitMono',
          'Consolas',
          'Courier',
          'Cousine',
          'Dank Mono',
          'DM Mono',
          'Droid Sans Mono',
          'Fira Code',
          'Fira Mono',
          'Geist',
          'GeistMono',
          'Google Sans',
          'Hack',
          'IBM Plex Mono',
          'Inconsolata',
          'Input',
          'Inter',
          'Iosevka',
          'JetBrains Mono',
          'Manrope',
          'Meslo',
          'Monaspace Argon',
          'Monaspace Krypton',
          'Monaspace Neon',
          'Monaspace Radon',
          'Monaspace Xenon',
          'Monocraft',
          'MonoLisa',
          'mononoki',
          'Montserrat',
          'Nunito',
          'Poppins',
          'Roboto',
          'Roboto Mono',
          'Source Code Pro',
          'Source Sans Pro',
          'Ubuntu',
          'Ubuntu Mono',
          'Victor Mono',
        ], (value) {
          setState(() => _fontFamily = value!);
          _updateMainWindow('updateFontFamily', value);
        },
            subtitle:
                'Make sure that the font is installed in your system. Falls back to Geist Mono.${_autoHideEnabled ? ' OverKeys must remain visible to avoid losing focus when typing in the dropdown. You may turn off auto-hide under General settings.' : ''}'),
        _buildSliderOption('Key font size', _keyFontSize, 12, 32, 40, (value) {
          setState(() => _keyFontSize = value);
          _updateMainWindow('updateKeyFontSize', value);
        }),
        _buildSliderOption('Space font size', _spaceFontSize, 12, 32, 40,
            (value) {
          setState(() => _spaceFontSize = value);
          _updateMainWindow('updateSpaceFontSize', value);
        }),
        _buildDropdownOption(
            'Font weight',
            _fontWeight == FontWeight.w100
                ? 'Thin'
                : _fontWeight == FontWeight.w200
                    ? 'ExtraLight'
                    : _fontWeight == FontWeight.w300
                        ? 'Light'
                        : _fontWeight == FontWeight.normal
                            ? 'Normal'
                            : _fontWeight == FontWeight.w500
                                ? 'Medium'
                                : _fontWeight == FontWeight.w600
                                    ? 'SemiBold'
                                    : _fontWeight == FontWeight.bold
                                        ? 'Bold'
                                        : _fontWeight == FontWeight.w800
                                            ? 'ExtraBold'
                                            : 'Black',
            [
              'Thin',
              'ExtraLight',
              'Light',
              'Normal',
              'Medium',
              'SemiBold',
              'Bold',
              'ExtraBold',
              'Black'
            ],
            subtitle: _autoHideEnabled
                ? 'OverKeys must remain visible to avoid losing focus when typing in the dropdown. You may turn off auto-hide under General settings.'
                : null, (value) {
          setState(() {
            switch (value) {
              case 'Thin':
                _fontWeight = FontWeight.w100;
                break;
              case 'ExtraLight':
                _fontWeight = FontWeight.w200;
                break;
              case 'Light':
                _fontWeight = FontWeight.w300;
                break;
              case 'Normal':
                _fontWeight = FontWeight.normal;
                break;
              case 'Medium':
                _fontWeight = FontWeight.w500;
                break;
              case 'SemiBold':
                _fontWeight = FontWeight.w600;
                break;
              case 'Bold':
                _fontWeight = FontWeight.bold;
                break;
              case 'ExtraBold':
                _fontWeight = FontWeight.w800;
                break;
              case 'Black':
                _fontWeight = FontWeight.w900;
                break;
            }
          });
          _updateMainWindow('updateFontWeight', _fontWeight.index);
        }),
        _buildColorOption('Text color (pressed)', _keyTextColor, (color) {
          setState(() => _keyTextColor = color);
          _updateMainWindow('updateKeyTextColor', color);
        }),
        _buildColorOption('Text color (not pressed)', _keyTextColorNotPressed,
            (color) {
          setState(() => _keyTextColorNotPressed = color);
          _updateMainWindow('updateKeyTextColorNotPressed', color);
        }),
      ],
    );
  }

  Widget _buildAboutTab() {
    final colorScheme = ThemeManager.getTheme(_brightness).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildSectionTitle('About'),
          const SizedBox(height: 20),
          Image.asset('assets/images/app_icon.png', width: 120),
          const SizedBox(height: 20),
          Text('OverKeys',
              style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 28,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),
          Text('Version: 0.2.3-alpha.1',
              style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Text('© 2024 Angelo Convento',
              style: TextStyle(
                  color: colorScheme.onSurface.withAlpha(153),
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () async {
              await launchUrl(
                  Uri.parse('https://github.com/conventoangelo/overkeys'),
                  mode: LaunchMode.externalApplication);
            },
            icon: ImageIcon(
              AssetImage('assets/images/github-mark.png'),
              size: 20,
            ),
            label: Text(
              'View on GitHub',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final colorScheme = ThemeManager.getTheme(_brightness).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildToggleOption(String label, bool value, Function(bool) onChanged,
      {String? subtitle}) {
    final colorScheme = ThemeManager.getTheme(_brightness).colorScheme;
    const WidgetStateProperty<Icon> thumbIcon =
        WidgetStateProperty<Icon>.fromMap(
      <WidgetStatesConstraint, Icon>{
        WidgetState.selected: Icon(Icons.check),
        WidgetState.any: Icon(Icons.close),
      },
    );
    return _buildOptionContainer(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 16)),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                        color: colorScheme.onSurface.withAlpha(153),
                        fontSize: 14.0),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            thumbIcon: thumbIcon,
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownOption(String label, String value, List<String> options,
      Function(String?) onChanged,
      {String? subtitle}) {
    final colorScheme = ThemeManager.getTheme(_brightness).colorScheme;
    final TextEditingController controller = TextEditingController(text: value);

    return _buildOptionContainer(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 16)),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                        color: colorScheme.onSurface.withAlpha(153),
                        fontSize: 14.0),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 40),
          DropdownMenu<String>(
            controller: controller,
            initialSelection: value,
            requestFocusOnTap: true,
            enableFilter: true,
            width: 210,
            menuHeight: 300,
            dropdownMenuEntries: options
                .map((String option) => DropdownMenuEntry<String>(
                      value: option,
                      label: option,
                      style: MenuItemButton.styleFrom(
                        textStyle: TextStyle(
                          fontFamily: option,
                          fontFamilyFallback: const ['Manrope'],
                          fontSize: 15,
                        ),
                      ),
                    ))
                .toList(),
            onSelected: (String? newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
            textStyle: TextStyle(
              fontFamily: value,
              fontFamilyFallback: const ['Manrope'],
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenConfigButton() {
    final colorScheme = ThemeManager.getTheme(_brightness).colorScheme;

    return _buildOptionContainer(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Open config file',
                    style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 16)),
                Text(
                  'Turn related advanced setting off then on again to apply changes',
                  style: TextStyle(
                      color: colorScheme.onSurface.withAlpha(153),
                      fontSize: 14.0),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            icon: Icon(Icons.file_open, color: colorScheme.primary),
            label: Text('Open',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                )),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.surfaceContainerHighest,
              elevation: 2,
              minimumSize: const Size(100, 45),
              side: BorderSide(color: colorScheme.primary),
            ),
            onPressed: () async {
              try {
                final configService = ConfigService();
                final configPath = await configService.configPath;
                final file = File(configPath);

                if (await file.exists()) {
                  Process.start('cmd.exe', ['/c', 'start', '', configPath]);
                } else {
                  await configService.saveConfig(UserConfig());
                  Process.start('cmd.exe', ['/c', 'start', '', configPath]);
                }
              } catch (e) {
                debugPrint('Error opening config file: $e');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSliderOption(String label, double value, double min, double max,
      int divisions, Function(double) onChanged,
      {String Function(double)? valueDisplayFormatter, String? subtitle}) {
    final colorScheme = ThemeManager.getTheme(_brightness).colorScheme;
    return _buildOptionContainer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 16)),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
              child: Text(
                subtitle,
                style: TextStyle(
                    color: colorScheme.onSurface.withAlpha(153),
                    fontSize: 14.0),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            )
          else
            const SizedBox(height: 8.0),
          Slider(
            value: value,
            min: min,
            divisions: divisions,
            label: valueDisplayFormatter != null
                ? valueDisplayFormatter(value)
                : value.toStringAsFixed(2),
            max: max,
            onChanged: (value) {
              final Map<String, Function(double)> updates = {
                'Key font size': (v) => _keyFontSize = v,
                'Space font size': (v) => _spaceFontSize = v,
                'Key size': (v) => _keySize = v,
                'Key border radius': (v) => _keyBorderRadius = v,
                'Key padding': (v) => _keyPadding = v,
                'Space width': (v) => _spaceWidth = v,
                'Split width': (v) => _splitWidth = v,
                'Opacity': (v) => _opacity = v,
                'Auto-hide duration (seconds)': (v) =>
                    _autoHideDuration = (v * 2).round() / 2,
                'Marker offset': (v) => _markerOffset = v,
                'Marker width': (v) => _markerWidth = v,
                'Marker height': (v) => _markerHeight = v,
                'Marker border radius': (v) => _markerBorderRadius = v,
              };
              setState(() {
                updates[label]?.call(value);
              });
            },
            onChangeEnd: onChanged,
            // ignore: deprecated_member_use
            year2023: false,
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption(
      String label, Color currentColor, Function(Color) onColorChanged) {
    final colorScheme = ThemeManager.getTheme(_brightness).colorScheme;

    return _buildOptionContainer(
      Builder(builder: (context) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 16)),
            ColorIndicator(
              width: 44,
              height: 44,
              borderRadius: 11,
              color: currentColor,
              onSelectFocus: false,
              onSelect: () async {
                final Color? newColor = await showDialog<Color>(
                  context: context,
                  builder: (BuildContext context) {
                    Color pickerColor = currentColor;
                    return AlertDialog(
                      backgroundColor: colorScheme.surface,
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          wheelDiameter: 250,
                          wheelWidth: 22,
                          wheelSquarePadding: 4,
                          wheelSquareBorderRadius: 16,
                          wheelHasBorder: true,
                          color: pickerColor,
                          onColorChanged: (Color color) {
                            pickerColor = color;
                          },
                          heading: Text(
                            'Select color',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                            ),
                          ),
                          showColorName: true,
                          showColorCode: true,
                          copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                            copyButton: true,
                            pasteButton: true,
                            ctrlC: true,
                            ctrlV: true,
                          ),
                          colorNameTextStyle:
                              TextStyle(color: colorScheme.onSurface),
                          colorCodeTextStyle:
                              TextStyle(color: colorScheme.onSurface),
                          pickersEnabled: const <ColorPickerType, bool>{
                            ColorPickerType.primary: false,
                            ColorPickerType.accent: false,
                            ColorPickerType.wheel: true,
                          },
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Cancel',
                              style: TextStyle(color: colorScheme.primary)),
                          onPressed: () {
                            onColorChanged(currentColor);
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text('OK',
                              style: TextStyle(color: colorScheme.primary)),
                          onPressed: () {
                            Navigator.of(context).pop(pickerColor);
                          },
                        ),
                      ],
                    );
                  },
                );
                if (newColor != null) {
                  onColorChanged(newColor);
                }
              },
            ),
          ],
        );
      }),
    );
  }

  Widget _buildOptionContainer(Widget child) {
    final colorScheme = ThemeManager.getTheme(_brightness).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
