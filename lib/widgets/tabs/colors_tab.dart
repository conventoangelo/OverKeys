import 'package:flutter/material.dart';
import 'package:overkeys/widgets/options/options.dart';

class ColorsTab extends StatelessWidget {
  final Color keyColorPressed;
  final Color keyColorNotPressed;
  final Color markerColor;
  final Color markerColorNotPressed;
  final Color keyTextColor;
  final Color keyTextColorNotPressed;
  final Color keyBorderColorPressed;
  final Color keyBorderColorNotPressed;
  final Function(Color) updateKeyColorPressed;
  final Function(Color) updateKeyColorNotPressed;
  final Function(Color) updateMarkerColor;
  final Function(Color) updateMarkerColorNotPressed;
  final Function(Color) updateKeyTextColor;
  final Function(Color) updateKeyTextColorNotPressed;
  final Function(Color) updateKeyBorderColorPressed;
  final Function(Color) updateKeyBorderColorNotPressed;

  const ColorsTab({
    super.key,
    required this.keyColorPressed,
    required this.keyColorNotPressed,
    required this.markerColor,
    required this.markerColorNotPressed,
    required this.keyTextColor,
    required this.keyTextColorNotPressed,
    required this.keyBorderColorPressed,
    required this.keyBorderColorNotPressed,
    required this.updateKeyColorPressed,
    required this.updateKeyColorNotPressed,
    required this.updateMarkerColor,
    required this.updateMarkerColorNotPressed,
    required this.updateKeyTextColor,
    required this.updateKeyTextColorNotPressed,
    required this.updateKeyBorderColorPressed,
    required this.updateKeyBorderColorNotPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Pressed colors column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ColorOption(
                label: 'Key (pressed)',
                currentColor: keyColorPressed,
                onColorChanged: updateKeyColorPressed,
              ),
              ColorOption(
                label: 'Marker (pressed)',
                currentColor: markerColor,
                onColorChanged: updateMarkerColor,
              ),
              ColorOption(
                label: 'Text (pressed)',
                currentColor: keyTextColor,
                onColorChanged: updateKeyTextColor,
              ),
              ColorOption(
                label: 'Border (pressed)',
                currentColor: keyBorderColorPressed,
                onColorChanged: updateKeyBorderColorPressed,
              ),
            ],
          ),
        ),
        const SizedBox(width: 14), // Space between columns
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ColorOption(
                label: 'Key (not pressed)',
                currentColor: keyColorNotPressed,
                onColorChanged: updateKeyColorNotPressed,
              ),
              ColorOption(
                label: 'Marker (not pressed)',
                currentColor: markerColorNotPressed,
                onColorChanged: updateMarkerColorNotPressed,
              ),
              ColorOption(
                label: 'Text (not pressed)',
                currentColor: keyTextColorNotPressed,
                onColorChanged: updateKeyTextColorNotPressed,
              ),
              ColorOption(
                label: 'Border (not pressed)',
                currentColor: keyBorderColorNotPressed,
                onColorChanged: updateKeyBorderColorNotPressed,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
