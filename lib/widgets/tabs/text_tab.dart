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
  late double _localSpaceFontSize;

  @override
  void initState() {
    super.initState();
    // Initialize with current provider values
    final keyboardState = ref.read(keyboardNotifierProvider);
    _localKeyFontSize = keyboardState.keyFontSize;
    _localSpaceFontSize = keyboardState.spaceFontSize;
  }

  @override
  Widget build(BuildContext context) {
    final keyboardState = ref.watch(keyboardNotifierProvider);

    // Listen for external provider changes and sync local state
    ref.listen<KeyboardState>(keyboardNotifierProvider, (previous, next) {
      if (previous != null) {
        if (_localKeyFontSize != next.keyFontSize) {
          setState(() => _localKeyFontSize = next.keyFontSize);
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
              ref
                  .read(keyboardNotifierProvider.notifier)
                  .updateFontFamily(value!);
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
            ref
                .read(keyboardNotifierProvider.notifier)
                .updateFontWeight(weight);
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
            ref
                .read(keyboardNotifierProvider.notifier)
                .updateKeyFontSize(value);
            widget.onUpdateMainWindow('updateKeyFontSize', value);
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
            ref
                .read(keyboardNotifierProvider.notifier)
                .updateSpaceFontSize(value);
            widget.onUpdateMainWindow('updateSpaceFontSize', value);
          },
        ),
      ],
    );
  }
}
