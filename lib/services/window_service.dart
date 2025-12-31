import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:overkeys/providers/keyboard_provider.dart';

/// Service for managing window size, position, and alignment
class WindowService {
  // Default window dimensions
  static const double defaultWindowWidth = 1000;
  static const double defaultWindowHeight = 330;

  // Extra dimensions when top row is shown
  static const double defaultTopRowExtraHeight = 80;
  static const double defaultTopRowExtraWidth = 160;

  /// Adjusts window size based on keyboard layout configuration
  Future<void> adjustWindowSize(WidgetRef ref) async {
    final keyboardState = ref.read(keyboardNotifierProvider);

    final height = keyboardState.showTopRow
        ? defaultWindowHeight + defaultTopRowExtraHeight
        : defaultWindowHeight;

    final width = keyboardState.showTopRow
        ? defaultWindowWidth + defaultTopRowExtraWidth
        : defaultWindowWidth;

    await windowManager.setSize(Size(width, height));
    await windowManager.setAlignment(Alignment.bottomCenter);
  }

  /// Resets window position to bottom center
  Future<void> resetPosition() async {
    await windowManager.setAlignment(Alignment.bottomCenter);
  }
}
