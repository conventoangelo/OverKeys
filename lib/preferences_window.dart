import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:overkeys/keyboard_layouts.dart';

class PreferencesWindow extends StatefulWidget {
  const PreferencesWindow({super.key, required this.windowController});

  final WindowController windowController;

  @override
  State<PreferencesWindow> createState() => _PreferencesWindowState();
}

class _PreferencesWindowState extends State<PreferencesWindow> {
  @override
  void initState() {
    super.initState();
  }

  String _currentTab = 'General';
  bool _openOnStartup = false;
  String _layout = 'Canary';
  String _fontStyle = 'Geist Mono';
  double _fontSize = 18;
  FontWeight _fontWeight = FontWeight.normal;
  Color _fontColor = Colors.white;
  Color _keyColorPressed = const Color.fromARGB(255, 30, 30, 30);
  Color _keyColorNotPressed = const Color.fromARGB(255, 119, 171, 255);
  double _keySize = 60;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Manrope',
      ),
      home: Scaffold(
        backgroundColor: const Color(0xFF1E1E2E),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E1E2E),
          toolbarHeight: 100,
          title: const Padding(
            padding: EdgeInsets.all(80),
            child: Text('Preferences',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 80.0),
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
      ),
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
        _buildToggleOption('Open on system startup', _openOnStartup,
            (value) => setState(() => _openOnStartup = value)),
        _buildDropdownOption(
            'Layout',
            _layout,
            availableLayouts.map((layout) => (layout.name)).toList(),
            (value) => setState(() => _layout = value!)),
      ],
    );
  }

  Widget _buildTextTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Text Settings'),
        _buildDropdownOption(
            'Font style',
            _fontStyle,
            ['GeistMono', 'Arial', 'Manrope'],
            (value) => setState(() => _fontStyle = value!)),
        _buildSliderOption('Font size', _fontSize, 12, 32,
            (value) => setState(() => _fontSize = value)),
        _buildDropdownOption(
            'Font weight',
            _fontWeight == FontWeight.normal ? 'Normal' : 'Bold',
            ['Normal', 'Bold'],
            (value) => setState(() => _fontWeight =
                value == 'Normal' ? FontWeight.normal : FontWeight.bold)),
        _buildColorPicker('Font color', _fontColor,
            (color) => setState(() => _fontColor = color)),
      ],
    );
  }

  Widget _buildKeyboardTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Keyboard Settings'),
        _buildColorPicker('Key color (pressed)', _keyColorPressed,
            (color) => setState(() => _keyColorPressed = color)),
        _buildColorPicker('Key color (not pressed)', _keyColorNotPressed,
            (color) => setState(() => _keyColorNotPressed = color)),
        _buildSliderOption('Key size', _keySize, 40, 80,
            (value) => setState(() => _keySize = value)),
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
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderOption(String label, double value, double min, double max,
      Function(double) onChanged) {
    return _buildOptionContainer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white)),
          Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
            activeColor: Colors.green,
          ),
          Text(value.round().toString(),
              style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildColorPicker(
      String label, Color currentColor, Function(Color) onColorChanged) {
    return _buildOptionContainer(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white)),
          GestureDetector(
            onTap: () =>
                _showColorPicker(context, currentColor, onColorChanged),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: currentColor,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
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

  void _showColorPicker(BuildContext context, Color currentColor,
      Function(Color) onColorChanged) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: onColorChanged,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
