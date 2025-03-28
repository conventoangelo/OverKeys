import 'package:flutter/material.dart';
import 'package:overkeys/widgets/preferences/preference_option_widgets.dart';

class AppearanceTab extends StatefulWidget {
  final double opacity;
  final Color keyColorPressed;
  final Color keyColorNotPressed;
  final Color markerColor;
  final Color markerColorNotPressed;
  final double markerOffset;
  final double markerWidth;
  final double markerHeight;
  final double markerBorderRadius;
  final bool showAltLayout;
  final Function(double) updateOpacity;
  final Function(Color) updateKeyColorPressed;
  final Function(Color) updateKeyColorNotPressed;
  final Function(Color) updateMarkerColor;
  final Function(Color) updateMarkerColorNotPressed;
  final Function(double) updateMarkerOffset;
  final Function(double) updateMarkerWidth;
  final Function(double) updateMarkerHeight;
  final Function(double) updateMarkerBorderRadius;

  const AppearanceTab({
    super.key,
    required this.opacity,
    required this.keyColorPressed,
    required this.keyColorNotPressed,
    required this.markerColor,
    required this.markerColorNotPressed,
    required this.markerOffset,
    required this.markerWidth,
    required this.markerHeight,
    required this.markerBorderRadius,
    required this.showAltLayout,
    required this.updateOpacity,
    required this.updateKeyColorPressed,
    required this.updateKeyColorNotPressed,
    required this.updateMarkerColor,
    required this.updateMarkerColorNotPressed,
    required this.updateMarkerOffset,
    required this.updateMarkerWidth,
    required this.updateMarkerHeight,
    required this.updateMarkerBorderRadius,
  });

  @override
  State<AppearanceTab> createState() => _AppearanceTabState();
}

class _AppearanceTabState extends State<AppearanceTab> {
  late double _localOpacity;
  late double _localMarkerOffset;
  late double _localMarkerWidth;
  late double _localMarkerHeight;
  late double _localMarkerBorderRadius;

  @override
  void initState() {
    super.initState();
    _localOpacity = widget.opacity;
    _localMarkerOffset = widget.markerOffset;
    _localMarkerWidth = widget.markerWidth;
    _localMarkerHeight = widget.markerHeight;
    _localMarkerBorderRadius = widget.markerBorderRadius;
  }

  @override
  void didUpdateWidget(AppearanceTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.opacity != widget.opacity) {
      _localOpacity = widget.opacity;
    }
    if (oldWidget.markerOffset != widget.markerOffset) {
      _localMarkerOffset = widget.markerOffset;
    }
    if (oldWidget.markerWidth != widget.markerWidth) {
      _localMarkerWidth = widget.markerWidth;
    }
    if (oldWidget.markerHeight != widget.markerHeight) {
      _localMarkerHeight = widget.markerHeight;
    }
    if (oldWidget.markerBorderRadius != widget.markerBorderRadius) {
      _localMarkerBorderRadius = widget.markerBorderRadius;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SectionTitle(title: 'Appearance Settings'),
        SliderOption(
          label: 'Opacity',
          value: _localOpacity,
          min: 0.1,
          max: 1.0,
          divisions: 18,
          onChanged: (value) {
            setState(() => _localOpacity = value);
          },
          onChangeEnd: widget.updateOpacity,
        ),
        ColorOption(
          label: 'Key color (pressed)',
          currentColor: widget.keyColorPressed,
          onColorChanged: widget.updateKeyColorPressed,
        ),
        ColorOption(
          label: 'Key color (not pressed)',
          currentColor: widget.keyColorNotPressed,
          onColorChanged: widget.updateKeyColorNotPressed,
        ),
        SectionTitle(title: 'Tactile Markers'),
        ColorOption(
          label: 'Marker color (pressed)',
          currentColor: widget.markerColor,
          onColorChanged: widget.updateMarkerColor,
        ),
        ColorOption(
          label: 'Marker color (not pressed)',
          currentColor: widget.markerColorNotPressed,
          onColorChanged: widget.updateMarkerColorNotPressed,
        ),
        SliderOption(
          label: 'Marker offset',
          value: _localMarkerOffset,
          min: 0,
          max: 20,
          divisions: 20,
          onChanged: (value) {
            setState(() => _localMarkerOffset = value);
          },
          onChangeEnd: widget.updateMarkerOffset,
        ),
        SliderOption(
          label: 'Marker width',
          value: _localMarkerWidth,
          min: 0,
          max: 20,
          divisions: 20,
          subtitle: widget.showAltLayout
              ? 'When alternative layout is shown, marker width appear at half the size (width × 0.5)'
              : null,
          onChanged: (value) {
            setState(() => _localMarkerWidth = value);
          },
          onChangeEnd: widget.updateMarkerWidth,
        ),
        SliderOption(
          label: 'Marker height',
          value: _localMarkerHeight,
          min: 0,
          max: 10,
          divisions: 10,
          subtitle: widget.showAltLayout
              ? 'When alternative layout is shown, marker height is not used and instead equals the marker width after computation'
              : null,
          onChanged: (value) {
            setState(() => _localMarkerHeight = value);
          },
          onChangeEnd: widget.updateMarkerHeight,
        ),
        SliderOption(
          label: 'Marker border radius',
          value: _localMarkerBorderRadius,
          min: 0,
          max: 10,
          divisions: 10,
          onChanged: (value) {
            setState(() => _localMarkerBorderRadius = value);
          },
          onChangeEnd: widget.updateMarkerBorderRadius,
        ),
      ],
    );
  }
}
