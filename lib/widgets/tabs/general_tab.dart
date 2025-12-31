import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overkeys/widgets/options/options.dart';
import 'package:overkeys/models/keyboard_layouts.dart';
import 'package:overkeys/providers/keyboard_provider.dart';
import 'package:overkeys/providers/preferences_provider.dart';

class GeneralTab extends ConsumerStatefulWidget {
  final Function(String method, dynamic value) onUpdateMainWindow;

  const GeneralTab({
    super.key,
    required this.onUpdateMainWindow,
  });

  @override
  ConsumerState<GeneralTab> createState() => _GeneralTabState();
}

class _GeneralTabState extends ConsumerState<GeneralTab> {
  late double _localAutoHideDuration;
  late double _localOpacity;

  @override
  void initState() {
    super.initState();
    // Initialize with current provider values
    final prefsState = ref.read(preferencesNotifierProvider);
    _localAutoHideDuration = prefsState.autoHideDuration;
    _localOpacity = prefsState.opacity.clamp(0.1, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final prefsState = ref.watch(preferencesNotifierProvider);
    final keyboardState = ref.watch(keyboardNotifierProvider);

    // Listen for external provider changes and sync local state
    ref.listen<PreferencesState>(preferencesNotifierProvider, (previous, next) {
      if (previous != null) {
        if (_localAutoHideDuration != next.autoHideDuration) {
          setState(() => _localAutoHideDuration = next.autoHideDuration);
        }
        if (_localOpacity != next.opacity.clamp(0.1, 1.0)) {
          setState(() => _localOpacity = next.opacity.clamp(0.1, 1.0));
        }
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ToggleOption(
          label: 'Open on system startup',
          value: prefsState.launchAtStartup,
          onChanged: (value) {
            ref
                .read(preferencesNotifierProvider.notifier)
                .updateLaunchAtStartup(value);
            widget.onUpdateMainWindow('updateLaunchAtStartup', value);
          },
        ),
        ToggleOption(
          label: 'Auto-hide keyboard',
          value: prefsState.autoHideEnabled,
          onChanged: (value) {
            ref
                .read(preferencesNotifierProvider.notifier)
                .updateAutoHideEnabled(value);
            widget.onUpdateMainWindow('updateAutoHideEnabled', value);
          },
        ),
        ToggleOption(
          label: 'Enable Reactive Shift',
          value: prefsState.reactiveShiftEnabled,
          subtitle:
              'Updates the displayed keys to their Shift+Key symbols when Shift is pressed',
          onChanged: (value) {
            ref
                .read(preferencesNotifierProvider.notifier)
                .updateReactiveShiftEnabled(value);
            widget.onUpdateMainWindow('updateReactiveShiftEnabled', value);
          },
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          firstChild: ToggleOption(
            label: 'Start hidden',
            value: prefsState.hideAtStartup,
            onChanged: (value) {
              ref
                  .read(preferencesNotifierProvider.notifier)
                  .updateHideAtStartup(value);
              widget.onUpdateMainWindow('updateHideAtStartup', value);
            },
          ),
          secondChild: SliderOption(
            label: 'Auto-hide duration (seconds)',
            value: _localAutoHideDuration,
            min: 0.5,
            max: 5.0,
            divisions: 9,
            onChanged: (value) {
              double roundedValue = (value * 2).round() / 2;
              setState(() => _localAutoHideDuration = roundedValue);
            },
            onChangeEnd: (value) {
              double roundedValue = (value * 2).round() / 2;
              ref
                  .read(preferencesNotifierProvider.notifier)
                  .updateAutoHideDuration(roundedValue);
              widget.onUpdateMainWindow('updateAutoHideDuration', roundedValue);
            },
            valueDisplayFormatter: (value) => value.toStringAsFixed(1),
          ),
          crossFadeState: prefsState.autoHideEnabled
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          sizeCurve: Curves.easeInOut,
        ),
        SliderOption(
          label: 'Opacity',
          value: _localOpacity,
          min: 0.1,
          max: 1.0,
          divisions: 18,
          onChanged: (value) {
            setState(() => _localOpacity = value);
          },
          onChangeEnd: (value) {
            ref.read(preferencesNotifierProvider.notifier).updateOpacity(value);
            widget.onUpdateMainWindow('updateOpacity', value);
          },
        ),
        DropdownOption(
          label: 'Layout',
          value: keyboardState.layout.name,
          options: availableLayouts.map((layout) => (layout.name)).toList(),
          onChanged: (value) {
            final layout = availableLayouts.firstWhere(
              (l) => l.name == value!,
              orElse: () => availableLayouts.first,
            );
            ref.read(keyboardNotifierProvider.notifier).updateLayout(layout);
            widget.onUpdateMainWindow('updateLayout', value!);
          },
        ),
        Text(
          'Tip: Press ESC key to close the preferences window',
          style: TextStyle(
            fontSize: 16,
            fontStyle: FontStyle.italic,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ],
    );
  }
}
