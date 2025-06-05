import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeService {
  static const _themeKey = 'artisanarc_theme_mode';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> setThemeMode(ThemeMode mode) async {
    final value = mode == ThemeMode.dark
        ? 'dark'
        : mode == ThemeMode.light
            ? 'light'
            : 'system';
    await _storage.write(key: _themeKey, value: value);
  }

  Future<ThemeMode> getThemeMode() async {
    final value = await _storage.read(key: _themeKey);
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }
}