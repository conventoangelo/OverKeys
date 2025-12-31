import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:overkeys/models/keyboard_layouts.dart';

part 'keyboard_provider.g.dart';

/// State class for keyboard display configuration and appearance
/// Manages layout, styling, colors, animations, and key press states
class KeyboardState {
  final KeyboardLayout layout;
  final KeyboardLayout? initialLayout;
  final Map<String, bool> keyPressStates;
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
  final String fontFamily;
  final String? initialFontFamily;
  final FontWeight fontWeight;
  final double keyFontSize;
  final double spaceFontSize;
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
  final Map<String, String>? customShiftMappings;
  final bool kanataEnabled;
  final bool showAltLayout;

  KeyboardState({
    required this.layout,
    this.initialLayout,
    this.keyPressStates = const {},
    this.keymapStyle = 'Staggered',
    this.showTopRow = false,
    this.showGraveKey = false,
    this.keySize = 52,
    this.keyBorderRadius = 14,
    this.keyBorderThickness = 0,
    this.keyPadding = 2,
    this.spaceWidth = 330,
    this.splitWidth = 200,
    this.lastRowSplitWidth = 90,
    this.keyShadowBlurRadius = 0,
    this.keyShadowOffsetX = 2,
    this.keyShadowOffsetY = 2,
    this.fontFamily = 'DM Mono',
    this.initialFontFamily,
    this.fontWeight = FontWeight.w500,
    this.keyFontSize = 22,
    this.spaceFontSize = 21,
    this.markerOffset = 10,
    this.markerWidth = 10,
    this.markerHeight = 2.5,
    this.markerBorderRadius = 3,
    this.keyColorPressed = const Color(0xFFA87FFB),
    this.keyColorNotPressed = const Color(0xFF10151D),
    this.markerColor = const Color(0xFF10151D),
    this.markerColorNotPressed = const Color(0xFFFAFBFE),
    this.keyTextColor = const Color(0xFF10151D),
    this.keyTextColorNotPressed = const Color(0xFFFAFBFE),
    this.keyBorderColorPressed = Colors.black,
    this.keyBorderColorNotPressed = Colors.white,
    this.animationEnabled = true,
    this.animationStyle = 'Raise',
    this.animationDuration = 80,
    this.animationScale = 2.0,
    this.learningModeEnabled = false,
    this.pinkyLeftColor = const Color(0xFFED3345),
    this.ringLeftColor = const Color(0xFFFAA71D),
    this.middleLeftColor = const Color(0xFF70C27B),
    this.indexLeftColor = const Color(0xFF00AFEB),
    this.indexRightColor = const Color(0xFF5985BF),
    this.middleRightColor = const Color(0xFF97D6F5),
    this.ringRightColor = const Color(0xFFFFE8A0),
    this.pinkyRightColor = const Color(0xFFBDE0BF),
    this.customShiftMappings,
    this.kanataEnabled = false,
    this.showAltLayout = false,
  });

