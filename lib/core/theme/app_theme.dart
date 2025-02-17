import 'package:flutter/material.dart';

class AppTheme {
  // Ana renkler
  static const Color primaryColor = Color(0xFFFF6600); // #FF6600
  static const Color primaryLightColor =
      Color(0xFFFF8C42); // FF6600'nin açık tonu
  static const Color primaryDarkColor =
      Color(0xFFCC5200); // FF6600'nin koyu tonu

  // Nötr renkler
  static const Color backgroundColor = Colors.white;
  static const Color surfaceColor = Colors.white;
  static final Color textPrimaryColor = Colors.grey.shade900;
  static final Color textSecondaryColor = Colors.grey.shade600;

  // Yardımcı renkler
  static final Color errorColor = Colors.red.shade400;
  static const Color successColor = Colors.green;

  static ThemeData get theme {
    return ThemeData(
      // Ana renk şeması
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: primaryLightColor,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: Colors.white,
      ),

      // AppBar teması
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      // Buton teması
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
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
        fillColor: surfaceColor,
        prefixIconColor: primaryColor,
        suffixIconColor: primaryColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: primaryColor),
        ),
        labelStyle: TextStyle(color: textSecondaryColor),
        hintStyle: TextStyle(color: textSecondaryColor),
      ),

      // IconButton teması
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: primaryColor,
        ),
      ),

      // TextButton teması
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
        ),
      ),

      // Card teması
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
        color: surfaceColor,
      ),

      // Bottom Navigation Bar teması
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
