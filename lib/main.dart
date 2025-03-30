import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'app.dart';
import 'screens/preferences_screen.dart';

void main(List<String> args) async {
  final isSubWindow = args.firstOrNull == 'multi_window';
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await hotKeyManager.unregisterAll();

  if (isSubWindow) {
    final windowId = int.parse(args[1]);
    final arguments = args[2].isEmpty
        ? const {}
        : jsonDecode(args[2]) as Map<String, dynamic>;

    if (arguments["name"] == "preferences") {
      WindowOptions windowOptions = const WindowOptions(
        title: "Preferences",
        titleBarStyle: TitleBarStyle.normal,
        size: Size(1280, 720),
      );

      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.setTitle("Preferences");
        await windowManager.setIcon("assets/images/app_icon.ico");
        await windowManager.center();
        await windowManager.setMinimumSize(const Size(828, 621));
        await windowManager.focus();
        await windowManager.show();
      });

      runApp(PreferencesScreen(
        windowController: WindowController.fromWindowId(windowId),
      ));
    }
  } else {
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

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setAlwaysOnTop(true);
      await windowManager.setAsFrameless();
      await windowManager.setSize(Size(windowWidth, windowHeight));
      await windowManager.setIgnoreMouseEvents(true);
      await windowManager.setAlignment(Alignment.bottomCenter);
      await windowManager.setSkipTaskbar(true);
      await windowManager.show();
    });

    runApp(const MainApp());
  }
}
