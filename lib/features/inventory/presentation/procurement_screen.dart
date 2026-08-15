import 'package:artisanarc/core/constants/selection_options.dart';
import 'package:artisanarc/core/widgets/personal_app_bar.dart';
import 'package:artisanarc/core/widgets/searchable_selection_field.dart';
import 'package:artisanarc/features/inventory/data/inventory_model.dart';
import 'package:artisanarc/features/inventory/data/material_purchase_model.dart';
import 'package:artisanarc/features/inventory/data/supplier_model.dart';
import 'package:artisanarc/features/inventory/domain/inventory_service.dart';
import 'package:artisanarc/features/inventory/domain/procurement_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ProcurementScreen extends StatefulWidget {
  const ProcurementScreen({super.key});

  @override
  State<ProcurementScreen> createState() => _ProcurementScreenState();
}

class _ProcurementScreenState extends State<ProcurementScreen> {
  final ProcurementService _procurementService = GetIt.I<ProcurementService>();
  final InventoryService _inventoryService = GetIt.I<InventoryService>();
  final _quantityController = TextEditingController();
  final _totalController = TextEditingController();
  final _noteController = TextEditingController();

  List<InventoryItem> _materials = [];
  List<Supplier> _suppliers = [];
  List<MaterialPurchase> _purchases = [];
  InventoryItem? _selectedMaterial;
  Supplier? _selectedSupplier;
  String? _unit;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _totalController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final items = await _inventoryService.fetchItems();
      final suppliers = await _procurementService.getSuppliers();
      final purchases = await _procurementService.getPurchaseHistory();
      if (!mounted) return;
      setState(() {
        _materials = items
            .where((item) => item.isMaterialStock && !item.isArchived)
            .toList()
          ..sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        _suppliers = suppliers;
        _purchases = purchases;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Could not load procurement records: $error')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _recordPurchase() async {
    final material = _selectedMaterial;
    final quantity = double.tryParse(_quantityController.text);
    final total = double.tryParse(_totalController.text);
    if (material == null ||
        quantity == null ||
        quantity <= 0 ||
        total == null ||
        total < 0 ||
        (_unit ?? '').trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Select a material and enter a valid quantity, unit, and total paid.')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final purchase = await _procurementService.recordPurchase(
        material: material,
        supplier: _selectedSupplier,
        quantityPurchased: quantity,
        unit: _unit!,
        totalPaid: total,
        note: _noteController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Recorded ${purchase.quantityPurchased} ${purchase.unit} · £${purchase.unitCost.toStringAsFixed(2)} per ${purchase.unit}.')),
      );
      setState(() {
        _quantityController.clear();
        _totalController.clear();
        _noteController.clear();
        _selectedMaterial = null;
        _selectedSupplier = null;
        _unit = null;
      });
      await _load();
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not record purchase: $error')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _showAddSupplierDialog() async {
    final nameController = TextEditingController();
    final websiteController = TextEditingController();
    final noteController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add supplier'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                      labelText: 'Supplier name',
                      border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(
                  controller: websiteController,
                  decoration: const InputDecoration(
                      labelText: 'Website or contact (optional)',
                      border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                      labelText: 'Note (optional)',
                      border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              try {
                final supplier = await _procurementService.saveSupplier(
                  name: nameController.text,
                  website: websiteController.text,
                  notes: noteController.text,
                );
                if (!Navigator.of(dialogContext).mounted) return;
                Navigator.of(dialogContext).pop();
                await _load();
                if (mounted) setState(() => _selectedSupplier = supplier);
              } catch (error) {
                if (Navigator.of(dialogContext).mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(
                      content: Text('Could not save supplier: $error')));
                }
              }
            },
            child: const Text('Save supplier'),
          ),
        ],
      ),
    );
    nameController.dispose();
    websiteController.dispose();
    noteController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PersonalAppBar(
        title: const Text('Suppliers & Purchases'),
        actions: [
          IconButton(
            tooltip: 'Add supplier',
            icon: const Icon(Icons.person_add_alt_1_outlined),
            onPressed: _showAddSupplierDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Record a material purchase',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                SearchableSelectionField<InventoryItem>(
                  options: _materials,
                  value: _selectedMaterial,
                  labelText: 'Material',
                  hintText: 'Search material stock',
                  emptyMessage:
                      'Add material stock before recording a purchase',
                  itemLabel: (item) => item.name,
                  itemSubtitle: (item) =>
                      '${item.formattedStockQuantity} available',
                  searchTerms: (item) => [item.name, item.category],
                  onChanged: (item) => setState(() {
                    _selectedMaterial = item;
                    _unit = item?.measurementUnit;
                  }),
                  validator: (_) => null,
                ),
                const SizedBox(height: 12),
                SearchableSelectionField<Supplier>(
                  options: _suppliers,
                  value: _selectedSupplier,
                  labelText: 'Supplier (optional)',
                  hintText: 'Search a saved supplier',
                  emptyMessage: 'Use the person-plus button to add a supplier',
                  itemLabel: (supplier) => supplier.name,
                  searchTerms: (supplier) => [
                    supplier.name,
                    supplier.website ?? '',
                    supplier.contactNote ?? ''
                  ],
                  onChanged: (supplier) =>
                      setState(() => _selectedSupplier = supplier),
                  validator: (_) => null,
                  allowClear: true,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _quantityController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                            labelText: 'Quantity purchased',
                            border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SearchableSelectionField<String>(
                        options: SelectionOptions.supplyUnits,
                        value: _unit,
                        labelText: 'Unit',
                        hintText: 'Unit',
                        itemLabel: (unit) => unit,
                        onChanged: (unit) => setState(() => _unit = unit),
                        customValueBuilder: (query) => query,
                        validator: (_) => null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _totalController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      labelText: 'Total paid',
                      prefixText: '£ ',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                      labelText: 'Purchase note (optional)',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _isSaving ? null : _recordPurchase,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.add_shopping_cart_outlined),
                  label: const Text('Record purchase'),
                ),
                const SizedBox(height: 24),
                Text('Recent purchases',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                if (_purchases.isEmpty)
                  const Card(
                      child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No material purchases recorded yet.')))
                else
                  ..._purchases.take(20).map((purchase) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.receipt_long_outlined),
                          title: Text(purchase.materialName),
                          subtitle: Text(
                              '${purchase.quantityPurchased} ${purchase.unit} · ${purchase.supplierName ?? 'No supplier recorded'}'),
                          trailing:
                              Text('£${purchase.totalPaid.toStringAsFixed(2)}'),
                        ),
                      )),
              ],
            ),
    );
  }
}
