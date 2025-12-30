import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

part 'app_state_provider.g.dart';

class AppState {
  // Window visibility
  final bool isWindowVisible;
  final bool ignoreMouseEvents;
  final bool forceHide;
  final bool autoHideBeforeForceHide;
  final bool autoHideBeforeMove;

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
    this.autoHideBeforeMove = false,
    this.hotKeysEnabled = true,
    this.visibilityHotKey,
    this.autoHideHotKey,
    this.toggleMoveHotKey,
    this.preferencesHotKey,
    this.increaseOpacityHotKey,
    this.decreaseOpacityHotKey,
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
  });

  AppState copyWith({
    bool? isWindowVisible,
    bool? ignoreMouseEvents,
    bool? forceHide,
    bool? autoHideBeforeForceHide,
    bool? autoHideBeforeMove,
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
      autoHideBeforeMove: autoHideBeforeMove ?? this.autoHideBeforeMove,
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

  void updateAutoHideBeforeMove(bool value) {
    state = state.copyWith(autoHideBeforeMove: value);
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
