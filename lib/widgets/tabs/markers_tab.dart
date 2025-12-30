import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overkeys/widgets/options/options.dart';
import 'package:overkeys/providers/keyboard_provider.dart';
import 'package:overkeys/providers/preferences_provider.dart';

class MarkersTab extends ConsumerStatefulWidget {
  final Function(String method, dynamic value) onUpdateMainWindow;

  const MarkersTab({
    super.key,
    required this.onUpdateMainWindow,
  });

  @override
  ConsumerState<MarkersTab> createState() => _MarkersTabState();
}

class _MarkersTabState extends ConsumerState<MarkersTab> {
  late double _localMarkerOffset;
  late double _localMarkerWidth;
  late double _localMarkerHeight;
  late double _localMarkerBorderRadius;

  @override
  void initState() {
    super.initState();
    // Initialize with current provider values
    final keyboardState = ref.read(keyboardNotifierProvider);
    _localMarkerOffset = keyboardState.markerOffset;
    _localMarkerWidth = keyboardState.markerWidth;
    _localMarkerHeight = keyboardState.markerHeight;
    _localMarkerBorderRadius = keyboardState.markerBorderRadius;
  }

  @override
  Widget build(BuildContext context) {
    final prefsState = ref.watch(preferencesNotifierProvider);

    // Listen for external provider changes and sync local state
    ref.listen<KeyboardState>(keyboardNotifierProvider, (previous, next) {
      if (previous != null) {
        if (_localMarkerOffset != next.markerOffset) {
          setState(() => _localMarkerOffset = next.markerOffset);
        }
        if (_localMarkerWidth != next.markerWidth) {
          setState(() => _localMarkerWidth = next.markerWidth);
        }
        if (_localMarkerHeight != next.markerHeight) {
          setState(() => _localMarkerHeight = next.markerHeight);
        }
        if (_localMarkerBorderRadius != next.markerBorderRadius) {
          setState(() => _localMarkerBorderRadius = next.markerBorderRadius);
        }
      }
    });

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
          onChangeEnd: (value) {
            ref
                .read(keyboardNotifierProvider.notifier)
                .updateMarkerOffset(value);
            widget.onUpdateMainWindow('updateMarkerOffset', value);
          },
        ),
        SliderOption(
          label: 'Marker width',
          value: _localMarkerWidth,
          min: 0,
          max: 20,
          divisions: 20,
          subtitle: prefsState.showAltLayout
              ? 'When alternative layout is shown, marker width appear at half the size (width × 0.5)'
              : null,
          onChanged: (value) {
            setState(() => _localMarkerWidth = value);
          },
          onChangeEnd: (value) {
            ref
                .read(keyboardNotifierProvider.notifier)
                .updateMarkerWidth(value);
            widget.onUpdateMainWindow('updateMarkerWidth', value);
          },
        ),
        SliderOption(
          label: 'Marker height',
          value: _localMarkerHeight,
          min: 0,
          max: 10,
          divisions: 20,
          subtitle: prefsState.showAltLayout
              ? 'When alternative layout is shown, marker height is not used and instead equals the marker width after computation'
              : null,
          onChanged: (value) {
            setState(() => _localMarkerHeight = value);
          },
          onChangeEnd: (value) {
            ref
                .read(keyboardNotifierProvider.notifier)
                .updateMarkerHeight(value);
            widget.onUpdateMainWindow('updateMarkerHeight', value);
          },
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
          onChangeEnd: (value) {
            ref
                .read(keyboardNotifierProvider.notifier)
                .updateMarkerBorderRadius(value);
            widget.onUpdateMainWindow('updateMarkerBorderRadius', value);
          },
        ),
      ],
    );
  }
}
