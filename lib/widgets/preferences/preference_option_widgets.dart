import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

class OptionContainer extends StatelessWidget {
  final Widget child;

  const OptionContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}

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

class ColorOption extends StatelessWidget {
  final String label;
  final Color currentColor;
  final Function(Color) onColorChanged;

  const ColorOption({
    super.key,
    required this.label,
    required this.currentColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return OptionContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 16)),
          ColorIndicator(
            width: 44,
            height: 44,
            borderRadius: 11,
            color: currentColor,
            onSelectFocus: false,
            onSelect: () async {
              final Color? newColor = await showDialog<Color>(
                context: context,
                builder: (BuildContext context) {
                  Color pickerColor = currentColor;
                  return AlertDialog(
                    backgroundColor: colorScheme.surface,
                    content: SingleChildScrollView(
                      child: ColorPicker(
                        wheelDiameter: 250,
                        wheelWidth: 22,
                        wheelSquarePadding: 4,
                        wheelSquareBorderRadius: 16,
                        wheelHasBorder: true,
                        color: pickerColor,
                        onColorChanged: (Color color) {
                          pickerColor = color;
                        },
                        heading: Text(
                          'Select color',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        showColorName: true,
                        showColorCode: true,
                        copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                          copyButton: true,
                          pasteButton: true,
                          ctrlC: true,
                          ctrlV: true,
                        ),
                        colorNameTextStyle:
                            TextStyle(color: colorScheme.onSurface),
                        colorCodeTextStyle:
                            TextStyle(color: colorScheme.onSurface),
                        pickersEnabled: const <ColorPickerType, bool>{
                          ColorPickerType.primary: false,
                          ColorPickerType.accent: false,
                          ColorPickerType.wheel: true,
                        },
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Cancel',
                            style: TextStyle(color: colorScheme.primary)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text('OK',
                            style: TextStyle(color: colorScheme.primary)),
                        onPressed: () {
                          Navigator.of(context).pop(pickerColor);
                        },
                      ),
                    ],
                  );
                },
              );
              if (newColor != null) {
                onColorChanged(newColor);
              }
            },
          ),
        ],
      ),
    );
  }
}
