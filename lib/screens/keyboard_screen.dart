import 'package:flutter/material.dart';
import '../utils/keyboard_layouts.dart';
import '../models/mappings.dart';

class KeyboardScreen extends StatelessWidget {
  final Map<String, bool> keyPressStates;
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
  final String keymapStyle;
  final double splitWidth;

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
      required this.spaceWidth,
      required this.keymapStyle,
      required this.splitWidth});

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
    List<Widget> rowWidgets = [];

    for (int i = 0; i < keys.length; i++) {
      if (i == 5 && keymapStyle == 'Split Matrix') {
        rowWidgets.add(SizedBox(width: splitWidth));
      }

      if (keymapStyle == 'Matrix' || keymapStyle == 'Split Matrix') {
        if (keymapStyle == 'Split Matrix' && rowIndex == 3) {
          rowWidgets.add(buildKeys(rowIndex, keys[i], i));
          rowWidgets.add(SizedBox(width: splitWidth));
          rowWidgets.add(buildKeys(rowIndex, keys[i], i));
        } else if (i < 10) {
          rowWidgets.add(buildKeys(rowIndex, keys[i], i));
        }
      } else {
        rowWidgets.add(buildKeys(rowIndex, keys[i], i));
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: rowWidgets,
    );
  }

  Widget buildKeys(int rowIndex, String key, int keyIndex) {
    String keyStateKey = Mappings.getKeyForSymbol(key);
    bool isPressed = keyPressStates[keyStateKey] ?? false;

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
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: spaceFontSize,
                    fontWeight: fontWeight,
                  ),
                )
              : Text(
                  key,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: key.length > 2 ? keyFontSize * 0.7 : keyFontSize,
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
