import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'app.dart';
import 'screens/preferences_screen.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (args.firstOrNull == 'multi_window') {
    final windowId = int.parse(args[1]);
    final arguments = args[2].isEmpty
        ? const {}
        : jsonDecode(args[2]) as Map<String, dynamic>;

    Map windows = {
      "preferences": PreferencesScreen(
        windowController: WindowController.fromWindowId(windowId),
      ),
    };
    runApp(windows[arguments["name"]]);
  } else {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    launchAtStartup.setup(
      appName: packageInfo.appName,
      appPath: Platform.resolvedExecutable,
      packageName: packageInfo.packageName,
    );
    await windowManager.ensureInitialized();
    double windowWidth = 960;
    double windowHeight = 320;

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
      await windowManager.show();
    });
    runApp(const MainApp());
  }
}
