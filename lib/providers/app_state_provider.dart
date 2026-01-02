import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

part 'app_state_provider.g.dart';

/// Application state for window visibility, hotkeys, and UI overlays
class AppState {
  // Window visibility
  final bool isWindowVisible;
  final bool ignoreMouseEvents;
  final bool forceHide;
  final bool autoHideBeforeForceHide;

  // HotKey settings
  final bool hotKeysEnabled;
  final HotKey? visibilityHotKey;
  final HotKey? autoHideHotKey;
  final HotKey? toggleMoveHotKey;
  final HotKey? preferencesHotKey;
  final HotKey? increaseOpacityHotKey;
  final HotKey? decreaseOpacityHotKey;
  final bool enableVisibilityHotKey;
  final bool enableAutoHideHotKey;
  final bool enableToggleMoveHotKey;
  final bool enablePreferencesHotKey;
  final bool enableIncreaseOpacityHotKey;
  final bool enableDecreaseOpacityHotKey;

  // Overlay state
  final bool showStatusOverlay;
  final String overlayMessage;
  final Icon statusIcon;

  // Misc
  final Set<String> activeTriggers;

  AppState({
    this.isWindowVisible = true,
    this.ignoreMouseEvents = true,
    this.forceHide = false,
    this.autoHideBeforeForceHide = false,
    this.hotKeysEnabled = true,
    HotKey? visibilityHotKey,
    HotKey? autoHideHotKey,
    HotKey? toggleMoveHotKey,
    HotKey? preferencesHotKey,
    HotKey? increaseOpacityHotKey,
    HotKey? decreaseOpacityHotKey,
    this.enableVisibilityHotKey = true,
    this.enableAutoHideHotKey = true,
    this.enableToggleMoveHotKey = true,
    this.enablePreferencesHotKey = true,
    this.enableIncreaseOpacityHotKey = true,
    this.enableDecreaseOpacityHotKey = true,
    this.showStatusOverlay = false,
    this.overlayMessage = '',
    this.statusIcon = const Icon(Icons.visibility),
    this.activeTriggers = const {},
  })  : visibilityHotKey = visibilityHotKey ??
            HotKey(
                key: PhysicalKeyboardKey.keyQ,
                modifiers: [HotKeyModifier.alt, HotKeyModifier.control]),
        autoHideHotKey = autoHideHotKey ??
            HotKey(
                key: PhysicalKeyboardKey.keyW,
                modifiers: [HotKeyModifier.alt, HotKeyModifier.control]),
        toggleMoveHotKey = toggleMoveHotKey ??
            HotKey(
                key: PhysicalKeyboardKey.keyE,
                modifiers: [HotKeyModifier.alt, HotKeyModifier.control]),
        preferencesHotKey = preferencesHotKey ??
            HotKey(
                key: PhysicalKeyboardKey.keyR,
                modifiers: [HotKeyModifier.alt, HotKeyModifier.control]),
        increaseOpacityHotKey = increaseOpacityHotKey ??
            HotKey(
                key: PhysicalKeyboardKey.arrowUp,
                modifiers: [HotKeyModifier.alt, HotKeyModifier.control]),
        decreaseOpacityHotKey = decreaseOpacityHotKey ??
            HotKey(
                key: PhysicalKeyboardKey.arrowDown,
                modifiers: [HotKeyModifier.alt, HotKeyModifier.control]);

