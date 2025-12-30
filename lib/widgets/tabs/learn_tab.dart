import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:overkeys/widgets/options/options.dart';
import 'package:overkeys/providers/keyboard_provider.dart';

class LearnTab extends ConsumerWidget {
  final Function(String method, dynamic value) onUpdateMainWindow;

  const LearnTab({
    super.key,
    required this.onUpdateMainWindow,
  });

  void _resetToDefaultColors(WidgetRef ref) {
    ref
        .read(keyboardNotifierProvider.notifier)
        .updatePinkyLeftColor(const Color(0xFFED3345));
    onUpdateMainWindow('updatePinkyLeftColor', const Color(0xFFED3345));
    ref
        .read(keyboardNotifierProvider.notifier)
        .updateRingLeftColor(const Color(0xFFFAA71D));
    onUpdateMainWindow('updateRingLeftColor', const Color(0xFFFAA71D));
    ref
        .read(keyboardNotifierProvider.notifier)
        .updateMiddleLeftColor(const Color(0xFF70C27B));
    onUpdateMainWindow('updateMiddleLeftColor', const Color(0xFF70C27B));
    ref
        .read(keyboardNotifierProvider.notifier)
        .updateIndexLeftColor(const Color(0xFF00AFEB));
    onUpdateMainWindow('updateIndexLeftColor', const Color(0xFF00AFEB));
    ref
        .read(keyboardNotifierProvider.notifier)
        .updateIndexRightColor(const Color(0xFF5985BF));
    onUpdateMainWindow('updateIndexRightColor', const Color(0xFF5985BF));
    ref
        .read(keyboardNotifierProvider.notifier)
        .updateMiddleRightColor(const Color(0xFF97D6F5));
    onUpdateMainWindow('updateMiddleRightColor', const Color(0xFF97D6F5));
    ref
        .read(keyboardNotifierProvider.notifier)
        .updateRingRightColor(const Color(0xFFFFE8A0));
    onUpdateMainWindow('updateRingRightColor', const Color(0xFFFFE8A0));
    ref
        .read(keyboardNotifierProvider.notifier)
        .updatePinkyRightColor(const Color(0xFFBDE0BF));
    onUpdateMainWindow('updatePinkyRightColor', const Color(0xFFBDE0BF));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keyboardState = ref.watch(keyboardNotifierProvider);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ToggleOption(
              label: 'Enable Learning Mode',
              subtitle:
                  'Color keys based on finger positions to help learn touch typing. Only changes the color of keys when not pressed',
              value: keyboardState.learningModeEnabled,
              onChanged: (value) {
                ref
                    .read(keyboardNotifierProvider.notifier)
                    .updateLearningModeEnabled(value);
                onUpdateMainWindow('updateLearningModeEnabled', value);
              },
            ),
            if (keyboardState.learningModeEnabled) ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ColorOption(
                          label: 'Pinky Finger (Left)',
                          currentColor: keyboardState.pinkyLeftColor,
                          onColorChanged: (value) {
                            ref
                                .read(keyboardNotifierProvider.notifier)
                                .updatePinkyLeftColor(value);
                            onUpdateMainWindow('updatePinkyLeftColor', value);
                          },
                        ),
                        ColorOption(
                          label: 'Ring Finger (Left)',
                          currentColor: keyboardState.ringLeftColor,
                          onColorChanged: (value) {
                            ref
                                .read(keyboardNotifierProvider.notifier)
                                .updateRingLeftColor(value);
                            onUpdateMainWindow('updateRingLeftColor', value);
                          },
                        ),
                        ColorOption(
                          label: 'Middle Finger (Left)',
                          currentColor: keyboardState.middleLeftColor,
                          onColorChanged: (value) {
                            ref
                                .read(keyboardNotifierProvider.notifier)
                                .updateMiddleLeftColor(value);
                            onUpdateMainWindow('updateMiddleLeftColor', value);
                          },
                        ),
                        ColorOption(
                          label: 'Index Finger (Left)',
                          currentColor: keyboardState.indexLeftColor,
                          onColorChanged: (value) {
                            ref
                                .read(keyboardNotifierProvider.notifier)
                                .updateIndexLeftColor(value);
                            onUpdateMainWindow('updateIndexLeftColor', value);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ColorOption(
                          label: 'Pinky Finger (Right)',
                          currentColor: keyboardState.pinkyRightColor,
                          onColorChanged: (value) {
                            ref
                                .read(keyboardNotifierProvider.notifier)
                                .updatePinkyRightColor(value);
                            onUpdateMainWindow('updatePinkyRightColor', value);
                          },
                        ),
                        ColorOption(
                          label: 'Ring Finger (Right)',
                          currentColor: keyboardState.ringRightColor,
                          onColorChanged: (value) {
                            ref
                                .read(keyboardNotifierProvider.notifier)
                                .updateRingRightColor(value);
                            onUpdateMainWindow('updateRingRightColor', value);
                          },
                        ),
                        ColorOption(
                          label: 'Middle Finger (Right)',
                          currentColor: keyboardState.middleRightColor,
                          onColorChanged: (value) {
                            ref
                                .read(keyboardNotifierProvider.notifier)
                                .updateMiddleRightColor(value);
                            onUpdateMainWindow('updateMiddleRightColor', value);
                          },
                        ),
                        ColorOption(
                          label: 'Index Finger (Right)',
                          currentColor: keyboardState.indexRightColor,
                          onColorChanged: (value) {
                            ref
                                .read(keyboardNotifierProvider.notifier)
                                .updateIndexRightColor(value);
                            onUpdateMainWindow('updateIndexRightColor', value);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              OptionContainer(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reset color configuration',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                          Text(
                            'Restore all finger colors to their default values',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withAlpha(153),
                                fontSize: 14.0),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      icon: Icon(LucideIcons.refreshCw,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24),
                      label: Text('Reset',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          )),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        elevation: 2,
                        minimumSize: const Size(100, 45),
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      onPressed: () => _resetToDefaultColors(ref),
                    ),
                  ],
                ),
              ),
              Text(
                'NOTE: The colors for key/s in the last row (Thumb keys) are customizable through the "Key(not pressed)" color under the Colors tab.',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(height: 20),
            ],
            Image.asset(
              'assets/images/learn_mode.png',
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
