import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/personal_app_bar.dart';
import '../domain/tax_service.dart';
import '../data/tax_models.dart';
import '../../business/data/sale_model.dart';
import 'package:hive/hive.dart';

class TaxDashboardScreen extends StatefulWidget {
  const TaxDashboardScreen({super.key});

  @override
  State<TaxDashboardScreen> createState() => _TaxDashboardScreenState();
}

class _TaxDashboardScreenState extends State<TaxDashboardScreen> {
  final TaxService _taxService = GetIt.I<TaxService>();
  final _currencyFormat = NumberFormat.currency(symbol: '£');

  bool _isLoading = true;
  double _totalRevenue = 0.0;
  double _totalExpenses = 0.0;
  List<BusinessExpense> _expenses = [];
  late TaxYearConfig _currentConfig;

  @override
  void initState() {
    super.initState();
    _currentConfig = _taxService.getUK2026Defaults();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Load Sales
    final salesBox = await Hive.openBox<SaleRecord>('salesBox');
    final sales = salesBox.values.where((s) =>
        s.date.isAfter(
            _currentConfig.startDate.subtract(const Duration(days: 1))) &&
        s.date.isBefore(_currentConfig.endDate.add(const Duration(days: 1))));

    double revenue = 0.0;
    for (var s in sales) {
      revenue += (s.pricePerUnit * s.quantity) - (s.discountAmount ?? 0.0);
    }

    // Load Expenses
    final expenses = await _taxService.getExpenses(
      start: _currentConfig.startDate,
      end: _currentConfig.endDate,
    );

    double expenseTotal = 0.0;
    for (var e in expenses) {
      if (e.isAllowable) expenseTotal += e.amount;
    }

    if (!mounted) return;
    setState(() {
      _totalRevenue = revenue;
      _totalExpenses = expenseTotal;
      _expenses = expenses;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final taxEstimate = _totalRevenue - _totalExpenses >
            _currentConfig.personalAllowance
        ? (_totalRevenue - _totalExpenses - _currentConfig.personalAllowance) *
            _currentConfig.basicRatePercent
        : 0.0;

    return Scaffold(
      appBar: PersonalAppBar(
        title: const Text('UK Tax & Expenses'),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildTaxCard(taxEstimate, colors),
                const SizedBox(height: 20),
                _buildSummarySection(colors),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Allowable Expenses',
                        style: Theme.of(context).textTheme.titleLarge),
                    TextButton.icon(
                      onPressed: () => _addExpense(),
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                if (_expenses.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text('No expenses recorded for this tax year.'),
                    ),
                  )
                else
                  ..._expenses.map((e) => _buildExpenseTile(e, colors)),
              ],
            ),
    );
  }

  Widget _buildTaxCard(double estimate, ColorScheme colors) {
    return Card(
      color: colors.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Estimated Self Assessment Tax',
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              _currencyFormat.format(estimate),
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: colors.onPrimaryContainer),
            ),
            const SizedBox(height: 8),
            Text(
              'For Tax Year ${_currentConfig.yearLabel}',
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: colors.onPrimaryContainer.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(ColorScheme colors) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
              'Total Revenue', _totalRevenue, Colors.green.shade700),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
              'Allowable Exp.', _totalExpenses, Colors.red.shade700),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, double value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              _currencyFormat.format(value),
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseTile(BusinessExpense e, ColorScheme colors) {
    return ListTile(
      title: Text(e.description),
      subtitle: Text('${e.category} · ${DateFormat.yMMMd().format(e.date)}'),
      trailing: Text(
        _currencyFormat.format(e.amount),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      onLongPress: () => _confirmDelete(e),
    );
  }

  Future<void> _addExpense() async {
    // Simplified add for now
    final descController = TextEditingController();
    final amountController = TextEditingController();
    String category = 'Materials';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description')),
            TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount (£)'),
                keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save')),
        ],
      ),
    );

    if (confirmed == true && descController.text.isNotEmpty) {
      final expense = BusinessExpense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: category,
        description: descController.text,
        amount: double.tryParse(amountController.text) ?? 0.0,
        date: DateTime.now(),
      );
      await _taxService.saveExpense(expense);
      _loadData();
    }
  }

  Future<void> _confirmDelete(BusinessExpense e) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await _taxService.deleteExpense(e.id);
      _loadData();
    }
  }
}
