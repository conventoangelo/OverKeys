import 'package:flutter/material.dart';

class ThemeManager {
  static final ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: const Color(0xFF742020),
    onPrimary: Colors.white,
    secondary: const Color(0xFF8D2A2A),
    onSecondary: Colors.white,
    error: Colors.red.shade600,
    onError: Colors.white,
    surface: Colors.white,
    onSurface: Colors.grey.shade900,
    surfaceContainerHighest: const Color(0xFFF8F0F0),
    onSurfaceVariant: const Color(0xFF4A3030),
    outline: Colors.grey.shade400,
  );

  static final ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: const Color(0xFFD15959),
    onPrimary: Colors.black,
    secondary: const Color(0xFFE77979),
    onSecondary: Colors.black,
    error: Colors.red.shade400,
    onError: Colors.black,
    surface: Colors.grey.shade900,
    onSurface: Colors.white,
    surfaceContainerHighest: Colors.grey.shade800,
    onSurfaceVariant: const Color(0xFFD8BCBC),
    outline: Colors.grey.shade600,
  );

  static ThemeData getTheme(Brightness brightness) {
    final colorScheme =
        brightness == Brightness.light ? lightColorScheme : darkColorScheme;

    return ThemeData(
      fontFamily: 'Manrope',
      colorScheme: colorScheme,
    );
  }
}
