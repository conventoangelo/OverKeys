import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:overkeys/widgets/options/options.dart';
import 'package:overkeys/services/config_service.dart';
import 'package:overkeys/models/user_config.dart';

class AdvancedTab extends StatelessWidget {
  final bool advancedSettingsEnabled;
  final bool useUserLayout;
  final bool showAltLayout;
  final bool customFontEnabled;
  final bool use6ColLayout;
  final bool kanataEnabled;
  final bool keyboardFollowsMouse;
  final Function(bool) updateAdvancedSettingsEnabled;
  final Function(bool) updateUseUserLayout;
  final Function(bool) updateShowAltLayout;
  final Function(bool) updateCustomFontEnabled;
  final Function(bool) updateUse6ColLayout;
  final Function(bool) updateKanataEnabled;
  final Function(bool) updateKeyboardFollowsMouse;

  const AdvancedTab({
    super.key,
    required this.advancedSettingsEnabled,
    required this.useUserLayout,
    required this.showAltLayout,
    required this.customFontEnabled,
    required this.use6ColLayout,
    required this.kanataEnabled,
    required this.keyboardFollowsMouse,
    required this.updateAdvancedSettingsEnabled,
    required this.updateUseUserLayout,
    required this.updateShowAltLayout,
    required this.updateCustomFontEnabled,
    required this.updateUse6ColLayout,
    required this.updateKanataEnabled,
    required this.updateKeyboardFollowsMouse,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ToggleOption(
          label: 'Turn on advanced settings',
          value: advancedSettingsEnabled,
          onChanged: updateAdvancedSettingsEnabled,
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: [
              ToggleOption(
                label: 'Use user layouts',
                value: useUserLayout,
                subtitle:
                    'Use defaultUserLayout defined in the config file (as the base layer). Enables OverKeys to listen and switch between different layers. Make sure that the layouts/layers are saved in the config file.',
                onChanged: (value) {
                  if (value && kanataEnabled) {
                    updateKanataEnabled(false);
                  }
                  updateUseUserLayout(value);
                },
              ),
              ToggleOption(
                label: 'Show alternative layout',
                subtitle:
                    'Show alternative layout alongside primary layout. Make sure that the layout is saved in the config file.',
                value: showAltLayout,
                onChanged: updateShowAltLayout,
              ),
              ToggleOption(
                label: 'Use custom font',
                value: customFontEnabled,
                subtitle:
                    'Use a custom font defined in the config file. Make sure that the font is installed on your system.',
                onChanged: updateCustomFontEnabled,
              ),
              ToggleOption(
                label: 'Use 6 column layout',
                subtitle:
                    'Use 6 column layout instead of 5 column split matrix layout. Make sure that a compatible layout is saved in the config file.',
                value: use6ColLayout,
                onChanged: updateUse6ColLayout,
              ),
              ToggleOption(
                label: 'Connect to Kanata',
                value: kanataEnabled,
                subtitle:
                    'Listen to layer changes and see the active layer. Make sure that Kanata and OverKeys are using the same port.',
                onChanged: (value) {
                  if (value && useUserLayout) {
                    updateUseUserLayout(false);
                  }
                  updateKanataEnabled(value);
                },
              ),
              ToggleOption(
                label: 'Keyboard follows mouse',
                value: keyboardFollowsMouse,
                subtitle:
                    'EXPERIMENTAL: Keyboard will follow your mouse cursor across monitors. Note: This will override manual position adjustments. Also causes focus issues',
                onChanged: updateKeyboardFollowsMouse,
              ),
              _buildOpenConfigButton(context),
            ],
          ),
          crossFadeState:
              advancedSettingsEnabled ? CrossFadeState.showSecond : CrossFadeState.showFirst,
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
                        color: colorScheme.onSurface, fontWeight: FontWeight.w600, fontSize: 16)),
                Text(
                  'Turn related advanced setting off then on again to apply changes.',
                  style: TextStyle(color: colorScheme.onSurface.withAlpha(153), fontSize: 14.0),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            icon: Icon(LucideIcons.fileJson2, color: colorScheme.primary, size: 24),
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
