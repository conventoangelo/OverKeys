import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:overkeys/widgets/preferences/dialog/record_hotkey.dart';

class HotKeysTab extends StatelessWidget {
  final HotKey visibilityHotKey;
  final HotKey autoHideHotKey;
  final Function(HotKey) updateVisibilityHotKey;
  final Function(HotKey) updateAutoHideHotKey;

  const HotKeysTab({
    super.key,
    required this.visibilityHotKey,
    required this.autoHideHotKey,
    required this.updateVisibilityHotKey,
    required this.updateAutoHideHotKey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Keyboard Shortcuts',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        _buildHotKeySection(
          context,
          'Toggle Visibility',
          'Show or hide the overlay with a keyboard shortcut',
          visibilityHotKey,
          updateVisibilityHotKey,
        ),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 20),
        _buildHotKeySection(
          context,
          'Toggle Auto Hide',
          'Enable or disable auto-hide feature with a keyboard shortcut',
          autoHideHotKey,
          updateAutoHideHotKey,
        ),
      ],
    );
  }

  Widget _buildHotKeySection(
    BuildContext context,
    String title,
    String description,
    HotKey hotKey,
    Function(HotKey) updateHotKey,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _formatHotKey(hotKey),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Geist Mono',
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainerHighest,
                elevation: 2,
                minimumSize: const Size(100, 45),
                side: BorderSide(color: colorScheme.primary),
              ),
              onPressed: () => _showRecordHotKeyDialog(context, updateHotKey),
              child: Text(
                'Change',
                style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
              ),
            ),
          ],
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
