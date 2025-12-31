import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:window_manager/window_manager.dart';
import 'package:overkeys/utils/theme_manager.dart';
import 'package:overkeys/services/state_service.dart';
import 'package:overkeys/providers/keyboard_provider.dart';
import 'package:overkeys/providers/preferences_provider.dart';
import 'package:overkeys/providers/app_state_provider.dart';
import 'package:overkeys/widgets/tabs/general_tab.dart';
import 'package:overkeys/widgets/tabs/keyboard_tab.dart';
import 'package:overkeys/widgets/tabs/text_tab.dart';
import 'package:overkeys/widgets/tabs/markers_tab.dart';
import 'package:overkeys/widgets/tabs/colors_tab.dart';
import 'package:overkeys/widgets/tabs/animations_tab.dart';
import 'package:overkeys/widgets/tabs/hotkeys_tab.dart';
import 'package:overkeys/widgets/tabs/learn_tab.dart';
import 'package:overkeys/widgets/tabs/advanced_tab.dart';
import 'package:overkeys/widgets/tabs/about_tab.dart';

class PreferencesScreen extends ConsumerStatefulWidget {
  const PreferencesScreen({super.key, required this.windowController});

  final WindowController windowController;

  @override
  ConsumerState<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends ConsumerState<PreferencesScreen>
    with WindowListener {
  final StateService _stateService = StateService();
  Timer? _saveDebounceTimer;

  // Constants
  static const Duration _saveDebounceDuration = Duration(milliseconds: 500);

  // UI state
  Brightness _brightness = Brightness.dark;
  String _appVersion = '';
  String _currentTab = 'General';

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _setupMethodHandler();
    _detectSystemTheme();
    _loadAppVersion();
    // Load state after other setup is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadState();
    });
  }

  void _detectSystemTheme() {
    final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
    _brightness = platformDispatcher.platformBrightness;

    platformDispatcher.onPlatformBrightnessChanged = () {
      if (mounted) {
        setState(() {
          _brightness = platformDispatcher.platformBrightness;
        });
      }
    };
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = packageInfo.version;
      });
    }
  }

  @override
  void dispose() {
    _saveDebounceTimer?.cancel();
    // Attempt final save, but don't fail if providers are disposed
    try {
      _saveState();
    } catch (_) {
      // Providers may already be disposed
    }
    windowManager.removeListener(this);
    super.dispose();
  }

  void _setupMethodHandler() async {
    await widget.windowController.setWindowMethodHandler((call) async {
      if (call.method == 'updateOpacityFromMainWindow' && mounted) {
        final opacity = call.arguments as double;
        ref.read(preferencesNotifierProvider.notifier).updateOpacity(opacity);
        await _stateService
            .savePreferencesState(ref.read(preferencesNotifierProvider));
      }

      if (call.method == 'updateAutoHideFromMainWindow' && mounted) {
        final autoHide = call.arguments as bool;
        ref
            .read(preferencesNotifierProvider.notifier)
            .updateAutoHideEnabled(autoHide);
        await _stateService
            .savePreferencesState(ref.read(preferencesNotifierProvider));
      }

      if (call.method == 'requestFocus') {
        await windowManager.focus();
      }
      return null;
    });
  }

  Future<void> _loadState() async {
    await _stateService.loadStatesIntoProviders(ref);
  }

  Future<void> _saveState() async {
    await _stateService.saveAllStates(
      keyboard: ref.read(keyboardNotifierProvider),
      preferences: ref.read(preferencesNotifierProvider),
      appState: ref.read(appStateNotifierProvider),
    );
  }

  void _debouncedSave() {
    _saveDebounceTimer?.cancel();
    _saveDebounceTimer = Timer(_saveDebounceDuration, () {
      _saveState();
    });
  }

  void _updateMainWindow(dynamic method, dynamic value) async {
    if (value is Color) {
      value = value.toARGB32();
    } else if (value is FontWeight) {
      value = value.index;
    } else if (value is HotKey) {
      value = jsonEncode(value.toJson());
    }
    final controllers = await WindowController.getAll();
    for (final controller in controllers) {
      if (controller.arguments.isEmpty || controller.arguments == 'main') {
        await controller.invokeMethod(method, value);
        break;
      }
    }
    _saveState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeManager.getTheme(_brightness);
    final FocusNode keyboardFocusNode = FocusNode();

    // Listen to provider changes and auto-save (debounced)
    ref.listen<KeyboardState>(keyboardNotifierProvider, (previous, next) {
      if (previous != null && previous != next) {
        _debouncedSave();
      }
    });
    ref.listen<PreferencesState>(preferencesNotifierProvider, (previous, next) {
      if (previous != null && previous != next) {
        _debouncedSave();
      }
    });
    ref.listen<AppState>(appStateNotifierProvider, (previous, next) {
      if (previous != null && previous != next) {
        _debouncedSave();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      keyboardFocusNode.requestFocus();
    });

    return MaterialApp(
      theme: theme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
      ],
      home: Builder(builder: (context) {
        return KeyboardListener(
          focusNode: keyboardFocusNode,
          onKeyEvent: (KeyEvent keyEvent) async {
            if (keyEvent is KeyDownEvent &&
                keyEvent.logicalKey == LogicalKeyboardKey.escape) {
              final controllers = await WindowController.getAll();
              for (final controller in controllers) {
                if (controller.arguments.isEmpty ||
                    controller.arguments == 'main') {
                  await controller.invokeMethod('closePreferencesWindow');
                  break;
                }
              }
            }
          },
          child: Scaffold(
            body: Row(
              children: [
                _buildNavigationPanel(context),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding:
                              const EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 20.0),
                          child: _buildCurrentTabContent(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
      debugShowCheckedModeBanner: false,
    );
  }

  Widget _buildNavigationPanel(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final double drawerWidth = 200;

    return Container(
      width: drawerWidth,
      color: Theme.of(context).drawerTheme.backgroundColor ??
          colorScheme.surfaceContainer,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Image.asset(
              'assets/images/app_icon.png',
              width: 60,
              height: 60,
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                'General',
                'Keyboard',
                'Text',
                'Markers',
                'Colors',
                'Animations',
                'Hotkeys',
                'Learn',
                'Advanced',
                'About',
              ].map((tab) => _buildDrawerItem(context, tab)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String tabName) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isSelected = _currentTab == tabName;

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? colorScheme.surface : Colors.transparent,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: ListTile(
          leading: Icon(
            _getIconForTab(tabName).icon,
            color: isSelected
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant.withAlpha(192),
          ),
          title: Text(
            tabName,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 16,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant.withAlpha(192),
            ),
          ),
          onTap: () {
            setState(() => _currentTab = tabName);
          },
          selected: isSelected,
        ),
      ),
    );
  }

  Icon _getIconForTab(String tabName) {
    switch (tabName) {
      case 'General':
        return const Icon(LucideIcons.settings2);
      case 'Keyboard':
        return const Icon(LucideIcons.keyboard);
      case 'Text':
        return const Icon(LucideIcons.type);
      case 'Markers':
        return const Icon(LucideIcons.mapPin);
      case 'Colors':
        return const Icon(LucideIcons.palette);
      case 'Animations':
        return const Icon(LucideIcons.sparkles);
      case 'Hotkeys':
        return const Icon(LucideIcons.zap);
      case 'Learn':
        return const Icon(LucideIcons.graduationCap);
      case 'Advanced':
        return const Icon(LucideIcons.userCog2);
      case 'About':
        return const Icon(LucideIcons.info);
      default:
        return const Icon(LucideIcons.menu);
    }
  }

  Widget _buildCurrentTabContent() {
    switch (_currentTab) {
      case 'General':
        return GeneralTab(
          onUpdateMainWindow: _updateMainWindow,
        );
      case 'Keyboard':
        return KeyboardTab(
          onUpdateMainWindow: _updateMainWindow,
        );
      case 'Text':
        return TextTab(
          onUpdateMainWindow: _updateMainWindow,
        );
      case 'Markers':
        return MarkersTab(
          onUpdateMainWindow: _updateMainWindow,
        );
      case 'Colors':
        return ColorsTab(
          onUpdateMainWindow: _updateMainWindow,
        );
      case 'Animations':
        return AnimationsTab(
          onUpdateMainWindow: _updateMainWindow,
        );
      case 'Hotkeys':
        return HotKeysTab(
          onUpdateMainWindow: _updateMainWindow,
        );
      case 'Learn':
        return LearnTab(
          onUpdateMainWindow: _updateMainWindow,
        );
      case 'Advanced':
        return AdvancedTab(
          onUpdateMainWindow: _updateMainWindow,
        );
      case 'About':
        return AboutTab(appVersion: _appVersion);
      default:
        return const SizedBox.shrink();
    }
  }
}
