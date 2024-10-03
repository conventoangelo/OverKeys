import 'package:flutter/material.dart';
import '../utils/keyboard_layouts.dart';
import '../utils/key_code.dart';

class KeyboardScreen extends StatelessWidget {
  final Map<int, bool> keyPressStates;
  final KeyboardLayout layout;
  final String fontStyle;
  final double keyFontSize;
  final double spaceFontSize;
  final FontWeight fontWeight;
  final Color keyTextColor;
  final Color keyTextColorNotPressed;
  final Color keyColorPressed;
  final Color keyColorNotPressed;
  final double keySize;
  final double keyBorderRadius;
  final double keyPadding;
  final Color markerColor;
  final double markerOffset;
  final double markerWidth;
  final double markerHeight;
  final double markerBorderRadius;
  final double spaceWidth;

  const KeyboardScreen(
      {super.key,
      required this.keyPressStates,
      required this.layout,
      required this.fontStyle,
      required this.keyFontSize,
      required this.spaceFontSize,
      required this.fontWeight,
      required this.keyTextColor,
      required this.keyTextColorNotPressed,
      required this.keyColorPressed,
      required this.keyColorNotPressed,
      required this.keySize,
      required this.keyBorderRadius,
      required this.keyPadding,
      required this.markerColor,
      required this.markerOffset,
      required this.markerWidth,
      required this.markerHeight,
      required this.markerBorderRadius,
      required this.spaceWidth});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: layout.keys.asMap().entries.map((entry) {
          int rowIndex = entry.key;
          List<String> row = entry.value;
          return buildRow(rowIndex, row);
        }).toList(),
      ),
    );
  }

  Widget buildRow(int rowIndex, List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.asMap().entries.map((entry) {
        int keyIndex = entry.key;
        String key = entry.value;
        return buildKeys(rowIndex, key, keyIndex);
      }).toList(),
    );
  }

  Widget buildKeys(int rowIndex, String key, int keyIndex) {
    int virtualKeyCode = getVirtualKeyCode(key);
    bool isPressed = keyPressStates[virtualKeyCode] ?? false;

    Color keyColor = isPressed ? keyColorPressed : keyColorNotPressed;
    Color textColor = isPressed ? keyTextColor : keyTextColorNotPressed;

    Widget keyWidget = Padding(
      padding: EdgeInsets.all(keyPadding),
      child: Container(
        width: key == " " ? spaceWidth : keySize,
        height: keySize,
        decoration: BoxDecoration(
          color: keyColor,
          borderRadius: BorderRadius.circular(keyBorderRadius),
        ),
        child: Center(
          child: key == " "
              ? Text(
                  layout.name.toLowerCase(),
                  style: TextStyle(
                    color: textColor,
                    fontSize: spaceFontSize,
                    fontWeight: fontWeight,
                  ),
                )
              : Text(
                  key,
                  style: TextStyle(
                    color: textColor,
                    fontSize: keyFontSize,
                    fontWeight: fontWeight,
                  ),
                ),
        ),
      ),
    );

    // Tactile Markers
    if (rowIndex == 1 && (keyIndex == 3 || keyIndex == 6)) {
      keyWidget = Stack(
        alignment: Alignment.bottomCenter,
        children: [
          keyWidget,
          Positioned(
            bottom: markerOffset,
            child: Container(
              width: markerWidth,
              height: markerHeight,
              decoration: BoxDecoration(
                color: markerColor,
                borderRadius: BorderRadius.circular(markerBorderRadius),
              ),
            ),
          ),
        ],
      );
    }

    return keyWidget;
  }
}
