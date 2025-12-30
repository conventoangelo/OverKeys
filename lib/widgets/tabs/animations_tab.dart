import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overkeys/widgets/options/options.dart';
import 'package:overkeys/providers/keyboard_provider.dart';

class AnimationsTab extends ConsumerStatefulWidget {
  final Function(String method, dynamic value) onUpdateMainWindow;

  const AnimationsTab({
    super.key,
    required this.onUpdateMainWindow,
  });

  @override
  ConsumerState<AnimationsTab> createState() => _AnimationsTabState();
}

class _AnimationsTabState extends ConsumerState<AnimationsTab> {
  late double _localAnimationDuration;
  late double _localAnimationScale;

  @override
  void initState() {
    super.initState();
    // Initialize with current provider values
    final keyboardState = ref.read(keyboardNotifierProvider);
    _localAnimationDuration = keyboardState.animationDuration;
    _localAnimationScale = keyboardState.animationScale;
  }

  @override
  Widget build(BuildContext context) {
    final keyboardState = ref.watch(keyboardNotifierProvider);

    // Listen for external provider changes and sync local state
    ref.listen<KeyboardState>(keyboardNotifierProvider, (previous, next) {
      if (previous != null) {
        if (_localAnimationDuration != next.animationDuration) {
          setState(() => _localAnimationDuration = next.animationDuration);
        }
        if (_localAnimationScale != next.animationScale) {
          setState(() => _localAnimationScale = next.animationScale);
        }
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ToggleOption(
          label: 'Enable animations',
          value: keyboardState.animationEnabled,
          onChanged: (value) {
            ref
                .read(keyboardNotifierProvider.notifier)
                .updateAnimationEnabled(value);
            widget.onUpdateMainWindow('updateAnimationEnabled', value);
          },
        ),
        DropdownOption(
          label: 'Animation style',
          value: keyboardState.animationStyle,
          options: ['Depress', 'Raise', 'Grow', 'Shrink'],
          onChanged: (value) {
            ref
                .read(keyboardNotifierProvider.notifier)
                .updateAnimationStyle(value!);
            widget.onUpdateMainWindow('updateAnimationStyle', value);
          },
        ),
        SliderOption(
          label: 'Animation duration (ms)',
          value: _localAnimationDuration,
          min: 50,
          max: 300,
          divisions: 25,
          onChanged: (value) {
            setState(() => _localAnimationDuration = value);
          },
          onChangeEnd: (value) {
            ref
                .read(keyboardNotifierProvider.notifier)
                .updateAnimationDuration(value);
            widget.onUpdateMainWindow('updateAnimationDuration', value);
          },
        ),
        SliderOption(
          label: 'Animation scale',
          value: _localAnimationScale,
          min: 1.0,
          max: 5.0,
          divisions: 40,
          onChanged: (value) {
            setState(() => _localAnimationScale = value);
          },
          onChangeEnd: (value) {
            ref
                .read(keyboardNotifierProvider.notifier)
                .updateAnimationScale(value);
            widget.onUpdateMainWindow('updateAnimationScale', value);
          },
        ),
      ],
    );
  }
}
