import 'dart:io';
import 'package:flutter/material.dart';
import 'package:overkeys/widgets/options/options.dart';
import 'package:overkeys/models/keyboard_layouts.dart';
import 'package:overkeys/services/config_service.dart';
import 'package:overkeys/models/user_config.dart';

class GeneralTab extends StatefulWidget {
  final bool launchAtStartup;
  final bool autoHideEnabled;
  final double autoHideDuration;
  final String keyboardLayoutName;
  final bool enableAdvancedSettings;
  final bool useUserLayout;
  final bool showAltLayout;
  final bool kanataEnabled;
  final Function(bool) updateLaunchAtStartup;
  final Function(bool) updateAutoHideEnabled;
  final Function(double) updateAutoHideDuration;
  final Function(String) updateKeyboardLayoutName;
  final Function(bool) updateEnableAdvancedSettings;
  final Function(bool) updateUseUserLayout;
  final Function(bool) updateShowAltLayout;
  final Function(bool) updateKanataEnabled;

  const GeneralTab({
    super.key,
    required this.launchAtStartup,
    required this.autoHideEnabled,
    required this.autoHideDuration,
    required this.keyboardLayoutName,
    required this.enableAdvancedSettings,
    required this.useUserLayout,
    required this.showAltLayout,
    required this.kanataEnabled,
    required this.updateLaunchAtStartup,
    required this.updateAutoHideEnabled,
    required this.updateAutoHideDuration,
    required this.updateKeyboardLayoutName,
    required this.updateEnableAdvancedSettings,
    required this.updateUseUserLayout,
    required this.updateShowAltLayout,
    required this.updateKanataEnabled,
  });

  @override
  State<GeneralTab> createState() => _GeneralTabState();
}

class _GeneralTabState extends State<GeneralTab> {
  late double _localAutoHideDuration;

  @override
  void initState() {
    super.initState();
    _localAutoHideDuration = widget.autoHideDuration;
  }

  @override
  void didUpdateWidget(GeneralTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.autoHideDuration != widget.autoHideDuration) {
      _localAutoHideDuration = widget.autoHideDuration;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SectionTitle(title: 'General Settings'),
        ToggleOption(
          label: 'Open on system startup',
          value: widget.launchAtStartup,
          onChanged: widget.updateLaunchAtStartup,
        ),
        ToggleOption(
          label: 'Auto-hide keyboard',
          value: widget.autoHideEnabled,
          onChanged: widget.updateAutoHideEnabled,
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          firstChild: const SizedBox.shrink(),
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
              widget.updateAutoHideDuration(roundedValue);
            },
            valueDisplayFormatter: (value) => value.toStringAsFixed(1),
          ),
          crossFadeState: widget.autoHideEnabled
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          sizeCurve: Curves.easeInOut,
        ),
        DropdownOption(
          label: 'Layout',
          value: widget.keyboardLayoutName,
          options: availableLayouts.map((layout) => (layout.name)).toList(),
          onChanged: (value) => widget.updateKeyboardLayoutName(value!),
        ),
        ToggleOption(
          label: 'Turn on advanced settings',
          value: widget.enableAdvancedSettings,
          onChanged: widget.updateEnableAdvancedSettings,
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: [
              ToggleOption(
                label: 'Use custom layout from config',
                value: widget.useUserLayout,
                subtitle:
                    'Sets layout to user-defined defaultUserLayout. Make sure that the layout is saved in the config file.',
                onChanged: (value) {
                  if (value && widget.kanataEnabled) {
                    widget.updateKanataEnabled(false);
                  }
                  widget.updateUseUserLayout(value);
                },
              ),
              ToggleOption(
                label: 'Show alternative layout',
                value: widget.showAltLayout,
                onChanged: widget.updateShowAltLayout,
              ),
              ToggleOption(
                label: 'Connect to Kanata',
                value: widget.kanataEnabled,
                subtitle:
                    'Make sure that Kanata and OverKeys are using the same port. Restart OverKeys if config file changes were made to apply changes.',
                onChanged: (value) {
                  if (value && widget.useUserLayout) {
                    widget.updateUseUserLayout(false);
                  }
                  widget.updateKanataEnabled(value);
                },
              ),
              _buildOpenConfigButton(context),
            ],
          ),
          crossFadeState: widget.enableAdvancedSettings
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          sizeCurve: Curves.easeInOut,
        ),
      ],
    );
  }

  Widget _buildOpenConfigButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return OptionContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Open config file',
                    style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 16)),
                Text(
                  'Turn related advanced setting off then on again to apply changes',
                  style: TextStyle(
                      color: colorScheme.onSurface.withAlpha(153),
                      fontSize: 14.0),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            icon: Icon(Icons.file_open, color: colorScheme.primary),
            label: Text('Open',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                )),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.surfaceContainerHighest,
              elevation: 2,
              minimumSize: const Size(100, 45),
              side: BorderSide(color: colorScheme.primary),
            ),
            onPressed: () async {
              try {
                final configService = ConfigService();
                final configPath = await configService.configPath;
                final file = File(configPath);

                if (await file.exists()) {
                  Process.start('cmd.exe', ['/c', 'start', '', configPath]);
                } else {
                  await configService.saveConfig(UserConfig());
                  Process.start('cmd.exe', ['/c', 'start', '', configPath]);
                }
              } catch (e) {
                debugPrint('Error opening config file: $e');
              }
            },
          ),
        ],
      ),
    );
  }
}
