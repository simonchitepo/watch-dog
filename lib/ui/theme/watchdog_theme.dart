import 'package:flutter/material.dart';

class WatchdogTokens {
  final Color muted;
  final Color good;
  final Color warn;
  final Color bad;

  final Color surface;
  final Color surfaceAlt;
  final Color border;

  const WatchdogTokens({
    required this.muted,
    required this.good,
    required this.warn,
    required this.bad,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
  });
}

/// If your project already defines this extension, keep only ONE copy.
/// Your screens call `context.wd`.
extension WatchdogContextX on BuildContext {
  WatchdogTokens get wd {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark ? WatchdogTheme.tokensDark : WatchdogTheme.tokensLight;
  }
}

class WatchdogTheme {
  static const Color _red = Color(0xFFE53935);
  static const Color _redDark = Color(0xFFB71C1C);

  static final WatchdogTokens tokensLight = WatchdogTokens(
    muted: const Color(0xFF616161),
    good: const Color(0xFF2E7D32),
    warn: const Color(0xFFF9A825),
    bad: const Color(0xFFC62828),
    surface: Colors.white,
    surfaceAlt: const Color(0xFFF6F6F6),
    border: const Color(0xFFE6E6E6),
  );

  static final WatchdogTokens tokensDark = WatchdogTokens(
    muted: const Color(0xFFBDBDBD),
    good: const Color(0xFF66BB6A),
    warn: const Color(0xFFFFD54F),
    bad: const Color(0xFFEF5350),
    surface: const Color(0xFF121212),
    surfaceAlt: const Color(0xFF1A1A1A),
    border: const Color(0xFF2A2A2A),
  );

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _red,
      brightness: Brightness.light,
      primary: _red,
      secondary: Colors.black,
      surface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.white,

      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
      ),

      // ✅ FIX: CardThemeData (not CardTheme)
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: tokensLight.border),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          side: BorderSide(color: tokensLight.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokensLight.surfaceAlt,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: tokensLight.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _red, width: 2),
        ),
      ),

      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: BorderSide(color: tokensLight.border),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.black,
        contentTextStyle: const TextStyle(color: Colors.white),
        actionTextColor: _red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),

      dividerTheme: DividerThemeData(
        color: tokensLight.border,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _red,
      brightness: Brightness.dark,
      primary: _red,
      secondary: Colors.white,
      surface: const Color(0xFF121212),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF0E0E0E),

      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
      ),

      // ✅ FIX: CardThemeData (not CardTheme)
      cardTheme: CardThemeData(
        color: tokensDark.surfaceAlt,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: tokensDark.border),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: tokensDark.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokensDark.surfaceAlt,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: tokensDark.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _red, width: 2),
        ),
      ),

      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: BorderSide(color: tokensDark.border),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1A1A1A),
        contentTextStyle: const TextStyle(color: Colors.white),
        actionTextColor: _red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),

      dividerTheme: DividerThemeData(
        color: tokensDark.border,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