  KeyboardState copyWith({
    KeyboardLayout? layout,
    KeyboardLayout? initialLayout,
    Map<String, bool>? keyPressStates,
    String? keymapStyle,
    bool? showTopRow,
    bool? showGraveKey,
    double? keySize,
    double? keyBorderRadius,
    double? keyBorderThickness,
    double? keyPadding,
    double? spaceWidth,
    double? splitWidth,
    double? lastRowSplitWidth,
    double? keyShadowBlurRadius,
    double? keyShadowOffsetX,
    double? keyShadowOffsetY,
    String? fontFamily,
    String? initialFontFamily,
    FontWeight? fontWeight,
    double? keyFontSize,
    double? spaceFontSize,
    double? markerOffset,
    double? markerWidth,
    double? markerHeight,
    double? markerBorderRadius,
    Color? keyColorPressed,
    Color? keyColorNotPressed,
    Color? markerColor,
    Color? markerColorNotPressed,
    Color? keyTextColor,
    Color? keyTextColorNotPressed,
    Color? keyBorderColorPressed,
    Color? keyBorderColorNotPressed,
    bool? animationEnabled,
    String? animationStyle,
    double? animationDuration,
    double? animationScale,
    bool? learningModeEnabled,
    Color? pinkyLeftColor,
    Color? ringLeftColor,
    Color? middleLeftColor,
    Color? indexLeftColor,
    Color? indexRightColor,
    Color? middleRightColor,
    Color? ringRightColor,
    Color? pinkyRightColor,
    Map<String, String>? customShiftMappings,
    bool? kanataEnabled,
    bool? showAltLayout,
  }) {
    return KeyboardState(
      layout: layout ?? this.layout,
      initialLayout: initialLayout ?? this.initialLayout,
      keyPressStates: keyPressStates ?? this.keyPressStates,
      keymapStyle: keymapStyle ?? this.keymapStyle,
      showTopRow: showTopRow ?? this.showTopRow,
      showGraveKey: showGraveKey ?? this.showGraveKey,
      keySize: keySize ?? this.keySize,
      keyBorderRadius: keyBorderRadius ?? this.keyBorderRadius,
      keyBorderThickness: keyBorderThickness ?? this.keyBorderThickness,
      keyPadding: keyPadding ?? this.keyPadding,
      spaceWidth: spaceWidth ?? this.spaceWidth,
      splitWidth: splitWidth ?? this.splitWidth,
      lastRowSplitWidth: lastRowSplitWidth ?? this.lastRowSplitWidth,
      keyShadowBlurRadius: keyShadowBlurRadius ?? this.keyShadowBlurRadius,
      keyShadowOffsetX: keyShadowOffsetX ?? this.keyShadowOffsetX,
      keyShadowOffsetY: keyShadowOffsetY ?? this.keyShadowOffsetY,
      fontFamily: fontFamily ?? this.fontFamily,
      initialFontFamily: initialFontFamily ?? this.initialFontFamily,
      fontWeight: fontWeight ?? this.fontWeight,
      keyFontSize: keyFontSize ?? this.keyFontSize,
      spaceFontSize: spaceFontSize ?? this.spaceFontSize,
      markerOffset: markerOffset ?? this.markerOffset,
      markerWidth: markerWidth ?? this.markerWidth,
      markerHeight: markerHeight ?? this.markerHeight,
      markerBorderRadius: markerBorderRadius ?? this.markerBorderRadius,
      keyColorPressed: keyColorPressed ?? this.keyColorPressed,
      keyColorNotPressed: keyColorNotPressed ?? this.keyColorNotPressed,
      markerColor: markerColor ?? this.markerColor,
      markerColorNotPressed:
          markerColorNotPressed ?? this.markerColorNotPressed,
      keyTextColor: keyTextColor ?? this.keyTextColor,
      keyTextColorNotPressed:
          keyTextColorNotPressed ?? this.keyTextColorNotPressed,
      keyBorderColorPressed:
          keyBorderColorPressed ?? this.keyBorderColorPressed,
      keyBorderColorNotPressed:
          keyBorderColorNotPressed ?? this.keyBorderColorNotPressed,
      animationEnabled: animationEnabled ?? this.animationEnabled,
      animationStyle: animationStyle ?? this.animationStyle,
      animationDuration: animationDuration ?? this.animationDuration,
      animationScale: animationScale ?? this.animationScale,
      learningModeEnabled: learningModeEnabled ?? this.learningModeEnabled,
      pinkyLeftColor: pinkyLeftColor ?? this.pinkyLeftColor,
      ringLeftColor: ringLeftColor ?? this.ringLeftColor,
      middleLeftColor: middleLeftColor ?? this.middleLeftColor,
      indexLeftColor: indexLeftColor ?? this.indexLeftColor,
      indexRightColor: indexRightColor ?? this.indexRightColor,
      middleRightColor: middleRightColor ?? this.middleRightColor,
      ringRightColor: ringRightColor ?? this.ringRightColor,
      pinkyRightColor: pinkyRightColor ?? this.pinkyRightColor,
      customShiftMappings: customShiftMappings ?? this.customShiftMappings,
      kanataEnabled: kanataEnabled ?? this.kanataEnabled,
      showAltLayout: showAltLayout ?? this.showAltLayout,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'layoutName': layout.name,
      'initialLayoutName': initialLayout?.name,
      'keymapStyle': keymapStyle,
      'showTopRow': showTopRow,
      'showGraveKey': showGraveKey,
      'keySize': keySize,
      'keyBorderRadius': keyBorderRadius,
      'keyBorderThickness': keyBorderThickness,
      'keyPadding': keyPadding,
      'spaceWidth': spaceWidth,
      'splitWidth': splitWidth,
      'lastRowSplitWidth': lastRowSplitWidth,
      'keyShadowBlurRadius': keyShadowBlurRadius,
      'keyShadowOffsetX': keyShadowOffsetX,
      'keyShadowOffsetY': keyShadowOffsetY,
      'fontFamily': fontFamily,
      'initialFontFamily': initialFontFamily,
      'fontWeightIndex': fontWeight.index,
      'keyFontSize': keyFontSize,
      'spaceFontSize': spaceFontSize,
      'markerOffset': markerOffset,
      'markerWidth': markerWidth,
      'markerHeight': markerHeight,
      'markerBorderRadius': markerBorderRadius,
      'keyColorPressed': keyColorPressed.toARGB32(),
      'keyColorNotPressed': keyColorNotPressed.toARGB32(),
      'markerColor': markerColor.toARGB32(),
      'markerColorNotPressed': markerColorNotPressed.toARGB32(),
      'keyTextColor': keyTextColor.toARGB32(),
      'keyTextColorNotPressed': keyTextColorNotPressed.toARGB32(),
      'keyBorderColorPressed': keyBorderColorPressed.toARGB32(),
      'keyBorderColorNotPressed': keyBorderColorNotPressed.toARGB32(),
      'animationEnabled': animationEnabled,
      'animationStyle': animationStyle,
      'animationDuration': animationDuration,
      'animationScale': animationScale,
      'learningModeEnabled': learningModeEnabled,
      'pinkyLeftColor': pinkyLeftColor.toARGB32(),
      'ringLeftColor': ringLeftColor.toARGB32(),
      'middleLeftColor': middleLeftColor.toARGB32(),
      'indexLeftColor': indexLeftColor.toARGB32(),
      'indexRightColor': indexRightColor.toARGB32(),
      'middleRightColor': middleRightColor.toARGB32(),
      'ringRightColor': ringRightColor.toARGB32(),
      'pinkyRightColor': pinkyRightColor.toARGB32(),
      'customShiftMappings': customShiftMappings,
      'kanataEnabled': kanataEnabled,
      'showAltLayout': showAltLayout,
    };
  }

