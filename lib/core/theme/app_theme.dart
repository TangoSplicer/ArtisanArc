import 'package:flutter/material.dart';

class AppTheme {
  static const ColorScheme _lightScheme = ColorScheme.light(
    primary: Color(0xFF5C4DB1),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFE7DEFF),
    onPrimaryContainer: Color(0xFF1E1248),
    secondary: Color(0xFF176A9C),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFCDE5FF),
    onSecondaryContainer: Color(0xFF001E31),
    tertiary: Color(0xFF78536A),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFFFD8E9),
    onTertiaryContainer: Color(0xFF2E1124),
    surface: Color(0xFFFFFBFF),
    onSurface: Color(0xFF1D1B20),
    surfaceVariant: Color(0xFFE7E0EC),
    onSurfaceVariant: Color(0xFF49454F),
    background: Color(0xFFF7F3FF),
    onBackground: Color(0xFF1D1B20),
    error: Color(0xFFB3261E),
    onError: Colors.white,
    outline: Color(0xFF79747E),
    outlineVariant: Color(0xFFCAC4D0),
  );

  static const ColorScheme _darkScheme = ColorScheme.dark(
    primary: Color(0xFFD0BCFF),
    onPrimary: Color(0xFF381E72),
    primaryContainer: Color(0xFF4F378B),
    onPrimaryContainer: Color(0xFFE9DDFF),
    secondary: Color(0xFFA8C8FF),
    onSecondary: Color(0xFF003258),
    secondaryContainer: Color(0xFF1B4A70),
    onSecondaryContainer: Color(0xFFD4E3FF),
    tertiary: Color(0xFFE9B8FF),
    onTertiary: Color(0xFF4B0A67),
    tertiaryContainer: Color(0xFF65377D),
    onTertiaryContainer: Color(0xFFF8D8FF),
    surface: Color(0xFF141218),
    onSurface: Color(0xFFE6E1E9),
    surfaceVariant: Color(0xFF49454F),
    onSurfaceVariant: Color(0xFFCAC4D0),
    background: Color(0xFF141218),
    onBackground: Color(0xFFE6E1E9),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    outline: Color(0xFF948F99),
    outlineVariant: Color(0xFF49454F),
  );

  static final ThemeData lightTheme = ThemeData(
    colorScheme: _lightScheme,
    scaffoldBackgroundColor: _lightScheme.background,
    textTheme: ThemeData.light()
        .textTheme
        .apply(
          bodyColor: _lightScheme.onSurface,
          displayColor: _lightScheme.onSurface,
        )
        .copyWith(
          headlineMedium: TextStyle(
            fontFamily: 'serif',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: _lightScheme.onSurface,
          ),
        ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF5C4DB1),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: _lightScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFFFFBFF),
    ),
    useMaterial3: true,
  );

  static final ThemeData darkTheme = ThemeData(
    colorScheme: _darkScheme,
    scaffoldBackgroundColor: _darkScheme.background,
    textTheme: ThemeData.dark()
        .textTheme
        .apply(
          bodyColor: _darkScheme.onSurface,
          displayColor: _darkScheme.onSurface,
        )
        .copyWith(
          headlineMedium: TextStyle(
            fontFamily: 'serif',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: _darkScheme.onSurface,
          ),
        ),
    appBarTheme: AppBarTheme(
      backgroundColor: _darkScheme.surface,
      foregroundColor: _darkScheme.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: _darkScheme.onSurface),
      titleTextStyle: TextStyle(
        color: _darkScheme.onSurface,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF1E1B24),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: Colors.black54,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF211F27),
      labelStyle: TextStyle(color: _darkScheme.onSurfaceVariant),
      floatingLabelStyle: TextStyle(color: _darkScheme.primary),
      hintStyle: TextStyle(color: _darkScheme.onSurfaceVariant),
      prefixIconColor: _darkScheme.onSurfaceVariant,
      suffixIconColor: _darkScheme.onSurfaceVariant,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _darkScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _darkScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _darkScheme.error),
      ),
    ),
    listTileTheme: ListTileThemeData(
      textColor: _darkScheme.onSurface,
      iconColor: _darkScheme.onSurfaceVariant,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: const Color(0xFF211F27),
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: _darkScheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: TextStyle(
        color: _darkScheme.onSurface,
        fontSize: 14,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF211F27),
      surfaceTintColor: Colors.transparent,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _darkScheme.surfaceVariant,
      contentTextStyle: TextStyle(color: _darkScheme.onSurface),
      actionTextColor: _darkScheme.primary,
    ),
    dividerTheme: DividerThemeData(color: _darkScheme.outlineVariant),
    iconTheme: IconThemeData(color: _darkScheme.onSurfaceVariant),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkScheme.primary,
        foregroundColor: _darkScheme.onPrimary,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _darkScheme.primary,
        side: BorderSide(color: _darkScheme.outline),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: _darkScheme.primary),
    ),
    useMaterial3: true,
  );
}
