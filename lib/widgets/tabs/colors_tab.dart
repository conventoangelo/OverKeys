import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overkeys/widgets/options/options.dart';
import 'package:overkeys/providers/keyboard_provider.dart';

class ColorsTab extends ConsumerWidget {
  final Function(String method, dynamic value) onUpdateMainWindow;

  const ColorsTab({
    super.key,
    required this.onUpdateMainWindow,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keyboardState = ref.watch(keyboardNotifierProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Pressed colors column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ColorOption(
                label: 'Key (pressed)',
                currentColor: keyboardState.keyColorPressed,
                onColorChanged: (value) {
                  ref
                      .read(keyboardNotifierProvider.notifier)
                      .updateKeyColorPressed(value);
                  onUpdateMainWindow('updateKeyColorPressed', value);
                },
              ),
              ColorOption(
                label: 'Marker (pressed)',
                currentColor: keyboardState.markerColor,
                onColorChanged: (value) {
                  ref
                      .read(keyboardNotifierProvider.notifier)
                      .updateMarkerColor(value);
                  onUpdateMainWindow('updateMarkerColor', value);
                },
              ),
              ColorOption(
                label: 'Text (pressed)',
                currentColor: keyboardState.keyTextColor,
                onColorChanged: (value) {
                  ref
                      .read(keyboardNotifierProvider.notifier)
                      .updateKeyTextColor(value);
                  onUpdateMainWindow('updateKeyTextColor', value);
                },
              ),
              ColorOption(
                label: 'Border (pressed)',
                currentColor: keyboardState.keyBorderColorPressed,
                onColorChanged: (value) {
                  ref
                      .read(keyboardNotifierProvider.notifier)
                      .updateKeyBorderColorPressed(value);
                  onUpdateMainWindow('updateKeyBorderColorPressed', value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 14), // Space between columns
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ColorOption(
                label: 'Key (not pressed)',
                currentColor: keyboardState.keyColorNotPressed,
                onColorChanged: (value) {
                  ref
                      .read(keyboardNotifierProvider.notifier)
                      .updateKeyColorNotPressed(value);
                  onUpdateMainWindow('updateKeyColorNotPressed', value);
                },
              ),
              ColorOption(
                label: 'Marker (not pressed)',
                currentColor: keyboardState.markerColorNotPressed,
                onColorChanged: (value) {
                  ref
                      .read(keyboardNotifierProvider.notifier)
                      .updateMarkerColorNotPressed(value);
                  onUpdateMainWindow('updateMarkerColorNotPressed', value);
                },
              ),
              ColorOption(
                label: 'Text (not pressed)',
                currentColor: keyboardState.keyTextColorNotPressed,
                onColorChanged: (value) {
                  ref
                      .read(keyboardNotifierProvider.notifier)
                      .updateKeyTextColorNotPressed(value);
                  onUpdateMainWindow('updateKeyTextColorNotPressed', value);
                },
              ),
              ColorOption(
                label: 'Border (not pressed)',
                currentColor: keyboardState.keyBorderColorNotPressed,
                onColorChanged: (value) {
                  ref
                      .read(keyboardNotifierProvider.notifier)
                      .updateKeyBorderColorNotPressed(value);
                  onUpdateMainWindow('updateKeyBorderColorNotPressed', value);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
