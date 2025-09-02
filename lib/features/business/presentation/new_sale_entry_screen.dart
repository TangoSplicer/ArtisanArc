import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import '../../inventory/domain/inventory_service.dart';
import '../../inventory/data/inventory_model.dart';
import '../domain/business_service.dart';
import '../data/sale_model.dart';

class NewSaleEntryScreen extends StatefulWidget {
  const NewSaleEntryScreen({super.key});

  @override
  State<NewSaleEntryScreen> createState() => _NewSaleEntryScreenState();
}

class _NewSaleEntryScreenState extends State<NewSaleEntryScreen> {
  final InventoryService _inventoryService = GetIt.I<InventoryService>();
  final BusinessService _businessService = GetIt.I<BusinessService>();

  List<InventoryItem> _items = [];
  InventoryItem? _selectedItem;
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await _inventoryService.fetchItems();
    setState(() => _items = items);
  }

  Future<void> _submitSale() async {
    if (_selectedItem == null) return;

    final sale = SaleRecord(
      id: const Uuid().v4(),
      itemId: _selectedItem!.id,
      quantity: int.tryParse(_quantityController.text) ?? 0,
      pricePerUnit: double.tryParse(_priceController.text) ?? 0.0,
      date: DateTime.now(),
    );

    await _businessService.createSale(sale);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Sale')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButton<InventoryItem>(
              value: _selectedItem,
              hint: const Text('Select Inventory Item'),
              isExpanded: true,
              items: _items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item.name),
                );
              }).toList(),
              onChanged: (item) => setState(() => _selectedItem = item),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Quantity Sold'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price Per Unit (£)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _submitSale,
              icon: const Icon(Icons.save),
              label: const Text('Record Sale'),
            ),
          ],
        ),
      ),
    );
  }
}