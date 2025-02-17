import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      // Ana renk şeması
      colorScheme: ColorScheme.light(
        primary: Colors.orange,
        secondary: Colors.orange.shade300,
        surface: Colors.white,
        onPrimary: Colors.white,
      ),

      // AppBar teması
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      // Buton teması
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),

      // Input teması
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orange),
        ),
      ),

      // Card teması
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
        color: Colors.white,
      ),

      // Bottom Navigation Bar teması
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
