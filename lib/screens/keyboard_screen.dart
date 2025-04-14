import 'package:flutter/material.dart';
import '../models/keyboard_layouts.dart';
import '../models/mappings.dart';

class KeyboardScreen extends StatelessWidget {
  final KeyboardLayout layout;
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
  final double keyFontSize;
  final double spaceFontSize;
  final FontWeight fontWeight;
  final double markerOffset;
  final double markerWidth;
  final double markerHeight;
  final double markerBorderRadius;
  final Color keyColorPressed;
  final Color keyColorNotPressed;
  final Color markerColor;
  final Color markerColorNotPressed;
  final Color keyTextColor;
  final Color keyTextColorNotPressed;
  final Color keyBorderColorPressed;
  final Color keyBorderColorNotPressed;
  final bool animationEnabled;
  final String animationStyle;
  final double animationDuration;
  final double animationScale;
  final bool learningModeEnabled;
  final Color pinkyLeftColor;
  final Color ringLeftColor;
  final Color middleLeftColor;
  final Color indexLeftColor;
  final Color indexRightColor;
  final Color middleRightColor;
  final Color ringRightColor;
  final Color pinkyRightColor;
  final bool showAltLayout;
  final KeyboardLayout? altLayout;
  final bool use6ColLayout;
  final Map<String, bool> keyPressStates;
  final Map<String, String>? customShiftMappings;

  const KeyboardScreen({
    super.key,
    required this.layout,
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
    required this.keyFontSize,
    required this.spaceFontSize,
    required this.fontWeight,
    required this.markerOffset,
    required this.markerWidth,
    required this.markerHeight,
    required this.markerBorderRadius,
    required this.keyColorPressed,
    required this.keyColorNotPressed,
    required this.markerColor,
    required this.markerColorNotPressed,
    required this.keyTextColor,
    required this.keyTextColorNotPressed,
    required this.keyBorderColorPressed,
    required this.keyBorderColorNotPressed,
    required this.animationEnabled,
    required this.animationStyle,
    required this.animationDuration,
    required this.animationScale,
    required this.learningModeEnabled,
    required this.pinkyLeftColor,
    required this.ringLeftColor,
    required this.middleLeftColor,
    required this.indexLeftColor,
    required this.indexRightColor,
    required this.middleRightColor,
    required this.ringRightColor,
    required this.pinkyRightColor,
    required this.showAltLayout,
    required this.altLayout,
    required this.use6ColLayout,
    required this.keyPressStates,
    this.customShiftMappings,
  });

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

    if (keymapStyle != 'Matrix' && keymapStyle != 'Split Matrix') {
      for (int i = 0; i < keys.length; i++) {
        if (rowIndex == 0 && i == 0 && !showGraveKey) continue;

        bool isLastKeyFirstRow = rowIndex == 0 && i == keys.length - 1 && showGraveKey;
        rowWidgets.add(buildKeys(rowIndex, keys[i], i, isLastKeyFirstRow: isLastKeyFirstRow));
      }
    } else {
      int startIndex = (rowIndex == 0 && (keymapStyle != 'Split Matrix' || !showGraveKey)) ? 1 : 0;
      int endIndex = (rowIndex == 0) ? 11 : (use6ColLayout ? 12 : 10);

      // Special handling for first row in Split Matrix with 6 columns
      if (rowIndex == 0 && keymapStyle == 'Split Matrix' && use6ColLayout) {
        rowWidgets.add(buildKeys(rowIndex, keys[0], 0));

        for (int i = 1; i < 6; i++) {
          rowWidgets.add(buildKeys(rowIndex, keys[i], i));
        }

        rowWidgets.add(SizedBox(width: splitWidth));

        for (int i = 6; i < 11; i++) {
          rowWidgets.add(buildKeys(rowIndex, keys[i], i));
        }

        rowWidgets.add(buildKeys(rowIndex, keys[11], 11));
      } else {
        for (int i = startIndex; i < keys.length && i < endIndex; i++) {
          if (keymapStyle == 'Split Matrix') {
            if ((rowIndex == 0 && i == 6) ||
                (i == (use6ColLayout ? 6 : 5) && rowIndex > 0 && rowIndex < 4)) {
              rowWidgets.add(SizedBox(width: splitWidth));
            } else if (i == keys.length ~/ 2 && rowIndex == 4 && keys.length != 1) {
              rowWidgets.add(SizedBox(width: lastRowSplitWidth));
            }
          }

          if (keymapStyle == 'Split Matrix' &&
              rowIndex == 4 &&
              keys[i] == " " &&
              keys.length == 1) {
            rowWidgets.add(buildKeys(rowIndex, keys[i], i));
            rowWidgets.add(SizedBox(width: lastRowSplitWidth));
            rowWidgets.add(buildKeys(rowIndex, keys[i], i));
          } else {
            rowWidgets.add(buildKeys(rowIndex, keys[i], i));
          }
        }
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: rowWidgets,
    );
  }

