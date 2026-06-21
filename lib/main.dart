import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'app.dart';
import 'screens/preferences_screen.dart';
import 'utils/window_controller_extension.dart';
import 'utils/logger.dart';

const MethodChannel _windowChannel = MethodChannel('overkeys/window');

// Window type definitions
enum WindowType {
  main,
  preferences;

  static WindowType fromString(String value) {
    return WindowType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => WindowType.main,
    );
  }
}

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize log capture early to catch all logs
  LogCapture();

  final windowController = _controllerFromEntrypointArgs(args) ??
      await WindowController.fromCurrentEngine();

  final entrypointArguments = windowArgumentsFromEntrypointArgs(args);
  final windowType = parseWindowType(
    entrypointArguments.isNotEmpty
        ? entrypointArguments
        : windowController.arguments,
  );

  // Initialize window manager
  await windowManager.ensureInitialized();

  // Run different apps based on the window type
  switch (windowType) {
    case WindowType.main:
      await hotKeyManager.unregisterAll();
      await _initMainWindow();
      runApp(const ProviderScope(child: MainApp()));
      break;
    case WindowType.preferences:
      await _initPreferencesWindow(windowController);
      runApp(ProviderScope(
        child: PreferencesScreen(
          windowController: windowController,
        ),
      ));
      break;
  }
}

WindowController? _controllerFromEntrypointArgs(List<String> args) {
  if (args.length >= 2 && args.first == 'multi_window') {
    return WindowController.fromWindowId(args[1]);
  }
  return null;
}

String windowArgumentsFromEntrypointArgs(List<String> args) {
  if (args.length >= 3 && args.first == 'multi_window') {
    return args[2];
  }
  return '';
}

WindowType parseWindowType(String arguments) {
  if (arguments.isEmpty) {
    return WindowType.main;
  }
  return WindowType.fromString(arguments);
}

Future<void> _initMainWindow() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  launchAtStartup.setup(
    appName: packageInfo.appName,
    appPath: Platform.resolvedExecutable,
    packageName: packageInfo.packageName,
  );

  double windowWidth = 1000;
  double windowHeight = 330;

  WindowOptions windowOptions = const WindowOptions(
    backgroundColor: Colors.transparent,
    skipTaskbar: true,
    title: "OverKeys",
    titleBarStyle: TitleBarStyle.hidden,
  );

  await _configureNativeKeyboardOverlay();

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setAsFrameless();
    await windowManager.setSize(Size(windowWidth, windowHeight));
    await windowManager.setIgnoreMouseEvents(true);
    await windowManager.setAlignment(Alignment.bottomCenter);
    await windowManager.setSkipTaskbar(true);
    await windowManager.show();
  });
}

Future<void> _configureNativeKeyboardOverlay() async {
  if (!Platform.isMacOS) {
    return;
  }

  try {
    await _windowChannel.invokeMethod<void>('configureKeyboardOverlay');
  } on MissingPluginException {
    // Unit tests and non-bundled runners do not register the macOS channel.
  }
}

Future<void> _initPreferencesWindow(WindowController windowController) async {
  // Initialize window controller methods
  await windowController.initializeWindowMethods();

  WindowOptions windowOptions = const WindowOptions(
    title: "Preferences",
    titleBarStyle: TitleBarStyle.normal,
    size: Size(1280, 720),
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setTitle("Preferences");
    if (Platform.isWindows) {
      await windowManager.setIcon("assets/images/app_icon.ico");
    }
    await windowManager.center();
    await windowManager.setMinimumSize(const Size(828, 621));
    await windowController.show();
    await windowManager.focus();
  });
}