  AppState copyWith({
    bool? isWindowVisible,
    bool? ignoreMouseEvents,
    bool? forceHide,
    bool? autoHideBeforeForceHide,
    bool? hotKeysEnabled,
    HotKey? visibilityHotKey,
    HotKey? autoHideHotKey,
    HotKey? toggleMoveHotKey,
    HotKey? preferencesHotKey,
    HotKey? increaseOpacityHotKey,
    HotKey? decreaseOpacityHotKey,
    bool? enableVisibilityHotKey,
    bool? enableAutoHideHotKey,
    bool? enableToggleMoveHotKey,
    bool? enablePreferencesHotKey,
    bool? enableIncreaseOpacityHotKey,
    bool? enableDecreaseOpacityHotKey,
    bool? showStatusOverlay,
    String? overlayMessage,
    Icon? statusIcon,
    Set<String>? activeTriggers,
  }) {
    return AppState(
      isWindowVisible: isWindowVisible ?? this.isWindowVisible,
      ignoreMouseEvents: ignoreMouseEvents ?? this.ignoreMouseEvents,
      forceHide: forceHide ?? this.forceHide,
      autoHideBeforeForceHide:
          autoHideBeforeForceHide ?? this.autoHideBeforeForceHide,
      hotKeysEnabled: hotKeysEnabled ?? this.hotKeysEnabled,
      visibilityHotKey: visibilityHotKey ?? this.visibilityHotKey,
      autoHideHotKey: autoHideHotKey ?? this.autoHideHotKey,
      toggleMoveHotKey: toggleMoveHotKey ?? this.toggleMoveHotKey,
      preferencesHotKey: preferencesHotKey ?? this.preferencesHotKey,
      increaseOpacityHotKey:
          increaseOpacityHotKey ?? this.increaseOpacityHotKey,
      decreaseOpacityHotKey:
          decreaseOpacityHotKey ?? this.decreaseOpacityHotKey,
      enableVisibilityHotKey:
          enableVisibilityHotKey ?? this.enableVisibilityHotKey,
      enableAutoHideHotKey: enableAutoHideHotKey ?? this.enableAutoHideHotKey,
      enableToggleMoveHotKey:
          enableToggleMoveHotKey ?? this.enableToggleMoveHotKey,
      enablePreferencesHotKey:
          enablePreferencesHotKey ?? this.enablePreferencesHotKey,
      enableIncreaseOpacityHotKey:
          enableIncreaseOpacityHotKey ?? this.enableIncreaseOpacityHotKey,
      enableDecreaseOpacityHotKey:
          enableDecreaseOpacityHotKey ?? this.enableDecreaseOpacityHotKey,
      showStatusOverlay: showStatusOverlay ?? this.showStatusOverlay,
      overlayMessage: overlayMessage ?? this.overlayMessage,
      statusIcon: statusIcon ?? this.statusIcon,
      activeTriggers: activeTriggers ?? this.activeTriggers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hotKeysEnabled': hotKeysEnabled,
      'visibilityHotKey': visibilityHotKey?.toJson(),
      'autoHideHotKey': autoHideHotKey?.toJson(),
      'toggleMoveHotKey': toggleMoveHotKey?.toJson(),
      'preferencesHotKey': preferencesHotKey?.toJson(),
      'increaseOpacityHotKey': increaseOpacityHotKey?.toJson(),
      'decreaseOpacityHotKey': decreaseOpacityHotKey?.toJson(),
      'enableVisibilityHotKey': enableVisibilityHotKey,
      'enableAutoHideHotKey': enableAutoHideHotKey,
      'enableToggleMoveHotKey': enableToggleMoveHotKey,
      'enablePreferencesHotKey': enablePreferencesHotKey,
      'enableIncreaseOpacityHotKey': enableIncreaseOpacityHotKey,
      'enableDecreaseOpacityHotKey': enableDecreaseOpacityHotKey,
    };
  }

  factory AppState.fromJson(Map<String, dynamic> json) {
    return AppState(
      hotKeysEnabled: json['hotKeysEnabled'] as bool? ?? true,
      visibilityHotKey: json['visibilityHotKey'] != null
          ? HotKey.fromJson(json['visibilityHotKey'])
          : HotKey(
              key: PhysicalKeyboardKey.keyQ,
              modifiers: [HotKeyModifier.alt, HotKeyModifier.control]),
      autoHideHotKey: json['autoHideHotKey'] != null
          ? HotKey.fromJson(json['autoHideHotKey'])
          : HotKey(
              key: PhysicalKeyboardKey.keyW,
              modifiers: [HotKeyModifier.alt, HotKeyModifier.control]),
      toggleMoveHotKey: json['toggleMoveHotKey'] != null
          ? HotKey.fromJson(json['toggleMoveHotKey'])
          : HotKey(
              key: PhysicalKeyboardKey.keyE,
              modifiers: [HotKeyModifier.alt, HotKeyModifier.control]),
      preferencesHotKey: json['preferencesHotKey'] != null
          ? HotKey.fromJson(json['preferencesHotKey'])
          : HotKey(
              key: PhysicalKeyboardKey.keyR,
              modifiers: [HotKeyModifier.alt, HotKeyModifier.control]),
      increaseOpacityHotKey: json['increaseOpacityHotKey'] != null
          ? HotKey.fromJson(json['increaseOpacityHotKey'])
          : HotKey(
              key: PhysicalKeyboardKey.arrowUp,
              modifiers: [HotKeyModifier.alt, HotKeyModifier.control]),
      decreaseOpacityHotKey: json['decreaseOpacityHotKey'] != null
          ? HotKey.fromJson(json['decreaseOpacityHotKey'])
          : HotKey(
              key: PhysicalKeyboardKey.arrowDown,
              modifiers: [HotKeyModifier.alt, HotKeyModifier.control]),
      enableVisibilityHotKey: json['enableVisibilityHotKey'] as bool? ?? true,
      enableAutoHideHotKey: json['enableAutoHideHotKey'] as bool? ?? true,
      enableToggleMoveHotKey: json['enableToggleMoveHotKey'] as bool? ?? true,
      enablePreferencesHotKey: json['enablePreferencesHotKey'] as bool? ?? true,
      enableIncreaseOpacityHotKey:
          json['enableIncreaseOpacityHotKey'] as bool? ?? true,
      enableDecreaseOpacityHotKey:
          json['enableDecreaseOpacityHotKey'] as bool? ?? true,
    );
  }
}

