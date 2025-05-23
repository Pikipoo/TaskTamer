import 'package:flutter/material.dart';

class AppTheme {
  static const Color _primaryColor = Color(0xFF6200EA);
  static const Color _secondaryColor = Color(0xFF03DAC6);
  static const Color _errorColor = Color(0xFFB00020);

  // Light theme colors
  static const Color _lightBackgroundColor = Color(0xFFF5F5F5);
  static const Color _lightSurfaceColor = Colors.white;
  static const Color _lightOnPrimaryColor = Colors.white;
  static const Color _lightOnSecondaryColor = Colors.black;
  static const Color _lightOnBackgroundColor = Colors.black87;
  static const Color _lightOnSurfaceColor = Colors.black87;

  // Dark theme colors
  static const Color _darkBackgroundColor = Color(0xFF121212);
  static const Color _darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color _darkPrimaryColor = Color(0xFFBB86FC);
  static const Color _darkOnPrimaryColor = Colors.black;
  static const Color _darkOnSecondaryColor = Colors.black;
  static const Color _darkOnBackgroundColor = Colors.white;
  static const Color _darkOnSurfaceColor = Colors.white;

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: _primaryColor,
      secondary: _secondaryColor,
      error: _errorColor,
      background: _lightBackgroundColor,
      surface: _lightSurfaceColor,
      onPrimary: _lightOnPrimaryColor,
      onSecondary: _lightOnSecondaryColor,
      onBackground: _lightOnBackgroundColor,
      onSurface: _lightOnSurfaceColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _primaryColor,
      foregroundColor: _lightOnPrimaryColor,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: _lightOnPrimaryColor,
        backgroundColor: _primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _primaryColor,
      foregroundColor: _lightOnPrimaryColor,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _lightSurfaceColor,
      selectedItemColor: _primaryColor,
      unselectedItemColor: Colors.grey,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: _darkPrimaryColor,
      secondary: _secondaryColor,
      error: _errorColor,
      background: _darkBackgroundColor,
      surface: _darkSurfaceColor,
      onPrimary: _darkOnPrimaryColor,
      onSecondary: _darkOnSecondaryColor,
      onBackground: _darkOnBackgroundColor,
      onSurface: _darkOnSurfaceColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _darkSurfaceColor,
      foregroundColor: _darkOnSurfaceColor,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: _darkOnPrimaryColor,
        backgroundColor: _darkPrimaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _darkPrimaryColor,
      foregroundColor: _darkOnPrimaryColor,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _darkSurfaceColor,
      selectedItemColor: _darkPrimaryColor,
      unselectedItemColor: Colors.grey,
    ),
  );
}
