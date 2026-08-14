import 'package:flutter/material.dart';
import 'package:artisanarc/core/widgets/personal_app_bar.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../domain/daily_sales_service.dart';
import '../domain/business_service.dart';
import '../domain/profit_reporting_service.dart';

class RevenueAnalyticsScreen extends StatefulWidget {
  const RevenueAnalyticsScreen({super.key});

  @override
  State<RevenueAnalyticsScreen> createState() => _RevenueAnalyticsScreenState();
}

class _RevenueAnalyticsScreenState extends State<RevenueAnalyticsScreen> {
  final DailySalesService _dailySalesService = GetIt.I<DailySalesService>();
  final BusinessService _businessService = GetIt.I<BusinessService>();
  final ProfitReportingService _profitReportingService =
      GetIt.I<ProfitReportingService>();

  Map<String, double> _monthlyRevenue = {};
  Map<String, double> _eventRevenue = {};
  double _totalRevenue = 0.0;
  ProfitSummary? _profitSummary;
  List<ItemPerformance> _itemPerformance = [];
  List<SessionProfitSummary> _sessionProfitability = [];
  List<StockMovement> _stockMovements = [];
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
      final profitSummary = await _profitReportingService.getSummary();
      final itemPerformance =
          await _profitReportingService.getItemPerformance();
      final sessionProfitability =
          await _profitReportingService.getSessionProfitability();
      final stockMovements =
          await _profitReportingService.getFinishedItemMovements();

      if (!mounted) return;
      setState(() {
        _monthlyRevenue = monthlyData;
        _eventRevenue = eventData;
        _totalRevenue = total;
        _profitSummary = profitSummary;
        _itemPerformance = itemPerformance;
        _sessionProfitability = sessionProfitability;
        _stockMovements = stockMovements;
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
                  if (_profitSummary != null) ...[
                    const SizedBox(height: 16),
                    _buildProfitCard(theme),
                  ],
                  const SizedBox(height: 16),
                  _buildMonthlyBreakdown(theme),
                  if (_eventRevenue.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildEventBreakdown(theme),
                  ],
                  if (_itemPerformance.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildItemPerformance(theme),
                  ],
                  if (_sessionProfitability.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildSessionProfitability(theme),
                  ],
                  if (_stockMovements.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildStockMovements(theme),
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

  Widget _buildProfitCard(ThemeData theme) {
    final summary = _profitSummary!;
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Material Cost & Gross Profit',
                style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            _metricRow('Material cost of sales', summary.materialCostOfSales),
            _metricRow('Gross profit', summary.grossProfit, bold: true),
            _metricRow('Gross margin', summary.marginPercent,
                prefix: '', suffix: '%', bold: true),
            if (summary.hasUnknownCosts) ...[
              const SizedBox(height: 8),
              Text(
                'Some sales have no linked production-cost snapshot yet. Their revenue is included, but their material cost is shown as £0.00 until you complete future makes through a project.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _metricRow(String label, double value,
      {String prefix = '£', String suffix = '', bool bold = false}) {
    final style = bold ? const TextStyle(fontWeight: FontWeight.bold) : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text('$prefix${value.toStringAsFixed(2)}$suffix', style: style),
        ],
      ),
    );
  }

  Widget _buildItemPerformance(ThemeData theme) {
    final entries = _itemPerformance.take(5).toList();
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Best Sellers & Created Stock',
                style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            ...entries.map((item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.workspace_premium_outlined),
                  title: Text(item.itemName),
                  subtitle: Text(
                      '${item.soldQuantity} sold · ${item.remainingQuantity} remaining'
                      '${item.costKnown ? '' : ' · Cost not linked'}'),
                  trailing: Text(
                    '£${item.profit.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionProfitability(ThemeData theme) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stall Profitability', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            ..._sessionProfitability.take(5).map((session) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.storefront_outlined),
                  title: Text(session.name),
                  subtitle: Text(
                      'Revenue £${session.revenue.toStringAsFixed(2)} · Direct costs £${session.directCosts.toStringAsFixed(2)}'),
                  trailing: Text(
                    '£${session.profitAfterDirectCosts.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildStockMovements(ThemeData theme) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Finished-Stock Movements',
                style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            ..._stockMovements.take(6).map((movement) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    movement.quantityChange >= 0
                        ? Icons.add_circle_outline
                        : Icons.remove_circle_outline,
                    color: movement.quantityChange >= 0
                        ? Colors.green
                        : theme.colorScheme.error,
                  ),
                  title: Text(movement.itemName),
                  subtitle: Text(
                      '${movement.reason} · ${DateFormat.MMMd().format(movement.date)}'),
                  trailing: Text(
                    '${movement.quantityChange >= 0 ? '+' : ''}${movement.quantityChange}',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildEventBreakdown(ThemeData theme) {
    final events = _eventRevenue.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
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
                  trailing: Text('£${entry.value.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyBreakdown(ThemeData theme) {
    final sortedMonths = _monthlyRevenue.keys.toList()
      ..sort((a, b) => b.compareTo(a));

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
                  final percentage =
                      _totalRevenue > 0 ? (revenue / _totalRevenue) * 100 : 0.0;

                  return ListTile(
                    title: Text(DateFormat('MMMM yyyy')
                        .format(DateTime.parse('$month-01'))),
                    subtitle: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: theme.colorScheme.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary),
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
