import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overkeys/widgets/options/options.dart';
import 'package:overkeys/providers/keyboard_provider.dart';

class KeyboardTab extends ConsumerStatefulWidget {
  final Function(String method, dynamic value) onUpdateMainWindow;

  const KeyboardTab({
    super.key,
    required this.onUpdateMainWindow,
  });

  @override
  ConsumerState<KeyboardTab> createState() => _KeyboardTabState();
}

class _KeyboardTabState extends ConsumerState<KeyboardTab> {
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
    // Initialize with current provider values
    final keyboardState = ref.read(keyboardNotifierProvider);
    _localKeySize = keyboardState.keySize;
    _localKeyBorderRadius = keyboardState.keyBorderRadius;
    _localKeyBorderThickness = keyboardState.keyBorderThickness;
    _localKeyPadding = keyboardState.keyPadding;
    _localSpaceWidth = keyboardState.spaceWidth;
    _localSplitWidth = keyboardState.splitWidth;
    _localLastRowSplitWidth = keyboardState.lastRowSplitWidth;
    _localKeyShadowBlurRadius = keyboardState.keyShadowBlurRadius;
    _localKeyShadowOffsetX = keyboardState.keyShadowOffsetX;
    _localKeyShadowOffsetY = keyboardState.keyShadowOffsetY;
  }

  @override
  Widget build(BuildContext context) {
    final keyboardState = ref.watch(keyboardNotifierProvider);

    // Listen for external provider changes and sync local state
    ref.listen<KeyboardState>(keyboardNotifierProvider, (previous, next) {
      if (previous != null) {
        if (_localKeySize != next.keySize) {
          setState(() => _localKeySize = next.keySize);
        }
        if (_localKeyBorderRadius != next.keyBorderRadius) {
          setState(() => _localKeyBorderRadius = next.keyBorderRadius);
        }
        if (_localKeyBorderThickness != next.keyBorderThickness) {
          setState(() => _localKeyBorderThickness = next.keyBorderThickness);
        }
        if (_localKeyPadding != next.keyPadding) {
          setState(() => _localKeyPadding = next.keyPadding);
        }
        if (_localSpaceWidth != next.spaceWidth) {
          setState(() => _localSpaceWidth = next.spaceWidth);
        }
        if (_localSplitWidth != next.splitWidth) {
          setState(() => _localSplitWidth = next.splitWidth);
        }
        if (_localLastRowSplitWidth != next.lastRowSplitWidth) {
          setState(() => _localLastRowSplitWidth = next.lastRowSplitWidth);
        }
        if (_localKeyShadowBlurRadius != next.keyShadowBlurRadius) {
          setState(() => _localKeyShadowBlurRadius = next.keyShadowBlurRadius);
        }
        if (_localKeyShadowOffsetX != next.keyShadowOffsetX) {
          setState(() => _localKeyShadowOffsetX = next.keyShadowOffsetX);
        }
        if (_localKeyShadowOffsetY != next.keyShadowOffsetY) {
          setState(() => _localKeyShadowOffsetY = next.keyShadowOffsetY);
        }
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        DropdownOption(
          label: 'Keymap style',
          value: keyboardState.keymapStyle,
          options: ['Staggered', 'Matrix', 'Split Matrix'],
          onChanged: (value) {
            if (value == 'Split Matrix') {
              if (_localSpaceWidth > 300) {
                setState(() => _localSpaceWidth = 220);
                ref
                    .read(keyboardNotifierProvider.notifier)
                    .updateSpaceWidth(220);
                widget.onUpdateMainWindow('updateSpaceWidth', 220);
              }
            }
            ref
                .read(keyboardNotifierProvider.notifier)
                .updateKeymapStyle(value!);
            widget.onUpdateMainWindow('updateKeymapStyle', value);
          },
        ),
        ToggleOption(
          label: 'Show top row',
          value: keyboardState.showTopRow,
          subtitle:
              'Recommended to toggle when keyboard is visible or auto-hide is off. Toggling while hidden may cause rendering errors.',
          onChanged: (value) {
            ref.read(keyboardNotifierProvider.notifier).updateShowTopRow(value);
            widget.onUpdateMainWindow('updateShowTopRow', value);
          },
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          firstChild: const SizedBox.shrink(),
          secondChild: ToggleOption(
            label: 'Show grave key',
            value: keyboardState.showGraveKey,
            onChanged: (value) {
              ref
                  .read(keyboardNotifierProvider.notifier)
                  .updateShowGraveKey(value);
              widget.onUpdateMainWindow('updateShowGraveKey', value);
            },
          ),
          crossFadeState: keyboardState.showTopRow
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
            onChangeEnd: (value) {
              ref
                  .read(keyboardNotifierProvider.notifier)
                  .updateSplitWidth(value);
              widget.onUpdateMainWindow('updateSplitWidth', value);
            },
          ),
          crossFadeState: keyboardState.keymapStyle == 'Split Matrix'
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
            onChangeEnd: (value) {
              ref
                  .read(keyboardNotifierProvider.notifier)
                  .updateLastRowSplitWidth(value);
              widget.onUpdateMainWindow('updateLastRowSplitWidth', value);
            },
          ),
          crossFadeState: keyboardState.keymapStyle == 'Split Matrix'
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
          onChangeEnd: (value) {
            ref.read(keyboardNotifierProvider.notifier).updateKeySize(value);
            widget.onUpdateMainWindow('updateKeySize', value);
          },
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
          onChangeEnd: (value) {
            ref
                .read(keyboardNotifierProvider.notifier)
                .updateKeyBorderRadius(value);
            widget.onUpdateMainWindow('updateKeyBorderRadius', value);
          },
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
          onChangeEnd: (value) {
            ref
                .read(keyboardNotifierProvider.notifier)
                .updateKeyBorderThickness(value);
            widget.onUpdateMainWindow('updateKeyBorderThickness', value);
          },
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
          onChangeEnd: (value) {
            ref.read(keyboardNotifierProvider.notifier).updateKeyPadding(value);
            widget.onUpdateMainWindow('updateKeyPadding', value);
          },
        ),
        SliderOption(
          label: 'Space width',
          value: _localSpaceWidth,
          min: 120,
          max: (keyboardState.keymapStyle == 'Split Matrix') ? 300 : 500,
          divisions: (keyboardState.keymapStyle == 'Split Matrix') ? 90 : 190,
          onChanged: (value) {
            setState(() => _localSpaceWidth = value);
          },
          onChangeEnd: (value) {
            ref.read(keyboardNotifierProvider.notifier).updateSpaceWidth(value);
            widget.onUpdateMainWindow('updateSpaceWidth', value);
          },
        ),
        SliderOption(
          label: 'Key shadow blur radius',
          value: _localKeyShadowBlurRadius,
          min: 0,
          max: 10,
          divisions: 10,
          onChanged: (value) {
            setState(() => _localKeyShadowBlurRadius = value);
          },
          onChangeEnd: (value) {
            ref
                .read(keyboardNotifierProvider.notifier)
                .updateKeyShadowBlurRadius(value);
            widget.onUpdateMainWindow('updateKeyShadowBlurRadius', value);
          },
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
          onChangeEnd: (value) {
            ref
                .read(keyboardNotifierProvider.notifier)
                .updateKeyShadowOffsetX(value);
            widget.onUpdateMainWindow('updateKeyShadowOffsetX', value);
          },
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
          onChangeEnd: (value) {
            ref
                .read(keyboardNotifierProvider.notifier)
                .updateKeyShadowOffsetY(value);
            widget.onUpdateMainWindow('updateKeyShadowOffsetY', value);
          },
        ),
      ],
    );
  }
}
