import 'package:flutter/material.dart';
import 'package:artisanarc/core/widgets/personal_app_bar.dart';
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
      appBar: PersonalAppBar(
        title: const Text('ArtisanArc Personal'),
        backgroundColor: color.primary,
        foregroundColor: color.onPrimary,
        actions: [
          IconButton(
            tooltip: 'Search items, projects and sales',
            onPressed: () => context.pushNamed('smartSearch'),
            icon: const Icon(Icons.search),
          ),
        ],
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
            Text('Quick actions',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            _buildQuickActions(context, color),
            const SizedBox(height: 20),
            _buildNavCard(
              context,
              title: 'Inventory · Created Items',
              subtitle: 'Keep a tally of finished makes that are ready to sell',
              icon: Icons.inventory_2,
              route: '/inventory',
              color: color.primary,
              onTap: () => _trackNavigation('inventory'),
            ),
            _buildNavCard(
              context,
              title: 'Materials Stock',
              subtitle:
                  'See yarn, hooks, notions, and supplies available to work with',
              icon: Icons.yard_outlined,
              route: '/stock',
              color: color.tertiary,
              onTap: () => _trackNavigation('materials_stock'),
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
            _buildNavCard(
              context,
              title: 'Crochet Make Recipes',
              subtitle:
                  'Reuse pattern references, hooks, gauge, materials, variants and making-time plans',
              icon: Icons.menu_book_outlined,
              route: '/make-recipes',
              color: Colors.purple,
              onTap: () => _trackNavigation('make_recipes'),
            ),
            _buildNavCard(
              context,
              title: 'Maker Collections & Capacity',
              subtitle:
                  'Plan seasonal ranges, track recipe targets, and verify weekly making capacity',
              icon: Icons.auto_awesome_outlined,
              route: '/collections',
              color: Colors.teal.shade700,
              onTap: () => _trackNavigation('maker_collections'),
            ),
            _buildNavCard(
              context,
              title: 'Maker Operations',
              subtitle:
                  'See local stock, orders, projects, stall context and seasonal work in one place',
              icon: Icons.dashboard_customize_outlined,
              route: '/operations',
              color: Colors.deepPurple,
              onTap: () => _trackNavigation('maker_operations'),
            ),
            _buildNavCard(
              context,
              title: 'Wholesale & Consignment',
              subtitle:
                  'Track shops, galleries, batches sent, sell-through, returns and settlement',
              icon: Icons.store_mall_directory_outlined,
              route: '/wholesale',
              color: Colors.brown.shade700,
              onTap: () => _trackNavigation('wholesale_ledger'),
            ),
            _buildNavCard(
              context,
              title: 'Crochet Stitch Library',
              subtitle:
                  'Offline reference guide for standard crochet stitches, abbreviations, and tips',
              icon: Icons.menu_book,
              route: '/stitches',
              color: Colors.pink.shade700,
              onTap: () => _trackNavigation('stitch_library'),
            ),
            _buildNavCard(
              context,
              title: 'Studio Equipment Ledger',
              subtitle:
                  'Track looms, ball winders, blocking mats, machinery and maintenance notes',
              icon: Icons.handyman_outlined,
              route: '/equipment',
              color: Colors.blueGrey.shade700,
              onTap: () => _trackNavigation('equipment_ledger'),
            ),
            _buildNavCard(
              context,
              title: 'UK Tax & Expenses',
              subtitle:
                  'Estimate Self Assessment tax, track allowable expenses, and monitor VAT thresholds',
              icon: Icons.calculate_outlined,
              route: '/tax',
              color: Colors.teal.shade800,
              onTap: () => _trackNavigation('tax_dashboard'),
            ),
            _buildNavCard(
              context,
              title: 'Commissions & Orders',
              subtitle:
                  'Keep private customer orders, deposits, due dates and linked projects together',
              icon: Icons.assignment_ind_outlined,
              route: '/commissions',
              color: Colors.indigo,
              onTap: () => _trackNavigation('commissions'),
            ),
            _buildNavCard(
              // Added Compliance Tracker card
              context,
              title: 'Compliance Tracker',
              subtitle: 'Manage safety certs, track standards',
              icon: Icons.verified_user, // Example Icon
              route: '/compliance',
              color: Colors.teal, // Example Color
              onTap: () => _trackNavigation('compliance'),
            ),
            _buildNavCard(
              // Added Smart Shopping card
              context,
              title: 'Smart Shopping',
              subtitle: 'Create supply lists and track what still needs buying',
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
              route: '/status',
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

  Widget _buildQuickActions(BuildContext context, ColorScheme color) {
    return Semantics(
      label: 'Quick actions',
      container: true,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _buildQuickAction(
            context,
            label: 'Add created item',
            icon: Icons.add_box_outlined,
            color: color.primary,
            routeName: 'addInventoryItem',
            usageKey: 'quick_add_finished',
          ),
          _buildQuickAction(
            context,
            label: 'Add material',
            icon: Icons.yard_outlined,
            color: color.tertiary,
            routeName: 'addMaterialStock',
            usageKey: 'quick_add_material',
          ),
          _buildQuickAction(
            context,
            label: 'Start stall',
            icon: Icons.storefront_outlined,
            color: color.secondary,
            routeName: 'eventSales',
            usageKey: 'quick_stall_session',
          ),
          _buildQuickAction(
            context,
            label: 'Plan project',
            icon: Icons.add_task_outlined,
            color: color.primary,
            routeName: 'addProject',
            usageKey: 'quick_add_project',
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required String routeName,
    required String usageKey,
  }) {
    final width = (MediaQuery.sizeOf(context).width - 50) / 2;
    return SizedBox(
      width: width,
      height: 64,
      child: OutlinedButton.icon(
        onPressed: () {
          _trackNavigation(usageKey);
          context.pushNamed(routeName);
        },
        icon: Icon(icon, color: color),
        label: Text(label, textAlign: TextAlign.center),
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12),
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
          context.push(route);
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
