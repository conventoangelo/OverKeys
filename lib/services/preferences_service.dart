import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();

  // General settings
  Future<bool> getLaunchAtStartup() async =>
      await asyncPrefs.getBool('launchAtStartup') ?? false;
  Future<bool> getAutoHideEnabled() async =>
      await asyncPrefs.getBool('autoHideEnabled') ?? false;
  Future<double> getAutoHideDuration() async =>
      await asyncPrefs.getDouble('autoHideDuration') ?? 2.0;
  Future<String> getKeyboardLayoutName() async =>
      await asyncPrefs.getString('layout') ?? 'QWERTY';
  Future<bool> getEnableAdvancedSettings() async =>
      await asyncPrefs.getBool('enableAdvancedSettings') ?? false;
  Future<bool> getUseUserLayout() async =>
      await asyncPrefs.getBool('useUserLayout') ?? false;
  Future<bool> getShowAltLayout() async =>
      await asyncPrefs.getBool('showAltLayout') ?? false;
  Future<bool> getKanataEnabled() async =>
      await asyncPrefs.getBool('kanataEnabled') ?? false;

  // Appearance settings
  Future<double> getOpacity() async =>
      await asyncPrefs.getDouble('opacity') ?? 0.6;
  Future<Color> getKeyColorPressed() async =>
      Color(await asyncPrefs.getInt('keyColorPressed') ?? 0xFF1E1E1E);
  Future<Color> getKeyColorNotPressed() async =>
      Color(await asyncPrefs.getInt('keyColorNotPressed') ?? 0xFF77ABFF);
  Future<Color> getMarkerColor() async =>
      Color(await asyncPrefs.getInt('markerColor') ?? 0xFFFFFFFF);
  Future<Color> getMarkerColorNotPressed() async =>
      Color(await asyncPrefs.getInt('markerColorNotPressed') ?? 0xFF000000);
  Future<double> getMarkerOffset() async =>
      await asyncPrefs.getDouble('markerOffset') ?? 10;
  Future<double> getMarkerWidth() async =>
      await asyncPrefs.getDouble('markerWidth') ?? 10;
  Future<double> getMarkerHeight() async =>
      await asyncPrefs.getDouble('markerHeight') ?? 2;
  Future<double> getMarkerBorderRadius() async =>
      await asyncPrefs.getDouble('markerBorderRadius') ?? 10;

  // Keyboard settings
  Future<String> getKeymapStyle() async =>
      await asyncPrefs.getString('keymapStyle') ?? 'Staggered';
  Future<bool> getShowTopRow() async =>
      await asyncPrefs.getBool('showTopRow') ?? false;
  Future<bool> getShowGraveKey() async =>
      await asyncPrefs.getBool('showGraveKey') ?? false;
  Future<double> getKeySize() async =>
      await asyncPrefs.getDouble('keySize') ?? 48;
  Future<double> getKeyBorderRadius() async =>
      await asyncPrefs.getDouble('keyBorderRadius') ?? 12;
  Future<double> getKeyPadding() async =>
      await asyncPrefs.getDouble('keyPadding') ?? 3;
  Future<double> getSpaceWidth() async =>
      await asyncPrefs.getDouble('spaceWidth') ?? 320;
  Future<double> getSplitWidth() async =>
      await asyncPrefs.getDouble('splitWidth') ?? 100;

  // Text settings
  Future<String> getFontFamily() async =>
      await asyncPrefs.getString('fontFamily') ?? 'GeistMono';
  Future<double> getKeyFontSize() async =>
      await asyncPrefs.getDouble('keyFontSize') ?? 20;
  Future<double> getSpaceFontSize() async =>
      await asyncPrefs.getDouble('spaceFontSize') ?? 14;
  Future<FontWeight> getFontWeight() async => FontWeight
      .values[await asyncPrefs.getInt('fontWeight') ?? FontWeight.w500.index];
  Future<Color> getKeyTextColor() async =>
      Color(await asyncPrefs.getInt('keyTextColor') ?? 0xFFFFFFFF);
  Future<Color> getKeyTextColorNotPressed() async =>
      Color(await asyncPrefs.getInt('keyTextColorNotPressed') ?? 0xFF000000);

  // Save methods
  Future<void> setLaunchAtStartup(bool value) async =>
      await asyncPrefs.setBool('launchAtStartup', value);
  Future<void> setAutoHideEnabled(bool value) async =>
      await asyncPrefs.setBool('autoHideEnabled', value);
  Future<void> setAutoHideDuration(double value) async =>
      await asyncPrefs.setDouble('autoHideDuration', value);
  Future<void> setKeyboardLayoutName(String value) async =>
      await asyncPrefs.setString('layout', value);
  Future<void> setEnableAdvancedSettings(bool value) async =>
      await asyncPrefs.setBool('enableAdvancedSettings', value);
  Future<void> setUseUserLayout(bool value) async =>
      await asyncPrefs.setBool('useUserLayout', value);
  Future<void> setShowAltLayout(bool value) async =>
      await asyncPrefs.setBool('showAltLayout', value);
  Future<void> setKanataEnabled(bool value) async =>
      await asyncPrefs.setBool('kanataEnabled', value);

  Future<void> setOpacity(double value) async =>
      await asyncPrefs.setDouble('opacity', value);
  Future<void> setKeyColorPressed(Color value) async =>
      await asyncPrefs.setInt('keyColorPressed', value.toARGB32());
  Future<void> setKeyColorNotPressed(Color value) async =>
      await asyncPrefs.setInt('keyColorNotPressed', value.toARGB32());
  Future<void> setMarkerColor(Color value) async =>
      await asyncPrefs.setInt('markerColor', value.toARGB32());
  Future<void> setMarkerColorNotPressed(Color value) async =>
      await asyncPrefs.setInt('markerColorNotPressed', value.toARGB32());
  Future<void> setMarkerOffset(double value) async =>
      await asyncPrefs.setDouble('markerOffset', value);
  Future<void> setMarkerWidth(double value) async =>
      await asyncPrefs.setDouble('markerWidth', value);
  Future<void> setMarkerHeight(double value) async =>
      await asyncPrefs.setDouble('markerHeight', value);
  Future<void> setMarkerBorderRadius(double value) async =>
      await asyncPrefs.setDouble('markerBorderRadius', value);

  Future<void> setKeymapStyle(String value) async =>
      await asyncPrefs.setString('keymapStyle', value);
  Future<void> setShowTopRow(bool value) async =>
      await asyncPrefs.setBool('showTopRow', value);
  Future<void> setShowGraveKey(bool value) async =>
      await asyncPrefs.setBool('showGraveKey', value);
  Future<void> setKeySize(double value) async =>
      await asyncPrefs.setDouble('keySize', value);
  Future<void> setKeyBorderRadius(double value) async =>
      await asyncPrefs.setDouble('keyBorderRadius', value);
  Future<void> setKeyPadding(double value) async =>
      await asyncPrefs.setDouble('keyPadding', value);
  Future<void> setSpaceWidth(double value) async =>
      await asyncPrefs.setDouble('spaceWidth', value);
  Future<void> setSplitWidth(double value) async =>
      await asyncPrefs.setDouble('splitWidth', value);

  Future<void> setFontFamily(String value) async =>
      await asyncPrefs.setString('fontFamily', value);
  Future<void> setKeyFontSize(double value) async =>
      await asyncPrefs.setDouble('keyFontSize', value);
  Future<void> setSpaceFontSize(double value) async =>
      await asyncPrefs.setDouble('spaceFontSize', value);
  Future<void> setFontWeight(FontWeight value) async =>
      await asyncPrefs.setInt('fontWeight', value.index);
  Future<void> setKeyTextColor(Color value) async =>
      await asyncPrefs.setInt('keyTextColor', value.toARGB32());
  Future<void> setKeyTextColorNotPressed(Color value) async =>
      await asyncPrefs.setInt('keyTextColorNotPressed', value.toARGB32());

  Future<Map<String, dynamic>> loadAllPreferences() async {
    return {
      // General settings
      'launchAtStartup': await getLaunchAtStartup(),
      'autoHideEnabled': await getAutoHideEnabled(),
      'autoHideDuration': await getAutoHideDuration(),
      'keyboardLayoutName': await getKeyboardLayoutName(),
      'enableAdvancedSettings': await getEnableAdvancedSettings(),
      'useUserLayout': await getUseUserLayout(),
      'showAltLayout': await getShowAltLayout(),
      'kanataEnabled': await getKanataEnabled(),

      // Appearance settings
      'opacity': await getOpacity(),
      'keyColorPressed': await getKeyColorPressed(),
      'keyColorNotPressed': await getKeyColorNotPressed(),
      'markerColor': await getMarkerColor(),
      'markerColorNotPressed': await getMarkerColorNotPressed(),
      'markerOffset': await getMarkerOffset(),
      'markerWidth': await getMarkerWidth(),
      'markerHeight': await getMarkerHeight(),
      'markerBorderRadius': await getMarkerBorderRadius(),

      // Keyboard settings
      'keymapStyle': await getKeymapStyle(),
      'showTopRow': await getShowTopRow(),
      'showGraveKey': await getShowGraveKey(),
      'keySize': await getKeySize(),
      'keyBorderRadius': await getKeyBorderRadius(),
      'keyPadding': await getKeyPadding(),
      'spaceWidth': await getSpaceWidth(),
      'splitWidth': await getSplitWidth(),

      // Text settings
      'fontFamily': await getFontFamily(),
      'keyFontSize': await getKeyFontSize(),
      'spaceFontSize': await getSpaceFontSize(),
      'fontWeight': await getFontWeight(),
      'keyTextColor': await getKeyTextColor(),
      'keyTextColorNotPressed': await getKeyTextColorNotPressed(),
    };
  }

  Future<void> saveAllPreferences(Map<String, dynamic> prefs) async {
    // General settings
    await setLaunchAtStartup(prefs['launchAtStartup']);
    await setAutoHideEnabled(prefs['autoHideEnabled']);
    await setAutoHideDuration(prefs['autoHideDuration']);
    await setKeyboardLayoutName(prefs['keyboardLayoutName']);
    await setEnableAdvancedSettings(prefs['enableAdvancedSettings']);
    await setUseUserLayout(prefs['useUserLayout']);
    await setShowAltLayout(prefs['showAltLayout']);
    await setKanataEnabled(prefs['kanataEnabled']);

    // Appearance settings
    await setOpacity(prefs['opacity']);
    await setKeyColorPressed(prefs['keyColorPressed']);
    await setKeyColorNotPressed(prefs['keyColorNotPressed']);
    await setMarkerColor(prefs['markerColor']);
    await setMarkerColorNotPressed(prefs['markerColorNotPressed']);
    await setMarkerOffset(prefs['markerOffset']);
    await setMarkerWidth(prefs['markerWidth']);
    await setMarkerHeight(prefs['markerHeight']);
    await setMarkerBorderRadius(prefs['markerBorderRadius']);

    // Keyboard settings
    await setKeymapStyle(prefs['keymapStyle']);
    await setShowTopRow(prefs['showTopRow']);
    await setShowGraveKey(prefs['showGraveKey']);
    await setKeySize(prefs['keySize']);
    await setKeyBorderRadius(prefs['keyBorderRadius']);
    await setKeyPadding(prefs['keyPadding']);
    await setSpaceWidth(prefs['spaceWidth']);
    await setSplitWidth(prefs['splitWidth']);

    // Text settings
    await setFontFamily(prefs['fontFamily']);
    await setKeyFontSize(prefs['keyFontSize']);
    await setSpaceFontSize(prefs['spaceFontSize']);
    await setFontWeight(prefs['fontWeight']);
    await setKeyTextColor(prefs['keyTextColor']);
    await setKeyTextColorNotPressed(prefs['keyTextColorNotPressed']);
  }
}

class SharedPreferencesAsync {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<bool?> getBool(String key) async {
    final prefs = await _instance;
    return prefs.containsKey(key) ? prefs.getBool(key) : null;
  }

  Future<int?> getInt(String key) async {
    final prefs = await _instance;
    return prefs.containsKey(key) ? prefs.getInt(key) : null;
  }

  Future<double?> getDouble(String key) async {
    final prefs = await _instance;
    return prefs.containsKey(key) ? prefs.getDouble(key) : null;
  }

  Future<String?> getString(String key) async {
    final prefs = await _instance;
    return prefs.containsKey(key) ? prefs.getString(key) : null;
  }

  Future<bool> setBool(String key, bool value) async {
    final prefs = await _instance;
    return prefs.setBool(key, value);
  }

  Future<bool> setInt(String key, int value) async {
    final prefs = await _instance;
    return prefs.setInt(key, value);
  }

  Future<bool> setDouble(String key, double value) async {
    final prefs = await _instance;
    return prefs.setDouble(key, value);
  }

  Future<bool> setString(String key, String value) async {
    final prefs = await _instance;
    return prefs.setString(key, value);
  }
}
