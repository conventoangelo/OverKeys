import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:overkeys/utils/keyboard_layouts.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key, required this.windowController});

  final WindowController windowController;

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();

  String _currentTab = 'General';

  String _keyboardLayoutName = 'QWERTY';
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
  String _keymapStyle = 'ANSI';
  double _splitWidth = 100;
  double _opacity = 0.6;
  int _autoHideDuration = 2;
  bool _launchAtStartup = false;

  @override
  void initState() {
    super.initState();
    // asyncPrefs.clear();
    _loadPreferences();
  }

  @override
  void dispose() {
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
    String keymapStyle = await asyncPrefs.getString('keymapStyle') ?? 'ANSI';
    double splitWidth = await asyncPrefs.getDouble('splitWidth') ?? 100;
    double opacity = await asyncPrefs.getDouble('opacity') ?? 0.6;
    int autoHideDuration = await asyncPrefs.getInt('autoHideDuration') ?? 2;
    bool launchAtStartup = await asyncPrefs.getBool('launchAtStartup') ?? false;

    setState(() {
      _keyboardLayoutName = keyboardLayoutName;
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
      _launchAtStartup = launchAtStartup;
    });
  }

  Future<void> _savePreferences() async {
    await asyncPrefs.setString('layout', _keyboardLayoutName);
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
    await asyncPrefs.setBool('launchAtStartup', _launchAtStartup);
  }

  void _updateMainWindow(dynamic method, dynamic value) async {
    if (value is Color) {
      value = value.value;
    } else if (value is FontWeight) {
      value = value.index;
    }
    await DesktopMultiWindow.invokeMethod(0, method, value);
    _savePreferences();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Manrope',
      ),
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
          backgroundColor: const Color(0xFF1E1E2E),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1E1E2E),
            toolbarHeight: 100,
            title: const Padding(
              padding: EdgeInsets.all(100),
              child: Text('Preferences',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100.0),
            child: Column(
              children: [
                _buildTabBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                    child: _buildCurrentTabContent(),
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

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: ['General', 'Text', 'Keyboard', 'Tactile Markers', 'About']
            .map((tab) => _buildTabButton(tab))
            .toList(),
      ),
    );
  }

  Widget _buildTabButton(String tabName) {
    bool isActive = _currentTab == tabName;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ElevatedButton(
        onPressed: () => setState(() => _currentTab = tabName),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isActive ? const Color(0xFF3A3A4C) : Colors.transparent,
          foregroundColor: isActive ? Colors.white : const Color(0xFF3A3A4C),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          side: const BorderSide(
            color: Color(0xFF3A3A4C),
            width: 2.0,
          ),
        ),
        child: Text(tabName),
      ),
    );
  }

  Widget _buildCurrentTabContent() {
    switch (_currentTab) {
      case 'General':
        return _buildGeneralTab();
      case 'Text':
        return _buildTextTab();
      case 'Keyboard':
        return _buildKeyboardTab();
      case 'Tactile Markers':
        return _buildTactileMarkersTab();
      case 'About':
        return _buildAboutTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildGeneralTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('General Settings'),
        _buildToggleOption('Open on system startup', _launchAtStartup, (value) {
          setState(() => _launchAtStartup = value);
          _updateMainWindow('updateLaunchAtStartup', value);
        }),
        _buildDropdownOption('Layout', _keyboardLayoutName,
            availableLayouts.map((layout) => (layout.name)).toList(), (value) {
          setState(() => _keyboardLayoutName = value!);
          _updateMainWindow('updateLayout', value);
        }),
        _buildDropdownOption(
            'Keymap style', _keymapStyle, ['ANSI', 'Matrix', 'Split Matrix'],
            (value) {
          if (value == 'Split Matrix' && _spaceWidth > 300) {
            _updateMainWindow('updateSpaceWidth', 220.0);
            setState(() => _spaceWidth = 220);
          }
          setState(() => _keymapStyle = value!);
          _updateMainWindow('updateKeymapStyle', value);
        }),
        _buildSliderOption('Opacity', _opacity, 0.1, 1.0, 18, (value) {
          setState(() => _opacity = value);
          _updateMainWindow('updateOpacity', value);
        }),
        _buildSliderOption(
            'Auto-hide duration', _autoHideDuration.toDouble(), 1.0, 10.0, 9,
            (value) {
          setState(() => _autoHideDuration = value.round());
          _updateMainWindow('updateAutoHideDuration', value.round());
        }),
      ],
    );
  }

  Widget _buildTextTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Text Settings'),
        _buildDropdownOptionWithSubtitle(
            'Font style',
            'Make sure that the font is installed in your system. Falls back to Geist Mono',
            _fontStyle, [
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
          setState(() => _fontStyle = value!);
          _updateMainWindow('updateFontStyle', value);
        }),
        _buildSliderOption('Font size', _keyFontSize, 12, 32, 40, (value) {
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
            ], (value) {
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

  Widget _buildKeyboardTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Keyboard Settings'),
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
        if (_keymapStyle == 'Split Matrix')
          _buildSliderOption('Split width', _splitWidth, 30, 200, 34, (value) {
            setState(() => _splitWidth = value);
            _updateMainWindow('updateSplitWidth', value);
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
      ],
    );
  }

  Widget _buildTactileMarkersTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Tactile Markers Settings'),
        _buildColorOption('Marker color', _markerColor, (color) {
          setState(() => _markerColor = color);
          _updateMainWindow('updateMarkerColor', color);
        }),
        _buildSliderOption('Marker offset', _markerOffset, 0, 20, 20, (value) {
          setState(() => _markerOffset = value);
          _updateMainWindow('updateMarkerOffset', value);
        }),
        _buildSliderOption('Marker width', _markerWidth, 0, 20, 20, (value) {
          setState(() => _markerWidth = value);
          _updateMainWindow('updateMarkerWidth', value);
        }),
        _buildSliderOption('Marker height', _markerHeight, 0, 10, 10, (value) {
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

  Widget _buildAboutTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('About'),
        const Text('OverKeys',
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Version 0.1.1', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        const Text(
            'OverKeys is an open-source, customizable on-screen keyboard for Windows. Learn and practice alternative layouts, personalize appearance, and improve your typing.',
            style: TextStyle(color: Colors.white)),
        const SizedBox(height: 16),
        const Text('© 2024 Angelo Convento. All rights reserved.',
            style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(title,
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildToggleOption(
      String label, bool value, Function(bool) onChanged) {
    return _buildOptionContainer(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownOptionWithSubtitle(String label, String subtitle,
      String value, List<String> options, Function(String?) onChanged) {
    return _buildOptionContainer(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white)),
              Text(subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 13.0)),
            ],
          ),
          DropdownButton<String>(
            value: value,
            items: options
                .map((String option) => DropdownMenuItem<String>(
                    value: option, child: Text(option)))
                .toList(),
            onChanged: onChanged,
            dropdownColor: const Color(0xFF2A2A3C),
            style: const TextStyle(color: Colors.white, fontFamily: 'Manrope'),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownOption(String label, String value, List<String> options,
      Function(String?) onChanged) {
    return _buildOptionContainer(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white)),
            ],
          ),
          DropdownButton<String>(
            value: value,
            items: options
                .map((String option) => DropdownMenuItem<String>(
                    value: option, child: Text(option)))
                .toList(),
            onChanged: onChanged,
            dropdownColor: const Color(0xFF2A2A3C),
            style: const TextStyle(color: Colors.white, fontFamily: 'Manrope'),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderOption(String label, double value, double min, double max,
      int divisions, Function(double) onChanged) {
    return _buildOptionContainer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white)),
          Slider(
            value: value,
            min: min,
            divisions: divisions,
            label: value.toStringAsFixed(2),
            max: max,
            onChanged: onChanged,
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionContainer(Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _buildColorOption(
      String label, Color currentColor, Function(Color) onColorChanged) {
    return _buildOptionContainer(
      Builder(builder: (context) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white)),
            ColorIndicator(
              width: 44,
              height: 44,
              borderRadius: 11,
              borderColor: Colors.white,
              hasBorder: true,
              color: currentColor,
              onSelectFocus: false,
              onSelect: () async {
                final Color? newColor = await showDialog<Color>(
                  context: context,
                  builder: (BuildContext context) {
                    Color pickerColor = currentColor;
                    return AlertDialog(
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
                            style: Theme.of(context).textTheme.titleSmall,
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
                              Theme.of(context).textTheme.bodySmall,
                          colorCodeTextStyle:
                              Theme.of(context).textTheme.bodySmall,
                          pickersEnabled: const <ColorPickerType, bool>{
                            ColorPickerType.primary: false,
                            ColorPickerType.accent: false,
                            ColorPickerType.wheel: true,
                          },
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancel',
                              style: TextStyle(color: Colors.black)),
                          onPressed: () {
                            onColorChanged(currentColor);
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text('OK',
                              style: TextStyle(color: Colors.black)),
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
}
