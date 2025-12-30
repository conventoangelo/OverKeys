import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:overkeys/services/config_service.dart';
import 'package:overkeys/services/kanata_service.dart';
import 'package:overkeys/services/state_service.dart';
import 'package:overkeys/utils/key_code.dart';
import 'package:overkeys/utils/window_controller_extension.dart';
import 'package:overkeys/widgets/status_overlay.dart';
import 'models/keyboard_layouts.dart';
import 'providers/keyboard_provider.dart';
import 'providers/preferences_provider.dart';
import 'providers/app_state_provider.dart';
import 'screens/keyboard_screen.dart';
import 'utils/hooks.dart';

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp>
    with TrayListener, WindowListener {
  static const double _defaultWindowWidth = 1000;
  static const double _defaultWindowHeight = 330;
  static const double _defaultTopRowExtraHeight = 80;
  static const double _defaultTopRowExtraWidth = 160;
  static const Duration _fadeDuration = Duration(milliseconds: 200);
  static const Duration _overlayDuration = Duration(milliseconds: 1000);
  static const double _opacityStep = 0.05;
  static const double _minOpacity = 0.1;
  static const double _maxOpacity = 1.0;

  // Local state for timers and non-provider state
  Timer? _autoHideTimer;
  Timer? _opacityDebounceTimer;
  Timer? _overlayTimer;
  bool autoHideBeforeForceHide = false;
  bool autoHideBeforeMove = false;
  double _lastOpacity = 0.6;
  Timer? _mouseCheckTimer;

  // Services
  final StateService _stateService = StateService();
  final KanataService _kanataService = KanataService();

  // Misc
  final Set<String> _activeTriggers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    await _loadAllPreferences();
    trayManager.addListener(this);
    windowManager.addListener(this);
    _setupTray();
    _setupKeyListener();
    _setupHotKeys();
    _setupMethodHandler();
    _initStartup();
    _setupKanataLayerChangeHandler();
    _loadConfiguration();
    final prefsState = ref.read(preferencesNotifierProvider);
    final keyboardState = ref.read(keyboardNotifierProvider);
    if (keyboardState.showTopRow) {
      _adjustWindowSize();
    }
    if (prefsState.autoHideEnabled) {
      _resetAutoHideTimer();
    } else if (prefsState.hideAtStartup) {
      onTrayIconMouseDown();
    }
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    trayManager.removeListener(this);
    unhook();
    _autoHideTimer?.cancel();
    _overlayTimer?.cancel();
    _mouseCheckTimer?.cancel();
    _kanataService.dispose();
    _saveAllPreferences();
    super.dispose();
  }

  void _startMouseTracking() {
    _mouseCheckTimer?.cancel();
    final prefsState = ref.read(preferencesNotifierProvider);
    if (prefsState.keyboardFollowsMouse && prefsState.advancedSettingsEnabled) {
      _mouseCheckTimer = Timer.periodic(const Duration(milliseconds: 500),
          (_) => windowManager.setAlignment(Alignment.bottomCenter));
    }
  }

  void _stopMouseTracking() {
    _mouseCheckTimer?.cancel();
  }

  Future<void> _loadAllPreferences() async {
    final states = await _stateService.loadAllStates();

    if (states['keyboard'] != null) {
      ref
          .read(keyboardNotifierProvider.notifier)
          .updateKeyboardState(states['keyboard']!);
    }

    if (states['preferences'] != null) {
      ref
          .read(preferencesNotifierProvider.notifier)
          .updatePreferencesState(states['preferences']!);
      _lastOpacity = states['preferences']!.opacity;
    }

    if (states['appState'] != null) {
      ref
          .read(appStateNotifierProvider.notifier)
          .updateAppState(states['appState']!);
    }
  }

  Future<void> _saveAllPreferences() async {
    await _stateService.saveAllStates(
      keyboard: ref.read(keyboardNotifierProvider),
      preferences: ref.read(preferencesNotifierProvider),
      appState: ref.read(appStateNotifierProvider),
    );
  }

  Future<void> _loadConfiguration() async {
    final prefsState = ref.read(preferencesNotifierProvider);

    await loadCustomKeys();
    await _loadCustomShiftMappings();
    if (prefsState.advancedSettingsEnabled) {
      if (prefsState.useUserLayout) {
        await _loadUserLayout();
        await _loadUserLayers();
      }
      if (prefsState.showAltLayout) {
        await _loadAltLayout();
      }
      if (prefsState.customFontEnabled) {
        await _loadCustomFont();
      }
      if (prefsState.kanataEnabled) {
        await _useKanata();
      }
      if (prefsState.keyboardFollowsMouse) {
        _startMouseTracking();
      }
    }
  }

  Future<void> _loadCustomShiftMappings() async {
    final configService = ConfigService();
    final mappings = await configService.getCustomShiftMappings();
    ref
        .read(keyboardNotifierProvider.notifier)
        .updateCustomShiftMappings(mappings);
  }

  void _setupKanataLayerChangeHandler() {
    _kanataService.onLayerChange = (newLayout, isDefaultUserLayout) {
      final keyboardNotifier = ref.read(keyboardNotifierProvider.notifier);
      final appNotifier = ref.read(appStateNotifierProvider.notifier);
      final prefsState = ref.read(preferencesNotifierProvider);
      final appState = ref.read(appStateNotifierProvider);

      keyboardNotifier.updateLayout(newLayout);
      _updateAutoHideBasedOnLayer(isDefaultUserLayout);

      // Handle hide on default layer functionality
      if (isDefaultUserLayout &&
          prefsState.hideOnDefaultLayer &&
          appState.isWindowVisible) {
        appNotifier.updateIsWindowVisible(false);
      } else {
        _fadeIn();
      }
    };
  }

  void _updateAutoHideBasedOnLayer(bool isDefaultUserLayout) {
    final prefsState = ref.read(preferencesNotifierProvider);
    if (!isDefaultUserLayout && prefsState.autoHideEnabled) {
      autoHideBeforeMove = true;
    } else if (isDefaultUserLayout && autoHideBeforeMove) {
      autoHideBeforeMove = false;
    }
  }

  Future<void> _useKanata() async {
    final configService = ConfigService();
    final keyboardNotifier = ref.read(keyboardNotifierProvider.notifier);
    final keyboardState = ref.read(keyboardNotifierProvider);
    final prefsState = ref.read(preferencesNotifierProvider);
    final userLayout = await configService.getUserLayout();

    if (userLayout != null) {
      keyboardNotifier.updateInitialLayout(userLayout);
    }
    if (keyboardState.kanataEnabled && prefsState.advancedSettingsEnabled) {
      _kanataService.connect();
    }
  }

  Future<void> _loadUserLayout() async {
    final prefsState = ref.read(preferencesNotifierProvider);
    if (!prefsState.useUserLayout) return;

    final configService = ConfigService();
    final keyboardNotifier = ref.read(keyboardNotifierProvider.notifier);
    final userLayout = await configService.getUserLayout();

    if (userLayout != null) {
      keyboardNotifier.updateInitialLayout(userLayout);
      if (!ref.read(keyboardNotifierProvider).kanataEnabled) {
        keyboardNotifier.updateLayout(userLayout);
      }
      _fadeIn();
    }
  }

  Future<void> _loadUserLayers() async {
    final prefsState = ref.read(preferencesNotifierProvider);
    if (!prefsState.useUserLayout) return;

    final configService = ConfigService();
    final prefsNotifier = ref.read(preferencesNotifierProvider.notifier);
    final layers = await configService.getUserLayers() ?? [];

    prefsNotifier.updateUserLayers(layers);
  }

  Future<void> _loadAltLayout() async {
    final keyboardState = ref.read(keyboardNotifierProvider);
    if (!keyboardState.showAltLayout) return;
    final configService = ConfigService();
    final keyboardNotifier = ref.read(keyboardNotifierProvider.notifier);
    final altLayout = await configService.getAltLayout();

    if (altLayout != null) {
      keyboardNotifier.updateShowAltLayout(true);
    }
  }

  Future<void> _loadCustomFont() async {
    final prefsState = ref.read(preferencesNotifierProvider);
    if (!prefsState.customFontEnabled || !prefsState.advancedSettingsEnabled)
      return;

    final configService = ConfigService();
    final keyboardNotifier = ref.read(keyboardNotifierProvider.notifier);
    final customFont = await configService.getCustomFont();

    if (customFont != null) {
      keyboardNotifier.updateFontFamily(customFont);
    }
  }

  Future<void> _initStartup() async {
    // Can be skipped, as preferences are loaded separately
  }

  Future<void> _handleStartupToggle(bool enable) async {
    if (enable) {
      await launchAtStartup.enable();
    } else {
      await launchAtStartup.disable();
    }
    await _initStartup();
  }

  Future<void> _adjustWindowSize() async {
    _fadeIn();
    final keyboardState = ref.read(keyboardNotifierProvider);
    double height = keyboardState.showTopRow
        ? _defaultWindowHeight + _defaultTopRowExtraHeight
        : _defaultWindowHeight;
    double width = keyboardState.showTopRow
        ? _defaultWindowWidth + _defaultTopRowExtraWidth
        : _defaultWindowWidth;
    await windowManager.setSize(Size(width, height));
    await windowManager.setAlignment(Alignment.bottomCenter);
  }

  bool _isOnDefaultLayer() {
    final keyboardState = ref.read(keyboardNotifierProvider);
    final prefsState = ref.read(preferencesNotifierProvider);

    // If hideOnDefaultLayer is disabled, always allow showing
    if (!prefsState.hideOnDefaultLayer) return false;

    // If advanced settings are not enabled, we're always on default
    if (!prefsState.advancedSettingsEnabled) return true;

    // For Kanata or user layout mode
    if (prefsState.kanataEnabled || prefsState.useUserLayout) {
      // If we have a default user layout, compare with current layout
      if (prefsState.defaultUserLayout != null) {
        return keyboardState.layout.name.toUpperCase() ==
            prefsState.defaultUserLayout!.name.toUpperCase();
      }
      // If no default user layout is set, check against initial layout
      if (prefsState.initialKeyboardLayout != null) {
        return keyboardState.layout.name.toUpperCase() ==
            prefsState.initialKeyboardLayout!.name.toUpperCase();
      }
    }

    // Default case: if we can't determine, don't hide
    return false;
  }

  void _fadeIn() {
    final appState = ref.read(appStateNotifierProvider);
    final appNotifier = ref.read(appStateNotifierProvider.notifier);

    if (appState.forceHide || appState.isWindowVisible) return;

    // Check if we should hide on default layer
    if (_isOnDefaultLayer()) {
      return; // Don't show if we're on default layer and setting is enabled
    }

    appNotifier.updateIsWindowVisible(true);
    _resetAutoHideTimer();
  }

  void _setupKeyListener() {
    final receivePort = ReceivePort();
    Isolate.spawn(setHook, receivePort.sendPort)
        .then((_) {})
        .catchError((error) {
      if (kDebugMode) {
        print('Error spawning Isolate: $error');
      }
    });

    receivePort.listen(_handleKeyEvent);
  }

  void _handleKeyEvent(dynamic message) {
    if (message is! List) return;

    final keyboardNotifier = ref.read(keyboardNotifierProvider.notifier);
    final appNotifier = ref.read(appStateNotifierProvider.notifier);
    final keyboardState = ref.read(keyboardNotifierProvider);
    final appState = ref.read(appStateNotifierProvider);
    final prefsState = ref.read(preferencesNotifierProvider);

    if (message[0] is String) {
      if (message[0] == 'session_unlock') {
        keyboardNotifier.clearKeyPressStates();
      }
      return;
    }

    if (message[0] is! int) return;

    final keyCode = message[0] as int;
    final isPressed = message[1] as bool;
    final isShiftDown = message[2] as bool;
    final key = getKeyFromKeyCodeShift(keyCode, isShiftDown);

    if (kDebugMode) {
      print(
          'Key: ${key.padRight(10)}\tKeyCode: ${keyCode.toString().padRight(5)}\tPressed: ${isPressed.toString().padRight(5)}\tShift: $isShiftDown');
    }
    keyboardNotifier.updateKeyPressState(key, isPressed);

    if (appState.forceHide) return;
    if (prefsState.autoHideEnabled && !appState.isWindowVisible && isPressed) {
      if (!_isOnDefaultLayer()) {
        _fadeIn();
      }
    } else {
      _resetAutoHideTimer();
    }

    if (prefsState.useUserLayout && prefsState.advancedSettingsEnabled) {
      final userLayers = prefsState.userLayers;
      final activeLayer = userLayers.where((l) => l.trigger == key);
      for (final layout in activeLayer) {
        if (layout.type == 'toggle' && isPressed) {
          if (keyboardState.layout.name != layout.name) {
            keyboardNotifier.updateLayout(layout);
          } else if (prefsState.defaultUserLayout != null) {
            keyboardNotifier.updateLayout(prefsState.defaultUserLayout!);
          }

          if (prefsState.hideOnDefaultLayer) {
            final isNowOnDefault = prefsState.defaultUserLayout != null &&
                keyboardState.layout.name == prefsState.defaultUserLayout!.name;
            if (isNowOnDefault && appState.isWindowVisible) {
              appNotifier.updateIsWindowVisible(false);
              _autoHideTimer?.cancel();
            } else if (!isNowOnDefault) {
              _fadeIn();
            }
          }
        } else if (layout.type == 'held') {
          if (isPressed && !_activeTriggers.contains(key)) {
            keyboardNotifier.updateLayout(layout);
            _activeTriggers.add(key);
            if (prefsState.hideOnDefaultLayer) {
              _fadeIn();
            }
          } else if (!isPressed && _activeTriggers.contains(key)) {
            if (prefsState.defaultUserLayout != null) {
              keyboardNotifier.updateLayout(prefsState.defaultUserLayout!);
            }
            _activeTriggers.remove(key);

            if (prefsState.hideOnDefaultLayer &&
                prefsState.defaultUserLayout != null &&
                keyboardState.layout.name ==
                    prefsState.defaultUserLayout!.name &&
                appState.isWindowVisible) {
              appNotifier.updateIsWindowVisible(false);
              _autoHideTimer?.cancel();
            }
          }
        }
        _updateAutoHideBasedOnLayer(
            keyboardState.layout.name == prefsState.defaultUserLayout?.name);
      }
    }
  }

  void _resetAutoHideTimer() {
    final prefsState = ref.read(preferencesNotifierProvider);
    if (!prefsState.autoHideEnabled) return;

    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(
        Duration(milliseconds: (prefsState.autoHideDuration * 1000).round()),
        _handleAutoHide);
  }

  void _handleAutoHide() {
    final prefsState = ref.read(preferencesNotifierProvider);
    final appState = ref.read(appStateNotifierProvider);
    if (prefsState.autoHideEnabled && appState.isWindowVisible) {
      _fadeOut();
    }
  }

  void _fadeOut() {
    final appState = ref.read(appStateNotifierProvider);
    final appNotifier = ref.read(appStateNotifierProvider.notifier);
    if (!appState.isWindowVisible) return;
    appNotifier.updateIsWindowVisible(false);
  }

  void _toggleAutoHide(bool enable) {
    final prefsNotifier = ref.read(preferencesNotifierProvider.notifier);
    final appState = ref.read(appStateNotifierProvider);

    prefsNotifier.updateAutoHideEnabled(enable);
    if (enable) {
      _resetAutoHideTimer();
    } else {
      _autoHideTimer?.cancel();
      if (!appState.isWindowVisible) {
        _fadeIn();
      }
    }
    _showOverlay(
        enable ? 'Auto-hide Enabled' : 'Auto-hide Disabled',
        enable
            ? const Icon(LucideIcons.timerReset)
            : const Icon(LucideIcons.timerOff));
    WindowController.getAll().then((controllers) {
      for (final controller in controllers) {
        if (controller.arguments == 'preferences') {
          controller.invokeMethod('updateAutoHideFromMainWindow', enable);
        }
      }
    });
    _saveAllPreferences();
    _setupTray();
  }

  void _adjustOpacity(bool increase) {
    final appState = ref.read(appStateNotifierProvider);
    final prefsState = ref.read(preferencesNotifierProvider);
    final prefsNotifier = ref.read(preferencesNotifierProvider.notifier);

    if (appState.forceHide) return;

    final newLastOpacity = increase
        ? (_lastOpacity + _opacityStep).clamp(_minOpacity, _maxOpacity)
        : (_lastOpacity - _opacityStep).clamp(_minOpacity, _maxOpacity);

    if (newLastOpacity != _lastOpacity) {
      _lastOpacity = newLastOpacity;

      _showOverlay(
          'Opacity: ${(_lastOpacity * 100).round()}%',
          increase
              ? const Icon(LucideIcons.plusCircle)
              : const Icon(LucideIcons.minusCircle));
    }

    _opacityDebounceTimer?.cancel();
    _opacityDebounceTimer = Timer(const Duration(milliseconds: 125), () {
      if (prefsState.opacity != _lastOpacity) {
        prefsNotifier.updateOpacity(_lastOpacity);
        _saveAllPreferences();
        WindowController.getAll().then((controllers) {
          for (final controller in controllers) {
            if (controller.arguments == 'preferences') {
              controller.invokeMethod(
                  'updateOpacityFromMainWindow', _lastOpacity);
            }
          }
        });
      }
    });
  }

  void _showOverlay(String message, Icon icon) {
    final appNotifier = ref.read(appStateNotifierProvider.notifier);
    appNotifier.showStatusOverlay(message, icon);
    _overlayTimer?.cancel();
    _overlayTimer = Timer(_overlayDuration, () {
      appNotifier.hideStatusOverlay();
    });
  }

  String _formatHotkey(HotKey? hotkey, bool enabled) {
    final appState = ref.read(appStateNotifierProvider);
    if (hotkey == null || !appState.hotKeysEnabled || !enabled) return '';

    final modifiers = hotkey.modifiers?.map((m) {
      switch (m) {
        case HotKeyModifier.alt:
          return '⌥';
        case HotKeyModifier.control:
          return '⌃';
        case HotKeyModifier.shift:
          return '⇧';
        case HotKeyModifier.meta:
          return '⊞';
        default:
          return '';
      }
    }).join('');

    final keyName = hotkey.key.keyLabel;
    return modifiers!.isNotEmpty ? '$modifiers$keyName' : keyName;
  }

  Future<void> _setupTray() async {
    final appState = ref.read(appStateNotifierProvider);
    final prefsState = ref.read(preferencesNotifierProvider);

    final String iconPath = Platform.isWindows
        ? 'assets/images/app_icon.ico'
        : 'assets/images/app_icon.png';
    await Future.wait([
      trayManager.setIcon(iconPath),
      trayManager.setToolTip('OverKeys'),
    ]);
    trayManager.setContextMenu(Menu(items: [
      MenuItem.checkbox(
        key: 'toggle_mouse_events',
        label:
            'Move\t${_formatHotkey(appState.toggleMoveHotKey, appState.enableToggleMoveHotKey)}',
        checked: !appState.ignoreMouseEvents,
        onClick: (menuItem) {
          final appNotifier = ref.read(appStateNotifierProvider.notifier);
          appNotifier.updateIgnoreMouseEvents(!appState.ignoreMouseEvents);
          windowManager.setIgnoreMouseEvents(!appState.ignoreMouseEvents);
          if (!appState.ignoreMouseEvents) {
            _fadeIn();
            _showOverlay('Move disabled', const Icon(LucideIcons.lock));
          } else {
            _showOverlay('Move enabled', const Icon(LucideIcons.move));
          }
        },
      ),
      MenuItem.separator(),
      MenuItem.checkbox(
        key: 'toggle_auto_hide',
        label:
            'Auto Hide\t${_formatHotkey(appState.autoHideHotKey, appState.enableAutoHideHotKey)}',
        checked: prefsState.autoHideEnabled,
        onClick: (menuItem) {
          _toggleAutoHide(!prefsState.autoHideEnabled);
        },
      ),
      MenuItem.separator(),
      MenuItem(
          key: 'reset_position',
          label: 'Reset Position',
          onClick: (menuItem) {
            windowManager.setAlignment(Alignment.bottomCenter);
            _showOverlay('Position reset', const Icon(LucideIcons.locateFixed));
          }),
      MenuItem.separator(),
      MenuItem(
        key: 'preferences',
        label:
            'Preferences\t${_formatHotkey(appState.preferencesHotKey, appState.enablePreferencesHotKey)}',
        onClick: (menuItem) {
          _showPreferences();
        },
      ),
      MenuItem.separator(),
      MenuItem(
        key: 'toggle_visibility',
        label:
            'Hide/Show\t${_formatHotkey(appState.visibilityHotKey, appState.enableVisibilityHotKey)}',
        onClick: (menuItem) {
          onTrayIconMouseDown();
        },
      ),
      MenuItem.separator(),
      MenuItem(
        key: 'reload_config',
        label: 'Reload Config',
        onClick: (menuItem) {
          _loadConfiguration();
          _showOverlay('Config Reloaded', const Icon(LucideIcons.refreshCw));
        },
      ),
      MenuItem.separator(),
      MenuItem(
        key: 'exit',
        label: 'Exit',
      ),
    ]));
  }

  Future<void> _setupHotKeys() async {
    final appState = ref.read(appStateNotifierProvider);
    final appNotifier = ref.read(appStateNotifierProvider.notifier);

    await hotKeyManager.unregisterAll();

    if (!appState.hotKeysEnabled) {
      _setupTray();
      return;
    }

    if (appState.enableAutoHideHotKey && appState.autoHideHotKey != null) {
      await hotKeyManager.register(
        appState.autoHideHotKey!,
        keyDownHandler: (hotKey) {
          if (kDebugMode) {
            print('Auto-hide hotkey triggered.');
          }
          final prefsState = ref.read(preferencesNotifierProvider);
          _toggleAutoHide(!prefsState.autoHideEnabled);
        },
      );
    }

    if (appState.enableVisibilityHotKey && appState.visibilityHotKey != null) {
      await hotKeyManager.register(
        appState.visibilityHotKey!,
        keyDownHandler: (hotKey) {
          if (kDebugMode) {
            print('Visibility hotkey triggered.');
          }
          onTrayIconMouseDown();
        },
      );
    }

    if (appState.enableToggleMoveHotKey && appState.toggleMoveHotKey != null) {
      await hotKeyManager.register(
        appState.toggleMoveHotKey!,
        keyDownHandler: (hotKey) {
          if (kDebugMode) {
            print('Move hotkey triggered.');
          }
          final currentAppState = ref.read(appStateNotifierProvider);
          appNotifier
              .updateIgnoreMouseEvents(!currentAppState.ignoreMouseEvents);
          windowManager
              .setIgnoreMouseEvents(!currentAppState.ignoreMouseEvents);
          if (!currentAppState.ignoreMouseEvents) {
            _fadeIn();
            _showOverlay('Move disabled', const Icon(LucideIcons.lock));
          } else {
            _showOverlay('Move enabled', const Icon(LucideIcons.move));
          }
        },
      );
    }

    if (appState.enablePreferencesHotKey &&
        appState.preferencesHotKey != null) {
      await hotKeyManager.register(
        appState.preferencesHotKey!,
        keyDownHandler: (hotKey) {
          if (kDebugMode) {
            print(
                'Preferences hotkey triggered. Opening/Focusing Preferences Window.');
          }
          _showOverlay(
              'Opening Preferences', const Icon(LucideIcons.appWindow));
          _showPreferences();
        },
      );
    }

    if (appState.enableIncreaseOpacityHotKey &&
        appState.increaseOpacityHotKey != null) {
      await hotKeyManager.register(
        appState.increaseOpacityHotKey!,
        keyDownHandler: (hotKey) {
          if (kDebugMode) {
            print('Increase opacity hotkey triggered.');
          }
          _adjustOpacity(true);
        },
      );
    }

    if (appState.enableDecreaseOpacityHotKey &&
        appState.decreaseOpacityHotKey != null) {
      await hotKeyManager.register(
        appState.decreaseOpacityHotKey!,
        keyDownHandler: (hotKey) {
          if (kDebugMode) {
            print('Decrease opacity hotkey triggered.');
          }
          _adjustOpacity(false);
        },
      );
    }

    _setupTray();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (menuItem.key == 'exit') {
      WindowController.getAll().then((controllers) async {
        for (final controller in controllers) {
          await controller.close();
        }
        await windowManager.close();
        exit(0);
      }).catchError((error) {
        if (kDebugMode) {
          print('Error closing windows: $error');
        }
        windowManager.close();
        exit(0);
      });
      return;
    }
    _setupTray();
  }

  @override
  void onTrayIconMouseDown() {
    final appNotifier = ref.read(appStateNotifierProvider.notifier);
    final appState = ref.read(appStateNotifierProvider);

    appNotifier.updateForceHide(!appState.forceHide);
    _showOverlay(
        appState.forceHide ? 'Keyboard Shown' : 'Keyboard Hidden',
        appState.forceHide
            ? const Icon(LucideIcons.eye)
            : const Icon(LucideIcons.eyeOff));
    if (appState.isWindowVisible) {
      _fadeOut();
    } else {
      _fadeIn();
    }
    windowManager.blur();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu(
      // ignore: deprecated_member_use
      bringAppToFront: true,
    );
  }

  @override
  void onWindowFocus() {
    windowManager.blur();
  }

  Future<void> _showPreferences() async {
    try {
      // Get all window controllers
      final controllers = await WindowController.getAll();

      // Check if preferences window already exists
      for (var controller in controllers) {
        if (controller.arguments == 'preferences') {
          await controller.show();
          return;
        }
      }

      // Create new preferences window if it doesn't exist (hidden initially)
      await WindowController.create(
        WindowConfiguration(
          hiddenAtLaunch: true,
          arguments: 'preferences',
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error handling preferences window: $e');
      }
    }
  }

  void _setupMethodHandler() async {
    final windowController = await WindowController.fromCurrentEngine();
    final keyboardNotifier = ref.read(keyboardNotifierProvider.notifier);
    final prefsNotifier = ref.read(preferencesNotifierProvider.notifier);
    final appNotifier = ref.read(appStateNotifierProvider.notifier);

    await windowController.setWindowMethodHandler((call) async {
      switch (call.method) {
        // General settings
        case 'updateLaunchAtStartup':
          final launchAtStartupValue = call.arguments as bool;
          prefsNotifier.updateLaunchAtStartup(launchAtStartupValue);
          _handleStartupToggle(launchAtStartupValue);
        case 'updateHideAtStartup':
          final hideAtStartup = call.arguments as bool;
          prefsNotifier.updateHideAtStartup(hideAtStartup);
        case 'updateAutoHideEnabled':
          final autoHideEnabled = call.arguments as bool;
          _toggleAutoHide(autoHideEnabled);
        case 'updateReactiveShiftEnabled':
          final reactiveShiftEnabled = call.arguments as bool;
          prefsNotifier.updateReactiveShiftEnabled(reactiveShiftEnabled);
        case 'updateAutoHideDuration':
          final autoHideDuration = call.arguments as double;
          prefsNotifier.updateAutoHideDuration(autoHideDuration);
        case 'updateOpacity':
          final opacity = call.arguments as double;
          prefsNotifier.updateOpacity(opacity);
          _lastOpacity = opacity;
        case 'updateLayout':
          final layoutName = call.arguments as String;
          final prefsState = ref.read(preferencesNotifierProvider);
          final keyboardState = ref.read(keyboardNotifierProvider);
          if ((keyboardState.kanataEnabled || prefsState.useUserLayout) &&
              prefsState.advancedSettingsEnabled) {
            final layout = availableLayouts
                .firstWhere((layout) => layout.name == layoutName);
            keyboardNotifier.updateLayout(layout);
          } else {
            final layout = availableLayouts
                .firstWhere((layout) => layout.name == layoutName);
            keyboardNotifier.updateLayout(layout);
            keyboardNotifier.updateInitialLayout(layout);
          }
          _fadeIn();

        // Keyboard settings
        case 'updateKeymapStyle':
          final keymapStyle = call.arguments as String;
          keyboardNotifier.updateKeymapStyle(keymapStyle);
        case 'updateShowTopRow':
          final showTopRow = call.arguments as bool;
          keyboardNotifier.updateShowTopRow(showTopRow);
          _adjustWindowSize();
        case 'updateShowGraveKey':
          final showGraveKey = call.arguments as bool;
          keyboardNotifier.updateShowGraveKey(showGraveKey);
        case 'updateKeySize':
          final keySize = call.arguments as double;
          keyboardNotifier.updateKeySize(keySize);
        case 'updateKeyBorderRadius':
          final keyBorderRadius = call.arguments as double;
          keyboardNotifier.updateKeyBorderRadius(keyBorderRadius);
        case 'updateKeyBorderThickness':
          final keyBorderThickness = call.arguments as double;
          keyboardNotifier.updateKeyBorderThickness(keyBorderThickness);
        case 'updateKeyPadding':
          final keyPadding = call.arguments as double;
          keyboardNotifier.updateKeyPadding(keyPadding);
        case 'updateSpaceWidth':
          final spaceWidth = call.arguments as double;
          keyboardNotifier.updateSpaceWidth(spaceWidth);
        case 'updateSplitWidth':
          final splitWidth = call.arguments as double;
          keyboardNotifier.updateSplitWidth(splitWidth);
        case 'updateLastRowSplitWidth':
          final lastRowSplitWidth = call.arguments as double;
          keyboardNotifier.updateLastRowSplitWidth(lastRowSplitWidth);
        case 'updateKeyShadowBlurRadius':
          final keyShadowBlurRadius = call.arguments as double;
          keyboardNotifier.updateKeyShadowBlurRadius(keyShadowBlurRadius);
        case 'updateKeyShadowOffsetX':
          final keyShadowOffsetX = call.arguments as double;
          keyboardNotifier.updateKeyShadowOffsetX(keyShadowOffsetX);
        case 'updateKeyShadowOffsetY':
          final keyShadowOffsetY = call.arguments as double;
          keyboardNotifier.updateKeyShadowOffsetY(keyShadowOffsetY);

        // Text settings
        case 'updateFontFamily':
          final fontFamily = call.arguments as String;
          final prefsState = ref.read(preferencesNotifierProvider);
          if (prefsState.customFontEnabled &&
              prefsState.advancedSettingsEnabled) {
            keyboardNotifier.updateFontFamily(fontFamily);
          } else {
            keyboardNotifier.updateFontFamily(fontFamily);
            keyboardNotifier.updateInitialFontFamily(fontFamily);
          }
        case 'updateFontWeight':
          final fontWeightIndex = call.arguments as int;
          keyboardNotifier.updateFontWeight(FontWeight.values[fontWeightIndex]);
        case 'updateKeyFontSize':
          final keyFontSize = call.arguments as double;
          keyboardNotifier.updateKeyFontSize(keyFontSize);
        case 'updateSpaceFontSize':
          final spaceFontSize = call.arguments as double;
          keyboardNotifier.updateSpaceFontSize(spaceFontSize);

        // Markers settings
        case 'updateMarkerOffset':
          final markerOffset = call.arguments as double;
          keyboardNotifier.updateMarkerOffset(markerOffset);
        case 'updateMarkerWidth':
          final markerWidth = call.arguments as double;
          keyboardNotifier.updateMarkerWidth(markerWidth);
        case 'updateMarkerHeight':
          final markerHeight = call.arguments as double;
          keyboardNotifier.updateMarkerHeight(markerHeight);
        case 'updateMarkerBorderRadius':
          final markerBorderRadius = call.arguments as double;
          keyboardNotifier.updateMarkerBorderRadius(markerBorderRadius);

        // Colors settings
        case 'updateKeyColorPressed':
          final keyColorPressed = call.arguments as int;
          keyboardNotifier.updateKeyColorPressed(Color(keyColorPressed));
        case 'updateKeyColorNotPressed':
          final keyColorNotPressed = call.arguments as int;
          keyboardNotifier.updateKeyColorNotPressed(Color(keyColorNotPressed));
        case 'updateMarkerColor':
          final markerColor = call.arguments as int;
          keyboardNotifier.updateMarkerColor(Color(markerColor));
        case 'updateMarkerColorNotPressed':
          final markerColorNotPressed = call.arguments as int;
          keyboardNotifier
              .updateMarkerColorNotPressed(Color(markerColorNotPressed));
        case 'updateKeyTextColor':
          final keyTextColor = call.arguments as int;
          keyboardNotifier.updateKeyTextColor(Color(keyTextColor));
        case 'updateKeyTextColorNotPressed':
          final keyTextColorNotPressed = call.arguments as int;
          keyboardNotifier
              .updateKeyTextColorNotPressed(Color(keyTextColorNotPressed));
        case 'updateKeyBorderColorPressed':
          final keyBorderColorPressed = call.arguments as int;
          keyboardNotifier
              .updateKeyBorderColorPressed(Color(keyBorderColorPressed));
        case 'updateKeyBorderColorNotPressed':
          final keyBorderColorNotPressed = call.arguments as int;
          keyboardNotifier
              .updateKeyBorderColorNotPressed(Color(keyBorderColorNotPressed));

        // Animations settings
        case 'updateAnimationEnabled':
          final animationEnabled = call.arguments as bool;
          keyboardNotifier.updateAnimationEnabled(animationEnabled);
        case 'updateAnimationStyle':
          final animationStyle = call.arguments as String;
          keyboardNotifier.updateAnimationStyle(animationStyle);
        case 'updateAnimationDuration':
          final animationDuration = call.arguments as double;
          keyboardNotifier.updateAnimationDuration(animationDuration);
        case 'updateAnimationScale':
          final animationScale = call.arguments as double;
          keyboardNotifier.updateAnimationScale(animationScale);

        // HotKey settings
        case 'updateHotKeysEnabled':
          final hotKeysEnabled = call.arguments as bool;
          appNotifier.updateHotKeysEnabled(hotKeysEnabled);
          _setupHotKeys();
        case 'updateVisibilityHotKey':
          final hotKeyJson = call.arguments as String;
          final newHotKey = HotKey.fromJson(jsonDecode(hotKeyJson));
          final currentVisibilityHotKey =
              ref.read(appStateNotifierProvider).visibilityHotKey;
          if (currentVisibilityHotKey != null) {
            await hotKeyManager.unregister(currentVisibilityHotKey);
          }
          appNotifier.updateVisibilityHotKey(newHotKey);
          await _setupHotKeys();
        case 'updateAutoHideHotKey':
          final hotKeyJson = call.arguments as String;
          final newHotKey = HotKey.fromJson(jsonDecode(hotKeyJson));
          final currentAutoHideHotKey =
              ref.read(appStateNotifierProvider).autoHideHotKey;
          if (currentAutoHideHotKey != null) {
            await hotKeyManager.unregister(currentAutoHideHotKey);
          }
          appNotifier.updateAutoHideHotKey(newHotKey);
          await _setupHotKeys();
        case 'updateToggleMoveHotKey':
          final hotKeyJson = call.arguments as String;
          final newHotKey = HotKey.fromJson(jsonDecode(hotKeyJson));
          final currentToggleMoveHotKey =
              ref.read(appStateNotifierProvider).toggleMoveHotKey;
          if (currentToggleMoveHotKey != null) {
            await hotKeyManager.unregister(currentToggleMoveHotKey);
          }
          appNotifier.updateToggleMoveHotKey(newHotKey);
          await _setupHotKeys();
        case 'updatePreferencesHotKey':
          final hotKeyJson = call.arguments as String;
          final newHotKey = HotKey.fromJson(jsonDecode(hotKeyJson));
          final currentPreferencesHotKey =
              ref.read(appStateNotifierProvider).preferencesHotKey;
          if (currentPreferencesHotKey != null) {
            await hotKeyManager.unregister(currentPreferencesHotKey);
          }
          appNotifier.updatePreferencesHotKey(newHotKey);
          await _setupHotKeys();
        case 'updateIncreaseOpacityHotKey':
          final hotKeyJson = call.arguments as String;
          final newHotKey = HotKey.fromJson(jsonDecode(hotKeyJson));
          final currentIncreaseOpacityHotKey =
              ref.read(appStateNotifierProvider).increaseOpacityHotKey;
          if (currentIncreaseOpacityHotKey != null) {
            await hotKeyManager.unregister(currentIncreaseOpacityHotKey);
          }
          appNotifier.updateIncreaseOpacityHotKey(newHotKey);
          await _setupHotKeys();
        case 'updateDecreaseOpacityHotKey':
          final hotKeyJson = call.arguments as String;
          final newHotKey = HotKey.fromJson(jsonDecode(hotKeyJson));
          final currentDecreaseOpacityHotKey =
              ref.read(appStateNotifierProvider).decreaseOpacityHotKey;
          if (currentDecreaseOpacityHotKey != null) {
            await hotKeyManager.unregister(currentDecreaseOpacityHotKey);
          }
          appNotifier.updateDecreaseOpacityHotKey(newHotKey);
          await _setupHotKeys();
        case 'updateEnableVisibilityHotKey':
          final enabled = call.arguments as bool;
          appNotifier.updateEnableVisibilityHotKey(enabled);
          await _setupHotKeys();
        case 'updateEnableAutoHideHotKey':
          final enabled = call.arguments as bool;
          appNotifier.updateEnableAutoHideHotKey(enabled);
          await _setupHotKeys();
        case 'updateEnableToggleMoveHotKey':
          final enabled = call.arguments as bool;
          appNotifier.updateEnableToggleMoveHotKey(enabled);
          await _setupHotKeys();
        case 'updateEnablePreferencesHotKey':
          final enabled = call.arguments as bool;
          appNotifier.updateEnablePreferencesHotKey(enabled);
          await _setupHotKeys();
        case 'updateEnableIncreaseOpacityHotKey':
          final enabled = call.arguments as bool;
          appNotifier.updateEnableIncreaseOpacityHotKey(enabled);
          await _setupHotKeys();
        case 'updateEnableDecreaseOpacityHotKey':
          final enabled = call.arguments as bool;
          appNotifier.updateEnableDecreaseOpacityHotKey(enabled);
          await _setupHotKeys();

        // Learn settings
        case 'updateLearningModeEnabled':
          final learningModeEnabled = call.arguments as bool;
          keyboardNotifier.updateLearningModeEnabled(learningModeEnabled);
        case 'updatePinkyLeftColor':
          final color = call.arguments as int;
          keyboardNotifier.updatePinkyLeftColor(Color(color));
        case 'updateRingLeftColor':
          final color = call.arguments as int;
          keyboardNotifier.updateRingLeftColor(Color(color));
        case 'updateMiddleLeftColor':
          final color = call.arguments as int;
          keyboardNotifier.updateMiddleLeftColor(Color(color));
        case 'updateIndexLeftColor':
          final color = call.arguments as int;
          keyboardNotifier.updateIndexLeftColor(Color(color));
        case 'updateIndexRightColor':
          final color = call.arguments as int;
          keyboardNotifier.updateIndexRightColor(Color(color));
        case 'updateMiddleRightColor':
          final color = call.arguments as int;
          keyboardNotifier.updateMiddleRightColor(Color(color));
        case 'updateRingRightColor':
          final color = call.arguments as int;
          keyboardNotifier.updateRingRightColor(Color(color));
        case 'updatePinkyRightColor':
          final color = call.arguments as int;
          keyboardNotifier.updatePinkyRightColor(Color(color));

        // Advanced settings
        case 'updateAdvancedSettingsEnabled':
          final advancedSettingsEnabled = call.arguments as bool;
          prefsNotifier.updateAdvancedSettingsEnabled(advancedSettingsEnabled);
          final keyboardState = ref.read(keyboardNotifierProvider);
          final currentPrefsState = ref.read(preferencesNotifierProvider);
          if (!advancedSettingsEnabled) {
            if (keyboardState.kanataEnabled) {
              _kanataService.disconnect();
              keyboardNotifier.updateLayout(
                  keyboardState.initialLayout ?? keyboardState.layout);
            }
            if (currentPrefsState.useUserLayout) {
              keyboardNotifier.updateLayout(
                  keyboardState.initialLayout ?? keyboardState.layout);
            }
            keyboardNotifier.updateShowAltLayout(false);
            if (currentPrefsState.customFontEnabled) {
              keyboardNotifier.updateFontFamily(
                  keyboardState.initialFontFamily ?? keyboardState.fontFamily);
            }
            if (currentPrefsState.keyboardFollowsMouse) {
              _stopMouseTracking();
            }
          } else {
            if (keyboardState.showAltLayout) {
              _loadAltLayout();
            }
            if (currentPrefsState.keyboardFollowsMouse) {
              _startMouseTracking();
            }
          }
          if (advancedSettingsEnabled) {
            if (keyboardState.kanataEnabled) {
              _useKanata();
            }
            if (currentPrefsState.useUserLayout &&
                !keyboardState.kanataEnabled) {
              _loadUserLayout();
            }
            if (keyboardState.showAltLayout) {
              _loadAltLayout();
            }
            if (currentPrefsState.customFontEnabled) {
              _loadCustomFont();
            }
          } else {
            _fadeIn();
          }
        case 'updateUseUserLayout':
          final useUserLayout = call.arguments as bool;
          prefsNotifier.updateUseUserLayout(useUserLayout);
          if (useUserLayout) {
            _loadUserLayout();
          } else {
            final keyboardState = ref.read(keyboardNotifierProvider);
            if (keyboardState.initialLayout != null &&
                !keyboardState.kanataEnabled) {
              keyboardNotifier.updateLayout(keyboardState.initialLayout!);
            }
            _fadeIn();
          }
        case 'updateShowAltLayout':
          final showAltLayout = call.arguments as bool;
          keyboardNotifier.updateShowAltLayout(showAltLayout);
          if (showAltLayout) {
            _loadAltLayout();
          }
          _fadeIn();
        case 'updateCustomFontEnabled':
          final customFontEnabled = call.arguments as bool;
          prefsNotifier.updateCustomFontEnabled(customFontEnabled);
          final keyboardState = ref.read(keyboardNotifierProvider);
          if (customFontEnabled) {
            _loadCustomFont();
          } else {
            keyboardNotifier.updateFontFamily(
                keyboardState.initialFontFamily ?? keyboardState.fontFamily);
          }
        case 'updateUse6ColLayout':
          final use6ColLayout = call.arguments as bool;
          prefsNotifier.updateUse6ColLayout(use6ColLayout);
          _fadeIn();
        case 'updateKanataEnabled':
          final kanataEnabled = call.arguments as bool;
          final keyboardState = ref.read(keyboardNotifierProvider);
          if (kanataEnabled && !keyboardState.kanataEnabled) {
            keyboardNotifier.updateInitialLayout(keyboardState.layout);
            keyboardNotifier.updateKanataEnabled(true);
            _useKanata();
          } else if (!kanataEnabled && keyboardState.kanataEnabled) {
            keyboardNotifier.updateKanataEnabled(false);
            _kanataService.disconnect();
            if (keyboardState.initialLayout != null) {
              keyboardNotifier.updateLayout(keyboardState.initialLayout!);
              _fadeIn();
            }
          }
        case 'updateKeyboardFollowsMouse':
          final keyboardFollowsMouse = call.arguments as bool;
          prefsNotifier.updateKeyboardFollowsMouse(keyboardFollowsMouse);
          final currentPrefsState = ref.read(preferencesNotifierProvider);
          if (keyboardFollowsMouse &&
              currentPrefsState.advancedSettingsEnabled) {
            _startMouseTracking();
            windowManager.setAlignment(Alignment.bottomCenter);
          } else {
            _stopMouseTracking();
          }

        case 'updateHideOnDefaultLayer':
          final hideOnDefaultLayer = call.arguments as bool;
          prefsNotifier.updateHideOnDefaultLayer(hideOnDefaultLayer);

        case 'closePreferencesWindow':
          await windowController.close();
          break;
        default:
          throw UnimplementedError('Unimplemented method ${call.method}');
      }
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboardState = ref.watch(keyboardNotifierProvider);
    final prefsState = ref.watch(preferencesNotifierProvider);
    final appState = ref.watch(appStateNotifierProvider);

    return MaterialApp(
      title: 'OverKeys',
      theme: ThemeData(
          fontFamily: keyboardState.fontFamily,
          fontFamilyFallback: const ['GeistMono', 'Manrope', 'sans-serif']),
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            AnimatedOpacity(
              opacity: appState.isWindowVisible ? prefsState.opacity : 0.0,
              duration: _fadeDuration,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanStart: (_) => windowManager.startDragging(),
                child: Container(
                  color: Colors.transparent,
                  child: const Center(
                    child: KeyboardScreen(),
                  ),
                ),
              ),
            ),
            StatusOverlay(
              visible: appState.showStatusOverlay,
              message: appState.overlayMessage,
              icon: appState.statusIcon,
              backgroundColor: keyboardState.keyColorNotPressed,
              textColor: keyboardState.keyTextColorNotPressed,
              keySize: keyboardState.keySize,
              keyBorderRadius: keyboardState.keyBorderRadius,
            ),
          ],
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
