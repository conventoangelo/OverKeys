import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    center: true,
    size: Size(700, 260),
    backgroundColor: Colors.transparent,
    skipTaskbar: true,
    title: "OverKeys",
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setAsFrameless();
    await windowManager.setOpacity(0.8);
    await windowManager.show();
    // await windowManager.setIgnoreMouseEvents(true);
  });

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OverKeys',
      theme: ThemeData(fontFamily: 'GeistMono'),
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanStart: (details) {
            windowManager.startDragging();
          },
          child: Container(
            color: Colors.transparent,
            child: const Center(
              child: KeyboardScreen(),
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class KeyboardScreen extends StatelessWidget {
  const KeyboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildRow(0,
                ["W", "L", "Y", "P", "K", "Z", "X", "O", "U", ";", "[", "]"]),
            buildRow(
                1, ["C", "R", "S", "T", "B", "F", "N", "E", "I", "A", "'"]),
            buildRow(2, ["J", "V", "D", "G", "Q", "M", "H", "/", ",", "."]),
            buildRow(3, [" "]),
          ],
        ),
      ),
    ]);
  }

  Widget buildRow(int rowIndex, List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.asMap().entries.map((entry) {
        int keyIndex = entry.key;
        String key = entry.value;
        return buildKeys(rowIndex, key, keyIndex);
      }).toList(),
    );
  }

  Widget buildKeys(int rowIndex, String key, int keyIndex) {
    Widget keyWidget = Padding(
      padding: const EdgeInsets.all(3.0),
      child: Container(
        width: key == " " ? 319 : 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 119, 171, 255),
          border: Border.all(
            color: Colors.black,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Center(
          child: Text(
            key,
            style: const TextStyle(color: Colors.black, fontSize: 18),
          ),
        ),
      ),
    );

    // Tactile Markers
    if (rowIndex == 1 && (keyIndex == 3 || keyIndex == 6)) {
      keyWidget = Stack(
        alignment: Alignment.bottomCenter,
        children: [
          keyWidget,
          Positioned(
            bottom: 12,
            child: Container(
              width: 10,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      );
    }

    return keyWidget;
  }
}
