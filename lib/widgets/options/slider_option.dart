import 'package:flutter/material.dart';
import 'base_option.dart';

class SliderOption extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final Function(double) onChanged;
  final Function(double) onChangeEnd;
  final String Function(double)? valueDisplayFormatter;
  final String? subtitle;

  const SliderOption({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    required this.onChangeEnd,
    this.valueDisplayFormatter,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return OptionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 16)),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
              child: Text(
                subtitle!,
                style: TextStyle(
                    color: colorScheme.onSurface.withAlpha(153),
                    fontSize: 14.0),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            )
          else
            const SizedBox(height: 8.0),
          Slider(
            value: value,
            min: min,
            divisions: divisions,
            label: valueDisplayFormatter != null
                ? valueDisplayFormatter!(value)
                : value.toStringAsFixed(2),
            max: max,
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
            // ignore: deprecated_member_use
            year2023: false,
          ),
        ],
      ),
    );
  }
}
