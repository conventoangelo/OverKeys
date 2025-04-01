import 'package:flutter/material.dart';
import 'package:overkeys/widgets/options/options.dart';

class AnimationsTab extends StatefulWidget {
  final bool animationEnabled;
  final String animationStyle;
  final double animationDuration;
  final double animationScale;
  final Function(bool) updateAnimationEnabled;
  final Function(String) updateAnimationStyle;
  final Function(double) updateAnimationDuration;
  final Function(double) updateAnimationScale;

  const AnimationsTab({
    super.key,
    required this.animationEnabled,
    required this.animationStyle,
    required this.animationDuration,
    required this.animationScale,
    required this.updateAnimationEnabled,
    required this.updateAnimationStyle,
    required this.updateAnimationDuration,
    required this.updateAnimationScale,
  });

  @override
  State<AnimationsTab> createState() => _AnimationsTabState();
}

class _AnimationsTabState extends State<AnimationsTab> {
  late double _localAnimationDuration;
  late double _localAnimationScale;

  @override
  void initState() {
    super.initState();
    _localAnimationDuration = widget.animationDuration;
    _localAnimationScale = widget.animationScale;
  }

  @override
  void didUpdateWidget(AnimationsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationDuration != widget.animationDuration) {
      _localAnimationDuration = widget.animationDuration;
    }
    if (oldWidget.animationScale != widget.animationScale) {
      _localAnimationScale = widget.animationScale;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ToggleOption(
          label: 'Enable animations',
          value: widget.animationEnabled,
          onChanged: widget.updateAnimationEnabled,
        ),
        DropdownOption(
          label: 'Animation style',
          value: widget.animationStyle,
          options: ['Depress', 'Raise', 'Grow', 'Shrink'],
          onChanged: (value) {
            widget.updateAnimationStyle(value!);
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
          onChangeEnd: widget.updateAnimationDuration,
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
          onChangeEnd: widget.updateAnimationScale,
        ),
      ],
    );
  }
}
