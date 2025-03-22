import 'package:flutter/material.dart';

class ThemeManager {
  static final ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: const Color(0xFF742020),
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFF5D6D6),
    onPrimaryContainer: const Color(0xFF550000),
    secondary: const Color(0xFF8D2A2A),
    onSecondary: Colors.white,
    secondaryContainer: const Color(0xFFF9DCDC),
    onSecondaryContainer: const Color(0xFF5D0000),
    tertiary: const Color(0xFF6C5D41),
    onTertiary: Colors.white,
    tertiaryContainer: const Color(0xFFF5EFDC),
    onTertiaryContainer: const Color(0xFF413625),
    error: Colors.red.shade600,
    onError: Colors.white,
    errorContainer: Colors.red.shade200,
    onErrorContainer: Colors.red.shade900,
    surface: Colors.white,
    onSurface: Colors.grey.shade900,
    onSurfaceVariant: const Color(0xFF493838),
    surfaceTint: const Color(0xFF742020),
    surfaceContainerLowest: const Color(0xFFFFFFFF),
    surfaceContainerLow: const Color(0xFFF9F1F1),
    surfaceContainer: const Color(0xFFF5EDED),
    surfaceContainerHigh: const Color(0xFFEFE7E7),
    surfaceContainerHighest: const Color(0xFFF8F0F0),
    outline: Colors.grey.shade400,
    outlineVariant: Colors.grey.shade300,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Colors.grey.shade900,
    onInverseSurface: Colors.white,
    inversePrimary: const Color(0xFFFFB3B3),
  );

  static final ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: const Color(0xFFD15959),
    onPrimary: Colors.black,
    primaryContainer: const Color(0xFF8F2C2C),
    onPrimaryContainer: const Color(0xFFFFDADA),
    secondary: const Color(0xFFE77979),
    onSecondary: Colors.black,
    secondaryContainer: const Color(0xFFA13636),
    onSecondaryContainer: const Color(0xFFFFDBDB),
    tertiary: const Color(0xFFCFBD99),
    onTertiary: Colors.black,
    tertiaryContainer: const Color(0xFF534628),
    onTertiaryContainer: const Color(0xFFEDE1C9),
    error: Colors.red.shade400,
    onError: Colors.black,
    errorContainer: Colors.red.shade900,
    onErrorContainer: Colors.red.shade100,
    surface: const Color(0xFF1A1A1A),
    onSurface: Colors.white,
    onSurfaceVariant: const Color(0xFFF2E5E5),
    surfaceTint: const Color(0xFFD15959),
    surfaceContainerLowest: const Color(0xFF121212),
    surfaceContainerLow: const Color(0xFF1F1F1F),
    surfaceContainer: const Color(0xFF252525),
    surfaceContainerHigh: const Color(0xFF2F2F2F),
    surfaceContainerHighest: Colors.grey.shade800,
    outline: Colors.grey.shade600,
    outlineVariant: Colors.grey.shade700,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Colors.grey.shade200,
    onInverseSurface: Colors.black,
    inversePrimary: const Color(0xFF742020),
  );

  static ThemeData getTheme(Brightness brightness) {
    final colorScheme =
        brightness == Brightness.light ? lightColorScheme : darkColorScheme;

    return ThemeData(
      fontFamily: 'Manrope',
      colorScheme: colorScheme,
      useMaterial3: true,
    );
  }
}
