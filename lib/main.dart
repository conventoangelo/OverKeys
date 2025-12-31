import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'app.dart';
import 'screens/preferences_screen.dart';
import 'utils/window_controller_extension.dart';

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

  // Get the current window controller
  final windowController = await WindowController.fromCurrentEngine();

  // Parse window arguments to determine which window to show
  final windowType = _parseWindowType(windowController.arguments);

  // Initialize window manager
  await windowManager.ensureInitialized();
  await hotKeyManager.unregisterAll();

  // Run different apps based on the window type
  switch (windowType) {
    case WindowType.main:
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

WindowType _parseWindowType(String arguments) {
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
    await windowManager.setIcon("assets/images/app_icon.ico");
    await windowManager.center();
    await windowManager.setMinimumSize(const Size(828, 621));
    await windowManager.focus();
    await windowManager.show();
  });
}
