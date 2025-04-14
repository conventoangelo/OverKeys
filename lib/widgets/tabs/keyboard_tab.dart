import 'package:flutter/material.dart';
import 'package:overkeys/widgets/options/options.dart';

class KeyboardTab extends StatefulWidget {
  final String keymapStyle;
  final bool showTopRow;
  final bool showGraveKey;
  final double keySize;
  final double keyBorderRadius;
  final double keyBorderThickness;
  final double keyPadding;
  final double spaceWidth;
  final double splitWidth;
  final double lastRowSplitWidth;
  final double keyShadowBlurRadius;
  final double keyShadowOffsetX;
  final double keyShadowOffsetY;
  final Function(String) updateKeymapStyle;
  final Function(bool) updateShowTopRow;
  final Function(bool) updateShowGraveKey;
  final Function(double) updateKeySize;
  final Function(double) updateKeyBorderRadius;
  final Function(double) updateKeyBorderThickness;
  final Function(double) updateKeyPadding;
  final Function(double) updateSpaceWidth;
  final Function(double) updateSplitWidth;
  final Function(double) updateLastRowSplitWidth;
  final Function(double) updateKeyShadowBlurRadius;
  final Function(double) updateKeyShadowOffsetX;
  final Function(double) updateKeyShadowOffsetY;

  const KeyboardTab({
    super.key,
    required this.keymapStyle,
    required this.showTopRow,
    required this.showGraveKey,
    required this.keySize,
    required this.keyBorderRadius,
    required this.keyBorderThickness,
    required this.keyPadding,
    required this.spaceWidth,
    required this.splitWidth,
    required this.lastRowSplitWidth,
    required this.keyShadowBlurRadius,
    required this.keyShadowOffsetX,
    required this.keyShadowOffsetY,
    required this.updateKeymapStyle,
    required this.updateShowTopRow,
    required this.updateShowGraveKey,
    required this.updateKeySize,
    required this.updateKeyBorderRadius,
    required this.updateKeyBorderThickness,
    required this.updateKeyPadding,
    required this.updateSpaceWidth,
    required this.updateSplitWidth,
    required this.updateLastRowSplitWidth,
    required this.updateKeyShadowBlurRadius,
    required this.updateKeyShadowOffsetX,
    required this.updateKeyShadowOffsetY,
  });

  @override
  State<KeyboardTab> createState() => _KeyboardTabState();
}

class _KeyboardTabState extends State<KeyboardTab> {
  late double _localKeySize;
  late double _localKeyBorderRadius;
  late double _localKeyBorderThickness;
  late double _localKeyPadding;
  late double _localSpaceWidth;
  late double _localSplitWidth;
  late double _localLastRowSplitWidth;
  late double _localKeyShadowBlurRadius;
  late double _localKeyShadowOffsetX;
  late double _localKeyShadowOffsetY;

  @override
  void initState() {
    super.initState();
    _localKeySize = widget.keySize;
    _localKeyBorderRadius = widget.keyBorderRadius;
    _localKeyBorderThickness = widget.keyBorderThickness;
    _localKeyPadding = widget.keyPadding;
    _localSpaceWidth = widget.spaceWidth;
    _localSplitWidth = widget.splitWidth;
    _localLastRowSplitWidth = widget.lastRowSplitWidth;
    _localKeyShadowBlurRadius = widget.keyShadowBlurRadius;
    _localKeyShadowOffsetX = widget.keyShadowOffsetX;
    _localKeyShadowOffsetY = widget.keyShadowOffsetY;
  }

  @override
  void didUpdateWidget(KeyboardTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.keySize != widget.keySize) {
      _localKeySize = widget.keySize;
    }
    if (oldWidget.keyBorderRadius != widget.keyBorderRadius) {
      _localKeyBorderRadius = widget.keyBorderRadius;
    }
    if (oldWidget.keyBorderThickness != widget.keyBorderThickness) {
      _localKeyBorderThickness = widget.keyBorderThickness;
    }
    if (oldWidget.keyPadding != widget.keyPadding) {
      _localKeyPadding = widget.keyPadding;
    }
    if (oldWidget.spaceWidth != widget.spaceWidth) {
      _localSpaceWidth = widget.spaceWidth;
    }
    if (oldWidget.splitWidth != widget.splitWidth) {
      _localSplitWidth = widget.splitWidth;
    }
    if (oldWidget.lastRowSplitWidth != widget.lastRowSplitWidth) {
      _localLastRowSplitWidth = widget.lastRowSplitWidth;
    }
    if (oldWidget.keyShadowBlurRadius != widget.keyShadowBlurRadius) {
      _localKeyShadowBlurRadius = widget.keyShadowBlurRadius;
    }
    if (oldWidget.keyShadowOffsetX != widget.keyShadowOffsetX) {
      _localKeyShadowOffsetX = widget.keyShadowOffsetX;
    }
    if (oldWidget.keyShadowOffsetY != widget.keyShadowOffsetY) {
      _localKeyShadowOffsetY = widget.keyShadowOffsetY;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        DropdownOption(
          label: 'Keymap style',
          value: widget.keymapStyle,
          options: ['Staggered', 'Matrix', 'Split Matrix'],
          onChanged: (value) {
            if (value == 'Split Matrix') {
              if (_localSpaceWidth > 300) {
                setState(() => _localSpaceWidth = 220);
                widget.updateSpaceWidth(220);
              }
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
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          firstChild: const SizedBox.shrink(),
          secondChild: SliderOption(
            label: 'Last row split width',
            value: _localLastRowSplitWidth,
            min: 30,
            max: 200,
            divisions: 34,
            onChanged: (value) {
              setState(() => _localLastRowSplitWidth = value);
            },
            onChangeEnd: widget.updateLastRowSplitWidth,
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
          label: 'Key border thickness',
          value: _localKeyBorderThickness,
          min: 0,
          max: 5,
          divisions: 10,
          onChanged: (value) {
            setState(() => _localKeyBorderThickness = value);
          },
          onChangeEnd: widget.updateKeyBorderThickness,
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
        SliderOption(
          label: 'Key shadow blur radius',
          value: _localKeyShadowBlurRadius,
          min: 0,
          max: 20,
          divisions: 20,
          onChanged: (value) {
            setState(() => _localKeyShadowBlurRadius = value);
          },
          onChangeEnd: widget.updateKeyShadowBlurRadius,
        ),
        SliderOption(
          label: 'Key shadow offset X',
          value: _localKeyShadowOffsetX,
          min: -10,
          max: 10,
          divisions: 20,
          onChanged: (value) {
            setState(() => _localKeyShadowOffsetX = value);
          },
          onChangeEnd: widget.updateKeyShadowOffsetX,
        ),
        SliderOption(
          label: 'Key shadow offset Y',
          value: _localKeyShadowOffsetY,
          min: -10,
          max: 10,
          divisions: 20,
          onChanged: (value) {
            setState(() => _localKeyShadowOffsetY = value);
          },
          onChangeEnd: widget.updateKeyShadowOffsetY,
        ),
      ],
    );
  }
}
