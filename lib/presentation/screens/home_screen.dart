import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ArtisanArc Home'),
        backgroundColor: color.primary,
        foregroundColor: color.onPrimary,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              color.surface,
              color.background,
              color.primary.withOpacity(0.1),
            ],
            radius: 1.4,
            center: Alignment.topLeft,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildNavCard(
              context,
              title: 'Inventory',
              subtitle: 'Organise materials, assign QR, price & storage',
              icon: Icons.inventory_2,
              route: '/inventory',
              color: color.primary,
            ),
            _buildNavCard(
              context,
              title: 'Business Tools',
              subtitle: 'Track sales, check VAT, analyse performance',
              icon: Icons.business_center,
              route: '/business',
              color: color.secondary,
            ),
            _buildNavCard(
              context,
              title: 'Project Planner',
              subtitle: 'Build timelines, track milestones, link materials',
              icon: Icons.timeline,
              route: '/projects',
              color: color.tertiary,
            ),
            _buildNavCard(
              context,
              title: 'Reports & Export',
              subtitle: 'Print labels, export to PDF/CSV, review history',
              icon: Icons.print,
              route: '/export',
              color: Colors.deepPurpleAccent,
            ),
            _buildNavCard(
              context,
              title: 'Settings',
              subtitle: 'Language, theme, onboarding preferences',
              icon: Icons.settings,
              route: '/settings',
              color: color.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String route,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: Card(
        elevation: 6,
        margin: const EdgeInsets.only(bottom: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        shadowColor: color.withOpacity(0.4),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: color.withOpacity(0.08),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}