import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeService with ChangeNotifier {
  static const _themeKey = 'artisanarc_theme_mode';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ThemeMode _themeMode = ThemeMode.system; // Add a private field to hold the current theme

  ThemeMode get currentThemeMode => _themeMode; // Getter for the current theme

  Future<void> setThemeMode(ThemeMode mode) async {
    final value = mode == ThemeMode.dark
        ? 'dark'
        : mode == ThemeMode.light
            ? 'light'
            : 'system';
    await _storage.write(key: _themeKey, value: value);
    _themeMode = mode; // Update the internal state
    notifyListeners(); // Notify listeners about the change
  }

  Future<void> loadThemeMode() async { // Renamed from getThemeMode to avoid confusion
    final value = await _storage.read(key: _themeKey);
    switch (value) {
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      default:
        _themeMode = ThemeMode.system;
        break;
    }
    notifyListeners(); // Notify listeners after loading the theme
  }
}