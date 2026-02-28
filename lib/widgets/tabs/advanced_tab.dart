import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:overkeys/widgets/options/options.dart';
import 'package:overkeys/services/config_service.dart';
import 'package:overkeys/models/user_config.dart';
import 'package:overkeys/providers/preferences_provider.dart';
import 'package:overkeys/widgets/debug_viewer.dart';

class AdvancedTab extends ConsumerWidget {
  final Function(String method, dynamic value) onUpdateMainWindow;

  const AdvancedTab({
    super.key,
    required this.onUpdateMainWindow,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsState = ref.watch(preferencesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ToggleOption(
          label: 'Turn on advanced settings',
          value: prefsState.advancedSettingsEnabled,
          onChanged: (value) {
            ref
                .read(preferencesProvider.notifier)
                .updateAdvancedSettingsEnabled(value);
            onUpdateMainWindow('updateAdvancedSettingsEnabled', value);
          },
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: [
              ToggleOption(
                label: 'Use user layouts',
                value: prefsState.useUserLayout,
                subtitle:
                    'Use defaultUserLayout defined in the config file (as the base layer). Enables OverKeys to listen and switch between different layers. Make sure that the layouts/layers are saved in the config file.',
                onChanged: (value) {
                  if (value && prefsState.kanataEnabled) {
                    ref
                        .read(preferencesProvider.notifier)
                        .updateKanataEnabled(false);
                    onUpdateMainWindow('updateKanataEnabled', false);
                  }
                  ref
                      .read(preferencesProvider.notifier)
                      .updateUseUserLayout(value);
                  onUpdateMainWindow('updateUseUserLayout', value);
                },
              ),
              ToggleOption(
                label: 'Show alternative layout',
                subtitle:
                    'Show alternative layout alongside primary layout. Make sure that the layout is saved in the config file.',
                value: prefsState.showAltLayout,
                onChanged: (value) {
                  ref
                      .read(preferencesProvider.notifier)
                      .updateShowAltLayout(value);
                  onUpdateMainWindow('updateShowAltLayout', value);
                },
              ),
              ToggleOption(
                label: 'Use custom font',
                value: prefsState.customFontEnabled,
                subtitle:
                    'Use a custom font defined in the config file. Make sure that the font is installed on your system.',
                onChanged: (value) {
                  ref
                      .read(preferencesProvider.notifier)
                      .updateCustomFontEnabled(value);
                  onUpdateMainWindow('updateCustomFontEnabled', value);
                },
              ),
              ToggleOption(
                label: 'Use 6 column layout',
                subtitle:
                    'Use 6 column layout instead of 5 column split matrix layout. Make sure that a compatible layout is saved in the config file.',
                value: prefsState.use6ColLayout,
                onChanged: (value) {
                  ref
                      .read(preferencesProvider.notifier)
                      .updateUse6ColLayout(value);
                  onUpdateMainWindow('updateUse6ColLayout', value);
                },
              ),
              ToggleOption(
                label: 'Connect to Kanata',
                value: prefsState.kanataEnabled,
                subtitle:
                    'Listen to layer changes and see the active layer. Make sure that Kanata and OverKeys are using the same port.',
                onChanged: (value) {
                  if (value && prefsState.useUserLayout) {
                    ref
                        .read(preferencesProvider.notifier)
                        .updateUseUserLayout(false);
                    onUpdateMainWindow('updateUseUserLayout', false);
                  }
                  ref
                      .read(preferencesProvider.notifier)
                      .updateKanataEnabled(value);
                  onUpdateMainWindow('updateKanataEnabled', value);
                },
              ),
              ToggleOption(
                label: 'Keyboard follows mouse',
                value: prefsState.keyboardFollowsMouse,
                subtitle:
                    'EXPERIMENTAL: Keyboard will follow your mouse cursor across monitors. Note: This will override manual position adjustments. Also causes focus issues',
                onChanged: (value) {
                  ref
                      .read(preferencesProvider.notifier)
                      .updateKeyboardFollowsMouse(value);
                  onUpdateMainWindow('updateKeyboardFollowsMouse', value);
                },
              ),
              ToggleOption(
                label: 'Hide on default layer',
                value: prefsState.hideOnDefaultLayer,
                subtitle:
                    'Automatically hide OverKeys when on the default/base layer. Only show when switching to other layers.',
                onChanged: (value) {
                  ref
                      .read(preferencesProvider.notifier)
                      .updateHideOnDefaultLayer(value);
                  onUpdateMainWindow('updateHideOnDefaultLayer', value);
                },
              ),
              _buildOpenConfigButton(context),
              OptionContainer(
                child: SizedBox(
                  height: 500,
                  child: const DebugViewer(),
                ),
              ),
            ],
          ),
          crossFadeState: prefsState.advancedSettingsEnabled
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
                  'Turn related advanced setting off then on again to apply changes.',
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
            icon: Icon(LucideIcons.fileJson2,
                color: colorScheme.primary, size: 24),
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
