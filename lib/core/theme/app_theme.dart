import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFC9BBE5), // Lavender
      secondary: Color(0xFFE7BFD6), // Rose Quartz
      surface: Color(0xFFF6F4F9),   // Pearl White
      background: Color(0xFFF6F4F9),
      error: Colors.redAccent,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: Colors.black87,
      onBackground: Colors.black87,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFFF6F4F9),
    textTheme: GoogleFonts.workSansTextTheme().copyWith(
      headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFC9BBE5),
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
    ),
    useMaterial3: true,
  );
}