  factory KeyboardState.fromJson(Map<String, dynamic> json) {
    final layoutName = json['layoutName'] as String? ?? 'QWERTY';
    final layout = availableLayouts.firstWhere(
      (l) => l.name == layoutName,
      orElse: () => qwerty,
    );

    final initialLayoutName = json['initialLayoutName'] as String?;
    final initialLayout = initialLayoutName != null
        ? availableLayouts.firstWhere(
            (l) => l.name == initialLayoutName,
            orElse: () => qwerty,
          )
        : null;

    return KeyboardState(
      layout: layout,
      initialLayout: initialLayout,
      keymapStyle: json['keymapStyle'] as String? ?? 'Staggered',
      showTopRow: json['showTopRow'] as bool? ?? false,
      showGraveKey: json['showGraveKey'] as bool? ?? false,
      keySize: (json['keySize'] as num?)?.toDouble() ?? 52,
      keyBorderRadius: (json['keyBorderRadius'] as num?)?.toDouble() ?? 14,
      keyBorderThickness: (json['keyBorderThickness'] as num?)?.toDouble() ?? 0,
      keyPadding: (json['keyPadding'] as num?)?.toDouble() ?? 2,
      spaceWidth: (json['spaceWidth'] as num?)?.toDouble() ?? 330,
      splitWidth: (json['splitWidth'] as num?)?.toDouble() ?? 200,
      lastRowSplitWidth: (json['lastRowSplitWidth'] as num?)?.toDouble() ?? 90,
      keyShadowBlurRadius:
          (json['keyShadowBlurRadius'] as num?)?.toDouble() ?? 0,
      keyShadowOffsetX: (json['keyShadowOffsetX'] as num?)?.toDouble() ?? 2,
      keyShadowOffsetY: (json['keyShadowOffsetY'] as num?)?.toDouble() ?? 2,
      fontFamily: json['fontFamily'] as String? ?? 'DM Mono',
      initialFontFamily: json['initialFontFamily'] as String?,
      fontWeight: FontWeight.values[json['fontWeightIndex'] as int? ?? 4],
      keyFontSize: (json['keyFontSize'] as num?)?.toDouble() ?? 22,
      spaceFontSize: (json['spaceFontSize'] as num?)?.toDouble() ?? 21,
      markerOffset: (json['markerOffset'] as num?)?.toDouble() ?? 10,
      markerWidth: (json['markerWidth'] as num?)?.toDouble() ?? 10,
      markerHeight: (json['markerHeight'] as num?)?.toDouble() ?? 2.5,
      markerBorderRadius: (json['markerBorderRadius'] as num?)?.toDouble() ?? 3,
      keyColorPressed: Color(json['keyColorPressed'] as int? ?? 0xFFA87FFB),
      keyColorNotPressed:
          Color(json['keyColorNotPressed'] as int? ?? 0xFF10151D),
      markerColor: Color(json['markerColor'] as int? ?? 0xFF10151D),
      markerColorNotPressed:
          Color(json['markerColorNotPressed'] as int? ?? 0xFFFAFBFE),
      keyTextColor: Color(json['keyTextColor'] as int? ?? 0xFF10151D),
      keyTextColorNotPressed:
          Color(json['keyTextColorNotPressed'] as int? ?? 0xFFFAFBFE),
      keyBorderColorPressed:
          Color(json['keyBorderColorPressed'] as int? ?? 0xFF000000),
      keyBorderColorNotPressed:
          Color(json['keyBorderColorNotPressed'] as int? ?? 0xFFFFFFFF),
      animationEnabled: json['animationEnabled'] as bool? ?? true,
      animationStyle: json['animationStyle'] as String? ?? 'Raise',
      animationDuration: (json['animationDuration'] as num?)?.toDouble() ?? 80,
      animationScale: (json['animationScale'] as num?)?.toDouble() ?? 2.0,
      learningModeEnabled: json['learningModeEnabled'] as bool? ?? false,
      pinkyLeftColor: Color(json['pinkyLeftColor'] as int? ?? 0xFFED3345),
      ringLeftColor: Color(json['ringLeftColor'] as int? ?? 0xFFFAA71D),
      middleLeftColor: Color(json['middleLeftColor'] as int? ?? 0xFF70C27B),
      indexLeftColor: Color(json['indexLeftColor'] as int? ?? 0xFF00AFEB),
      indexRightColor: Color(json['indexRightColor'] as int? ?? 0xFF5985BF),
      middleRightColor: Color(json['middleRightColor'] as int? ?? 0xFF97D6F5),
      ringRightColor: Color(json['ringRightColor'] as int? ?? 0xFFFFE8A0),
      pinkyRightColor: Color(json['pinkyRightColor'] as int? ?? 0xFFBDE0BF),
      customShiftMappings: json['customShiftMappings'] != null
          ? Map<String, String>.from(json['customShiftMappings'] as Map)
          : null,
      kanataEnabled: json['kanataEnabled'] as bool? ?? false,
      showAltLayout: json['showAltLayout'] as bool? ?? false,
    );
  }
}

