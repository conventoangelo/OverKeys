import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:overkeys/models/user_config.dart';
import 'package:overkeys/models/keyboard_layouts.dart';

part 'preferences_provider.g.dart';

class PreferencesState {
  // General settings
  final bool launchAtStartup;
  final bool hideAtStartup;
  final bool autoHideEnabled;
  final bool reactiveShiftEnabled;
  final double autoHideDuration;
  final double opacity;

  // Keyboard layout settings
  final KeyboardLayout? initialKeyboardLayout;
  final KeyboardLayout? defaultUserLayout;
  final KeyboardLayout? altLayout;
  final bool useUserLayout;
  final bool showAltLayout;
  final bool use6ColLayout;

  // Custom font settings
  final bool customFontEnabled;
  final String? customFont;

  // Advanced settings
  final bool advancedSettingsEnabled;
  final bool kanataEnabled;
  final String? kanataHost;
  final int? kanataPort;
  final bool keyboardFollowsMouse;
  final bool hideOnDefaultLayer;

  // User layouts and config
  final List<KeyboardLayout> userLayers;
  final UserConfig? userConfig;

  PreferencesState({
    this.launchAtStartup = false,
    this.hideAtStartup = false,
    this.autoHideEnabled = false,
    this.reactiveShiftEnabled = true,
    this.autoHideDuration = 2.0,
    this.opacity = 0.6,
    this.initialKeyboardLayout,
    this.defaultUserLayout,
    this.altLayout,
    this.useUserLayout = false,
    this.showAltLayout = false,
    this.use6ColLayout = false,
    this.customFontEnabled = false,
    this.customFont,
    this.advancedSettingsEnabled = false,
    this.kanataEnabled = false,
    this.kanataHost,
    this.kanataPort,
    this.keyboardFollowsMouse = false,
    this.hideOnDefaultLayer = false,
    this.userLayers = const [],
    this.userConfig,
  });

  PreferencesState copyWith({
    bool? launchAtStartup,
    bool? hideAtStartup,
    bool? autoHideEnabled,
    bool? reactiveShiftEnabled,
    double? autoHideDuration,
    double? opacity,
    KeyboardLayout? initialKeyboardLayout,
    KeyboardLayout? defaultUserLayout,
    KeyboardLayout? altLayout,
    bool? useUserLayout,
    bool? showAltLayout,
    bool? use6ColLayout,
    bool? customFontEnabled,
    String? customFont,
    bool? advancedSettingsEnabled,
    bool? kanataEnabled,
    String? kanataHost,
    int? kanataPort,
    bool? keyboardFollowsMouse,
    bool? hideOnDefaultLayer,
    List<KeyboardLayout>? userLayers,
    UserConfig? userConfig,
  }) {
    return PreferencesState(
      launchAtStartup: launchAtStartup ?? this.launchAtStartup,
      hideAtStartup: hideAtStartup ?? this.hideAtStartup,
      autoHideEnabled: autoHideEnabled ?? this.autoHideEnabled,
      reactiveShiftEnabled: reactiveShiftEnabled ?? this.reactiveShiftEnabled,
      autoHideDuration: autoHideDuration ?? this.autoHideDuration,
      opacity: opacity ?? this.opacity,
      initialKeyboardLayout:
          initialKeyboardLayout ?? this.initialKeyboardLayout,
      defaultUserLayout: defaultUserLayout ?? this.defaultUserLayout,
      altLayout: altLayout ?? this.altLayout,
      useUserLayout: useUserLayout ?? this.useUserLayout,
      showAltLayout: showAltLayout ?? this.showAltLayout,
      use6ColLayout: use6ColLayout ?? this.use6ColLayout,
      customFontEnabled: customFontEnabled ?? this.customFontEnabled,
      customFont: customFont ?? this.customFont,
      advancedSettingsEnabled:
          advancedSettingsEnabled ?? this.advancedSettingsEnabled,
      kanataEnabled: kanataEnabled ?? this.kanataEnabled,
      kanataHost: kanataHost ?? this.kanataHost,
      kanataPort: kanataPort ?? this.kanataPort,
      keyboardFollowsMouse: keyboardFollowsMouse ?? this.keyboardFollowsMouse,
      hideOnDefaultLayer: hideOnDefaultLayer ?? this.hideOnDefaultLayer,
      userLayers: userLayers ?? this.userLayers,
      userConfig: userConfig ?? this.userConfig,
    );
  }
}

@riverpod
class PreferencesNotifier extends _$PreferencesNotifier {
  @override
  PreferencesState build() {
    return PreferencesState();
  }

  void updateLaunchAtStartup(bool value) {
    state = state.copyWith(launchAtStartup: value);
  }

  void updateHideAtStartup(bool value) {
    state = state.copyWith(hideAtStartup: value);
  }

  void updateAutoHideEnabled(bool value) {
    state = state.copyWith(autoHideEnabled: value);
  }

  void updateReactiveShiftEnabled(bool value) {
    state = state.copyWith(reactiveShiftEnabled: value);
  }

  void updateAutoHideDuration(double value) {
    state = state.copyWith(autoHideDuration: value);
  }

  void updateOpacity(double value) {
    state = state.copyWith(opacity: value);
  }

  void updateInitialKeyboardLayout(KeyboardLayout? layout) {
    state = state.copyWith(initialKeyboardLayout: layout);
  }

  void updateDefaultUserLayout(KeyboardLayout? layout) {
    state = state.copyWith(defaultUserLayout: layout);
  }

  void updateAltLayout(KeyboardLayout? layout) {
    state = state.copyWith(altLayout: layout);
  }

  void updateUseUserLayout(bool value) {
    state = state.copyWith(useUserLayout: value);
  }

  void updateShowAltLayout(bool value) {
    state = state.copyWith(showAltLayout: value);
  }

  void updateUse6ColLayout(bool value) {
    state = state.copyWith(use6ColLayout: value);
  }

  void updateCustomFontEnabled(bool value) {
    state = state.copyWith(customFontEnabled: value);
  }

  void updateCustomFont(String? font) {
    state = state.copyWith(customFont: font);
  }

  void updateAdvancedSettingsEnabled(bool value) {
    state = state.copyWith(advancedSettingsEnabled: value);
  }

  void updateKanataEnabled(bool value) {
    state = state.copyWith(kanataEnabled: value);
  }

  void updateKanataHost(String? host) {
    state = state.copyWith(kanataHost: host);
  }

  void updateKanataPort(int? port) {
    state = state.copyWith(kanataPort: port);
  }

  void updateKeyboardFollowsMouse(bool value) {
    state = state.copyWith(keyboardFollowsMouse: value);
  }

  void updateHideOnDefaultLayer(bool value) {
    state = state.copyWith(hideOnDefaultLayer: value);
  }

  void updateUserLayers(List<KeyboardLayout> layers) {
    state = state.copyWith(userLayers: layers);
  }

  void updateUserConfig(UserConfig? config) {
    state = state.copyWith(userConfig: config);
  }

  void updatePreferencesState(PreferencesState newState) {
    state = newState;
  }
}
