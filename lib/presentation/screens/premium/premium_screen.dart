import 'package:flutter/material.dart';
import '../../../core/utils/premium_checker.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Status'),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4.0,
              margin: const EdgeInsets.symmetric(vertical: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(Icons.verified_user, size: 60, color: theme.colorScheme.primary),
                    const SizedBox(height: 16.0),
                    Text(
                      'Personal Edition',
                      style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.primary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'All professional features are unlocked for your personal use. Enjoy the full power of ArtisanArc.',
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            _buildBenefitsSection(context, theme),
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
      'Offline-first architecture for total privacy.',
      'Export data in various formats.',
      'No advertisements or subscriptions.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Unlocked Features:',
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
                leading: Icon(Icons.check_circle, color: theme.colorScheme.primary),
                title: Text(benefits[index], style: theme.textTheme.bodyLarge),
              ),
            );
          },
        ),
      ],
    );
  }
}
