import 'package:flutter/material.dart';
import 'package:overkeys/widgets/preferences/preference_option_widgets.dart';

class KeyboardTab extends StatefulWidget {
  final String keymapStyle;
  final bool showTopRow;
  final bool showGraveKey;
  final double keySize;
  final double keyBorderRadius;
  final double keyPadding;
  final double spaceWidth;
  final double splitWidth;
  final Function(String) updateKeymapStyle;
  final Function(bool) updateShowTopRow;
  final Function(bool) updateShowGraveKey;
  final Function(double) updateKeySize;
  final Function(double) updateKeyBorderRadius;
  final Function(double) updateKeyPadding;
  final Function(double) updateSpaceWidth;
  final Function(double) updateSplitWidth;

  const KeyboardTab({
    super.key,
    required this.keymapStyle,
    required this.showTopRow,
    required this.showGraveKey,
    required this.keySize,
    required this.keyBorderRadius,
    required this.keyPadding,
    required this.spaceWidth,
    required this.splitWidth,
    required this.updateKeymapStyle,
    required this.updateShowTopRow,
    required this.updateShowGraveKey,
    required this.updateKeySize,
    required this.updateKeyBorderRadius,
    required this.updateKeyPadding,
    required this.updateSpaceWidth,
    required this.updateSplitWidth,
  });

  @override
  State<KeyboardTab> createState() => _KeyboardTabState();
}

class _KeyboardTabState extends State<KeyboardTab> {
  late double _localSpaceWidth;
  late double _localKeySize;
  late double _localKeyBorderRadius;
  late double _localKeyPadding;
  late double _localSplitWidth;

  @override
  void initState() {
    super.initState();
    _localSpaceWidth = widget.spaceWidth;
    _localKeySize = widget.keySize;
    _localKeyBorderRadius = widget.keyBorderRadius;
    _localKeyPadding = widget.keyPadding;
    _localSplitWidth = widget.splitWidth;
  }

  @override
  void didUpdateWidget(KeyboardTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.spaceWidth != widget.spaceWidth) {
      _localSpaceWidth = widget.spaceWidth;
    }
    if (oldWidget.keySize != widget.keySize) {
      _localKeySize = widget.keySize;
    }
    if (oldWidget.keyBorderRadius != widget.keyBorderRadius) {
      _localKeyBorderRadius = widget.keyBorderRadius;
    }
    if (oldWidget.keyPadding != widget.keyPadding) {
      _localKeyPadding = widget.keyPadding;
    }
    if (oldWidget.splitWidth != widget.splitWidth) {
      _localSplitWidth = widget.splitWidth;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SectionTitle(title: 'Keyboard Layout'),
        DropdownOption(
          label: 'Keymap style',
          value: widget.keymapStyle,
          options: ['Staggered', 'Matrix', 'Split Matrix'],
          onChanged: (value) {
            if (value == 'Split Matrix' && _localSpaceWidth > 300) {
              setState(() => _localSpaceWidth = 220.0);
            }
            widget.updateKeymapStyle(value!);
          },
        ),
        ToggleOption(
          label: 'Show top row',
          value: widget.showTopRow,
          subtitle:
              'Recommended to toggle when keyboard is visible or auto-hide is off. Toggling while hidden may cause rendering errors.',
          onChanged: widget.updateShowTopRow,
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          firstChild: const SizedBox.shrink(),
          secondChild: ToggleOption(
            label: 'Show grave key',
            value: widget.showGraveKey,
            onChanged: widget.updateShowGraveKey,
          ),
          crossFadeState: widget.showTopRow
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          sizeCurve: Curves.easeInOut,
        ),
        SectionTitle(title: 'Key Dimensions'),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          firstChild: const SizedBox.shrink(),
          secondChild: SliderOption(
            label: 'Split width',
            value: _localSplitWidth,
            min: 30,
            max: 200,
            divisions: 34,
            onChanged: (value) {
              setState(() => _localSplitWidth = value);
            },
            onChangeEnd: widget.updateSplitWidth,
          ),
          crossFadeState: widget.keymapStyle == 'Split Matrix'
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          sizeCurve: Curves.easeInOut,
        ),
        SliderOption(
          label: 'Key size',
          value: _localKeySize,
          min: 40,
          max: 60,
          divisions: 40,
          onChanged: (value) {
            setState(() => _localKeySize = value);
          },
          onChangeEnd: widget.updateKeySize,
        ),
        SliderOption(
          label: 'Key border radius',
          value: _localKeyBorderRadius,
          min: 0,
          max: 30,
          divisions: 30,
          onChanged: (value) {
            setState(() => _localKeyBorderRadius = value);
          },
          onChangeEnd: widget.updateKeyBorderRadius,
        ),
        SliderOption(
          label: 'Key padding',
          value: _localKeyPadding,
          min: 0,
          max: 10,
          divisions: 20,
          onChanged: (value) {
            setState(() => _localKeyPadding = value);
          },
          onChangeEnd: widget.updateKeyPadding,
        ),
        SliderOption(
          label: 'Space width',
          value: _localSpaceWidth,
          min: 120,
          max: (widget.keymapStyle == 'Split Matrix') ? 300 : 500,
          divisions: (widget.keymapStyle == 'Split Matrix') ? 90 : 190,
          onChanged: (value) {
            setState(() => _localSpaceWidth = value);
          },
          onChangeEnd: widget.updateSpaceWidth,
        ),
      ],
    );
  }
}
