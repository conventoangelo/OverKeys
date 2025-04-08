import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'base_option.dart';

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
                          copyFormat: ColorPickerCopyFormat.hexRRGGBB,
                          parseShortHexCode: true,
                          editUsesParsedPaste: true,
                          copyButton: false,
                          pasteButton: false,
                          ctrlC: false,
                          ctrlV: false,
                          autoFocus: false,
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
