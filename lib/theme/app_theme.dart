import 'package:flutter/material.dart';

class AppTheme {
  // Dark theme colors
  static const darkBackground = Color(0xFF0F1629);
  static const darkSurface = Color(0xFF1A2235);
  static const darkCard = Color(0xFF1E2A3D);
  static const darkCardAlt = Color(0xFF243044);

  // Light theme colors
  static const lightBackground = Color(0xFFF0F4FF);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);

  // Accent colors
  static const primaryBlue = Color(0xFF3B5BDB);
  static const primaryBlueDark = Color(0xFF2F4AC0);
  static const accentBlue = Color(0xFF4C6EF5);
  static const iconCircle = Color(0xFF2D4090);

  // Text
  static const darkTextPrimary = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFF8A9BB5);
  static const lightTextPrimary = Color(0xFF0F1629);
  static const lightTextSecondary = Color(0xFF5A6880);

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: primaryBlue,
      secondary: accentBlue,
      surface: darkSurface,
      background: darkBackground,
    ),
    cardTheme: const CardThemeData(
      color: darkCard,
      elevation: 0,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      elevation: 0,
      iconTheme: IconThemeData(color: darkTextPrimary),
      titleTextStyle: TextStyle(
        color: darkTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        fontFamily: 'SF Pro Display',
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCardAlt,
      hintStyle: const TextStyle(color: darkTextSecondary, fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w800, fontSize: 28),
      headlineMedium: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w700, fontSize: 24),
      titleLarge: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w700, fontSize: 20),
      titleMedium: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600, fontSize: 16),
      bodyLarge: TextStyle(color: darkTextPrimary, fontSize: 15),
      bodyMedium: TextStyle(color: darkTextSecondary, fontSize: 13),
      labelSmall: TextStyle(color: darkTextSecondary, fontSize: 11),
    ),
  );

  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      secondary: accentBlue,
      surface: lightSurface,
      background: lightBackground,
    ),
    cardTheme: const CardThemeData(
      color: lightCard,
      elevation: 2,
      shadowColor: Color(0x1A000000),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightBackground,
      elevation: 0,
      iconTheme: IconThemeData(color: lightTextPrimary),
      titleTextStyle: TextStyle(
        color: lightTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF0F4FF),
      hintStyle: const TextStyle(color: lightTextSecondary, fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDDE3EE), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.w800, fontSize: 28),
      headlineMedium: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.w700, fontSize: 24),
      titleLarge: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.w700, fontSize: 20),
      titleMedium: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.w600, fontSize: 16),
      bodyLarge: TextStyle(color: lightTextPrimary, fontSize: 15),
      bodyMedium: TextStyle(color: lightTextSecondary, fontSize: 13),
      labelSmall: TextStyle(color: lightTextSecondary, fontSize: 11),
    ),
  );
}