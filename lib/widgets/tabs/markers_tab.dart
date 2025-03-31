import 'package:flutter/material.dart';
import 'package:overkeys/widgets/options/options.dart';

class MarkersTab extends StatefulWidget {
  final double markerOffset;
  final double markerWidth;
  final double markerHeight;
  final double markerBorderRadius;
  final bool showAltLayout;
  final Function(double) updateMarkerOffset;
  final Function(double) updateMarkerWidth;
  final Function(double) updateMarkerHeight;
  final Function(double) updateMarkerBorderRadius;

  const MarkersTab({
    super.key,
    required this.markerOffset,
    required this.markerWidth,
    required this.markerHeight,
    required this.markerBorderRadius,
    required this.showAltLayout,
    required this.updateMarkerOffset,
    required this.updateMarkerWidth,
    required this.updateMarkerHeight,
    required this.updateMarkerBorderRadius,
  });

  @override
  State<MarkersTab> createState() => _MarkersTabState();
}

class _MarkersTabState extends State<MarkersTab> {
  late double _localMarkerOffset;
  late double _localMarkerWidth;
  late double _localMarkerHeight;
  late double _localMarkerBorderRadius;

  @override
  void initState() {
    super.initState();
    _localMarkerOffset = widget.markerOffset;
    _localMarkerWidth = widget.markerWidth;
    _localMarkerHeight = widget.markerHeight;
    _localMarkerBorderRadius = widget.markerBorderRadius;
  }

  @override
  void didUpdateWidget(MarkersTab oldWidget) {
    super.didUpdateWidget(oldWidget);
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
