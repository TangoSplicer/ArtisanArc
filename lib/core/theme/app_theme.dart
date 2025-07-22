import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF6A5ACD), // SlateBlue
      secondary: Color(0xFF4682B4), // SteelBlue
      tertiary: Color(0xFFB0C4DE), // LightSteelBlue
      surface: Color(0xFFF0F8FF),   // AliceBlue
      background: Color(0xFFFFFFFF), // White
      error: Colors.redAccent,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: Colors.black,
      onSurface: Colors.black87,
      onBackground: Colors.black87,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFFF0F8FF),
    textTheme: GoogleFonts.workSansTextTheme().copyWith(
      headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF6A5ACD),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
    ),
    useMaterial3: true,
  );

  static final ThemeData darkTheme = ThemeData(
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF6A5ACD), // SlateBlue
      secondary: Color(0xFF4682B4), // SteelBlue
      tertiary: Color(0xFFB0C4DE), // LightSteelBlue
      surface: Color(0xFF121212),   // Dark Surface
      background: Color(0xFF121212), // Dark Background
      error: Colors.redAccent,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: Colors.black,
      onSurface: Colors.white,
      onBackground: Colors.white,
      onError: Colors.black,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    textTheme: GoogleFonts.workSansTextTheme().copyWith(
      headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF6A5ACD),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
    ),
    useMaterial3: true,
  );
}