import 'package:flutter/material.dart';

class AppTheme {
  // Main Theme Color Palette
  static const Color primaryIndigo = Color(0xFF6366F1); // #6366F1
  static const Color accentCyan = Color(0xFF06B6D4);    // #06B6D4
  static const Color pureWhite = Color(0xFFFFFFFF);     // #FFFFFF
  static const String fontHind = 'hind';

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: fontHind,
    brightness: Brightness.light,
    primaryColor: primaryIndigo,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryIndigo,
      primary: primaryIndigo,
      secondary: accentCyan,
      brightness: Brightness.light,
      surface: pureWhite,
    ),
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Color(0xFFF8FAFC),
      iconTheme: IconThemeData(color: primaryIndigo),
      actionsIconTheme: IconThemeData(color: primaryIndigo),
      titleTextStyle: TextStyle(
        fontFamily: fontHind,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shadowColor: primaryIndigo.withValues(alpha: 0.08),
      color: pureWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryIndigo,
      foregroundColor: pureWhite,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryIndigo,
        foregroundColor: pureWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: fontHind,
    brightness: Brightness.dark,
    primaryColor: primaryIndigo,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryIndigo,
      primary: primaryIndigo,
      secondary: accentCyan,
      brightness: Brightness.dark,
      surface: const Color(0xFF1E293B),
    ),
    scaffoldBackgroundColor: const Color(0xFF0F172A),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Color(0xFF0F172A),
      iconTheme: IconThemeData(color: accentCyan),
      actionsIconTheme: IconThemeData(color: accentCyan),
      titleTextStyle: TextStyle(
        fontFamily: fontHind,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: pureWhite,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.4),
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentCyan,
      foregroundColor: pureWhite,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryIndigo,
        foregroundColor: pureWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