@riverpod
class KeyboardNotifier extends _$KeyboardNotifier {
  @override
  KeyboardState build() {
    return KeyboardState(layout: qwerty);
  }

  void updateLayout(KeyboardLayout layout) {
    state = state.copyWith(layout: layout);
  }

  void updateKeyPressState(String key, bool isPressed) {
    final newStates = {...state.keyPressStates};
    newStates[key] = isPressed;
    state = state.copyWith(keyPressStates: newStates);
  }

  void clearKeyPressStates() {
    state = state.copyWith(keyPressStates: {});
  }

  void updateKeymapStyle(String style) {
    state = state.copyWith(keymapStyle: style);
  }

  void updateShowTopRow(bool value) {
    state = state.copyWith(showTopRow: value);
  }

  void updateShowGraveKey(bool value) {
    state = state.copyWith(showGraveKey: value);
  }

  void updateKeySize(double size) {
    state = state.copyWith(keySize: size);
  }

  void updateKeyBorderRadius(double radius) {
    state = state.copyWith(keyBorderRadius: radius);
  }

  void updateKeyBorderThickness(double thickness) {
    state = state.copyWith(keyBorderThickness: thickness);
  }

  void updateKeyPadding(double padding) {
    state = state.copyWith(keyPadding: padding);
  }

  void updateSpaceWidth(double width) {
    state = state.copyWith(spaceWidth: width);
  }

  void updateSplitWidth(double width) {
    state = state.copyWith(splitWidth: width);
  }

