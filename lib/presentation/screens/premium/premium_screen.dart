import 'package:flutter/material.dart';
import '../../../core/utils/premium_checker.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _unlocked = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final result = await PremiumChecker.isPremiumUnlocked();
    setState(() => _unlocked = result);
  }

  Future<void> _unlock() async {
    await PremiumChecker.unlockPremium();
    setState(() => _unlocked = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Premium unlocked!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Go Premium'),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_unlocked)
              Card(
                elevation: 4.0,
                margin: const EdgeInsets.symmetric(vertical: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(Icons.star, size: 60, color: theme.colorScheme.primary),
                      const SizedBox(height: 16.0),
                      Text(
                        'Premium Unlocked!',
                        style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.primary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Thank you for supporting ArtisanArc! You now have access to all premium features.',
                        style: theme.textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              _buildUpgradeSection(context, theme),
            const SizedBox(height: 24.0),
            _buildBenefitsSection(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeSection(BuildContext context, ThemeData theme) {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Unlock All Features',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            Text(
              'Support the development of ArtisanArc and get access to exclusive premium features.',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),
            ElevatedButton.icon(
              icon: const Icon(Icons.lock_open),
              label: const Text('Unlock Premium Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                textStyle: theme.textTheme.titleMedium,
              ),
              onPressed: _unlock,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsSection(BuildContext context, ThemeData theme) {
    final benefits = [
      'Advanced AI-powered suggestions and analytics.',
      'Unlimited project and inventory management.',
      'In-depth business performance tracking.',
      'Customizable compliance and labeling options.',
      'Priority support and early access to new features.',
      'Export data in various formats.',
      'No advertisements, ever.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Premium Benefits:',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16.0),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: benefits.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 2.0,
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                leading: Icon(Icons.check_circle_outline, color: theme.colorScheme.secondary),
                title: Text(benefits[index], style: theme.textTheme.bodyLarge),
              ),
            );
          },
        ),
      ],
    );
  }
}