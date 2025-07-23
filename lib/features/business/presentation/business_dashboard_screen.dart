import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart'; // Added go_router
import '../domain/business_service.dart';
import '../data/sale_model.dart';
// Screen imports are still needed if you pass arguments or for type safety,
// but not strictly for navigation if using named routes only.
// import 'daily_sales_screen.dart';
// import 'new_sale_entry_screen.dart';

class BusinessDashboardScreen extends StatefulWidget {
  const BusinessDashboardScreen({super.key});

  @override
  State<BusinessDashboardScreen> createState() => _BusinessDashboardScreenState();
}

class _BusinessDashboardScreenState extends State<BusinessDashboardScreen> {
  final BusinessService _service = GetIt.I<BusinessService>();
  List<SaleRecord> _sales = [];

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    final sales = await _service.fetchSales();
    setState(() => _sales = sales);
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final totalRevenue = _service.calculateTotalRevenue(_sales);

    return Scaffold(
      appBar: AppBar(
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 4,
            child: ListTile(
              title: const Text('Total Revenue'),
              subtitle: Text('£${totalRevenue.toStringAsFixed(2)}'),
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.calendar_today),
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