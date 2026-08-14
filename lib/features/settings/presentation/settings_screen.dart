import 'package:flutter/material.dart';
import 'package:artisanarc/core/widgets/personal_app_bar.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // Added url_launcher

import '../../../core/services/theme_service.dart';
import '../../../core/widgets/searchable_selection_field.dart';
import '../../../core/services/backup_service.dart';
import '../../../core/services/sample_data_service.dart';
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
  AutomaticSnapshotInfo? _latestSnapshot;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadLatestSnapshot();
  }

  Future<void> _loadLatestSnapshot() async {
    final snapshot = await BackupService.latestAutomaticSnapshot();
    if (mounted) setState(() => _latestSnapshot = snapshot);
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
      appBar: PersonalAppBar(
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
                    SearchableSelectionField<String>(
                      options: const ['en_GB', 'en_US'],
                      value: _selectedLocale,
                      labelText: 'Language and region',
                      hintText: 'Search language or region',
                      itemLabel: (locale) => locale == 'en_GB' ? 'English (UK)' : 'English (US)',
                      itemSubtitle: (locale) => locale == 'en_GB' ? 'Pound sterling and UK date formats' : 'US date formats',
                      searchTerms: (locale) => [locale, 'English', locale == 'en_GB' ? 'United Kingdom Britain UK' : 'United States America US'],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedLocale = value);
                          _service.changeLocale(value);
                        }
                      },
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
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 5,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.shield_outlined),
                    title: const Text('Automatic Safety Snapshots'),
                    subtitle: Text(
                      _latestSnapshot == null
                          ? 'A rotating local snapshot is created after craft data is available.'
                          : 'Latest: ${_latestSnapshot!.description}. The five newest snapshots are retained on this device.',
                    ),
                    trailing: IconButton(
                      tooltip: 'Create safety snapshot now',
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: _createSafetySnapshot,
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.ios_share_outlined),
                    title: const Text('Export Portable Backup'),
                    subtitle: const Text('Create a shareable protected copy of your craft data.'),
                    onTap: _exportBackup,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.restore),
                    title: const Text('Restore Portable Backup'),
                    subtitle: const Text('Preview the backup before replacing local craft data.'),
                    onTap: _importBackup,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 5,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.auto_awesome_outlined),
                    title: const Text('Load Starter Sample Data'),
                    subtitle: const Text('Add crochet and knitting stock, a project, a shopping list, and market sales.'),
                    onTap: _loadStarterData,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.delete_forever_outlined, color: color.error),
                    title: Text('Clear Craft Data', style: TextStyle(color: color.error)),
                    subtitle: const Text('Remove inventory, sales, projects, shopping lists, and compliance records.'),
                    onTap: _clearCraftData,
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

  Future<void> _createSafetySnapshot() async {
    try {
      final snapshot = await BackupService.createAutomaticSnapshot(reason: 'created from Settings');
      if (!mounted) return;
      setState(() => _latestSnapshot = snapshot);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(snapshot == null ? 'There is no craft data to snapshot yet.' : 'Safety snapshot created.')),
      );
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not create a safety snapshot: $error')));
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
    try {
      final preview = await BackupService.pickBackupForRestore();
      if (preview == null || !mounted) return;

      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Restore Portable Backup'),
          content: Text(
            'Backup created: ${preview.createdAt.toLocal()}\n\nIncludes: ${preview.includedBoxes.join(', ')}\n\nYour current data will first be protected in a new automatic safety snapshot. Restoring requires you to close and reopen ArtisanArc afterwards.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            FilledButton.tonal(onPressed: () => Navigator.pop(context, true), child: const Text('Restore & Restart')),
          ],
        ),
      );

      if (confirm != true) return;
      await BackupService.restorePortableBackup(preview);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup restored. Close and reopen ArtisanArc to load the restored data.')),
        );
      }
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not restore backup: $error')));
    }
  }

  Future<void> _loadStarterData() async {
    final hasExistingData = await SampleDataService.hasCraftData();
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Load Starter Sample Data'),
        content: Text(
          hasExistingData
              ? 'This will replace your current inventory, sales, projects, shopping lists, and compliance records with fictional crochet and knitting examples. Create a backup first if you want to keep your current data.'
              : 'This adds fictional crochet and knitting inventory, a project, a shopping list, and a makers-market sales example. You can clear it later in Settings.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(hasExistingData ? 'Replace & Load' : 'Load Data')),
        ],
      ),
    );

    if (confirmed != true) return;
    try {
      await SampleDataService.loadStarterData(replaceExisting: hasExistingData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Starter data loaded. Explore Inventory, Projects, Business Tools, and Shopping.')),
        );
      }
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not load starter data: $error')));
    }
  }

  Future<void> _clearCraftData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Craft Data'),
        content: const Text('This permanently removes inventory, sales, projects, shopping lists, and compliance records from this device. Create a backup first if you may need them again.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await SampleDataService.clearCraftData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Craft data cleared.')));
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