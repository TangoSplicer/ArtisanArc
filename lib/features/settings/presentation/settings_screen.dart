import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../../../core/services/theme_service.dart';
import '../../../core/utils/storage_keys.dart';
import '../../domain/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _service = GetIt.I<SettingsService>();
  final _storage = const FlutterSecureStorage();
  final ThemeService _themeService = ThemeService();

  String _selectedLocale = 'en_GB';
  bool _isVATRegistered = false;
  bool _resetOnboarding = false;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final locale = await _service.getCurrentLocale();
    final vat = await _service.isVATRegistered();
    final theme = await _themeService.getThemeMode();

    setState(() {
      _selectedLocale = locale ?? 'en_GB';
      _isVATRegistered = vat;
      _themeMode = theme;
    });
  }

  void _updateTheme(ThemeMode mode) async {
    await _themeService.setThemeMode(mode);
    setState(() => _themeMode = mode);
    // Trigger rebuild by restarting app tree
    runApp(await _reloadAppWithTheme(mode));
  }

  Future<Widget> _reloadAppWithTheme(ThemeMode mode) async {
    final seenOnboarding = await _storage.read(key: StorageKeys.onboardingComplete) == 'true';
    return ArtisanArcApp(seenOnboarding: seenOnboarding, themeMode: mode);
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: color.primary,
        foregroundColor: color.onPrimary,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [color.surface, color.background, color.primary.withOpacity(0.06)],
            center: Alignment.center,
            radius: 1.2,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Language & Region', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      value: _selectedLocale,
                      isExpanded: true,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedLocale = value);
                          _service.changeLocale(value);
                        }
                      },
                      items: const [
                        DropdownMenuItem(value: 'en_GB', child: Text('English (UK)')),
                        DropdownMenuItem(value: 'en_US', child: Text('English (US)')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 5,
              child: SwitchListTile(
                title: const Text('VAT Registered?'),
                value: _isVATRegistered,
                onChanged: (value) {
                  setState(() => _isVATRegistered = value);
                  _service.updateVATStatus(value);
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 5,
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Theme'),
                    subtitle: const Text('Light, Dark or System Default'),
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('System Default'),
                    value: ThemeMode.system,
                    groupValue: _themeMode,
                    onChanged: _updateTheme,
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Light'),
                    value: ThemeMode.light,
                    groupValue: _themeMode,
                    onChanged: _updateTheme,
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Dark'),
                    value: ThemeMode.dark,
                    groupValue: _themeMode,
                    onChanged: _updateTheme,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 5,
              child: SwitchListTile(
                title: const Text('Restart Onboarding'),
                subtitle: const Text('View the welcome tour again on next launch'),
                value: _resetOnboarding,
                onChanged: (value) async {
                  if (value) {
                    await _storage.delete(key: StorageKeys.onboardingComplete);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Onboarding will restart on next launch.')),
                    );
                  }
                  setState(() => _resetOnboarding = value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}