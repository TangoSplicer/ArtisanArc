import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../core/utils/premium_checker.dart';
import '../../domain/inventory_service.dart';
import '../../data/inventory_model.dart';
import '../../../presentation/widgets/premium_prompt.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final InventoryService _service = GetIt.I<InventoryService>();
  List<InventoryItem> _items = [];
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
    _checkPremium();
  }

  Future<void> _checkPremium() async {
    final unlocked = await PremiumChecker.isPremiumUnlocked();
    setState(() => _isPremium = unlocked);
  }

  Future<void> _loadItems() async {
    final items = await _service.fetchItems();
    setState(() => _items = items);
  }

  Future<void> _addSampleItem() async {
    if (!_isPremium && _items.length >= 5) {
      showDialog(context: context, builder: (_) => const PremiumPrompt());
      return;
    }

    final newItem = InventoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Sample Item ${_items.length + 1}',
      category: 'Misc',
      quantity: 1,
    );

    await _service.createItem(newItem);
    _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        backgroundColor: color.primary,
        foregroundColor: color.onPrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSampleItem,
        backgroundColor: color.primary,
        child: const Icon(Icons.add),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [color.surface, color.background, color.primary.withOpacity(0.05)],
            radius: 1.3,
            center: Alignment.topRight,
          ),
        ),
        child: _items.isEmpty
            ? const Center(child: Text('No items found. Tap + to add.'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                itemBuilder: (_, i) {
                  final item = _items[i];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      title: Text(item.name),
                      subtitle: Text('Qty: ${item.quantity} • ${item.category}'),
                      trailing: _isPremium ? const Icon(Icons.qr_code_2) : null,
                    ),
                  );
                },
              ),
      ),
    );
  }
}