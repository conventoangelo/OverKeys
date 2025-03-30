import 'package:flutter/material.dart';
import 'base_option.dart';

class ToggleOption extends StatelessWidget {
  final String label;
  final bool value;
  final Function(bool) onChanged;
  final String? subtitle;

  const ToggleOption({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const WidgetStateProperty<Icon> thumbIcon =
        WidgetStateProperty<Icon>.fromMap(
      <WidgetStatesConstraint, Icon>{
        WidgetState.selected: Icon(Icons.check),
        WidgetState.any: Icon(Icons.close),
      },
    );
    return OptionContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 16)),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                        color: colorScheme.onSurface.withAlpha(153),
                        fontSize: 14.0),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            thumbIcon: thumbIcon,
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
