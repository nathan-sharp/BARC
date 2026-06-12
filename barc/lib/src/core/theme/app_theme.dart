import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get retroDark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      primaryColor: const Color(0xFF00FF00), 
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF00FF00),
        secondary: Color(0xFFFFB000), 
        surface: Color(0xFF111111),
      ),
      textTheme: GoogleFonts.vt323TextTheme(ThemeData.dark().textTheme).copyWith(
        bodyLarge: GoogleFonts.vt323(color: const Color(0xFF00FF00), fontSize: 20),
        bodyMedium: GoogleFonts.vt323(color: const Color(0xFF00FF00), fontSize: 18),
        titleLarge: GoogleFonts.vt323(color: const Color(0xFF00FF00), fontSize: 28),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Color(0xFF00FF00),
        elevation: 0,
        shape: Border(bottom: BorderSide(color: Color(0xFF00FF00), width: 2)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: const Color(0xFF00FF00),
          side: const BorderSide(color: Color(0xFF00FF00), width: 2),
          shape: const BeveledRectangleBorder(),
          textStyle: GoogleFonts.vt323(fontSize: 24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.black,
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF00FF00), width: 2),
          borderRadius: BorderRadius.zero,
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF00FF00), width: 2),
          borderRadius: BorderRadius.zero,
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF00FF00), width: 3),
          borderRadius: BorderRadius.zero,
        ),
        labelStyle: GoogleFonts.vt323(color: const Color(0xFF00FF00)),
      ),
    );
  }
}
