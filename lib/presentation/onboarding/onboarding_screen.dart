import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/sample_data_service.dart';
import '../../core/utils/storage_keys.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _loadStarterData = true;
  bool _isCompleting = false;

  static const _pages = [
    _OnboardingContent(
      title: 'Welcome to ArtisanArc Personal',
      description: 'A private, offline workspace for crochet, knitting, and the rest of your making life.',
      icon: Icons.auto_awesome,
    ),
    _OnboardingContent(
      title: '1. Add stock you can find',
      description: 'Start in Inventory. Save yarn, hooks, needles, finished makes, prices, and where each item lives. Use the search buttons whenever a list gets long.',
      icon: Icons.inventory_2,
    ),
    _OnboardingContent(
      title: '2. Turn an idea into a project',
      description: 'Use Projects to choose a craft, add milestones, and note the supplies you need. The planner can search your saved inventory when you add a supply.',
      icon: Icons.timeline,
    ),
    _OnboardingContent(
      title: '3. Sell quickly at a table or stall',
      description: 'Open Business Tools and choose On-the-day Sales. Tap + as an item sells, then save once. Stock reduces and the sale appears in daily totals, analytics, and exports.',
      icon: Icons.storefront,
    ),
    _OnboardingContent(
      title: '4. Review, export, and move around',
      description: 'Reports and exports use the sales you record. The app Back arrow and your device Back button return to the previous screen; Home always returns to your main dashboard.',
      icon: Icons.insights,
    ),
    _OnboardingContent(
      title: 'Choose your starting point',
      description: 'You can begin with an empty app, or load fictional crochet and knitting examples to see the complete workflow straight away. Starter data can be cleared from Settings at any time.',
      icon: Icons.playlist_add_check,
      showsStarterDataChoice: true,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    if (_isCompleting) return;
    setState(() => _isCompleting = true);

    try {
      if (_loadStarterData && !await SampleDataService.hasCraftData()) {
        await SampleDataService.loadStarterData();
      }
      const storage = FlutterSecureStorage();
      await storage.write(key: StorageKeys.onboardingComplete, value: 'true');
      if (mounted) context.go('/home');
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not complete setup: $error')));
        setState(() => _isCompleting = false);
      }
    }
  }

  void _nextPage() {
    _pageController.nextPage(duration: const Duration(milliseconds: 260), curve: Curves.easeOutCubic);
  }

  void _previousPage() {
    _pageController.previousPage(duration: const Duration(milliseconds: 260), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final isFinalPage = _currentPage == _pages.length - 1;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) => _OnboardingPage(
                  content: _pages[index],
                  loadStarterData: _loadStarterData,
                  onStarterDataChanged: (value) => setState(() => _loadStarterData = value),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: index == _currentPage ? 22 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: index == _currentPage ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            if (_currentPage > 0)
              TextButton.icon(
                onPressed: _previousPage,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
              )
            else
              const SizedBox(width: 80),
            const Spacer(),
            FilledButton.icon(
              onPressed: _isCompleting ? null : (isFinalPage ? _completeOnboarding : _nextPage),
              icon: _isCompleting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(isFinalPage ? Icons.check : Icons.arrow_forward),
              label: Text(isFinalPage ? (_loadStarterData ? 'Start with sample data' : 'Start empty') : 'Next'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingContent {
  final String title;
  final String description;
  final IconData icon;
  final bool showsStarterDataChoice;

  const _OnboardingContent({
    required this.title,
    required this.description,
    required this.icon,
    this.showsStarterDataChoice = false,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingContent content;
  final bool loadStarterData;
  final ValueChanged<bool> onStarterDataChanged;

  const _OnboardingPage({
    required this.content,
    required this.loadStarterData,
    required this.onStarterDataChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 56,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(content.icon, size: 56, color: theme.colorScheme.onPrimaryContainer),
            ),
            const SizedBox(height: 36),
            Text(content.title, style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text(content.description, style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
            if (content.showsStarterDataChoice) ...[
              const SizedBox(height: 28),
              Card(
                child: CheckboxListTile(
                  value: loadStarterData,
                  onChanged: (value) => onStarterDataChanged(value ?? false),
                  title: const Text('Load starter sample data'),
                  subtitle: const Text('Includes fictional yarn, finished makes, a crochet project, shopping list, and makers-market sales.'),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
