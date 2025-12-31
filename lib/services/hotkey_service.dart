import 'package:flutter/foundation.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

/// Service for managing global hotkeys and their registration
class HotKeyService {
  /// Registers all enabled hotkeys with their respective callbacks
  Future<void> setupHotKeys({
    required HotKey? autoHideHotKey,
    required bool enableAutoHideHotKey,
    required HotKey? visibilityHotKey,
    required bool enableVisibilityHotKey,
    required HotKey? toggleMoveHotKey,
    required bool enableToggleMoveHotKey,
    required HotKey? preferencesHotKey,
    required bool enablePreferencesHotKey,
    required HotKey? increaseOpacityHotKey,
    required bool enableIncreaseOpacityHotKey,
    required HotKey? decreaseOpacityHotKey,
    required bool enableDecreaseOpacityHotKey,
    required bool hotKeysEnabled,
    required VoidCallback onAutoHideTriggered,
    required VoidCallback onVisibilityTriggered,
    required VoidCallback onToggleMoveTriggered,
    required VoidCallback onPreferencesTriggered,
    required VoidCallback onIncreaseOpacityTriggered,
    required VoidCallback onDecreaseOpacityTriggered,
  }) async {
    await hotKeyManager.unregisterAll();

    if (!hotKeysEnabled) {
      return;
    }

    if (enableAutoHideHotKey && autoHideHotKey != null) {
      await hotKeyManager.register(
        autoHideHotKey,
        keyDownHandler: (hotKey) {
          if (kDebugMode) {
            print('Auto-hide hotkey triggered.');
          }
          onAutoHideTriggered();
        },
      );
    }

    if (enableVisibilityHotKey && visibilityHotKey != null) {
      await hotKeyManager.register(
        visibilityHotKey,
        keyDownHandler: (hotKey) {
          if (kDebugMode) {
            print('Visibility hotkey triggered.');
          }
          onVisibilityTriggered();
        },
      );
    }

    if (enableToggleMoveHotKey && toggleMoveHotKey != null) {
      await hotKeyManager.register(
        toggleMoveHotKey,
        keyDownHandler: (hotKey) {
          if (kDebugMode) {
            print('Move hotkey triggered.');
          }
          onToggleMoveTriggered();
        },
      );
    }

    if (enablePreferencesHotKey && preferencesHotKey != null) {
      await hotKeyManager.register(
        preferencesHotKey,
        keyDownHandler: (hotKey) {
          if (kDebugMode) {
            print(
                'Preferences hotkey triggered. Opening/Focusing Preferences Window.');
          }
          onPreferencesTriggered();
        },
      );
    }

    if (enableIncreaseOpacityHotKey && increaseOpacityHotKey != null) {
      await hotKeyManager.register(
        increaseOpacityHotKey,
        keyDownHandler: (hotKey) {
          if (kDebugMode) {
            print('Increase opacity hotkey triggered.');
          }
          onIncreaseOpacityTriggered();
        },
      );
    }

    if (enableDecreaseOpacityHotKey && decreaseOpacityHotKey != null) {
      await hotKeyManager.register(
        decreaseOpacityHotKey,
        keyDownHandler: (hotKey) {
          if (kDebugMode) {
            print('Decrease opacity hotkey triggered.');
          }
          onDecreaseOpacityTriggered();
        },
      );
    }
  }

  /// Formats a hotkey for display with symbols (e.g., "⌃⇧Q")
  String formatHotkey(HotKey? hotkey, bool enabled) {
    if (hotkey == null || !enabled) return '';

    final modifiersList = hotkey.modifiers ?? [];
    final modifiersString = modifiersList.map((m) {
      switch (m) {
        case HotKeyModifier.alt:
          return '⌥';
        case HotKeyModifier.control:
          return '⌃';
        case HotKeyModifier.shift:
          return '⇧';
        case HotKeyModifier.meta:
          return '⊞';
        default:
          return '';
      }
    }).join('');

    final keyName = hotkey.key.keyLabel;
    return modifiersString.isNotEmpty ? '$modifiersString$keyName' : keyName;
  }

  /// Unregisters a single hotkey
  Future<void> unregisterHotKey(HotKey? hotKey) async {
    if (hotKey != null) {
      await hotKeyManager.unregister(hotKey);
    }
  }
}
