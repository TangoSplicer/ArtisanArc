import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import '../../../core/widgets/personal_app_bar.dart';
import '../../../core/widgets/searchable_selection_field.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();

  List<InventoryItem> _items = [];
  InventoryItem? _selectedItem;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    final items = await _inventoryService.fetchItems();
    if (!mounted) return;
    setState(() {
      _items = items.where((item) => item.isFinishedItem).toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    });
  }

  Future<void> _submitSale() async {
    if (!_formKey.currentState!.validate() || _selectedItem == null) return;

    final quantity = int.parse(_quantityController.text);
    if (quantity > _selectedItem!.quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Only ${_selectedItem!.quantity} ${_selectedItem!.name} available in the created-item tally.')),
      );
      return;
    }

    final now = DateTime.now();
    final sale = SaleRecord(
      id: const Uuid().v4(),
      itemId: _selectedItem!.id,
      quantity: quantity,
      pricePerUnit: double.parse(_priceController.text),
      date: now,
    );

    await _businessService.createSale(sale);
    await _inventoryService.updateItem(
      _selectedItem!.copyWith(
        quantity: _selectedItem!.quantity - quantity,
        lastUpdated: now,
      ),
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PersonalAppBar(title: Text('New Sale')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SearchableSelectionField<InventoryItem>(
                options: _items,
                value: _selectedItem,
                labelText: 'Created item',
                hintText: 'Search created items ready to sell',
                emptyMessage: 'No created items available to sell',
                itemLabel: (item) => item.name,
                itemSubtitle: (item) => '${item.category} · ${item.quantity} available${item.storageLocation == null || item.storageLocation!.isEmpty ? '' : ' · ${item.storageLocation}'}',
                searchTerms: (item) => [item.name, item.category, item.storageLocation ?? ''],
                onChanged: (item) => setState(() => _selectedItem = item),
                validator: (item) => item == null ? 'Select an inventory item' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity sold', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) => (int.tryParse(value ?? '') ?? 0) > 0 ? null : 'Enter a quantity greater than zero',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price per unit (£)', border: OutlineInputBorder()),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => (double.tryParse(value ?? '') ?? -1) >= 0 ? null : 'Enter a valid price',
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _submitSale,
                icon: const Icon(Icons.save),
                label: const Text('Record Sale'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
