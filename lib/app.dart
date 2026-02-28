import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart'
    hide MethodCallHandler;
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:overkeys/services/kanata_service.dart';
import 'package:overkeys/services/state_service.dart';
import 'package:overkeys/services/hotkey_service.dart';
import 'package:overkeys/services/app_tray_service.dart';
import 'package:overkeys/services/configuration_loader.dart';
import 'package:overkeys/services/auto_hide_manager.dart';
import 'package:overkeys/services/method_call_handler.dart';
import 'package:overkeys/services/window_service.dart';
import 'package:overkeys/services/visibility_service.dart';
import 'package:overkeys/services/key_event_service.dart';
import 'package:overkeys/utils/window_controller_extension.dart';
import 'package:overkeys/widgets/status_overlay.dart';
import 'package:overkeys/utils/logger.dart';
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
  /// Logger instance for this widget
  final _log = SimplePrintLogger('MainApp');
  static const Duration _fadeDuration = Duration(milliseconds: 200);
  static const double _opacityStep = 0.05;
  static const double _minOpacity = 0.1;
  static const double _maxOpacity = 1.0;

  // Services
  final StateService _stateService = StateService();
  final KanataService _kanataService = KanataService();
  final HotKeyService _hotKeyService = HotKeyService();
  final AppTrayService _trayService = AppTrayService();
  late final ConfigurationLoader _configLoader;
  final AutoHideManager _autoHideManager = AutoHideManager();
  final MethodCallHandler _methodCallHandler = MethodCallHandler();
  final WindowService _windowService = WindowService();
  final VisibilityService _visibilityService = VisibilityService();
  final KeyEventService _keyEventService = KeyEventService();

  @override
  void initState() {
    super.initState();
    _configLoader = ConfigurationLoader(_kanataService);
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
    _setupKanataLayerChangeHandler();
    _loadConfiguration();
    final prefsState = ref.read(preferencesProvider);
    final keyboardState = ref.read(keyboardProvider);
    if (keyboardState.showTopRow) {
      _adjustWindowSize();
    }
    if (prefsState.autoHideEnabled) {
      _resetAutoHideTimer();
    } else if (prefsState.hideAtStartup) {
      onTrayIconMouseDown();
    }
  }

  void _setupKanataLayerChangeHandler() {
    _kanataService.onLayerChange = (newLayout, isDefaultUserLayout) {
      final keyboardNotifier = ref.read(keyboardProvider.notifier);
      final appNotifier = ref.read(appStateProvider.notifier);
      final prefsState = ref.read(preferencesProvider);
      final appState = ref.read(appStateProvider);

      keyboardNotifier.updateLayout(newLayout);
      _autoHideManager.resetAutoHideTimer(ref);

      // Handle hide on default layer functionality
      if (isDefaultUserLayout &&
          prefsState.hideOnDefaultLayer &&
          appState.isWindowVisible) {
        appNotifier.updateIsWindowVisible(false);
      } else {
        _fadeIn();
      }
    };

    // Set up disconnect callback to restore layout when Kanata connection is lost
    _kanataService.onDisconnect = () {
      final keyboardNotifier = ref.read(keyboardProvider.notifier);
      final keyboardState = ref.read(keyboardProvider);
      final prefsState = ref.read(preferencesProvider);

      // Only restore layout if Kanata is still enabled in preferences
      // (if user manually disabled it, the layout restore is handled elsewhere)
      if (prefsState.kanataEnabled && keyboardState.initialLayout != null) {
        keyboardNotifier.updateLayout(keyboardState.initialLayout!);
        _fadeIn();
      }
    };
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    trayManager.removeListener(this);
    unhook();
    _kanataService.dispose();
    _autoHideManager.dispose();
    _keyEventService.clearActiveTriggers();
    _saveAllPreferences();
    super.dispose();
  }

  void _startMouseTracking() {
    _autoHideManager.startMouseTracking(ref, () {
      windowManager.setAlignment(Alignment.bottomCenter);
    });
  }

  void _stopMouseTracking() {
    _autoHideManager.stopMouseTracking();
  }

  Future<void> _loadAllPreferences() async {
    await _stateService.loadStatesIntoProviders(ref);
  }

  Future<void> _saveAllPreferences() async {
    await _stateService.saveAllStates(
      keyboard: ref.read(keyboardProvider),
      preferences: ref.read(preferencesProvider),
      appState: ref.read(appStateProvider),
    );
  }

  Future<void> _loadConfiguration() async {
    // Clear the cached config to force reload from file
    _configLoader.clearConfigCache();
    await _configLoader.loadAllConfiguration(ref);
  }

  Future<void> _loadUserLayout() async {
    await _configLoader.loadUserLayout(ref);
  }

  Future<void> _loadAltLayout() async {
    await _configLoader.loadAltLayout(ref);
  }

  Future<void> _loadCustomFont() async {
    await _configLoader.loadCustomFont(ref);
  }

  Future<void> _useKanata() async {
    await _configLoader.useKanata(ref);
  }

  Future<void> _adjustWindowSize() async {
    _fadeIn();
    await _windowService.adjustWindowSize(ref);
  }

  void _fadeIn() {
    _visibilityService.fadeIn(ref, _resetAutoHideTimer);
  }

  void _setupKeyListener() {
    _keyEventService.setupKeyListener(
      () => ReceivePort(),
      (message) => _keyEventService.handleKeyEvent(message, ref, _fadeIn,
          _resetAutoHideTimer, () => _autoHideManager.cancelAutoHideTimer()),
    );
  }

  void _resetAutoHideTimer() {
    _autoHideManager.resetAutoHideTimer(ref);
  }

  void _fadeOut() {
    _autoHideManager.fadeOut(ref);
  }

  void _toggleAutoHide(bool enable) {
    final prefsNotifier = ref.read(preferencesProvider.notifier);
    final appState = ref.read(appStateProvider);

    prefsNotifier.updateAutoHideEnabled(enable);
    if (enable) {
      _resetAutoHideTimer();
    } else {
      _autoHideManager.cancelAutoHideTimer();
      if (!appState.isWindowVisible) {
        _fadeIn();
      }
    }
    _autoHideManager.showOverlay(
        ref,
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
    final appState = ref.read(appStateProvider);
    final prefsState = ref.read(preferencesProvider);
    final prefsNotifier = ref.read(preferencesProvider.notifier);
    double lastOpacity = prefsState.opacity;

    if (appState.forceHide) return;

    final newLastOpacity = increase
        ? (lastOpacity + _opacityStep).clamp(_minOpacity, _maxOpacity)
        : (lastOpacity - _opacityStep).clamp(_minOpacity, _maxOpacity);

    if (newLastOpacity != lastOpacity) {
      lastOpacity = newLastOpacity;

      _autoHideManager.showOverlay(
          ref,
          'Opacity: ${(lastOpacity * 100).round()}%',
          increase
              ? const Icon(LucideIcons.plusCircle)
              : const Icon(LucideIcons.minusCircle));
    }

    _autoHideManager
        .debouncedOpacityUpdate(ref, const Duration(milliseconds: 125), () {
      if (prefsState.opacity != lastOpacity) {
        prefsNotifier.updateOpacity(lastOpacity);
        _saveAllPreferences();
        WindowController.getAll().then((controllers) {
          for (final controller in controllers) {
            if (controller.arguments == 'preferences') {
              controller.invokeMethod(
                  'updateOpacityFromMainWindow', lastOpacity);
            }
          }
        });
      }
    });
  }

  String _formatHotkey(HotKey? hotkey, bool enabled) {
    final appState = ref.read(appStateProvider);
    if (hotkey == null || !appState.hotKeysEnabled || !enabled) return '';
    return _hotKeyService.formatHotkey(hotkey, true);
  }

  Future<void> _setupTray() async {
    final appState = ref.read(appStateProvider);
    final prefsState = ref.read(preferencesProvider);

    await _trayService.setupTray(
      toggleMoveHotKeyLabel: _formatHotkey(
          appState.toggleMoveHotKey, appState.enableToggleMoveHotKey),
      autoHideHotKeyLabel:
          _formatHotkey(appState.autoHideHotKey, appState.enableAutoHideHotKey),
      preferencesHotKeyLabel: _formatHotkey(
          appState.preferencesHotKey, appState.enablePreferencesHotKey),
      visibilityHotKeyLabel: _formatHotkey(
          appState.visibilityHotKey, appState.enableVisibilityHotKey),
      ignoreMouseEvents: appState.ignoreMouseEvents,
      autoHideEnabled: prefsState.autoHideEnabled,
      onToggleMoveClicked: () {
        final appNotifier = ref.read(appStateProvider.notifier);
        appNotifier.updateIgnoreMouseEvents(!appState.ignoreMouseEvents);
        windowManager.setIgnoreMouseEvents(!appState.ignoreMouseEvents);
        if (!appState.ignoreMouseEvents) {
          _fadeIn();
          _autoHideManager.showOverlay(
              ref, 'Move disabled', const Icon(LucideIcons.lock));
        } else {
          _autoHideManager.showOverlay(
              ref, 'Move enabled', const Icon(LucideIcons.move));
        }
      },
      onAutoHideClicked: () => _toggleAutoHide(!prefsState.autoHideEnabled),
      onResetPositionClicked: () {
        _windowService.resetPosition();
        _autoHideManager.showOverlay(
            ref, 'Position reset', const Icon(LucideIcons.locateFixed));
      },
      onPreferencesClicked: () => _showPreferences(),
      onToggleVisibilityClicked: () => onTrayIconMouseDown(),
      onReloadConfigClicked: () {
        _loadConfiguration();
        _autoHideManager.showOverlay(
            ref, 'Config Reloaded', const Icon(LucideIcons.refreshCw));
      },
    );
  }

  Future<void> _setupHotKeys() async {
    final appState = ref.read(appStateProvider);
    await _hotKeyService.setupHotKeys(
      autoHideHotKey: appState.autoHideHotKey,
      enableAutoHideHotKey: appState.enableAutoHideHotKey,
      visibilityHotKey: appState.visibilityHotKey,
      enableVisibilityHotKey: appState.enableVisibilityHotKey,
      toggleMoveHotKey: appState.toggleMoveHotKey,
      enableToggleMoveHotKey: appState.enableToggleMoveHotKey,
      preferencesHotKey: appState.preferencesHotKey,
      enablePreferencesHotKey: appState.enablePreferencesHotKey,
      increaseOpacityHotKey: appState.increaseOpacityHotKey,
      enableIncreaseOpacityHotKey: appState.enableIncreaseOpacityHotKey,
      decreaseOpacityHotKey: appState.decreaseOpacityHotKey,
      enableDecreaseOpacityHotKey: appState.enableDecreaseOpacityHotKey,
      hotKeysEnabled: appState.hotKeysEnabled,
      onAutoHideTriggered: () {
        final prefsState = ref.read(preferencesProvider);
        _toggleAutoHide(!prefsState.autoHideEnabled);
      },
      onVisibilityTriggered: () => onTrayIconMouseDown(),
      onToggleMoveTriggered: () {
        final currentAppState = ref.read(appStateProvider);
        final appNotifier = ref.read(appStateProvider.notifier);
        appNotifier.updateIgnoreMouseEvents(!currentAppState.ignoreMouseEvents);
        windowManager.setIgnoreMouseEvents(!currentAppState.ignoreMouseEvents);
        if (!currentAppState.ignoreMouseEvents) {
          _fadeIn();
          _autoHideManager.showOverlay(
              ref, 'Move disabled', const Icon(LucideIcons.lock));
        } else {
          _autoHideManager.showOverlay(
              ref, 'Move enabled', const Icon(LucideIcons.move));
        }
      },
      onPreferencesTriggered: () {
        _autoHideManager.showOverlay(
            ref, 'Opening Preferences', const Icon(LucideIcons.appWindow));
        _showPreferences();
      },
      onIncreaseOpacityTriggered: () => _adjustOpacity(true),
      onDecreaseOpacityTriggered: () => _adjustOpacity(false),
    );

    _setupTray();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (menuItem.key == 'exit') {
      _closePreferencesThenExit();
      return;
    }
    _setupTray();
  }

  Future<void> _closePreferencesThenExit() async {
    try {
      final controllers = await WindowController.getAll();
      for (final controller in controllers) {
        if (controller.arguments == 'preferences') {
          await controller.close();
        }
      }
    } catch (error) {
      _log.error('Error closing preferences window', error: error);
    }

    try {
      await windowManager.close();
    } finally {
      exit(0);
    }
  }

  @override
  void onTrayIconMouseDown() {
    final appNotifier = ref.read(appStateProvider.notifier);
    final appState = ref.read(appStateProvider);

    appNotifier.updateForceHide(!appState.forceHide);
    _autoHideManager.showOverlay(
        ref,
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
          await controller.invokeMethod('requestFocus');
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
      _log.error('Error handling preferences window', error: e);
    }
  }

  void _setupMethodHandler() async {
    final windowController = await WindowController.fromCurrentEngine();

    await windowController.setWindowMethodHandler((call) async {
      if (call.method == 'updateAutoHideEnabled') {
        final autoHideEnabled = call.arguments as bool;
        _toggleAutoHide(autoHideEnabled);
        return null;
      }

      if (call.method == 'updateShowTopRow') {
        final showTopRow = call.arguments as bool;
        ref.read(keyboardProvider.notifier).updateShowTopRow(showTopRow);
        _adjustWindowSize();
        return null;
      }

      await _methodCallHandler.handleMethodCall(
        call,
        ref,
        _kanataService,
        _setupHotKeys,
        _loadAltLayout,
        _loadCustomFont,
        _loadUserLayout,
        _useKanata,
        (bool start) {
          if (start) {
            _startMouseTracking();
          } else {
            _stopMouseTracking();
          }
        },
        _stopMouseTracking,
        _fadeIn,
        () => _configLoader.clearConfigCache(),
        _loadConfiguration,
      );

      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboardState = ref.watch(keyboardProvider);
    final prefsState = ref.watch(preferencesProvider);
    final appState = ref.watch(appStateProvider);

    return MaterialApp(
      title: 'OverKeys',
      theme: ThemeData(
          fontFamily: keyboardState.fontFamily,
          fontFamilyFallback: const ['DM Mono', 'Manrope', 'sans-serif']),
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
