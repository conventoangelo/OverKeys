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
  final Function(bool) updateHotKeysEnabled;
  final Function(HotKey) updateVisibilityHotKey;
  final Function(HotKey) updateAutoHideHotKey;
  final Function(HotKey) updateToggleMoveHotKey;
  final Function(HotKey) updatePreferencesHotKey;

  const HotKeysTab({
    super.key,
    required this.hotKeysEnabled,
    required this.visibilityHotKey,
    required this.autoHideHotKey,
    required this.toggleMoveHotKey,
    required this.preferencesHotKey,
    required this.updateHotKeysEnabled,
    required this.updateVisibilityHotKey,
    required this.updateAutoHideHotKey,
    required this.updateToggleMoveHotKey,
    required this.updatePreferencesHotKey,
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
          onChangePressed: () => _showRecordHotKeyDialog(
            context,
            widget.updateVisibilityHotKey,
            widget.visibilityHotKey,
          ),
        ),
        HotKeyOption(
          label: 'Toggle Auto Hide',
          subtitle: 'Enable or disable auto-hide feature',
          formattedHotKey: _formatHotKey(widget.autoHideHotKey),
          onChangePressed: () => _showRecordHotKeyDialog(
            context,
            widget.updateAutoHideHotKey,
            widget.autoHideHotKey,
          ),
        ),
        HotKeyOption(
          label: 'Toggle Move',
          subtitle: 'Enable or disable keyboard dragging',
          formattedHotKey: _formatHotKey(widget.toggleMoveHotKey),
          onChangePressed: () => _showRecordHotKeyDialog(
            context,
            widget.updateToggleMoveHotKey,
            widget.toggleMoveHotKey,
          ),
        ),
        HotKeyOption(
          label: 'Open Preferences',
          subtitle: 'Show/focus the preferences window (may be delayed)',
          formattedHotKey: _formatHotKey(widget.preferencesHotKey),
          onChangePressed: () => _showRecordHotKeyDialog(
            context,
            widget.updatePreferencesHotKey,
            widget.preferencesHotKey,
          ),
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
