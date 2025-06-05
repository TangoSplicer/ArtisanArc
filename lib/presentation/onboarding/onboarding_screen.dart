import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/utils/storage_keys.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final List<Widget> _pages = const [
    _OnboardingPage(
      title: 'Welcome to ArtisanArc',
      description: 'Your organised space for crafting, planning, and thriving.',
      icon: Icons.auto_awesome,
    ),
    _OnboardingPage(
      title: 'Track Your Inventory',
      description: 'Manage materials, swatches, and reorder with QR.',
      icon: Icons.inventory_2,
    ),
    _OnboardingPage(
      title: 'Plan Projects with Milestones',
      description: 'Build timelines and track your progress.',
      icon: Icons.timeline,
    ),
    _OnboardingPage(
      title: 'Grow Your Business',
      description: 'Log sales, check VAT, and generate reports.',
      icon: Icons.business_center,
    ),
  ];

  int _currentPage = 0;

  Future<void> _completeOnboarding() async {
    const storage = FlutterSecureStorage();
    await storage.write(key: StorageKeys.onboardingComplete, value: 'true');
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: _pages.length,
        onPageChanged: (i) => setState(() => _currentPage = i),
        itemBuilder: (context, index) => _pages[index],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentPage > 0)
              TextButton(
                onPressed: () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 300), curve: Curves.ease),
                child: const Text('Back'),
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: _currentPage == _pages.length - 1
                  ? _completeOnboarding
                  : () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 300), curve: Curves.ease),
              child: Text(_currentPage == _pages.length - 1 ? 'Get Started' : 'Next'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 100, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 40),
            Text(title, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text(description, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}