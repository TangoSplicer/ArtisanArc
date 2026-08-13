import 'package:flutter/material.dart';
import 'package:artisanarc/core/widgets/personal_app_bar.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../domain/daily_sales_service.dart';
import '../domain/business_service.dart';

class RevenueAnalyticsScreen extends StatefulWidget {
  const RevenueAnalyticsScreen({super.key});

  @override
  State<RevenueAnalyticsScreen> createState() => _RevenueAnalyticsScreenState();
}

class _RevenueAnalyticsScreenState extends State<RevenueAnalyticsScreen> {
  final DailySalesService _dailySalesService = GetIt.I<DailySalesService>();
  final BusinessService _businessService = GetIt.I<BusinessService>();
  
  Map<String, double> _monthlyRevenue = {};
  Map<String, double> _eventRevenue = {};
  double _totalRevenue = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    try {
      final monthlyData = await _dailySalesService.getRevenueByMonth();
      final eventData = await _dailySalesService.getRevenueByEvent();
      final sales = await _businessService.fetchSales();
      final total = _businessService.calculateTotalRevenue(sales);
      
      setState(() {
        _monthlyRevenue = monthlyData;
        _eventRevenue = eventData;
        _totalRevenue = total;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading analytics: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: PersonalAppBar(
        title: const Text('Revenue Analytics'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildTotalRevenueCard(theme),
                  const SizedBox(height: 16),
                  _buildMonthlyBreakdown(theme),
                  if (_eventRevenue.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildEventBreakdown(theme),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildTotalRevenueCard(ThemeData theme) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.account_balance_wallet,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Total Revenue',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '£${_totalRevenue.toStringAsFixed(2)}',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventBreakdown(ThemeData theme) {
    final events = _eventRevenue.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Event & Stall Sales', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            ...events.map((entry) => ListTile(
                  leading: const Icon(Icons.storefront_outlined),
                  title: Text(entry.key),
                  trailing: Text('£${entry.value.toStringAsFixed(2)}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyBreakdown(ThemeData theme) {
    final sortedMonths = _monthlyRevenue.keys.toList()..sort((a, b) => b.compareTo(a));
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Breakdown',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (sortedMonths.isEmpty)
              const Center(child: Text('No sales data available'))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedMonths.length,
                itemBuilder: (context, index) {
                  final month = sortedMonths[index];
                  final revenue = _monthlyRevenue[month]!;
                  final percentage = _totalRevenue > 0 ? (revenue / _totalRevenue) * 100 : 0.0;
                  
                  return ListTile(
                    title: Text(DateFormat('MMMM yyyy').format(DateTime.parse('$month-01'))),
                    subtitle: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: theme.colorScheme.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '£${revenue.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}