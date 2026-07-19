import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overkeys/widgets/options/options.dart';
import 'package:overkeys/utils/font_options.dart';
import 'package:overkeys/providers/keyboard_provider.dart';

class TextTab extends ConsumerStatefulWidget {
  final Function(String method, dynamic value) onUpdateMainWindow;

  const TextTab({
    super.key,
    required this.onUpdateMainWindow,
  });

  @override
  ConsumerState<TextTab> createState() => _TextTabState();
}

class _TextTabState extends ConsumerState<TextTab> {
  late double _localKeyFontSize;
  late double _localLongKeyFontSize;
  late double _localTopLabelFontSize;
  late double _localSpaceFontSize;

  @override
  void initState() {
    super.initState();
    // Initialize with current provider values
    final keyboardState = ref.read(keyboardProvider);
    _localKeyFontSize = keyboardState.keyFontSize;
    _localLongKeyFontSize = keyboardState.longKeyFontSize;
    _localTopLabelFontSize = keyboardState.topLabelFontSize;
    _localSpaceFontSize = keyboardState.spaceFontSize;
  }

  @override
  Widget build(BuildContext context) {
    final keyboardState = ref.watch(keyboardProvider);

    // Listen for external provider changes and sync local state
    ref.listen<KeyboardState>(keyboardProvider, (previous, next) {
      if (previous != null) {
        if (_localKeyFontSize != next.keyFontSize) {
          setState(() => _localKeyFontSize = next.keyFontSize);
        }
        if (_localLongKeyFontSize != next.longKeyFontSize) {
          setState(() => _localLongKeyFontSize = next.longKeyFontSize);
        }
        if (_localTopLabelFontSize != next.topLabelFontSize) {
          setState(() => _localTopLabelFontSize = next.topLabelFontSize);
        }
        if (_localSpaceFontSize != next.spaceFontSize) {
          setState(() => _localSpaceFontSize = next.spaceFontSize);
        }
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        DropdownOption(
            label: 'Font style',
            value: keyboardState.fontFamily,
            options: availableFontFamilies,
            onChanged: (value) {
              ref.read(keyboardProvider.notifier).updateFontFamily(value!);
              widget.onUpdateMainWindow('updateFontFamily', value);
            },
            subtitle:
                'Make sure that the font is installed in your system. Falls back to DM Mono.'),
        DropdownOption(
          label: 'Font weight',
          value: keyboardState.fontWeight == FontWeight.w100
              ? 'Thin'
              : keyboardState.fontWeight == FontWeight.w200
                  ? 'ExtraLight'
                  : keyboardState.fontWeight == FontWeight.w300
                      ? 'Light'
                      : keyboardState.fontWeight == FontWeight.normal
                          ? 'Normal'
                          : keyboardState.fontWeight == FontWeight.w500
                              ? 'Medium'
                              : keyboardState.fontWeight == FontWeight.w600
                                  ? 'SemiBold'
                                  : keyboardState.fontWeight == FontWeight.bold
                                      ? 'Bold'
                                      : keyboardState.fontWeight ==
                                              FontWeight.w800
                                          ? 'ExtraBold'
                                          : 'Black',
          options: [
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
          onChanged: (value) {
            FontWeight weight;
            switch (value) {
              case 'Thin':
                weight = FontWeight.w100;
                break;
              case 'ExtraLight':
                weight = FontWeight.w200;
                break;
              case 'Light':
                weight = FontWeight.w300;
                break;
              case 'Normal':
                weight = FontWeight.normal;
                break;
              case 'Medium':
                weight = FontWeight.w500;
                break;
              case 'SemiBold':
                weight = FontWeight.w600;
                break;
              case 'Bold':
                weight = FontWeight.bold;
                break;
              case 'ExtraBold':
                weight = FontWeight.w800;
                break;
              case 'Black':
                weight = FontWeight.w900;
                break;
              default:
                weight = FontWeight.w500;
            }
            ref.read(keyboardProvider.notifier).updateFontWeight(weight);
            widget.onUpdateMainWindow('updateFontWeight', weight);
          },
        ),
        SliderOption(
          label: 'Key font size',
          value: _localKeyFontSize,
          min: 12,
          max: 32,
          divisions: 40,
          onChanged: (value) {
            setState(() => _localKeyFontSize = value);
          },
          onChangeEnd: (value) {
            ref.read(keyboardProvider.notifier).updateKeyFontSize(value);
            widget.onUpdateMainWindow('updateKeyFontSize', value);
          },
        ),
        SliderOption(
          label: 'Long key font size',
          value: _localLongKeyFontSize,
          min: 8,
          max: 24,
          divisions: 32,
          onChanged: (value) {
            setState(() => _localLongKeyFontSize = value);
          },
          onChangeEnd: (value) {
            ref.read(keyboardProvider.notifier).updateLongKeyFontSize(value);
            widget.onUpdateMainWindow('updateLongKeyFontSize', value);
          },
        ),
        SliderOption(
          label: 'Top label font size',
          value: _localTopLabelFontSize,
          min: 6,
          max: 20,
          divisions: 28,
          onChanged: (value) {
            setState(() => _localTopLabelFontSize = value);
          },
          onChangeEnd: (value) {
            ref.read(keyboardProvider.notifier).updateTopLabelFontSize(value);
            widget.onUpdateMainWindow('updateTopLabelFontSize', value);
          },
        ),
        SliderOption(
          label: 'Space font size',
          value: _localSpaceFontSize,
          min: 12,
          max: 32,
          divisions: 40,
          onChanged: (value) {
            setState(() => _localSpaceFontSize = value);
          },
          onChangeEnd: (value) {
            ref.read(keyboardProvider.notifier).updateSpaceFontSize(value);
            widget.onUpdateMainWindow('updateSpaceFontSize', value);
          },
        ),
      ],
    );
  }
}
