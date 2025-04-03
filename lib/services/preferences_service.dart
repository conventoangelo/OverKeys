import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  // General settings
  Future<bool> getLaunchAtStartup() async =>
      await _prefs.getBool('launchAtStartup') ?? false;
  Future<bool> getAutoHideEnabled() async =>
      await _prefs.getBool('autoHideEnabled') ?? false;
  Future<double> getAutoHideDuration() async =>
      await _prefs.getDouble('autoHideDuration') ?? 2.0;
  Future<double> getOpacity() async => await _prefs.getDouble('opacity') ?? 0.6;
  Future<String> getKeyboardLayoutName() async =>
      await _prefs.getString('layout') ?? 'QWERTY';

  // Keyboard settings
  Future<String> getKeymapStyle() async =>
      await _prefs.getString('keymapStyle') ?? 'Staggered';
  Future<bool> getShowTopRow() async =>
      await _prefs.getBool('showTopRow') ?? false;
  Future<bool> getShowGraveKey() async =>
      await _prefs.getBool('showGraveKey') ?? false;
  Future<double> getKeySize() async => await _prefs.getDouble('keySize') ?? 48;
  Future<double> getKeyBorderRadius() async =>
      await _prefs.getDouble('keyBorderRadius') ?? 12;
  Future<double> getKeyPadding() async =>
      await _prefs.getDouble('keyPadding') ?? 3;
  Future<double> getSpaceWidth() async =>
      await _prefs.getDouble('spaceWidth') ?? 320;
  Future<double> getSplitWidth() async =>
      await _prefs.getDouble('splitWidth') ?? 100;
  Future<double> getLastRowSplitWidth() async =>
      await _prefs.getDouble('lastRowSplitWidth') ?? 100;
  Future<double> getKeyBorderThickness() async =>
      await _prefs.getDouble('keyBorderThickness') ?? 0;

  // Text settings
  Future<String> getFontFamily() async =>
      await _prefs.getString('fontFamily') ?? 'GeistMono';
  Future<FontWeight> getFontWeight() async => FontWeight
      .values[await _prefs.getInt('fontWeight') ?? FontWeight.w500.index];
  Future<double> getKeyFontSize() async =>
      await _prefs.getDouble('keyFontSize') ?? 20;
  Future<double> getSpaceFontSize() async =>
      await _prefs.getDouble('spaceFontSize') ?? 14;

  // Markers settings
  Future<double> getMarkerOffset() async =>
      await _prefs.getDouble('markerOffset') ?? 10;
  Future<double> getMarkerWidth() async =>
      await _prefs.getDouble('markerWidth') ?? 10;
  Future<double> getMarkerHeight() async =>
      await _prefs.getDouble('markerHeight') ?? 2;
  Future<double> getMarkerBorderRadius() async =>
      await _prefs.getDouble('markerBorderRadius') ?? 10;

  // Colors settings
  Future<Color> getKeyColorPressed() async =>
      Color(await _prefs.getInt('keyColorPressed') ?? 0xFF1E1E1E);
  Future<Color> getKeyColorNotPressed() async =>
      Color(await _prefs.getInt('keyColorNotPressed') ?? 0xFF77ABFF);
  Future<Color> getMarkerColor() async =>
      Color(await _prefs.getInt('markerColor') ?? 0xFFFFFFFF);
  Future<Color> getMarkerColorNotPressed() async =>
      Color(await _prefs.getInt('markerColorNotPressed') ?? 0xFF000000);
  Future<Color> getKeyTextColor() async =>
      Color(await _prefs.getInt('keyTextColor') ?? 0xFFFFFFFF);
  Future<Color> getKeyTextColorNotPressed() async =>
      Color(await _prefs.getInt('keyTextColorNotPressed') ?? 0xFF000000);
  Future<Color> getKeyBorderColorPressed() async =>
      Color(await _prefs.getInt('keyBorderColorPressed') ?? 0xFF000000);
  Future<Color> getKeyBorderColorNotPressed() async =>
      Color(await _prefs.getInt('keyBorderColorNotPressed') ?? 0xFFFFFFFF);

  // Animations settings
  Future<bool> getAnimationEnabled() async =>
      await _prefs.getBool('animationEnabled') ?? false;
  Future<String> getAnimationStyle() async =>
      await _prefs.getString('animationStyle') ?? 'Raise';
  Future<double> getAnimationDuration() async =>
      await _prefs.getDouble('animationDuration') ?? 100;
  Future<double> getAnimationScale() async =>
      await _prefs.getDouble('animationScale') ?? 2.0;

  // HotKey settings
  Future<bool> getHotKeysEnabled() async =>
      await _prefs.getBool('enableHotKeys') ?? false;
  Future<HotKey?> getVisibilityHotKey() async {
    final json = await _prefs.getString('visibilityHotKey');
    try {
      return HotKey.fromJson(jsonDecode(json!));
    } catch (e) {
      return HotKey(
        key: PhysicalKeyboardKey.keyQ,
        modifiers: [HotKeyModifier.alt, HotKeyModifier.control],
      );
    }
  }

  Future<HotKey?> getAutoHideHotKey() async {
    final json = await _prefs.getString('autoHideHotKey');
    try {
      return HotKey.fromJson(jsonDecode(json!));
    } catch (e) {
      return HotKey(
        key: PhysicalKeyboardKey.keyW,
        modifiers: [HotKeyModifier.alt, HotKeyModifier.control],
      );
    }
  }

  Future<HotKey?> getToggleMoveHotKey() async {
    final json = await _prefs.getString('toggleMoveHotKey');
    try {
      return HotKey.fromJson(jsonDecode(json!));
    } catch (e) {
      return HotKey(
        key: PhysicalKeyboardKey.keyE,
        modifiers: [HotKeyModifier.alt, HotKeyModifier.control],
      );
    }
  }

  Future<HotKey?> getPreferencesHotKey() async {
    final json = await _prefs.getString('preferencesHotKey');
    try {
      return HotKey.fromJson(jsonDecode(json!));
    } catch (e) {
      return HotKey(
        key: PhysicalKeyboardKey.keyR,
        modifiers: [HotKeyModifier.alt, HotKeyModifier.control],
      );
    }
  }

  // Advanced settings
  Future<bool> getAdvancedSettingsEnabled() async =>
      await _prefs.getBool('advancedSettingsEnabled') ?? false;
  Future<bool> getUseUserLayout() async =>
      await _prefs.getBool('useUserLayout') ?? false;
  Future<bool> getShowAltLayout() async =>
      await _prefs.getBool('showAltLayout') ?? false;
  Future<bool> getCustomFontEnabled() async =>
      await _prefs.getBool('customFontEnabled') ?? false;
  Future<bool> getUse6ColLayout() async =>
      await _prefs.getBool('use6ColLayout') ?? false;
  Future<bool> getKanataEnabled() async =>
      await _prefs.getBool('kanataEnabled') ?? false;
  Future<bool> getKeyboardFollowsMouse() async =>
      await _prefs.getBool('keyboardFollowsMouse') ?? false;

  // General settings
  Future<void> setLaunchAtStartup(bool value) async =>
      await _prefs.setBool('launchAtStartup', value);
  Future<void> setAutoHideEnabled(bool value) async =>
      await _prefs.setBool('autoHideEnabled', value);
  Future<void> setAutoHideDuration(double value) async =>
      await _prefs.setDouble('autoHideDuration', value);
  Future<void> setOpacity(double value) async =>
      await _prefs.setDouble('opacity', value);
  Future<void> setKeyboardLayoutName(String value) async =>
      await _prefs.setString('layout', value);

  // Keyboard settings
  Future<void> setKeymapStyle(String value) async =>
      await _prefs.setString('keymapStyle', value);
  Future<void> setShowTopRow(bool value) async =>
      await _prefs.setBool('showTopRow', value);
  Future<void> setShowGraveKey(bool value) async =>
      await _prefs.setBool('showGraveKey', value);
  Future<void> setKeySize(double value) async =>
      await _prefs.setDouble('keySize', value);
  Future<void> setKeyBorderRadius(double value) async =>
      await _prefs.setDouble('keyBorderRadius', value);
  Future<void> setKeyPadding(double value) async =>
      await _prefs.setDouble('keyPadding', value);
  Future<void> setSpaceWidth(double value) async =>
      await _prefs.setDouble('spaceWidth', value);
  Future<void> setSplitWidth(double value) async =>
      await _prefs.setDouble('splitWidth', value);
  Future<void> setLastRowSplitWidth(double value) async =>
      await _prefs.setDouble('lastRowSplitWidth', value);
  Future<void> setKeyBorderThickness(double value) async =>
      await _prefs.setDouble('keyBorderThickness', value);

  // Text settings
  Future<void> setFontFamily(String value) async =>
      await _prefs.setString('fontFamily', value);
  Future<void> setKeyFontSize(double value) async =>
      await _prefs.setDouble('keyFontSize', value);
  Future<void> setSpaceFontSize(double value) async =>
      await _prefs.setDouble('spaceFontSize', value);
  Future<void> setFontWeight(FontWeight value) async =>
      await _prefs.setInt('fontWeight', value.index);

  // Markers settings
  Future<void> setMarkerOffset(double value) async =>
      await _prefs.setDouble('markerOffset', value);
  Future<void> setMarkerWidth(double value) async =>
      await _prefs.setDouble('markerWidth', value);
  Future<void> setMarkerHeight(double value) async =>
      await _prefs.setDouble('markerHeight', value);
  Future<void> setMarkerBorderRadius(double value) async =>
      await _prefs.setDouble('markerBorderRadius', value);

  // Colors settings
  Future<void> setKeyColorPressed(Color value) async =>
      await _prefs.setInt('keyColorPressed', value.toARGB32());
  Future<void> setKeyColorNotPressed(Color value) async =>
      await _prefs.setInt('keyColorNotPressed', value.toARGB32());
  Future<void> setMarkerColor(Color value) async =>
      await _prefs.setInt('markerColor', value.toARGB32());
  Future<void> setMarkerColorNotPressed(Color value) async =>
      await _prefs.setInt('markerColorNotPressed', value.toARGB32());
  Future<void> setKeyTextColor(Color value) async =>
      await _prefs.setInt('keyTextColor', value.toARGB32());
  Future<void> setKeyTextColorNotPressed(Color value) async =>
      await _prefs.setInt('keyTextColorNotPressed', value.toARGB32());
  Future<void> setKeyBorderColorPressed(Color value) async =>
      await _prefs.setInt('keyBorderColorPressed', value.toARGB32());
  Future<void> setKeyBorderColorNotPressed(Color value) async =>
      await _prefs.setInt('keyBorderColorNotPressed', value.toARGB32());

  // Animations settings
  Future<void> setAnimationEnabled(bool value) async =>
      await _prefs.setBool('animationEnabled', value);
  Future<void> setAnimationStyle(String value) async =>
      await _prefs.setString('animationStyle', value);
  Future<void> setAnimationDuration(double value) async =>
      await _prefs.setDouble('animationDuration', value);
  Future<void> setAnimationScale(double value) async =>
      await _prefs.setDouble('animationScale', value);

  // HotKey settings
  Future<void> setHotKeysEnabled(bool value) async =>
      await _prefs.setBool('enableHotKeys', value);
  Future<void> setVisibilityHotKey(HotKey value) async =>
      await _prefs.setString('visibilityHotKey', jsonEncode(value.toJson()));
  Future<void> setAutoHideHotKey(HotKey value) async =>
      await _prefs.setString('autoHideHotKey', jsonEncode(value.toJson()));
  Future<void> setToggleMoveHotKey(HotKey value) async =>
      await _prefs.setString('toggleMoveHotKey', jsonEncode(value.toJson()));
  Future<void> setPreferencesHotKey(HotKey value) async =>
      await _prefs.setString('preferencesHotKey', jsonEncode(value.toJson()));

  // Advanced settings
  Future<void> setAdvancedSettingsEnabled(bool value) async =>
      await _prefs.setBool('advancedSettingsEnabled', value);
  Future<void> setUseUserLayout(bool value) async =>
      await _prefs.setBool('useUserLayout', value);
  Future<void> setShowAltLayout(bool value) async =>
      await _prefs.setBool('showAltLayout', value);
  Future<void> setCustomFontEnabled(bool value) async =>
      await _prefs.setBool('customFontEnabled', value);
  Future<void> setUse6ColLayout(bool value) async =>
      await _prefs.setBool('use6ColLayout', value);
  Future<void> setKanataEnabled(bool value) async =>
      await _prefs.setBool('kanataEnabled', value);
  Future<void> setKeyboardFollowsMouse(bool value) async =>
      await _prefs.setBool('keyboardFollowsMouse', value);

  Future<Map<String, dynamic>> loadAllPreferences() async {
    return {
      // General settings
      'launchAtStartup': await getLaunchAtStartup(),
      'autoHideEnabled': await getAutoHideEnabled(),
      'autoHideDuration': await getAutoHideDuration(),
      'opacity': await getOpacity(),
      'keyboardLayoutName': await getKeyboardLayoutName(),

      // Keyboard settings
      'keymapStyle': await getKeymapStyle(),
      'showTopRow': await getShowTopRow(),
      'showGraveKey': await getShowGraveKey(),
      'keySize': await getKeySize(),
      'keyBorderRadius': await getKeyBorderRadius(),
      'keyPadding': await getKeyPadding(),
      'spaceWidth': await getSpaceWidth(),
      'splitWidth': await getSplitWidth(),
      'lastRowSplitWidth': await getLastRowSplitWidth(),
      'keyBorderThickness': await getKeyBorderThickness(),

      // Text settings
      'fontFamily': await getFontFamily(),
      'fontWeight': await getFontWeight(),
      'keyFontSize': await getKeyFontSize(),
      'spaceFontSize': await getSpaceFontSize(),

      // Markers settings
      'markerOffset': await getMarkerOffset(),
      'markerWidth': await getMarkerWidth(),
      'markerHeight': await getMarkerHeight(),
      'markerBorderRadius': await getMarkerBorderRadius(),

      // Colors settings
      'keyColorPressed': await getKeyColorPressed(),
      'keyColorNotPressed': await getKeyColorNotPressed(),
      'markerColor': await getMarkerColor(),
      'markerColorNotPressed': await getMarkerColorNotPressed(),
      'keyTextColor': await getKeyTextColor(),
      'keyTextColorNotPressed': await getKeyTextColorNotPressed(),
      'keyBorderColorPressed': await getKeyBorderColorPressed(),
      'keyBorderColorNotPressed': await getKeyBorderColorNotPressed(),

      // Animations settings
      'animationEnabled': await getAnimationEnabled(),
      'animationStyle': await getAnimationStyle(),
      'animationDuration': await getAnimationDuration(),
      'animationScale': await getAnimationScale(),

      // HotKey settings
      'hotKeysEnabled': await getHotKeysEnabled(),
      'visibilityHotKey': await getVisibilityHotKey(),
      'autoHideHotKey': await getAutoHideHotKey(),
      'toggleMoveHotKey': await getToggleMoveHotKey(),
      'preferencesHotKey': await getPreferencesHotKey(),

      // Advanced settings
      'advancedSettingsEnabled': await getAdvancedSettingsEnabled(),
      'useUserLayout': await getUseUserLayout(),
      'showAltLayout': await getShowAltLayout(),
      'customFontEnabled': await getCustomFontEnabled(),
      'use6ColLayout': await getUse6ColLayout(),
      'kanataEnabled': await getKanataEnabled(),
      'keyboardFollowsMouse': await getKeyboardFollowsMouse(),
    };
  }

  Future<void> saveAllPreferences(Map<String, dynamic> prefs) async {
    // General settings
    await setLaunchAtStartup(prefs['launchAtStartup']);
    await setAutoHideEnabled(prefs['autoHideEnabled']);
    await setAutoHideDuration(prefs['autoHideDuration']);
    await setOpacity(prefs['opacity']);
    await setKeyboardLayoutName(prefs['keyboardLayoutName']);

    // Keyboard settings
    await setKeymapStyle(prefs['keymapStyle']);
    await setShowTopRow(prefs['showTopRow']);
    await setShowGraveKey(prefs['showGraveKey']);
    await setKeySize(prefs['keySize']);
    await setKeyBorderRadius(prefs['keyBorderRadius']);
    await setKeyPadding(prefs['keyPadding']);
    await setSpaceWidth(prefs['spaceWidth']);
    await setSplitWidth(prefs['splitWidth']);
    await setLastRowSplitWidth(prefs['lastRowSplitWidth']);
    await setKeyBorderThickness(prefs['keyBorderThickness']);

    // Text settings
    await setFontFamily(prefs['fontFamily']);
    await setFontWeight(prefs['fontWeight']);
    await setKeyFontSize(prefs['keyFontSize']);
    await setSpaceFontSize(prefs['spaceFontSize']);

    // Markers settings
    await setMarkerOffset(prefs['markerOffset']);
    await setMarkerWidth(prefs['markerWidth']);
    await setMarkerHeight(prefs['markerHeight']);
    await setMarkerBorderRadius(prefs['markerBorderRadius']);

    // Colors settings
    await setKeyColorPressed(prefs['keyColorPressed']);
    await setKeyColorNotPressed(prefs['keyColorNotPressed']);
    await setMarkerColor(prefs['markerColor']);
    await setMarkerColorNotPressed(prefs['markerColorNotPressed']);
    await setKeyTextColor(prefs['keyTextColor']);
    await setKeyTextColorNotPressed(prefs['keyTextColorNotPressed']);
    await setKeyBorderColorPressed(prefs['keyBorderColorPressed']);
    await setKeyBorderColorNotPressed(prefs['keyBorderColorNotPressed']);

    // Animations settings
    await setAnimationEnabled(prefs['animationEnabled']);
    await setAnimationStyle(prefs['animationStyle']);
    await setAnimationDuration(prefs['animationDuration']);
    await setAnimationScale(prefs['animationScale']);

    // HotKey settings
    await setHotKeysEnabled(prefs['hotKeysEnabled']);
    await setVisibilityHotKey(prefs['visibilityHotKey']);
    await setAutoHideHotKey(prefs['autoHideHotKey']);
    await setToggleMoveHotKey(prefs['toggleMoveHotKey']);
    await setPreferencesHotKey(prefs['preferencesHotKey']);

    // Advanced settings
    await setAdvancedSettingsEnabled(prefs['advancedSettingsEnabled']);
    await setUseUserLayout(prefs['useUserLayout']);
    await setShowAltLayout(prefs['showAltLayout']);
    await setCustomFontEnabled(prefs['customFontEnabled']);
    await setUse6ColLayout(prefs['use6ColLayout']);
    await setKanataEnabled(prefs['kanataEnabled']);
    await setKeyboardFollowsMouse(prefs['keyboardFollowsMouse']);
  }
}
