import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:overkeys/widgets/options/options.dart';
import 'package:overkeys/widgets/dialog/record_hotkey.dart';

class HotKeysTab extends StatefulWidget {
  final bool hotKeysEnabled;
  final HotKey visibilityHotKey;
  final HotKey autoHideHotKey;
  final Function(bool) updateHotKeysEnabled;
  final Function(HotKey) updateVisibilityHotKey;
  final Function(HotKey) updateAutoHideHotKey;

  const HotKeysTab({
    super.key,
    required this.hotKeysEnabled,
    required this.visibilityHotKey,
    required this.autoHideHotKey,
    required this.updateHotKeysEnabled,
    required this.updateVisibilityHotKey,
    required this.updateAutoHideHotKey,
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
          ),
        ),
        HotKeyOption(
          label: 'Toggle Auto Hide',
          subtitle:
              'Enable or disable auto-hide feature with a keyboard shortcut',
          formattedHotKey: _formatHotKey(widget.autoHideHotKey),
          onChangePressed: () => _showRecordHotKeyDialog(
            context,
            widget.updateAutoHideHotKey,
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

  void _showRecordHotKeyDialog(
      BuildContext context, Function(HotKey) onHotKeyRecorded) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return RecordHotKeyDialog(
          onHotKeyRecorded: onHotKeyRecorded,
        );
      },
    );
  }
}
