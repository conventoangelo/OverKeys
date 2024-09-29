import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:overkeys/keyboard_layouts.dart';

class PreferencesWindow extends StatefulWidget {
  const PreferencesWindow({super.key, required this.windowController});

  final WindowController windowController;

  @override
  State<PreferencesWindow> createState() => _PreferencesWindowState();
}

class _PreferencesWindowState extends State<PreferencesWindow> {
  final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();

  String _currentTab = 'General';

  bool _openOnStartup = false;
  String _keyboardLayoutName = 'QWERTY';
  String _fontStyle = 'Geist Mono';
  double _keyFontSize = 20;
  double _spaceFontSize = 14;
  FontWeight _fontWeight = FontWeight.w600;
  Color _keyTextColor = Colors.white;
  Color _keyTextColorNotPressed = Colors.black;
  Color _keyColorPressed = const Color.fromARGB(255, 30, 30, 30);
  Color _keyColorNotPressed = const Color.fromARGB(255, 119, 171, 255);
  double _keySize = 60;
  double _spaceWidth = 40;
  double _opacity = 0.6;
  int _autoHideDuration = 2;

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
    String fontStyle = await asyncPrefs.getString('fontStyle') ?? 'Geist Mono';
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
    double spaceWidth = await asyncPrefs.getDouble('spaceWidth') ?? 320;
    double opacity = await asyncPrefs.getDouble('opacity') ?? 0.6;
    int autoHideDuration = await asyncPrefs.getInt('autoHideDuration') ?? 2;

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
      _spaceWidth = spaceWidth;
      _opacity = opacity;
      _autoHideDuration = autoHideDuration;
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
    await asyncPrefs.setDouble('spaceWidth', _spaceWidth);
    await asyncPrefs.setDouble('opacity', _opacity);
    await asyncPrefs.setInt('autoHideDuration', _autoHideDuration);
  }

  void _updateMainWindow(dynamic method, dynamic value) async {
    if (value is Color) {
      value = value.value;
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
        Locale('en', ''), // English, no country code
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
        children: ['General', 'Text', 'Keyboard', 'About']
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
            color: Color(0xFF3A3A4C), // Border color
            width: 2.0, // Border width
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
        _buildToggleOption('Open on system startup', _openOnStartup, (value) {
          setState(() => _openOnStartup = value);
          _savePreferences();
        }),
        _buildDropdownOption('Layout', _keyboardLayoutName,
            availableLayouts.map((layout) => (layout.name)).toList(), (value) {
          setState(() => _keyboardLayoutName = value!);
          _updateMainWindow('updateLayout', value);
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
        _buildDropdownOption(
            'Font style', _fontStyle, ['Geist Mono', 'Arial', 'Manrope'],
            (value) {
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
            _fontWeight == FontWeight.normal
                ? 'Normal'
                : _fontWeight == FontWeight.w500
                    ? 'Medium'
                    : _fontWeight == FontWeight.w600
                        ? 'SemiBold'
                        : 'Bold',
            ['Normal', 'Medium', 'SemiBold', 'Bold'], (value) {
          setState(() {
            switch (value) {
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
            }
          });
          _updateMainWindow('updateFontWeight', _fontWeight);
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
        _buildSliderOption('Space width', _spaceWidth, 200, 600, 400, (value) {
          setState(() => _spaceWidth = value);
          _updateMainWindow('updateSpaceWidth', value);
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
        const Text('Version 0.1.0', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        const Text(
            'OverKeys is an open-source on-screen keyboard overlay for Windows designed to help you learn your next keyboard layout.',
            style: TextStyle(color: Colors.white)),
        const SizedBox(height: 16),
        const Text('© 2024 Angelo Convento',
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

  Widget _buildDropdownOption(String label, String value, List<String> options,
      Function(String?) onChanged) {
    return _buildOptionContainer(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white)),
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
          // Text(value.toString(), style: const TextStyle(color: Colors.grey)),
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
                          // ... other ColorPicker properties ...
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancel',
                              style: TextStyle(color: Colors.black)),
                          onPressed: () {
                            // Revert to original color
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