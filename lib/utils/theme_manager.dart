import 'package:flutter/material.dart';

/// Centralized theme management based on Monospace Terminal colors
class ThemeManager {
  // --- MONOSPACE LIGHT SCHEME ---
  static final ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: const Color(0xFF8964E8), // Accent
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFEADBFF),
    onPrimaryContainer: const Color(0xFF2B0066),
    
    secondary: const Color(0xFF3C60DD), // Normal Blue
    onSecondary: Colors.white,
    secondaryContainer: const Color(0xFFDCE1FF),
    onSecondaryContainer: const Color(0xFF001551),

    tertiary: const Color(0xFFA65921), // Normal Yellow
    onTertiary: Colors.white,
    tertiaryContainer: const Color(0xFFFFDDB1),
    onTertiaryContainer: const Color(0xFF381A00),

    error: const Color(0xFFD03941), // Normal Red
    onError: Colors.white,
    errorContainer: const Color(0xFFFFDAD9),
    onErrorContainer: const Color(0xFF41000A),

    surface: const Color(0xFFF4F7FD), // Background
    onSurface: const Color(0xFF475365), // Foreground
    onSurfaceVariant: const Color(0xFF5D6A7D), // Normal White/Grey
    
    // M3 Surface Containers - derived from background #F4F7FD
    surfaceContainerLowest: const Color(0xFFFFFFFF),
    surfaceContainerLow: const Color(0xFFEFF2F9),
    surfaceContainer: const Color(0xFFE9EDF6),
    surfaceContainerHigh: const Color(0xFFE3E8F2),
    surfaceContainerHighest: const Color(0xFFDDE3EE),

    outline: const Color(0xFF738295),
    outlineVariant: const Color(0xFFC3C7CF),
    inverseSurface: const Color(0xFF2F343D),
    onInverseSurface: const Color(0xFFF0F0F3),
    inversePrimary: const Color(0xFFA87FFB),
  );

  // --- MONOSPACE DARK SCHEME ---
  static final ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: const Color(0xFFA87FFB), // Accent
    onPrimary: const Color(0xFF3D0090),
    primaryContainer: const Color(0xFF5535A0),
    onPrimaryContainer: const Color(0xFFEADBFF),

    secondary: const Color(0xFF708FFF), // Normal Blue
    onSecondary: const Color(0xFF002279),
    secondaryContainer: const Color(0xFF2142A5),
    onSecondaryContainer: const Color(0xFFDCE1FF),

    tertiary: const Color(0xFFFFA23E), // Normal Yellow
    onTertiary: const Color(0xFF4B2800),
    tertiaryContainer: const Color(0xFF6B3B00),
    onTertiaryContainer: const Color(0xFFFFDDB1),

    error: const Color(0xFFF76769), // Normal Red
    onError: const Color(0xFF680014),
    errorContainer: const Color(0xFF93001F),
    onErrorContainer: const Color(0xFFFFDAD9),

    surface: const Color(0xFF10151D), // Background
    onSurface: const Color(0xFFA4AFBD), // Foreground
    onSurfaceVariant: const Color(0xFF8B98A9), // Bright Black
    
    // M3 Surface Containers - derived from background #10151D
    surfaceContainerLowest: const Color(0xFF0A0E14),
    surfaceContainerLow: const Color(0xFF191E26),
    surfaceContainer: const Color(0xFF1D232C),
    surfaceContainerHigh: const Color(0xFF282D38),
    surfaceContainerHighest: const Color(0xFF333944),

    outline: const Color(0xFF738295),
    outlineVariant: const Color(0xFF44474E),
    inverseSurface: const Color(0xFFE2E2E6),
    onInverseSurface: const Color(0xFF2F3033),
    inversePrimary: const Color(0xFF8964E8),
  );

  /// Returns a ThemeData object based on the requested brightness
  static ThemeData getTheme(Brightness brightness) {
    final colorScheme =
        brightness == Brightness.light ? lightColorScheme : darkColorScheme;

    return ThemeData(
      fontFamily: 'Manrope', // Keeping your font choice
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
    );
  }
}