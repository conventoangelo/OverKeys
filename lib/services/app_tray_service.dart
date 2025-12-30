import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:tray_manager/tray_manager.dart';

/// Service for managing the system tray icon and menu
class AppTrayService {
  Future<void> setupTray({
    required String toggleMoveHotKeyLabel,
    required String autoHideHotKeyLabel,
    required String preferencesHotKeyLabel,
    required String visibilityHotKeyLabel,
    required bool ignoreMouseEvents,
    required bool autoHideEnabled,
    required VoidCallback onToggleMoveClicked,
    required VoidCallback onAutoHideClicked,
    required VoidCallback onResetPositionClicked,
    required VoidCallback onPreferencesClicked,
    required VoidCallback onToggleVisibilityClicked,
    required VoidCallback onReloadConfigClicked,
  }) async {
    final String iconPath = Platform.isWindows
        ? 'assets/images/app_icon.ico'
        : 'assets/images/app_icon.png';

    await Future.wait([
      trayManager.setIcon(iconPath),
      trayManager.setToolTip('OverKeys'),
    ]);

    trayManager.setContextMenu(Menu(items: [
      MenuItem.checkbox(
        key: 'toggle_mouse_events',
        label: 'Move\t$toggleMoveHotKeyLabel',
        checked: !ignoreMouseEvents,
        onClick: (menuItem) => onToggleMoveClicked(),
      ),
      MenuItem.separator(),
      MenuItem.checkbox(
        key: 'toggle_auto_hide',
        label: 'Auto Hide\t$autoHideHotKeyLabel',
        checked: autoHideEnabled,
        onClick: (menuItem) => onAutoHideClicked(),
      ),
      MenuItem.separator(),
      MenuItem(
        key: 'reset_position',
        label: 'Reset Position',
        onClick: (menuItem) => onResetPositionClicked(),
      ),
      MenuItem.separator(),
      MenuItem(
        key: 'preferences',
        label: 'Preferences\t$preferencesHotKeyLabel',
        onClick: (menuItem) => onPreferencesClicked(),
      ),
      MenuItem.separator(),
      MenuItem(
        key: 'toggle_visibility',
        label: 'Hide/Show\t$visibilityHotKeyLabel',
        onClick: (menuItem) => onToggleVisibilityClicked(),
      ),
      MenuItem.separator(),
      MenuItem(
        key: 'reload_config',
        label: 'Reload Config',
        onClick: (menuItem) => onReloadConfigClicked(),
      ),
      MenuItem.separator(),
      MenuItem(
        key: 'exit',
        label: 'Exit',
      ),
    ]));
  }
}
