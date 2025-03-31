import 'dart:io';
import 'package:flutter/material.dart';
import 'package:overkeys/widgets/options/options.dart';
import 'package:overkeys/services/config_service.dart';
import 'package:overkeys/models/user_config.dart';

class AdvancedTab extends StatelessWidget {
  final bool enableAdvancedSettings;
  final bool useUserLayout;
  final bool showAltLayout;
  final bool kanataEnabled;
  final Function(bool) updateEnableAdvancedSettings;
  final Function(bool) updateUseUserLayout;
  final Function(bool) updateShowAltLayout;
  final Function(bool) updateKanataEnabled;

  const AdvancedTab({
    super.key,
    required this.enableAdvancedSettings,
    required this.useUserLayout,
    required this.showAltLayout,
    required this.kanataEnabled,
    required this.updateEnableAdvancedSettings,
    required this.updateUseUserLayout,
    required this.updateShowAltLayout,
    required this.updateKanataEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ToggleOption(
          label: 'Turn on advanced settings',
          value: enableAdvancedSettings,
          onChanged: updateEnableAdvancedSettings,
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: [
              ToggleOption(
                label: 'Use custom layout from config',
                value: useUserLayout,
                subtitle:
                    'Sets layout to user-defined defaultUserLayout. Make sure that the layout is saved in the config file.',
                onChanged: (value) {
                  if (value && kanataEnabled) {
                    updateKanataEnabled(false);
                  }
                  updateUseUserLayout(value);
                },
              ),
              ToggleOption(
                label: 'Show alternative layout',
                value: showAltLayout,
                onChanged: updateShowAltLayout,
              ),
              ToggleOption(
                label: 'Connect to Kanata',
                value: kanataEnabled,
                subtitle:
                    'Make sure that Kanata and OverKeys are using the same port. Restart OverKeys if config file changes were made to apply changes.',
                onChanged: (value) {
                  if (value && useUserLayout) {
                    updateUseUserLayout(false);
                  }
                  updateKanataEnabled(value);
                },
              ),
              _buildOpenConfigButton(context),
            ],
          ),
          crossFadeState: enableAdvancedSettings
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
