import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/keyboard_layouts.dart';
import '../models/mappings.dart';
import '../providers/keyboard_provider.dart';
import '../providers/preferences_provider.dart';

/// Main keyboard overlay screen that displays the virtual keyboard
/// Shows key press states in real-time with customizable styling and layouts
class KeyboardScreen extends ConsumerWidget {
  const KeyboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keyboardState = ref.watch(keyboardNotifierProvider);
    final prefsState = ref.watch(preferencesNotifierProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: keyboardState.layout.keys.asMap().entries.where((entry) {
          return keyboardState.showTopRow || entry.key > 0;
        }).map((entry) {
          int rowIndex = entry.key;
          List<String> row = entry.value;
          return buildRow(
            rowIndex,
            row,
            keyboardState,
            prefsState,
          );
        }).toList(),
      ),
    );
  }

  Widget buildRow(
    int rowIndex,
    List<String> keys,
    KeyboardState keyboardState,
    PreferencesState prefsState,
  ) {
    List<Widget> rowWidgets = [];
    final KeyboardLayout? effectiveAltLayout =
        (prefsState.advancedSettingsEnabled && prefsState.showAltLayout)
            ? prefsState.altLayout
            : null;

    if (keyboardState.keymapStyle != 'Matrix' &&
        keyboardState.keymapStyle != 'Split Matrix') {
      for (int i = 0; i < keys.length; i++) {
        if (rowIndex == 0 && i == 0 && !keyboardState.showGraveKey) continue;

        bool isLastKeyFirstRow =
            rowIndex == 0 && i == keys.length - 1 && keyboardState.showGraveKey;
        rowWidgets.add(buildKeys(
          rowIndex,
          keys[i],
          i,
          isLastKeyFirstRow: isLastKeyFirstRow,
          keyboardState: keyboardState,
          prefsState: prefsState,
          altLayout: effectiveAltLayout,
        ));
      }
    } else {
      int startIndex = (rowIndex == 0 &&
              (keyboardState.keymapStyle != 'Split Matrix' ||
                  !keyboardState.showGraveKey))
          ? 1
          : 0;
      int endIndex = (rowIndex == 0)
          ? 11
          : ((prefsState.use6ColLayout && prefsState.advancedSettingsEnabled)
              ? 12
              : 10);

      // Special handling for first row in Split Matrix with 6 columns
      if (rowIndex == 0 &&
          keyboardState.keymapStyle == 'Split Matrix' &&
          prefsState.use6ColLayout &&
          prefsState.advancedSettingsEnabled) {
        rowWidgets.add(buildKeys(rowIndex, keys[0], 0,
            keyboardState: keyboardState,
            prefsState: prefsState,
            altLayout: effectiveAltLayout));

        for (int i = 1; i < 6; i++) {
          rowWidgets.add(buildKeys(rowIndex, keys[i], i,
              keyboardState: keyboardState,
              prefsState: prefsState,
              altLayout: effectiveAltLayout));
        }

        rowWidgets.add(SizedBox(width: keyboardState.splitWidth));

        for (int i = 6; i < 11; i++) {
          rowWidgets.add(buildKeys(rowIndex, keys[i], i,
              keyboardState: keyboardState,
              prefsState: prefsState,
              altLayout: effectiveAltLayout));
        }

        rowWidgets.add(buildKeys(rowIndex, keys[11], 11,
            keyboardState: keyboardState,
            prefsState: prefsState,
            altLayout: effectiveAltLayout));
      } else {
        for (int i = startIndex; i < keys.length && i < endIndex; i++) {
          if (keyboardState.keymapStyle == 'Split Matrix') {
            if ((rowIndex == 0 && i == 6) ||
                (i ==
                        ((prefsState.use6ColLayout &&
                                prefsState.advancedSettingsEnabled)
                            ? 6
                            : 5) &&
                    rowIndex > 0 &&
                    rowIndex < 4)) {
              rowWidgets.add(SizedBox(width: keyboardState.splitWidth));
            } else if (i == keys.length ~/ 2 &&
                rowIndex == 4 &&
                keys.length != 1) {
              rowWidgets.add(SizedBox(width: keyboardState.lastRowSplitWidth));
            }
          }

          if (keyboardState.keymapStyle == 'Split Matrix' &&
              rowIndex == 4 &&
              keys[i] == " " &&
              keys.length == 1) {
            rowWidgets.add(buildKeys(rowIndex, keys[i], i,
                keyboardState: keyboardState,
                prefsState: prefsState,
                altLayout: effectiveAltLayout));
            rowWidgets.add(SizedBox(width: keyboardState.lastRowSplitWidth));
            rowWidgets.add(buildKeys(rowIndex, keys[i], i,
                keyboardState: keyboardState,
                prefsState: prefsState,
                altLayout: effectiveAltLayout));
          } else {
            rowWidgets.add(buildKeys(rowIndex, keys[i], i,
                keyboardState: keyboardState,
                prefsState: prefsState,
                altLayout: effectiveAltLayout));
          }
        }
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: rowWidgets,
    );
  }

  Widget buildKeys(
    int rowIndex,
    String key,
    int keyIndex, {
    bool isLastKeyFirstRow = false,
    required KeyboardState keyboardState,
    required PreferencesState prefsState,
    KeyboardLayout? altLayout,
  }) {
    key = _getShiftedKey(key, keyboardState, prefsState);
    String realKey = (keyboardState.layout.foreign ?? false)
        ? qwerty.keys[rowIndex][keyIndex]
        : key;

    String keyStateKey = Mappings.getKeyForSymbol(realKey);
    bool isPressed = keyboardState.keyPressStates[keyStateKey] ?? false;

    // Adjust key index for 6-column layouts (extra backtick column shifts indices by 1)
    keyIndex -= (prefsState.use6ColLayout && prefsState.advancedSettingsEnabled)
        ? 1
        : 0;
    Color keyColor;
    if (isPressed) {
      keyColor = keyboardState.keyColorPressed;
    } else if (keyboardState.learningModeEnabled && rowIndex < 4) {
      keyColor = getFingerColor(rowIndex, keyIndex, keyboardState, prefsState);
    } else {
      keyColor = keyboardState.keyColorNotPressed;
    }

    Color textColor = isPressed
        ? keyboardState.keyTextColor
        : keyboardState.keyTextColorNotPressed;
    Color tactMarkerColor = isPressed
        ? keyboardState.markerColor
        : keyboardState.markerColorNotPressed;
    Color borderColor = isPressed
        ? keyboardState.keyBorderColorPressed
        : keyboardState.keyBorderColorNotPressed;

    double width = key == " "
        ? keyboardState.spaceWidth
        : (isLastKeyFirstRow
            ? keyboardState.keySize * 2 + keyboardState.keyPadding / 2
            : keyboardState.keySize);

    Widget keyWidget = Padding(
      padding: EdgeInsets.all(keyboardState.keyPadding),
      child: AnimatedContainer(
        duration: Duration(
            milliseconds: keyboardState.animationEnabled
                ? keyboardState.animationDuration.toInt()
                : 20),
        curve: Curves.easeInOutCubic,
        width: width,
        height: keyboardState.keySize,
        decoration: BoxDecoration(
            color: keyColor,
            borderRadius: BorderRadius.circular(keyboardState.keyBorderRadius),
            boxShadow: keyboardState.keyShadowBlurRadius > 0
                ? [
                    BoxShadow(
                      blurRadius: keyboardState.keyShadowBlurRadius,
                      offset: Offset(keyboardState.keyShadowOffsetX,
                          keyboardState.keyShadowOffsetY),
                    ),
                  ]
                : null,
            border: keyboardState.keyBorderThickness > 0
                ? Border.all(
                    color: borderColor,
                    width: keyboardState.keyBorderThickness,
                  )
                : null),
        transform: _getAnimationTransform(isPressed, keyboardState),
        child: key == " "
            ? Center(
                child: Text(
                  altLayout != null
                      ? "${keyboardState.layout.name.toLowerCase()} (${altLayout.name.toLowerCase()})"
                      : keyboardState.layout.name.toLowerCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: keyboardState.spaceFontSize,
                    fontWeight: keyboardState.fontWeight,
                  ),
                ),
              )
            : altLayout != null
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
                                ? keyboardState.keyFontSize * 0.6
                                : keyboardState.keyFontSize * 0.85,
                            fontWeight: keyboardState.fontWeight,
                          ),
                        ),
                      ),
                      // Alt layout key (bottom right)
                      Positioned(
                        bottom: 4,
                        right: 8,
                        child: Text(
                          _getAltLayoutKey(rowIndex, keyIndex, keyboardState,
                              prefsState, altLayout),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: textColor,
                            fontSize: _getAltLayoutKey(
                                            rowIndex,
                                            keyIndex,
                                            keyboardState,
                                            prefsState,
                                            altLayout)
                                        .length >
                                    2
                                ? keyboardState.keyFontSize * 0.6
                                : keyboardState.keyFontSize * 0.85,
                            fontWeight: keyboardState.fontWeight,
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
                        fontSize: key.length > 2
                            ? keyboardState.keyFontSize * 0.7
                            : keyboardState.keyFontSize,
                        fontWeight: keyboardState.fontWeight,
                      ),
                    ),
                  ),
      ),
    );

    // Tactile Markers
    if (rowIndex == 2 && (keyIndex == 3 || keyIndex == 6)) {
      keyWidget = Stack(
        alignment:
            altLayout != null ? Alignment.center : Alignment.bottomCenter,
        children: [
          keyWidget,
          Positioned(
            bottom: altLayout != null ? null : keyboardState.markerOffset,
            child: AnimatedContainer(
              duration: Duration(
                  milliseconds: keyboardState.animationEnabled
                      ? keyboardState.animationDuration.toInt()
                      : 20),
              curve: Curves.easeInOutCubic,
              transform: _getMarkerAnimationTransform(
                  isPressed, keyboardState, altLayout),
              width: keyboardState.markerWidth * (altLayout != null ? 0.5 : 1),
              height: altLayout != null
                  ? keyboardState.markerWidth * 0.5
                  : keyboardState.markerHeight,
              decoration: BoxDecoration(
                color: tactMarkerColor,
                borderRadius:
                    BorderRadius.circular(keyboardState.markerBorderRadius),
              ),
            ),
          ),
        ],
      );
    }
    return keyWidget;
  }

  Matrix4 _getAnimationTransform(bool isPressed, KeyboardState keyboardState) {
    if (!keyboardState.animationEnabled || !isPressed) {
      return Matrix4.identity();
    }
    switch (keyboardState.animationStyle.toLowerCase()) {
      case 'depress':
        return Matrix4.translationValues(
            0, 2 * keyboardState.animationScale, 0); // Move down
      case 'raise':
        return Matrix4.translationValues(
            0, -2 * keyboardState.animationScale, 0); // Move up
      case 'grow':
        final scaleValue = 1 + 0.05 * keyboardState.animationScale;
        return Matrix4.identity()
          ..scaleByDouble(scaleValue, scaleValue, 1, 1)
          ..translateByDouble(
              -keyboardState.keySize * (scaleValue - 1) / (2 * scaleValue),
              -keyboardState.keySize * (scaleValue - 1) / (2 * scaleValue),
              1,
              1);
      case 'shrink':
        final scaleValue = 1 - 0.05 * keyboardState.animationScale;
        return Matrix4.identity()
          ..scaleByDouble(scaleValue, scaleValue, 1, 1)
          ..translateByDouble(
              keyboardState.keySize * (1 - scaleValue) / (2 * scaleValue),
              keyboardState.keySize * (1 - scaleValue) / (2 * scaleValue),
              1,
              1);
      default:
        return Matrix4.translationValues(
            0, 2 * keyboardState.animationScale, 0); // Default animation
    }
  }

  Matrix4 _getMarkerAnimationTransform(
      bool isPressed, KeyboardState keyboardState, KeyboardLayout? altLayout) {
    if (!keyboardState.animationEnabled || !isPressed) {
      return Matrix4.identity();
    }
    switch (keyboardState.animationStyle.toLowerCase()) {
      case 'depress':
        return Matrix4.translationValues(
            0, 2 * keyboardState.animationScale, 0);
      case 'raise':
        return Matrix4.translationValues(
            0, -2 * keyboardState.animationScale, 0);
      case 'grow':
        final scaleValue = 1 + 0.05 * keyboardState.animationScale;
        if (altLayout != null) {
          return Matrix4.identity()
            ..scaleByDouble(scaleValue, scaleValue, 1, 1)
            ..translateByDouble(
                -keyboardState.markerWidth *
                    (scaleValue - 1) /
                    (2 * scaleValue),
                -keyboardState.markerWidth *
                    (scaleValue - 1) /
                    (2 * scaleValue),
                1,
                1);
        } else {
          return Matrix4.identity()
            ..scaleByDouble(scaleValue, scaleValue, 1, 1)
            ..translateByDouble(
                -keyboardState.markerWidth *
                    (scaleValue - 1) /
                    (2 * scaleValue),
                -keyboardState.markerHeight *
                        (scaleValue - 1) /
                        (2 * scaleValue) +
                    0.8 * keyboardState.animationScale,
                1,
                1);
        }
      case 'shrink':
        final scaleValue = 1 - 0.05 * keyboardState.animationScale;
        if (altLayout != null) {
          return Matrix4.identity()
            ..scaleByDouble(scaleValue, scaleValue, 1, 1)
            ..translateByDouble(
                keyboardState.markerWidth * (1 - scaleValue) / (2 * scaleValue),
                keyboardState.markerWidth * (1 - scaleValue) / (2 * scaleValue),
                1,
                1);
        } else {
          return Matrix4.identity()
            ..scaleByDouble(scaleValue, scaleValue, 1, 1)
            ..translateByDouble(
                keyboardState.markerWidth * (1 - scaleValue) / (2 * scaleValue),
                keyboardState.markerHeight *
                        (1 - scaleValue) /
                        (2 * scaleValue) -
                    0.8 * keyboardState.animationScale,
                1,
                1);
        }
      default:
        return Matrix4.translationValues(
            0, 2 * keyboardState.animationScale, 0);
    }
  }

  String _getShiftedKey(
    String key,
    KeyboardState keyboardState,
    PreferencesState prefsState,
  ) {
    bool isShiftPressed = (keyboardState.keyPressStates["LShift"] ?? false) ||
        (keyboardState.keyPressStates["RShift"] ?? false);

    if (isShiftPressed &&
        prefsState.reactiveShiftEnabled &&
        keyboardState.fontFamily != '') {
      if (keyboardState.customShiftMappings != null &&
          keyboardState.customShiftMappings!.containsKey(key)) {
        return keyboardState.customShiftMappings![key]!;
      }
      return Mappings.getShiftedSymbol(key) ?? key;
    }
    return key;
  }

  String _getAltLayoutKey(
      int rowIndex,
      int keyIndex,
      KeyboardState keyboardState,
      PreferencesState prefsState,
      KeyboardLayout? altLayout) {
    // Adjust key index for 6-column layouts when retrieving alternative layout keys
    keyIndex += (prefsState.use6ColLayout && prefsState.advancedSettingsEnabled)
        ? 1
        : 0;
    if (altLayout == null || rowIndex >= altLayout.keys.length) {
      return "";
    }
    List<String> altRow = altLayout.keys[rowIndex];
    if (keyIndex >= altRow.length) {
      return "";
    }
    String altKey = altRow[keyIndex];
    altKey = _getShiftedKey(altKey, keyboardState, prefsState);
    return altKey;
  }

  Color getFingerColor(int rowIndex, int keyIndex, KeyboardState keyboardState,
      PreferencesState prefsState) {
    // On top row (row 0), adjust index by 1 unless using 6-column layout (which already accounts for it)
    if (rowIndex == 0 &&
        !(prefsState.use6ColLayout && prefsState.advancedSettingsEnabled)) {
      keyIndex -= 1;
    }
    switch (keyIndex) {
      case -1:
        return keyboardState.pinkyLeftColor;
      case 0:
        return keyboardState.pinkyLeftColor;
      case 1:
        return keyboardState.ringLeftColor;
      case 2:
        return keyboardState.middleLeftColor;
      case 3:
      case 4:
        return keyboardState.indexLeftColor;
      case 5:
      case 6:
        return keyboardState.indexRightColor;
      case 7:
        return keyboardState.middleRightColor;
      case 8:
        return keyboardState.ringRightColor;
      case 9:
      case 10:
      case 11:
      case 12:
        return keyboardState.pinkyRightColor;
      default:
        return keyboardState.keyColorNotPressed;
    }
  }
}