  void updateLastRowSplitWidth(double width) {
    state = state.copyWith(lastRowSplitWidth: width);
  }

  void updateKeyShadowBlurRadius(double radius) {
    state = state.copyWith(keyShadowBlurRadius: radius);
  }

  void updateKeyShadowOffsetX(double offset) {
    state = state.copyWith(keyShadowOffsetX: offset);
  }

  void updateKeyShadowOffsetY(double offset) {
    state = state.copyWith(keyShadowOffsetY: offset);
  }

  void updateFontFamily(String family) {
    state = state.copyWith(fontFamily: family);
  }

  void updateFontWeight(FontWeight weight) {
    state = state.copyWith(fontWeight: weight);
  }

  void updateKeyFontSize(double size) {
    state = state.copyWith(keyFontSize: size);
  }

  void updateSpaceFontSize(double size) {
    state = state.copyWith(spaceFontSize: size);
  }

  void updateMarkerOffset(double offset) {
    state = state.copyWith(markerOffset: offset);
  }

  void updateMarkerWidth(double width) {
    state = state.copyWith(markerWidth: width);
  }

  void updateMarkerHeight(double height) {
    state = state.copyWith(markerHeight: height);
  }

  void updateMarkerBorderRadius(double radius) {
    state = state.copyWith(markerBorderRadius: radius);
  }

  void updateKeyColorPressed(Color color) {
    state = state.copyWith(keyColorPressed: color);
  }

  void updateKeyColorNotPressed(Color color) {
    state = state.copyWith(keyColorNotPressed: color);
  }

  void updateMarkerColor(Color color) {
    state = state.copyWith(markerColor: color);
  }

  void updateMarkerColorNotPressed(Color color) {
    state = state.copyWith(markerColorNotPressed: color);
  }

  void updateKeyTextColor(Color color) {
    state = state.copyWith(keyTextColor: color);
  }

  void updateKeyTextColorNotPressed(Color color) {
    state = state.copyWith(keyTextColorNotPressed: color);
  }

  void updateKeyBorderColorPressed(Color color) {
    state = state.copyWith(keyBorderColorPressed: color);
  }

  void updateKeyBorderColorNotPressed(Color color) {
    state = state.copyWith(keyBorderColorNotPressed: color);
  }

  void updateAnimationEnabled(bool value) {
    state = state.copyWith(animationEnabled: value);
  }

  void updateAnimationStyle(String style) {
    state = state.copyWith(animationStyle: style);
  }

  void updateAnimationDuration(double duration) {
    state = state.copyWith(animationDuration: duration);
  }

  void updateAnimationScale(double scale) {
    state = state.copyWith(animationScale: scale);
  }

  void updateLearningModeEnabled(bool value) {
    state = state.copyWith(learningModeEnabled: value);
  }

  void updatePinkyLeftColor(Color color) {
    state = state.copyWith(pinkyLeftColor: color);
  }

  void updateRingLeftColor(Color color) {
    state = state.copyWith(ringLeftColor: color);
  }

  void updateMiddleLeftColor(Color color) {
    state = state.copyWith(middleLeftColor: color);
  }

  void updateIndexLeftColor(Color color) {
    state = state.copyWith(indexLeftColor: color);
  }

  void updateIndexRightColor(Color color) {
    state = state.copyWith(indexRightColor: color);
  }

  void updateMiddleRightColor(Color color) {
    state = state.copyWith(middleRightColor: color);
  }

  void updateRingRightColor(Color color) {
    state = state.copyWith(ringRightColor: color);
  }

  void updatePinkyRightColor(Color color) {
    state = state.copyWith(pinkyRightColor: color);
  }

  void updateCustomShiftMappings(Map<String, String>? mappings) {
    state = state.copyWith(customShiftMappings: mappings);
  }

  void updateInitialLayout(KeyboardLayout layout) {
    state = state.copyWith(initialLayout: layout);
  }

  void updateInitialFontFamily(String family) {
    state = state.copyWith(initialFontFamily: family);
  }

  void updateKanataEnabled(bool value) {
    state = state.copyWith(kanataEnabled: value);
  }

  void updateShowAltLayout(bool value) {
    state = state.copyWith(showAltLayout: value);
  }

  void updateKeyboardState(KeyboardState newState) {
    state = newState;
  }
}
