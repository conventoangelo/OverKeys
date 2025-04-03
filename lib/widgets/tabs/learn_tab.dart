import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:overkeys/widgets/options/options.dart';

class LearnTab extends StatelessWidget {
  final bool learningModeEnabled;
  final Color pinkyLeftColor;
  final Color ringLeftColor;
  final Color middleLeftColor;
  final Color indexLeftColor;
  final Color indexRightColor;
  final Color middleRightColor;
  final Color ringRightColor;
  final Color pinkyRightColor;
  final Function(bool) updateLearningModeEnabled;
  final Function(Color) updatePinkyLeftColor;
  final Function(Color) updateRingLeftColor;
  final Function(Color) updateMiddleLeftColor;
  final Function(Color) updateIndexLeftColor;
  final Function(Color) updateIndexRightColor;
  final Function(Color) updateMiddleRightColor;
  final Function(Color) updateRingRightColor;
  final Function(Color) updatePinkyRightColor;

  const LearnTab({
    super.key,
    required this.learningModeEnabled,
    required this.pinkyLeftColor,
    required this.ringLeftColor,
    required this.middleLeftColor,
    required this.indexLeftColor,
    required this.indexRightColor,
    required this.middleRightColor,
    required this.ringRightColor,
    required this.pinkyRightColor,
    required this.updateLearningModeEnabled,
    required this.updatePinkyLeftColor,
    required this.updateRingLeftColor,
    required this.updateMiddleLeftColor,
    required this.updateIndexLeftColor,
    required this.updateIndexRightColor,
    required this.updateMiddleRightColor,
    required this.updateRingRightColor,
    required this.updatePinkyRightColor,
  });

  void _resetToDefaultColors() {
    updatePinkyLeftColor(const Color(0xFFED3345));
    updateRingLeftColor(const Color(0xFFFAA71D));
    updateMiddleLeftColor(const Color(0xFF70C27B));
    updateIndexLeftColor(const Color(0xFF00AFEB));
    updateIndexRightColor(const Color(0xFF5985BF));
    updateMiddleRightColor(const Color(0xFF97D6F5));
    updateRingRightColor(const Color(0xFFFFE8A0));
    updatePinkyRightColor(const Color(0xFFBDE0BF));
  }

  @override
  Widget build(BuildContext context) {
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
              value: learningModeEnabled,
              onChanged: updateLearningModeEnabled,
            ),
            if (learningModeEnabled) ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ColorOption(
                          label: 'Pinky Finger (Left)',
                          currentColor: pinkyLeftColor,
                          onColorChanged: updatePinkyLeftColor,
                        ),
                        ColorOption(
                          label: 'Ring Finger (Left)',
                          currentColor: ringLeftColor,
                          onColorChanged: updateRingLeftColor,
                        ),
                        ColorOption(
                          label: 'Middle Finger (Left)',
                          currentColor: middleLeftColor,
                          onColorChanged: updateMiddleLeftColor,
                        ),
                        ColorOption(
                          label: 'Index Finger (Left)',
                          currentColor: indexLeftColor,
                          onColorChanged: updateIndexLeftColor,
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
                          currentColor: pinkyRightColor,
                          onColorChanged: updatePinkyRightColor,
                        ),
                        ColorOption(
                          label: 'Ring Finger (Right)',
                          currentColor: ringRightColor,
                          onColorChanged: updateRingRightColor,
                        ),
                        ColorOption(
                          label: 'Middle Finger (Right)',
                          currentColor: middleRightColor,
                          onColorChanged: updateMiddleRightColor,
                        ),
                        ColorOption(
                          label: 'Index Finger (Right)',
                          currentColor: indexRightColor,
                          onColorChanged: updateIndexRightColor,
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
                      onPressed: _resetToDefaultColors,
                    ),
                  ],
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60.0),
              child: Image.asset(
                'assets/images/colorkeys.png',
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
