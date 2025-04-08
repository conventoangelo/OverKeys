import 'package:flutter/material.dart';
import 'base_option.dart';

class HotKeyOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final String formattedHotKey;
  final bool enabled;
  final bool isEnabled;
  final Function(bool) onToggleChanged;
  final VoidCallback onChangePressed;

  const HotKeyOption({
    super.key,
    required this.label,
    required this.subtitle,
    required this.formattedHotKey,
    required this.enabled,
    required this.onToggleChanged,
    required this.onChangePressed,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return OptionContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      color: colorScheme.onSurface.withAlpha(153),
                      fontSize: 14.0,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Switch(
                thumbIcon: const WidgetStateProperty<Icon>.fromMap(
                  <WidgetStatesConstraint, Icon>{
                    WidgetState.selected: Icon(Icons.check),
                    WidgetState.any: Icon(Icons.close),
                  },
                ),
                value: enabled,
                onChanged: isEnabled ? onToggleChanged : null,
              ),
              const SizedBox(width: 12),
              Opacity(
                opacity: enabled ? 1.0 : 0.35,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    formattedHotKey,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Geist Mono',
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.surface,
                  elevation: 1,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: colorScheme.primary),
                  ),
                ),
                onPressed: enabled ? onChangePressed : null,
                child: Text(
                  'Change',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
