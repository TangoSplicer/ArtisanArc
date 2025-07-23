import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../domain/daily_sales_service.dart';
import '../../data/sale_model.dart';

class _LinkedSale {
  final SaleRecord sale;
  final String? itemName;

  _LinkedSale({required this.sale, this.itemName});
}

class DailySalesScreen extends StatefulWidget {
  const DailySalesScreen({super.key});

  @override
  State<DailySalesScreen> createState() => _DailySalesScreenState();
}

class _DailySalesScreenState extends State<DailySalesScreen> {
  final DailySalesService _service = GetIt.I<DailySalesService>();
  Map<String, List<_LinkedSale>> _grouped = {};
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    final sales = await _service.getSalesWithItemNames();
    final Map<String, List<_LinkedSale>> grouped = {};
    for (var sale in sales) {
      final dateKey = DateFormat('yyyy-MM-dd').format(sale.key.date);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(_LinkedSale(sale: sale.key, itemName: sale.value));
    }
    setState(() => _grouped = grouped);
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _clearFilter() {
    setState(() => _selectedDate = null);
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final sortedDates = _grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final filteredDates = _selectedDate != null
        ? sortedDates.where((d) => d == DateFormat('yyyy-MM-dd').format(_selectedDate!)).toList()
        : sortedDates;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Sales Tracker'),
        backgroundColor: color.primary,
        foregroundColor: color.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _pickDate,
          ),
          if (_selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearFilter,
              tooltip: 'Clear Filter',
            ),
        ],
      ),
      body: filteredDates.isEmpty
          ? const Center(child: Text('No sales on selected date.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredDates.length,
              itemBuilder: (context, index) {
                final date = filteredDates[index];
                final sales = _grouped[date]!;
                final dailyTotal = sales.fold<double>(0, (sum, s) => sum + (s.sale.total ?? 0.0));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMMM dd, yyyy').format(DateTime.parse(date)),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...sales.map((s) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                          child: ListTile(
                            title: Text(s.itemName ?? 'Unknown Item'),
                            subtitle: Text('${s.sale.quantity} × £${s.sale.pricePerUnit.toStringAsFixed(2)}'),
                            trailing: Text('£${s.sale.total?.toStringAsFixed(2) ?? '0.00'}'),
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 20),
                      child: Text('Daily Total: £${dailyTotal.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                );
              },
            ),
    );
  }
}