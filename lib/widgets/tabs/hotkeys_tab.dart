import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:overkeys/widgets/options/options.dart';
import 'package:overkeys/widgets/dialog/record_hotkey.dart';

class HotKeysTab extends StatefulWidget {
  final bool hotKeysEnabled;
  final HotKey visibilityHotKey;
  final HotKey autoHideHotKey;
  final HotKey toggleMoveHotKey;
  final HotKey preferencesHotKey;
  final HotKey increaseOpacityHotKey;
  final HotKey decreaseOpacityHotKey;
  final bool enableVisibilityHotKey;
  final bool enableAutoHideHotKey;
  final bool enableToggleMoveHotKey;
  final bool enablePreferencesHotKey;
  final bool enableIncreaseOpacityHotKey;
  final bool enableDecreaseOpacityHotKey;
  final Function(bool) updateHotKeysEnabled;
  final Function(HotKey) updateVisibilityHotKey;
  final Function(HotKey) updateAutoHideHotKey;
  final Function(HotKey) updateToggleMoveHotKey;
  final Function(HotKey) updatePreferencesHotKey;
  final Function(HotKey) updateIncreaseOpacityHotKey;
  final Function(HotKey) updateDecreaseOpacityHotKey;
  final Function(bool) updateEnableVisibilityHotKey;
  final Function(bool) updateEnableAutoHideHotKey;
  final Function(bool) updateEnableToggleMoveHotKey;
  final Function(bool) updateEnablePreferencesHotKey;
  final Function(bool) updateEnableIncreaseOpacityHotKey;
  final Function(bool) updateEnableDecreaseOpacityHotKey;

  const HotKeysTab({
    super.key,
    required this.hotKeysEnabled,
    required this.visibilityHotKey,
    required this.autoHideHotKey,
    required this.toggleMoveHotKey,
    required this.preferencesHotKey,
    required this.increaseOpacityHotKey,
    required this.decreaseOpacityHotKey,
    required this.updateHotKeysEnabled,
    required this.updateVisibilityHotKey,
    required this.updateAutoHideHotKey,
    required this.updateToggleMoveHotKey,
    required this.updatePreferencesHotKey,
    required this.updateIncreaseOpacityHotKey,
    required this.updateDecreaseOpacityHotKey,
    required this.enableVisibilityHotKey,
    required this.enableAutoHideHotKey,
    required this.enableToggleMoveHotKey,
    required this.enablePreferencesHotKey,
    required this.enableIncreaseOpacityHotKey,
    required this.enableDecreaseOpacityHotKey,
    required this.updateEnableVisibilityHotKey,
    required this.updateEnableAutoHideHotKey,
    required this.updateEnableToggleMoveHotKey,
    required this.updateEnablePreferencesHotKey,
    required this.updateEnableIncreaseOpacityHotKey,
    required this.updateEnableDecreaseOpacityHotKey,
  });

  @override
  State<HotKeysTab> createState() => _HotKeysTabState();
}

class _HotKeysTabState extends State<HotKeysTab> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ToggleOption(
            label: 'Enable hotkeys',
            value: widget.hotKeysEnabled,
            onChanged: widget.updateHotKeysEnabled),
        HotKeyOption(
          label: 'Toggle Visibility',
          subtitle:
              'Force show or hide the overlay with a keyboard shortcut even if it\'s set to auto-hide',
          formattedHotKey: _formatHotKey(widget.visibilityHotKey),
          enabled: widget.enableVisibilityHotKey,
          onToggleChanged: widget.updateEnableVisibilityHotKey,
          onChangePressed: () => _showRecordHotKeyDialog(
            context,
            widget.updateVisibilityHotKey,
            widget.visibilityHotKey,
          ),
          isEnabled: widget.hotKeysEnabled,
        ),
        HotKeyOption(
          label: 'Toggle Auto Hide',
          subtitle: 'Enable or disable auto-hide feature',
          formattedHotKey: _formatHotKey(widget.autoHideHotKey),
          enabled: widget.enableAutoHideHotKey,
          onToggleChanged: widget.updateEnableAutoHideHotKey,
          onChangePressed: () => _showRecordHotKeyDialog(
            context,
            widget.updateAutoHideHotKey,
            widget.autoHideHotKey,
          ),
          isEnabled: widget.hotKeysEnabled,
        ),
        HotKeyOption(
          label: 'Toggle Move',
          subtitle: 'Enable or disable keyboard dragging',
          formattedHotKey: _formatHotKey(widget.toggleMoveHotKey),
          enabled: widget.enableToggleMoveHotKey,
          onToggleChanged: widget.updateEnableToggleMoveHotKey,
          onChangePressed: () => _showRecordHotKeyDialog(
            context,
            widget.updateToggleMoveHotKey,
            widget.toggleMoveHotKey,
          ),
          isEnabled: widget.hotKeysEnabled,
        ),
        HotKeyOption(
          label: 'Open Preferences',
          subtitle: 'Show/focus the preferences window',
          formattedHotKey: _formatHotKey(widget.preferencesHotKey),
          enabled: widget.enablePreferencesHotKey,
          onToggleChanged: widget.updateEnablePreferencesHotKey,
          onChangePressed: () => _showRecordHotKeyDialog(
            context,
            widget.updatePreferencesHotKey,
            widget.preferencesHotKey,
          ),
          isEnabled: widget.hotKeysEnabled,
        ),
        HotKeyOption(
          label: 'Increase Opacity',
          subtitle: 'Increase opacity by 5%',
          formattedHotKey: _formatHotKey(widget.increaseOpacityHotKey),
          enabled: widget.enableIncreaseOpacityHotKey,
          onToggleChanged: widget.updateEnableIncreaseOpacityHotKey,
          onChangePressed: () => _showRecordHotKeyDialog(
            context,
            widget.updateIncreaseOpacityHotKey,
            widget.increaseOpacityHotKey,
          ),
          isEnabled: widget.hotKeysEnabled,
        ),
        HotKeyOption(
          label: 'Decrease Opacity',
          subtitle: 'Decrease opacity by 5%',
          formattedHotKey: _formatHotKey(widget.decreaseOpacityHotKey),
          enabled: widget.enableDecreaseOpacityHotKey,
          onToggleChanged: widget.updateEnableDecreaseOpacityHotKey,
          onChangePressed: () => _showRecordHotKeyDialog(
            context,
            widget.updateDecreaseOpacityHotKey,
            widget.decreaseOpacityHotKey,
          ),
          isEnabled: widget.hotKeysEnabled,
        ),
      ],
    );
  }

  String _formatHotKey(HotKey hotKey) {
    final modifiers = hotKey.modifiers?.map((m) {
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
    return modifiers!.isNotEmpty ? '$modifiers + $keyName' : keyName;
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
