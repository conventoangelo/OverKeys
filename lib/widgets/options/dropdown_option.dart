import 'package:flutter/material.dart';
import 'base_option.dart';

class DropdownOption extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final Function(String?) onChanged;
  final String? subtitle;

  const DropdownOption({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final TextEditingController controller = TextEditingController(text: value);

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
          const SizedBox(width: 40),
          DropdownMenu<String>(
            controller: controller,
            initialSelection: value,
            requestFocusOnTap: true,
            enableFilter: true,
            width: 210,
            menuHeight: 300,
            dropdownMenuEntries: options
                .map((String option) => DropdownMenuEntry<String>(
                      value: option,
                      label: option,
                      style: MenuItemButton.styleFrom(
                        textStyle: TextStyle(
                          fontFamily: option,
                          fontFamilyFallback: const ['Manrope'],
                          fontSize: 15,
                        ),
                      ),
                    ))
                .toList(),
            onSelected: (String? newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
            textStyle: TextStyle(
              fontFamily: value,
              fontFamilyFallback: const ['Manrope'],
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