  Widget buildKeys(int rowIndex, String key, int keyIndex, {bool isLastKeyFirstRow = false}) {
    bool isShiftPressed =
        (keyPressStates["LShift"] ?? false) || (keyPressStates["RShift"] ?? false);
    if (isShiftPressed) {
      if (customShiftMappings != null && customShiftMappings!.containsKey(key)) {
        key = customShiftMappings![key]!;
      } else {
        key = Mappings.getShiftedSymbol(key) ?? key;
      }
    }
    String keyStateKey = Mappings.getKeyForSymbol(key);
    bool isPressed = keyPressStates[keyStateKey] ?? false;

    Color keyColor;
    if (isPressed) {
      keyColor = keyColorPressed;
    } else if (learningModeEnabled && rowIndex < 4) {
      keyColor = getFingerColor(rowIndex, keyIndex);
    } else {
      keyColor = keyColorNotPressed;
    }

    Color textColor = isPressed ? keyTextColor : keyTextColorNotPressed;
    Color tactMarkerColor = isPressed ? markerColor : markerColorNotPressed;
    Color borderColor = isPressed ? keyBorderColorPressed : keyBorderColorNotPressed;

    double width =
        key == " " ? spaceWidth : (isLastKeyFirstRow ? keySize * 2 + keyPadding / 2 : keySize);

    Widget keyWidget = Padding(
      padding: EdgeInsets.all(keyPadding),
      child: AnimatedContainer(
        duration: Duration(milliseconds: animationEnabled ? animationDuration.toInt() : 20),
        curve: Curves.easeInOutCubic,
        width: width,
        height: keySize,
        decoration: BoxDecoration(
            color: keyColor,
            borderRadius: BorderRadius.circular(keyBorderRadius),
            boxShadow: keyShadowBlurRadius > 0
                ? [
                    BoxShadow(
                      blurStyle: BlurStyle.inner,
                      blurRadius: keyShadowBlurRadius,
                      offset: Offset(keyShadowOffsetX, keyShadowOffsetY),
                    ),
                  ]
                : null,
            border: keyBorderThickness > 0
                ? Border.all(
                    color: borderColor,
                    width: keyBorderThickness,
                  )
                : null),
        transform: _getAnimationTransform(isPressed),
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
                            fontSize: key.length > 2 ? keyFontSize * 0.6 : keyFontSize * 0.85,
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
                            fontSize: _getAltLayoutKey(rowIndex, keyIndex).length > 2
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
                        fontSize: key.length > 2 ? keyFontSize * 0.7 : keyFontSize,
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
            child: AnimatedContainer(
              duration: Duration(milliseconds: animationEnabled ? animationDuration.toInt() : 20),
              curve: Curves.easeInOutCubic,
              transform: _getMarkerAnimationTransform(isPressed),
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

  Matrix4 _getAnimationTransform(bool isPressed) {
    if (!animationEnabled || !isPressed) {
      return Matrix4.identity();
    }
    switch (animationStyle.toLowerCase()) {
      case 'depress':
        return Matrix4.translationValues(0, 2 * animationScale, 0); // Move down
      case 'raise':
        return Matrix4.translationValues(0, -2 * animationScale, 0); // Move up
      case 'grow':
        final scaleValue = 1 + 0.05 * animationScale;
        return Matrix4.identity()
          ..scale(scaleValue)
          ..translate(
            -keySize * (scaleValue - 1) / (2 * scaleValue),
            -keySize * (scaleValue - 1) / (2 * scaleValue),
          );
      case 'shrink':
        final scaleValue = 1 - 0.05 * animationScale;
        return Matrix4.identity()
          ..scale(scaleValue)
          ..translate(
            keySize * (1 - scaleValue) / (2 * scaleValue),
            keySize * (1 - scaleValue) / (2 * scaleValue),
          );
      default:
        return Matrix4.translationValues(0, 2 * animationScale, 0); // Default animation
    }
  }

  Matrix4 _getMarkerAnimationTransform(bool isPressed) {
    if (!animationEnabled || !isPressed) {
      return Matrix4.identity();
    }
    switch (animationStyle.toLowerCase()) {
      case 'depress':
        return Matrix4.translationValues(0, 2 * animationScale, 0);
      case 'raise':
        return Matrix4.translationValues(0, -2 * animationScale, 0);
      case 'grow':
        final scaleValue = 1 + 0.05 * animationScale;
        if (showAltLayout) {
          return Matrix4.identity()
            ..scale(scaleValue)
            ..translate(
              -markerWidth * (scaleValue - 1) / (2 * scaleValue),
              -markerWidth * (scaleValue - 1) / (2 * scaleValue),
            );
        } else {
          return Matrix4.identity()
            ..scale(scaleValue)
            ..translate(
              -markerWidth * (scaleValue - 1) / (2 * scaleValue),
              -markerHeight * (scaleValue - 1) / (2 * scaleValue) + 0.8 * animationScale,
            );
        }
      case 'shrink':
        final scaleValue = 1 - 0.05 * animationScale;
        if (showAltLayout) {
          return Matrix4.identity()
            ..scale(scaleValue)
            ..translate(
              markerWidth * (1 - scaleValue) / (2 * scaleValue),
              markerWidth * (1 - scaleValue) / (2 * scaleValue),
            );
        } else {
          return Matrix4.identity()
            ..scale(scaleValue)
            ..translate(
              markerWidth * (1 - scaleValue) / (2 * scaleValue),
              markerHeight * (1 - scaleValue) / (2 * scaleValue) - 0.8 * animationScale,
            );
        }
      default:
        return Matrix4.translationValues(0, 2 * animationScale, 0);
    }
  }

  String _getAltLayoutKey(int rowIndex, int keyIndex) {
    if (altLayout == null || rowIndex >= altLayout!.keys.length) {
      return "";
    }
    List<String> altRow = altLayout!.keys[rowIndex];
    if (keyIndex >= altRow.length) {
      return "";
    }
    String altKey = altRow[keyIndex];
    bool isShiftPressed =
        (keyPressStates["LShift"] ?? false) || (keyPressStates["RShift"] ?? false);
    if (isShiftPressed) {
      if (customShiftMappings != null && customShiftMappings!.containsKey(altKey)) {
        altKey = customShiftMappings![altKey]!;
      } else {
        altKey = Mappings.getShiftedSymbol(altKey) ?? altKey;
      }
    }
    return altKey;
  }

  Color getFingerColor(int rowIndex, int keyIndex) {
    if (rowIndex == 0) {
      keyIndex -= 1;
    }
    switch (keyIndex) {
      case -1:
        return pinkyLeftColor;
      case 0:
        return pinkyLeftColor;
      case 1:
        return ringLeftColor;
      case 2:
        return middleLeftColor;
      case 3:
      case 4:
        return indexLeftColor;
      case 5:
      case 6:
        return indexRightColor;
      case 7:
        return middleRightColor;
      case 8:
        return ringRightColor;
      case 9:
      case 10:
      case 11:
      case 12:
        return pinkyRightColor;
      default:
        return keyColorNotPressed;
    }
  }
}
