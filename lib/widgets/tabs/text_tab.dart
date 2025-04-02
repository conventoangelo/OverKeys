import 'package:flutter/material.dart';
import 'package:overkeys/widgets/options/options.dart';
import 'package:overkeys/utils/font_options.dart';

class TextTab extends StatefulWidget {
  final String fontFamily;
  final FontWeight fontWeight;
  final double keyFontSize;
  final double spaceFontSize;
  final Function(String) updateFontFamily;
  final Function(FontWeight) updateFontWeight;
  final Function(double) updateKeyFontSize;
  final Function(double) updateSpaceFontSize;

  const TextTab({
    super.key,
    required this.fontFamily,
    required this.fontWeight,
    required this.keyFontSize,
    required this.spaceFontSize,
    required this.updateFontFamily,
    required this.updateFontWeight,
    required this.updateKeyFontSize,
    required this.updateSpaceFontSize,
  });

  @override
  State<TextTab> createState() => _TextTabState();
}

class _TextTabState extends State<TextTab> {
  late double _localKeyFontSize;
  late double _localSpaceFontSize;

  @override
  void initState() {
    super.initState();
    _localKeyFontSize = widget.keyFontSize;
    _localSpaceFontSize = widget.spaceFontSize;
  }

  @override
  void didUpdateWidget(TextTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.keyFontSize != widget.keyFontSize) {
      _localKeyFontSize = widget.keyFontSize;
    }
    if (oldWidget.spaceFontSize != widget.spaceFontSize) {
      _localSpaceFontSize = widget.spaceFontSize;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        DropdownOption(
            label: 'Font style',
            value: widget.fontFamily,
            options: availableFontFamilies,
            onChanged: (value) => widget.updateFontFamily(value!),
            subtitle:
                'Make sure that the font is installed in your system. Falls back to Geist Mono.'),
        DropdownOption(
          label: 'Font weight',
          value: widget.fontWeight == FontWeight.w100
              ? 'Thin'
              : widget.fontWeight == FontWeight.w200
                  ? 'ExtraLight'
                  : widget.fontWeight == FontWeight.w300
                      ? 'Light'
                      : widget.fontWeight == FontWeight.normal
                          ? 'Normal'
                          : widget.fontWeight == FontWeight.w500
                              ? 'Medium'
                              : widget.fontWeight == FontWeight.w600
                                  ? 'SemiBold'
                                  : widget.fontWeight == FontWeight.bold
                                      ? 'Bold'
                                      : widget.fontWeight == FontWeight.w800
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
            widget.updateFontWeight(weight);
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
          onChangeEnd: widget.updateKeyFontSize,
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
          onChangeEnd: widget.updateSpaceFontSize,
        ),
      ],
    );
  }
}
