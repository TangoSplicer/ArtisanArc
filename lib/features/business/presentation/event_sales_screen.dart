import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

import '../../../core/widgets/personal_app_bar.dart';
import '../../inventory/data/inventory_model.dart';
import '../../inventory/domain/inventory_service.dart';
import '../data/sale_model.dart';
import '../domain/business_service.dart';

/// Fast, offline capture for a table, stall, or market-day session.
/// Each saved line becomes an ordinary SaleRecord, so the existing daily,
/// monthly, export, and revenue reports include it automatically.
class EventSalesScreen extends StatefulWidget {
  const EventSalesScreen({super.key});

  @override
  State<EventSalesScreen> createState() => _EventSalesScreenState();
}

class _EventSalesScreenState extends State<EventSalesScreen> {
  final InventoryService _inventoryService = GetIt.I<InventoryService>();
  final BusinessService _businessService = GetIt.I<BusinessService>();
  final _eventController = TextEditingController(text: 'On-the-day sales');
  final _locationController = TextEditingController();
  final Map<String, int> _soldQuantities = {};

  List<InventoryItem> _items = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _eventController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    final items = await _inventoryService.fetchItems();
    if (!mounted) return;
    setState(() {
      _items = [...items]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      _isLoading = false;
    });
  }

  List<InventoryItem> get _visibleItems {
    final saleable = _items.where((item) => item.isFinishedItem && item.quantity > 0 && item.price != null).toList();
    return saleable;
  }

  int get _totalItemsSold => _soldQuantities.values.fold(0, (sum, quantity) => sum + quantity);

  double get _totalRevenue => _items.fold(0.0, (sum, item) {
        final quantity = _soldQuantities[item.id] ?? 0;
        return sum + quantity * (item.price ?? 0);
      });

  void _adjustQuantity(InventoryItem item, int change) {
    final current = _soldQuantities[item.id] ?? 0;
    final next = (current + change).clamp(0, item.quantity) as int;
    setState(() {
      if (next == 0) {
        _soldQuantities.remove(item.id);
      } else {
        _soldQuantities[item.id] = next;
      }
    });
  }

  Future<void> _recordSales() async {
    if (_soldQuantities.isEmpty || _isSaving) return;

    final eventName = _eventController.text.trim().isEmpty ? 'On-the-day sales' : _eventController.text.trim();
    final eventLocation = _locationController.text.trim().isEmpty ? null : _locationController.text.trim();
    final soldItems = _items.where((item) => (_soldQuantities[item.id] ?? 0) > 0).toList();

    setState(() => _isSaving = true);
    try {
      final now = DateTime.now();
      for (final item in soldItems) {
        final quantity = _soldQuantities[item.id]!;
        await _businessService.createSale(
          SaleRecord(
            id: const Uuid().v4(),
            itemId: item.id,
            quantity: quantity,
            pricePerUnit: item.price!,
            date: now,
            eventName: eventName,
            eventLocation: eventLocation,
          ),
        );
        await _inventoryService.updateItem(
          item.copyWith(
            quantity: item.quantity - quantity,
            lastUpdated: now,
          ),
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recorded $_totalItemsSold item${_totalItemsSold == 1 ? '' : 's'} · £${_totalRevenue.toStringAsFixed(2)}')),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not record sales: $error')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleItems = _visibleItems;

    return Scaffold(
      appBar: const PersonalAppBar(title: Text('On-the-day Sales')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                TextField(
                  controller: _eventController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Event or session name',
                    hintText: 'e.g. Saturday Makers Market',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.storefront_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _locationController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Table, stall or venue (optional)',
                    hintText: 'e.g. Table 12 · Town Hall',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Tap + as each created item sells. Your finished-item tally is updated when you save.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : visibleItems.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'Add finished created items with sale prices in Inventory before recording a sale.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        itemCount: visibleItems.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = visibleItems[index];
                          final sold = _soldQuantities[item.id] ?? 0;
                          final stockRemaining = item.quantity - sold;
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                      title: Text(item.name),
                                      subtitle: Text('${item.category} · £${item.price!.toStringAsFixed(2)} · $stockRemaining available'),
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Remove one ${item.name}',
                                    onPressed: sold == 0 ? null : () => _adjustQuantity(item, -1),
                                    icon: const Icon(Icons.remove_circle_outline),
                                  ),
                                  SizedBox(
                                    width: 24,
                                    child: Text('$sold', textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
                                  ),
                                  IconButton(
                                    tooltip: 'Record one ${item.name} sold',
                                    onPressed: stockRemaining == 0 ? null : () => _adjustQuantity(item, 1),
                                    icon: const Icon(Icons.add_circle),
                                    color: theme.colorScheme.primary,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: ElevatedButton.icon(
          onPressed: _soldQuantities.isEmpty || _isSaving ? null : _recordSales,
          icon: _isSaving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.check_circle_outline),
          label: Text(_soldQuantities.isEmpty
              ? 'Tap + to record sales'
              : 'Save $_totalItemsSold item${_totalItemsSold == 1 ? '' : 's'} · £${_totalRevenue.toStringAsFixed(2)}'),
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
        ),
      ),
    );
  }
}
