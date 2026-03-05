import 'package:flutter/material.dart';

class ThemeManager {
  static final ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: const Color(0xFF742020), // Your fixed primary
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFFFDAD9), // Soft, warm red tint
    onPrimaryContainer: const Color(0xFF400006),

    // Derived from your dark mode's secondary (#E77979)
    secondary: const Color(0xFF904A4A),
    onSecondary: Colors.white,
    secondaryContainer: const Color(0xFFFFDAD9),
    onSecondaryContainer: const Color(0xFF3B090B),

    // Derived from your dark mode's tertiary (#CFBD99)
    tertiary: const Color(0xFF705C2E),
    onTertiary: Colors.white,
    tertiaryContainer: const Color(0xFFFBE0A6),
    onTertiaryContainer: const Color(0xFF251A00),

    error: const Color(0xFFBA1A1A),
    onError: Colors.white,
    errorContainer: const Color(0xFFFFDAD6),
    onErrorContainer: const Color(0xFF410002),

    // Neutral colors with a hint of "Primary" warmth
    surface: const Color(0xFFFFF8F7), // "Warm" white
    onSurface: const Color(0xFF221919), // Deep brown-grey
    onSurfaceVariant: const Color(0xFF524343),
    surfaceTint: const Color(0xFF742020),

    // Material 3 Surface Containers
    surfaceContainerLowest: const Color(0xFFFFFFFF),
    surfaceContainerLow: const Color(0xFFFFF0F0),
    surfaceContainer: const Color(0xFFF9EDED),
    surfaceContainerHigh: const Color(0xFFF3E7E7),
    surfaceContainerHighest: const Color(0xFFEDE1E1),

    outline: const Color(0xFF857372),
    outlineVariant: const Color(0xFFD8C2C1),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: const Color(0xFF392E2E),
    onInverseSurface: const Color(0xFFFBEEEE),
    inversePrimary: const Color(0xFFFFB3B3),
  );

  static final ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: const Color(0xFFD15959),
    onPrimary: const Color(0xFF68000F),
    primaryContainer: const Color(0xFF8F2C2C),
    onPrimaryContainer: const Color(0xFFFFDADA),
    secondary: const Color(0xFFE77979),
    onSecondary: const Color(0xFF441B1B),
    secondaryContainer: const Color(0xFFA13636),
    onSecondaryContainer: const Color(0xFFFFDBDB),
    tertiary: const Color(0xFFCFBD99),
    onTertiary: const Color(0xFF342F00),
    tertiaryContainer: const Color(0xFF534628),
    onTertiaryContainer: const Color(0xFFEDE1C9),
    error: const Color(0xFFFFB4AB),
    onError: const Color(0xFF690005),
    errorContainer: const Color(0xFF93000A),
    onErrorContainer: const Color(0xFFFFDAD6),
    surface: const Color(0xFF1A1111), // Deep warm black
    onSurface: const Color(0xFFF0E0DF),
    onSurfaceVariant: const Color(0xFFD8C2C1),
    surfaceTint: const Color(0xFFD15959),
    surfaceContainerLowest: const Color(0xFF140C0C),
    surfaceContainerLow: const Color(0xFF221919),
    surfaceContainer: const Color(0xFF271D1D),
    surfaceContainerHigh: const Color(0xFF322727),
    surfaceContainerHighest: const Color(0xFF3D3232),
    outline: const Color(0xFFA08C8B),
    outlineVariant: const Color(0xFF524343),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: const Color(0xFFF0E0DF),
    onInverseSurface: const Color(0xFF392E2E),
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
