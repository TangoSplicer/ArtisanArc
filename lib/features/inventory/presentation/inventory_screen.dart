import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart'; // Added go_router
import '../../../core/utils/premium_checker.dart';
import '../../domain/inventory_service.dart';
import '../../domain/entities/inventory_item.dart'; // Corrected to use entity
import '../../../presentation/widgets/premium_prompt.dart';
// AddInventoryItemScreen is not directly used here, but routing to it.

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

  Future<void> _navigateToAddItemForm() async {
    if (!_isPremium && _items.length >= _service.getFreeTierLimit()) { // Using service method for limit
      showDialog(context: context, builder: (_) => const PremiumPrompt());
      return;
    }
    // Navigate to the add item screen and wait for a result.
    final result = await context.pushNamed('addInventoryItem');

    // If the form was submitted successfully (returned true), reload the items.
    if (result == true) {
      _loadItems();
    }
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
        onPressed: _navigateToAddItemForm, // Changed to new method
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
                      leading: CircleAvatar(
                        backgroundColor: color.secondaryContainer,
                        child: Text(item.name.isNotEmpty ? item.name[0].toUpperCase() : '?'),
                      ),
                      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          'Qty: ${item.quantity} • Category: ${item.category}\n'
                          'Price: ${item.price != null ? '\$${item.price!.toStringAsFixed(2)}' : 'N/A'}\n'
                          'Location: ${item.storageLocation ?? 'N/A'}',
                          ),
                      trailing: _isPremium ? IconButton(
                        icon: const Icon(Icons.qr_code_2),
                        onPressed: () {
                          // TODO: Implement QR code generation/display for this item
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('QR Code for ${item.name} (Premium)')),
                          );
                        },
                      ) : null,
                      isThreeLine: true, // To accommodate more details
                    ),
                  );
                },
              ),
      ),
    );
  }
}