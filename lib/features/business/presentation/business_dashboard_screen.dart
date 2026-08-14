import 'package:flutter/material.dart';
import 'package:artisanarc/core/widgets/personal_app_bar.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart'; // Added go_router
import '../domain/business_service.dart';
import '../data/sale_model.dart';
import '../data/stall_session_model.dart';
import '../domain/stall_session_service.dart';
// Screen imports are still needed if you pass arguments or for type safety,
// but not strictly for navigation if using named routes only.
// import 'daily_sales_screen.dart';
// import 'new_sale_entry_screen.dart';

class BusinessDashboardScreen extends StatefulWidget {
  const BusinessDashboardScreen({super.key});

  @override
  State<BusinessDashboardScreen> createState() =>
      _BusinessDashboardScreenState();
}

class _BusinessDashboardScreenState extends State<BusinessDashboardScreen> {
  final BusinessService _service = GetIt.I<BusinessService>();
  final StallSessionService _stallSessionService =
      GetIt.I<StallSessionService>();
  List<SaleRecord> _sales = [];
  StallSession? _activeSession;
  StallSessionSummary? _activeSummary;

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    final sales = await _service.fetchSales();
    final activeSession = await _stallSessionService.getActiveSession();
    final activeSummary = activeSession == null
        ? null
        : await _stallSessionService.getSummary(activeSession);
    if (!mounted) return;
    setState(() {
      _sales = sales;
      _activeSession = activeSession;
      _activeSummary = activeSummary;
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final totalRevenue = _service.calculateTotalRevenue(_sales);

    return Scaffold(
      appBar: PersonalAppBar(
        title: const Text('Business Tools'),
        backgroundColor: color.primary,
        foregroundColor: color.onPrimary,
        actions: [
          IconButton(
            onPressed: () {
              // Navigate using go_router's named route
              context.pushNamed('newSale');
            },
            icon: const Icon(Icons.add),
            tooltip: 'New Sale',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 4,
            child: ListTile(
              title: const Text('Total Revenue'),
              trailing: const Icon(Icons.trending_up),
              subtitle: Text('£${totalRevenue.toStringAsFixed(2)}'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: _activeSession == null
                ? color.primaryContainer
                : color.secondaryContainer,
            child: ListTile(
              leading: Icon(
                _activeSession == null
                    ? Icons.storefront
                    : Icons.play_circle_fill,
                color: _activeSession == null
                    ? color.onPrimaryContainer
                    : color.onSecondaryContainer,
              ),
              title: Text(
                _activeSession == null
                    ? 'Start Stall Session'
                    : 'Active: ${_activeSession!.name}',
                style: TextStyle(
                  color: _activeSession == null
                      ? color.onPrimaryContainer
                      : color.onSecondaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                _activeSession == null
                    ? 'Open an offline event session with basket sales and cash-up.'
                    : '£${_activeSummary?.netRevenue.toStringAsFixed(2) ?? '0.00'} recorded · tap to sell or cash-up.',
                style: TextStyle(
                  color: _activeSession == null
                      ? color.onPrimaryContainer
                      : color.onSecondaryContainer,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: _activeSession == null
                    ? color.onPrimaryContainer
                    : color.onSecondaryContainer,
              ),
              onTap: () async {
                await context.pushNamed('eventSales');
                _loadSales();
              },
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Revenue Analytics'),
            subtitle: const Text('View detailed revenue breakdown'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.pushNamed('revenueAnalytics');
            },
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            subtitle: const Text('Track sales by date'),
            title: const Text('View Daily Sales'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate using go_router's named route
              context.pushNamed('dailySales');
            },
          ),
        ],
      ),
    );
  }
}
