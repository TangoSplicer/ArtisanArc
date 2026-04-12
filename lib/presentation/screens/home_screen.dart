import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/inventory/presentation/low_stock_widget.dart';
import '../../core/services/analytics_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _trackNavigation(String feature) {
    AnalyticsService.trackFeatureUsage(feature);
  }

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
            const LowStockWidget(),
            const SizedBox(height: 20),
            _buildNavCard(
              context,
              title: 'Inventory',
              subtitle: 'Organise materials, assign QR, price & storage',
              icon: Icons.inventory_2,
              route: '/inventory',
              color: color.primary,
              onTap: () => _trackNavigation('inventory'),
            ),
            _buildNavCard(
              context,
              title: 'Business Tools',
              subtitle: 'Track sales, check VAT, analyse performance',
              icon: Icons.business_center,
              route: '/business',
              color: color.secondary,
              onTap: () => _trackNavigation('business'),
            ),
            _buildNavCard(
              context,
              title: 'Project Planner',
              subtitle: 'Build timelines, track milestones, link materials',
              icon: Icons.timeline,
              route: '/projects',
              color: color.tertiary,
              onTap: () => _trackNavigation('projects'),
            ),
            _buildNavCard( // Added Compliance Tracker card
              context,
              title: 'Compliance Tracker',
              subtitle: 'Manage safety certs, track standards',
              icon: Icons.shield_check_outlined, // Example Icon
              route: '/compliance',
              color: Colors.teal, // Example Color
              onTap: () => _trackNavigation('compliance'),
            ),
             _buildNavCard( // Added Smart Shopping card
              context,
              title: 'Smart Shopping',
              subtitle: 'Create lists, track needs, (future: compare prices)',
              icon: Icons.shopping_cart_checkout,
              route: '/shopping-lists', // Route to overview
              color: Colors.orangeAccent,
              onTap: () => _trackNavigation('shopping'),
            ),
            _buildNavCard(
              context,
              title: 'Reports & Export',
              subtitle: 'Print labels, export to PDF/CSV, review history',
              icon: Icons.print,
              route: '/export',
              color: Colors.deepPurpleAccent,
              onTap: () => _trackNavigation('export'),
            ),
            _buildNavCard(
              context,
              title: 'App Status',
              subtitle: 'Personal Edition - All features unlocked',
              icon: Icons.verified_user,
              route: '/premium',
              color: Colors.amber,
              onTap: () => _trackNavigation('status'),
            ),
            _buildNavCard(
              context,
              title: 'Settings',
              subtitle: 'Language, theme, onboarding preferences',
              icon: Icons.settings,
              route: '/settings',
              color: color.error,
              onTap: () => _trackNavigation('settings'),
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
    VoidCallback? onTap,
  }) {
    return Card(
        elevation: 6,
        margin: const EdgeInsets.only(bottom: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        shadowColor: color.withOpacity(0.4),
        child: InkWell(
          onTap: () {
            onTap?.call();
            context.go(route);
          },
          borderRadius: BorderRadius.circular(20),
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
