import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:overkeys/widgets/options/options.dart';
import 'package:overkeys/widgets/dialog/record_hotkey.dart';
import 'package:overkeys/providers/app_state_provider.dart';

class HotKeysTab extends ConsumerWidget {
  final Function(String method, dynamic value) onUpdateMainWindow;

  const HotKeysTab({
    super.key,
    required this.onUpdateMainWindow,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ToggleOption(
            label: 'Enable hotkeys',
            value: appState.hotKeysEnabled,
            onChanged: (value) {
              ref
                  .read(appStateNotifierProvider.notifier)
                  .updateHotKeysEnabled(value);
              onUpdateMainWindow('updateHotKeysEnabled', value);
            }),
        HotKeyOption(
          label: 'Toggle Visibility',
          subtitle:
              'Force show or hide the overlay with a keyboard shortcut even if it\'s set to auto-hide',
          formattedHotKey: _formatHotKey(appState.visibilityHotKey),
          enabled: appState.enableVisibilityHotKey,
          onToggleChanged: (value) {
            ref
                .read(appStateNotifierProvider.notifier)
                .updateEnableVisibilityHotKey(value);
            onUpdateMainWindow('updateEnableVisibilityHotKey', value);
          },
          onChangePressed: () => _showRecordHotKeyDialog(
            context,
            (value) {
              ref
                  .read(appStateNotifierProvider.notifier)
                  .updateVisibilityHotKey(value);
              onUpdateMainWindow('updateVisibilityHotKey', value);
            },
            appState.visibilityHotKey ??
                HotKey(
                    key: PhysicalKeyboardKey.keyQ,
                    modifiers: [HotKeyModifier.alt, HotKeyModifier.control]),
          ),
          isEnabled: appState.hotKeysEnabled,
        ),
        HotKeyOption(
          label: 'Toggle Auto Hide',
          subtitle: 'Enable or disable auto-hide feature',
          formattedHotKey: _formatHotKey(appState.autoHideHotKey),
          enabled: appState.enableAutoHideHotKey,
          onToggleChanged: (value) {
            ref
                .read(appStateNotifierProvider.notifier)
                .updateEnableAutoHideHotKey(value);
            onUpdateMainWindow('updateEnableAutoHideHotKey', value);
          },
          onChangePressed: () => _showRecordHotKeyDialog(
            context,
            (value) {
              ref
                  .read(appStateNotifierProvider.notifier)
                  .updateAutoHideHotKey(value);
              onUpdateMainWindow('updateAutoHideHotKey', value);
            },
            appState.autoHideHotKey ??
                HotKey(
                    key: PhysicalKeyboardKey.keyW,
                    modifiers: [HotKeyModifier.alt, HotKeyModifier.control]),
          ),
          isEnabled: appState.hotKeysEnabled,
        ),
        HotKeyOption(
          label: 'Toggle Move',
          subtitle: 'Enable or disable keyboard dragging',
          formattedHotKey: _formatHotKey(appState.toggleMoveHotKey),
          enabled: appState.enableToggleMoveHotKey,
          onToggleChanged: (value) {
            ref
                .read(appStateNotifierProvider.notifier)
                .updateEnableToggleMoveHotKey(value);
            onUpdateMainWindow('updateEnableToggleMoveHotKey', value);
          },
          onChangePressed: () => _showRecordHotKeyDialog(
            context,
            (value) {
              ref
                  .read(appStateNotifierProvider.notifier)
                  .updateToggleMoveHotKey(value);
              onUpdateMainWindow('updateToggleMoveHotKey', value);
            },
            appState.toggleMoveHotKey ??
                HotKey(
                    key: PhysicalKeyboardKey.keyE,
                    modifiers: [HotKeyModifier.alt, HotKeyModifier.control]),
          ),
          isEnabled: appState.hotKeysEnabled,
        ),
        HotKeyOption(
          label: 'Open Preferences',
          subtitle: 'Show/focus the preferences window',
          formattedHotKey: _formatHotKey(appState.preferencesHotKey),
          enabled: appState.enablePreferencesHotKey,
          onToggleChanged: (value) {
            ref
                .read(appStateNotifierProvider.notifier)
                .updateEnablePreferencesHotKey(value);
            onUpdateMainWindow('updateEnablePreferencesHotKey', value);
          },
          onChangePressed: () => _showRecordHotKeyDialog(
            context,
            (value) {
              ref
                  .read(appStateNotifierProvider.notifier)
                  .updatePreferencesHotKey(value);
              onUpdateMainWindow('updatePreferencesHotKey', value);
            },
            appState.preferencesHotKey ??
                HotKey(
                    key: PhysicalKeyboardKey.keyR,
                    modifiers: [HotKeyModifier.alt, HotKeyModifier.control]),
          ),
          isEnabled: appState.hotKeysEnabled,
        ),
        HotKeyOption(
          label: 'Increase Opacity',
          subtitle: 'Increase opacity by 5%',
          formattedHotKey: _formatHotKey(appState.increaseOpacityHotKey),
          enabled: appState.enableIncreaseOpacityHotKey,
          onToggleChanged: (value) {
            ref
                .read(appStateNotifierProvider.notifier)
                .updateEnableIncreaseOpacityHotKey(value);
            onUpdateMainWindow('updateEnableIncreaseOpacityHotKey', value);
          },
          onChangePressed: () => _showRecordHotKeyDialog(
            context,
            (value) {
              ref
                  .read(appStateNotifierProvider.notifier)
                  .updateIncreaseOpacityHotKey(value);
              onUpdateMainWindow('updateIncreaseOpacityHotKey', value);
            },
            appState.increaseOpacityHotKey ??
                HotKey(
                    key: PhysicalKeyboardKey.arrowUp,
                    modifiers: [HotKeyModifier.alt, HotKeyModifier.control]),
          ),
          isEnabled: appState.hotKeysEnabled,
        ),
        HotKeyOption(
          label: 'Decrease Opacity',
          subtitle: 'Decrease opacity by 5%',
          formattedHotKey: _formatHotKey(appState.decreaseOpacityHotKey),
          enabled: appState.enableDecreaseOpacityHotKey,
          onToggleChanged: (value) {
            ref
                .read(appStateNotifierProvider.notifier)
                .updateEnableDecreaseOpacityHotKey(value);
            onUpdateMainWindow('updateEnableDecreaseOpacityHotKey', value);
          },
          onChangePressed: () => _showRecordHotKeyDialog(
            context,
            (value) {
              ref
                  .read(appStateNotifierProvider.notifier)
                  .updateDecreaseOpacityHotKey(value);
              onUpdateMainWindow('updateDecreaseOpacityHotKey', value);
            },
            appState.decreaseOpacityHotKey ??
                HotKey(
                    key: PhysicalKeyboardKey.arrowDown,
                    modifiers: [HotKeyModifier.alt, HotKeyModifier.control]),
          ),
          isEnabled: appState.hotKeysEnabled,
        ),
      ],
    );
  }

  String _formatHotKey(HotKey? hotKey) {
    if (hotKey == null) return 'Not set';
    final modifiers = (hotKey.modifiers ?? []).map((m) {
      switch (m) {
        case HotKeyModifier.alt:
          return 'Alt';
        case HotKeyModifier.control:
          return 'Ctrl';
        case HotKeyModifier.shift:
          return 'Shift';
        case HotKeyModifier.meta:
          return 'Win';
        default:
          return '';
      }
    }).join(' + ');

    final keyName = hotKey.key.keyLabel;
    return modifiers.isNotEmpty ? '$modifiers + $keyName' : keyName;
  }

  void _showRecordHotKeyDialog(BuildContext context,
      Function(HotKey) onHotKeyRecorded, HotKey initialHotKey) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return RecordHotKeyDialog(
          onHotKeyRecorded: onHotKeyRecorded,
          initialHotKey: initialHotKey,
        );
      },
    );
  }
}
