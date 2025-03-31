import 'package:flutter/material.dart';
import 'package:overkeys/widgets/options/options.dart';

class ColorsTab extends StatelessWidget {
  final Color keyColorPressed;
  final Color keyColorNotPressed;
  final Color markerColor;
  final Color markerColorNotPressed;
  final Color keyTextColor;
  final Color keyTextColorNotPressed;
  final Function(Color) updateKeyColorPressed;
  final Function(Color) updateKeyColorNotPressed;
  final Function(Color) updateMarkerColor;
  final Function(Color) updateMarkerColorNotPressed;
  final Function(Color) updateKeyTextColor;
  final Function(Color) updateKeyTextColorNotPressed;

  const ColorsTab({
    super.key,
    required this.keyColorPressed,
    required this.keyColorNotPressed,
    required this.markerColor,
    required this.markerColorNotPressed,
    required this.keyTextColor,
    required this.keyTextColorNotPressed,
    required this.updateKeyColorPressed,
    required this.updateKeyColorNotPressed,
    required this.updateMarkerColor,
    required this.updateMarkerColorNotPressed,
    required this.updateKeyTextColor,
    required this.updateKeyTextColorNotPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Key colors
        ColorOption(
          label: 'Key color (pressed)',
          currentColor: keyColorPressed,
          onColorChanged: updateKeyColorPressed,
        ),
        ColorOption(
          label: 'Key color (not pressed)',
          currentColor: keyColorNotPressed,
          onColorChanged: updateKeyColorNotPressed,
        ),

        // Marker colors
        ColorOption(
          label: 'Marker color (pressed)',
          currentColor: markerColor,
          onColorChanged: updateMarkerColor,
        ),
        ColorOption(
          label: 'Marker color (not pressed)',
          currentColor: markerColorNotPressed,
          onColorChanged: updateMarkerColorNotPressed,
        ),

        // Text colors
        ColorOption(
          label: 'Text color (pressed)',
          currentColor: keyTextColor,
          onColorChanged: updateKeyTextColor,
        ),
        ColorOption(
          label: 'Text color (not pressed)',
          currentColor: keyTextColorNotPressed,
          onColorChanged: updateKeyTextColorNotPressed,
        ),
      ],
    );
  }
}
