import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../domain/inventory_service.dart';
import '../data/inventory_model.dart';

class LowStockWidget extends StatefulWidget {
  final int threshold;

  const LowStockWidget({super.key, this.threshold = 5});

  @override
  State<LowStockWidget> createState() => _LowStockWidgetState();
}

class _LowStockWidgetState extends State<LowStockWidget> {
  final InventoryService _service = GetIt.I<InventoryService>();
  List<InventoryItem> _lowStockItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLowStockItems();
  }

  Future<void> _loadLowStockItems() async {
    setState(() => _isLoading = true);
    try {
      final allItems = await _service.fetchItems();
      final lowStock = allItems.where((item) => item.quantity <= widget.threshold).toList();
      setState(() => _lowStockItems = lowStock);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading low stock items: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_lowStockItems.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 12),
              Text(
                'All items well stocked!',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Low Stock Alert',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _lowStockItems.length,
              itemBuilder: (context, index) {
                final item = _lowStockItems[index];
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.withOpacity(0.2),
                    child: Text(item.quantity.toString()),
                  ),
                  title: Text(item.name),
                  subtitle: Text(item.category),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}