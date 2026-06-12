import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData getTheme(Brightness brightness, String fontFamily) {
    if (brightness == Brightness.dark) {
      return whatsappDark(fontFamily);
    }
    return whatsappLight(fontFamily);
  }

  static ThemeData whatsappLight(String fontFamily) {
    return ThemeData(
      brightness: Brightness.light,
      fontFamily: fontFamily == 'Default' ? null : fontFamily,
      scaffoldBackgroundColor: const Color(0xFFECE5DD),
      primaryColor: const Color(0xFF128C7E),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF128C7E),
        secondary: Color(0xFF25D366),
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF128C7E),
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF128C7E),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFF128C7E), width: 2),
        ),
      ),
    );
  }

  static ThemeData whatsappDark(String fontFamily) {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: fontFamily == 'Default' ? null : fontFamily,
      scaffoldBackgroundColor: const Color(0xFF0B141A),
      primaryColor: const Color(0xFF1F2C34),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF00A884),
        secondary: Color(0xFF00A884),
        surface: Color(0xFF1F2C34),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1F2C34),
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00A884),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A3942),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFF00A884), width: 2),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        textColor: Colors.white,
        iconColor: Colors.white70,
      ),
    );
  }
}
