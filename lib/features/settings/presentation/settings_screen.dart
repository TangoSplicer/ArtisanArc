import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // Added url_launcher

import '../../../core/services/theme_service.dart';
import '../../../core/services/backup_service.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/utils/storage_keys.dart';
import '../domain/settings_service.dart';

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
    // Theme is now managed by ThemeService and Provider, initial load happens in main.dart
    // We can still get the current theme for initial UI state if needed, but updates are reactive.
    if (mounted) { // Check if the widget is still in the tree
      setState(() {
        _selectedLocale = locale ?? 'en_GB';
        _isVATRegistered = vat;
        // _themeMode is now directly from the provider in the build method
      });
    }
  }

  void _updateTheme(ThemeMode? mode) { // Changed to accept ThemeMode? for RadioListTile
    if (mode != null) {
      // Use Provider to access ThemeService and update the theme
      Provider.of<ThemeService>(context, listen: false).setThemeMode(mode);
      // No need to call setState here for _themeMode as the widget will rebuild
      // when the ThemeService notifies listeners and ArtisanArcApp rebuilds.
      // However, if _themeMode is used to control the RadioListTile's groupValue directly,
      // then it might need to be updated via a listener or Consumer.
      // For simplicity, we'll rely on the build method to get the current theme.
    }
  }

  // _reloadAppWithTheme and the runApp call are no longer needed.

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    // Get the current theme mode from the provider for the RadioListTile groupValue
    final currentThemeMode = Provider.of<ThemeService>(context).currentThemeMode;

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
                    groupValue: currentThemeMode, // Use theme from provider
                    onChanged: _updateTheme,
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Light'),
                    value: ThemeMode.light,
                    groupValue: currentThemeMode, // Corrected to use currentThemeMode
                    onChanged: _updateTheme,
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Dark'),
                    value: ThemeMode.dark,
                    groupValue: currentThemeMode, // Corrected to use currentThemeMode
                    onChanged: _updateTheme,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card( // Added Backup & Restore Card
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 5,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.backup),
                    title: const Text('Backup Data'),
                    subtitle: const Text('Export all your data to a file'),
                    onTap: _exportBackup,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.restore),
                    title: const Text('Restore Data'),
                    subtitle: const Text('Import data from a backup file'),
                    onTap: _importBackup,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card( // Added Analytics Card
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 5,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.analytics),
                    title: const Text('Usage Analytics'),
                    subtitle: const Text('View your app usage patterns'),
                    onTap: _showAnalytics,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.delete_sweep),
                    title: const Text('Clear Analytics'),
                    subtitle: const Text('Remove all usage data'),
                    onTap: _clearAnalytics,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card( // Added Feedback Card
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 5,
              child: ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Send Feedback'),
                subtitle: const Text('Report issues or suggest features'),
                onTap: _sendFeedbackEmail,
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

  Future<void> _sendFeedbackEmail() async {
    const String recipientEmail = 'feedback@artisanarc.app'; // Replace with your actual feedback email
    const String emailSubject = 'ArtisanArc App Feedback';

    final Uri mailtoUri = Uri(
      scheme: 'mailto',
      path: recipientEmail,
      queryParameters: {
        'subject': emailSubject,
        // 'body': 'Device Info:\nOS: ${Platform.operatingSystem}\nVersion: ${Platform.operatingSystemVersion}\n\nFeedback:\n', // Example prefilled body
      },
    );

    try {
      // Attempt to launch the mailto URI
      if (await canLaunchUrl(mailtoUri)) {
        await launchUrl(mailtoUri);
      } else {
        // If mailto scheme is not supported, try to launch a generic URL to a feedback page or show error
        // For this example, we'll just show a snackbar if mailto fails.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open email app. Please send feedback manually to $recipientEmail')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    }
  }

  Future<void> _exportBackup() async {
    try {
      await BackupService.exportBackup();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup exported successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting backup: $e')),
        );
      }
    }
  }

  Future<void> _importBackup() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Backup'),
        content: const Text('This will replace all current data. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final success = await BackupService.importBackup();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? 'Backup imported successfully!' : 'Import cancelled'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error importing backup: $e')),
          );
        }
      }
    }
  }

  Future<void> _showAnalytics() async {
    final analytics = await AnalyticsService.getUsageAnalytics();
    
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Usage Analytics'),
          content: SizedBox(
            width: double.maxFinite,
            child: analytics.isEmpty
                ? const Text('No usage data available yet.')
                : ListView(
                    shrinkWrap: true,
                    children: analytics.entries.map((entry) {
                      final feature = entry.key;
                      final usage = entry.value as Map<String, dynamic>;
                      final totalUsage = usage.values.fold<int>(0, (sum, count) => sum + (count as int));
                      
                      return ListTile(
                        title: Text(feature),
                        trailing: Text('$totalUsage uses'),
                      );
                    }).toList(),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _clearAnalytics() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Analytics'),
        content: const Text('Are you sure you want to clear all usage analytics?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AnalyticsService.clearAnalytics();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Analytics cleared')),
        );
      }
    }
  }
}