import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:overkeys/models/user_config.dart';
import 'package:overkeys/models/keyboard_layouts.dart';

part 'preferences_provider.g.dart';

/// State class for user preferences and application settings
/// Includes general settings, layout preferences, and advanced features
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
    this.autoHideDuration = 0.5,
    this.opacity = 0.5,
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

  Map<String, dynamic> toJson() {
    // Note: userLayers and userConfig are intentionally omitted from serialization.
    // These fields are loaded separately from the user's config file (config.json)
    // and are not persisted in the preferences file to avoid duplication and
    // maintain a single source of truth for user-defined layouts and configurations.
    return {
      'launchAtStartup': launchAtStartup,
      'hideAtStartup': hideAtStartup,
      'autoHideEnabled': autoHideEnabled,
      'reactiveShiftEnabled': reactiveShiftEnabled,
      'autoHideDuration': autoHideDuration,
      'opacity': opacity,
      'initialKeyboardLayoutName': initialKeyboardLayout?.name,
      'defaultUserLayoutName': defaultUserLayout?.name,
      'altLayoutName': altLayout?.name,
      'useUserLayout': useUserLayout,
      'showAltLayout': showAltLayout,
      'use6ColLayout': use6ColLayout,
      'customFontEnabled': customFontEnabled,
      'customFont': customFont,
      'advancedSettingsEnabled': advancedSettingsEnabled,
      'kanataEnabled': kanataEnabled,
      'kanataHost': kanataHost,
      'kanataPort': kanataPort,
      'keyboardFollowsMouse': keyboardFollowsMouse,
      'hideOnDefaultLayer': hideOnDefaultLayer,
    };
  }

  factory PreferencesState.fromJson(Map<String, dynamic> json) {
    // Note: userLayers and userConfig are intentionally not deserialized here.
    // These fields are loaded separately from the user's config file (config.json)
    // by the ConfigService and injected into the state after preferences are loaded.
    // This maintains separation between app preferences and user-defined layouts.
    final initialLayoutName = json['initialKeyboardLayoutName'] as String?;
    final initialLayout = initialLayoutName != null
        ? availableLayouts.firstWhere(
            (l) => l.name == initialLayoutName,
            orElse: () => qwerty,
          )
        : null;

    final defaultLayoutName = json['defaultUserLayoutName'] as String?;
    final defaultLayout = defaultLayoutName != null
        ? availableLayouts.firstWhere(
            (l) => l.name == defaultLayoutName,
            orElse: () => qwerty,
          )
        : null;

    final altLayoutName = json['altLayoutName'] as String?;
    final altLayout = altLayoutName != null
        ? availableLayouts.firstWhere(
            (l) => l.name == altLayoutName,
            orElse: () => qwerty,
          )
        : null;

    return PreferencesState(
      launchAtStartup: json['launchAtStartup'] as bool? ?? false,
      hideAtStartup: json['hideAtStartup'] as bool? ?? false,
      autoHideEnabled: json['autoHideEnabled'] as bool? ?? false,
      reactiveShiftEnabled: json['reactiveShiftEnabled'] as bool? ?? true,
      autoHideDuration: (json['autoHideDuration'] as num?)?.toDouble() ?? 0.5,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 0.5,
      initialKeyboardLayout: initialLayout,
      defaultUserLayout: defaultLayout,
      altLayout: altLayout,
      useUserLayout: json['useUserLayout'] as bool? ?? false,
      showAltLayout: json['showAltLayout'] as bool? ?? false,
      use6ColLayout: json['use6ColLayout'] as bool? ?? false,
      customFontEnabled: json['customFontEnabled'] as bool? ?? false,
      customFont: json['customFont'] as String?,
      advancedSettingsEnabled:
          json['advancedSettingsEnabled'] as bool? ?? false,
      kanataEnabled: json['kanataEnabled'] as bool? ?? false,
      kanataHost: json['kanataHost'] as String?,
      kanataPort: json['kanataPort'] as int?,
      keyboardFollowsMouse: json['keyboardFollowsMouse'] as bool? ?? false,
      hideOnDefaultLayer: json['hideOnDefaultLayer'] as bool? ?? false,
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