@riverpod
class AppStateNotifier extends _$AppStateNotifier {
  @override
  AppState build() {
    return AppState();
  }

  void updateIsWindowVisible(bool value) {
    state = state.copyWith(isWindowVisible: value);
  }

  void updateIgnoreMouseEvents(bool value) {
    state = state.copyWith(ignoreMouseEvents: value);
  }

  void updateForceHide(bool value) {
    state = state.copyWith(forceHide: value);
  }

  void updateAutoHideBeforeForceHide(bool value) {
    state = state.copyWith(autoHideBeforeForceHide: value);
  }

  void updateHotKeysEnabled(bool value) {
    state = state.copyWith(hotKeysEnabled: value);
  }

  void updateVisibilityHotKey(HotKey hotKey) {
    state = state.copyWith(visibilityHotKey: hotKey);
  }

  void updateAutoHideHotKey(HotKey hotKey) {
    state = state.copyWith(autoHideHotKey: hotKey);
  }

  void updateToggleMoveHotKey(HotKey hotKey) {
    state = state.copyWith(toggleMoveHotKey: hotKey);
  }

  void updatePreferencesHotKey(HotKey hotKey) {
    state = state.copyWith(preferencesHotKey: hotKey);
  }

  void updateIncreaseOpacityHotKey(HotKey hotKey) {
    state = state.copyWith(increaseOpacityHotKey: hotKey);
  }

  void updateDecreaseOpacityHotKey(HotKey hotKey) {
    state = state.copyWith(decreaseOpacityHotKey: hotKey);
  }

  void updateEnableVisibilityHotKey(bool value) {
    state = state.copyWith(enableVisibilityHotKey: value);
  }

  void updateEnableAutoHideHotKey(bool value) {
    state = state.copyWith(enableAutoHideHotKey: value);
  }

  void updateEnableToggleMoveHotKey(bool value) {
    state = state.copyWith(enableToggleMoveHotKey: value);
  }

  void updateEnablePreferencesHotKey(bool value) {
    state = state.copyWith(enablePreferencesHotKey: value);
  }

  void updateEnableIncreaseOpacityHotKey(bool value) {
    state = state.copyWith(enableIncreaseOpacityHotKey: value);
  }

  void updateEnableDecreaseOpacityHotKey(bool value) {
    state = state.copyWith(enableDecreaseOpacityHotKey: value);
  }

  void showStatusOverlay(String message, Icon icon) {
    state = state.copyWith(
      showStatusOverlay: true,
      overlayMessage: message,
      statusIcon: icon,
    );
  }

  void hideStatusOverlay() {
    state = state.copyWith(showStatusOverlay: false);
  }

  void updateActiveTriggers(Set<String> triggers) {
    state = state.copyWith(activeTriggers: triggers);
  }

  void addActiveTrigger(String trigger) {
    final newTriggers = {...state.activeTriggers};
    newTriggers.add(trigger);
    state = state.copyWith(activeTriggers: newTriggers);
  }

  void removeActiveTrigger(String trigger) {
    final newTriggers = {...state.activeTriggers};
    newTriggers.remove(trigger);
    state = state.copyWith(activeTriggers: newTriggers);
  }

  void updateAppState(AppState newState) {
    state = newState;
  }
}
