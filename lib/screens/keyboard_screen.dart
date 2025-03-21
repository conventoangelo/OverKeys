import 'package:flutter/material.dart';
import '../utils/keyboard_layouts.dart';
import '../models/mappings.dart';

class KeyboardScreen extends StatelessWidget {
  final Map<String, bool> keyPressStates;
  final KeyboardLayout layout;
  final bool showAltLayout;
  final KeyboardLayout? altLayout;
  final Color keyColorPressed;
  final Color keyColorNotPressed;
  final Color markerColor;
  final Color markerColorNotPressed;
  final double markerOffset;
  final double markerWidth;
  final double markerHeight;
  final double markerBorderRadius;
  final String keymapStyle;
  final bool showTopRow;
  final double keySize;
  final double keyBorderRadius;
  final double keyPadding;
  final double spaceWidth;
  final double splitWidth;
  final double keyFontSize;
  final double spaceFontSize;
  final FontWeight fontWeight;
  final Color keyTextColor;
  final Color keyTextColorNotPressed;

  const KeyboardScreen(
      {super.key,
      required this.keyPressStates,
      required this.layout,
      required this.showAltLayout,
      required this.altLayout,
      required this.keyColorPressed,
      required this.keyColorNotPressed,
      required this.markerColor,
      required this.markerColorNotPressed,
      required this.markerOffset,
      required this.markerWidth,
      required this.markerHeight,
      required this.markerBorderRadius,
      required this.keymapStyle,
      required this.showTopRow,
      required this.keySize,
      required this.keyBorderRadius,
      required this.keyPadding,
      required this.spaceWidth,
      required this.splitWidth,
      required this.keyFontSize,
      required this.spaceFontSize,
      required this.fontWeight,
      required this.keyTextColor,
      required this.keyTextColorNotPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: layout.keys.asMap().entries.where((entry) {
          return showTopRow || entry.key > 0;
        }).map((entry) {
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
        if (keymapStyle == 'Split Matrix' && rowIndex == 4) {
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
    Color tactMarkerColor = isPressed ? markerColor : markerColorNotPressed;

    Widget keyWidget = Padding(
      padding: EdgeInsets.all(keyPadding),
      child: Container(
        width: key == " " ? spaceWidth : keySize,
        height: keySize,
        decoration: BoxDecoration(
          color: keyColor,
          borderRadius: BorderRadius.circular(keyBorderRadius),
        ),
        child: key == " "
            ? Center(
                child: Text(
                  showAltLayout && altLayout != null
                      ? "${layout.name.toLowerCase()} (${altLayout!.name.toLowerCase()})"
                      : layout.name.toLowerCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: spaceFontSize,
                    fontWeight: fontWeight,
                  ),
                ),
              )
            : showAltLayout && altLayout != null
                ? Stack(
                    children: [
                      // Primary layout key (top left)
                      Positioned(
                        top: 4,
                        left: 8,
                        child: Text(
                          key,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: textColor,
                            fontSize: key.length > 2
                                ? keyFontSize * 0.6
                                : keyFontSize * 0.85,
                            fontWeight: fontWeight,
                          ),
                        ),
                      ),
                      // Alt layout key (bottom right)
                      Positioned(
                        bottom: 4,
                        right: 8,
                        child: Text(
                          _getAltLayoutKey(rowIndex, keyIndex),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: textColor,
                            fontSize:
                                _getAltLayoutKey(rowIndex, keyIndex).length > 2
                                    ? keyFontSize * 0.6
                                    : keyFontSize * 0.85,
                            fontWeight: fontWeight,
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Text(
                      key,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor,
                        fontSize:
                            key.length > 2 ? keyFontSize * 0.7 : keyFontSize,
                        fontWeight: fontWeight,
                      ),
                    ),
                  ),
      ),
    );

    // Tactile Markers
    if (rowIndex == 2 && (keyIndex == 3 || keyIndex == 6)) {
      keyWidget = Stack(
        alignment: showAltLayout ? Alignment.center : Alignment.bottomCenter,
        children: [
          keyWidget,
          Positioned(
            bottom: showAltLayout ? null : markerOffset,
            child: Container(
                width: markerWidth * (showAltLayout ? 0.5 : 1),
                height: showAltLayout ? markerWidth * 0.5 : markerHeight,
              decoration: BoxDecoration(
                color: tactMarkerColor,
                borderRadius: BorderRadius.circular(markerBorderRadius),
              ),
            ),
          ),
        ],
      );
    }
    return keyWidget;
  }

  String _getAltLayoutKey(int rowIndex, int keyIndex) {
    if (altLayout == null || rowIndex >= altLayout!.keys.length) {
      return "";
    }

    List<String> altRow = altLayout!.keys[rowIndex];
    if (keyIndex >= altRow.length) {
      return "";
    }

    return altRow[keyIndex];
  }
}
