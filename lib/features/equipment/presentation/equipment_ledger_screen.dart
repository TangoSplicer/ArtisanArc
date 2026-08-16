import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

import '../../../core/widgets/personal_app_bar.dart';
import '../data/equipment_model.dart';
import '../data/equipment_repository.dart';

class EquipmentLedgerScreen extends StatefulWidget {
  const EquipmentLedgerScreen({super.key});

  @override
  State<EquipmentLedgerScreen> createState() => _EquipmentLedgerScreenState();
}

class _EquipmentLedgerScreenState extends State<EquipmentLedgerScreen> {
  final EquipmentRepository _repository = GetIt.I<EquipmentRepository>();
  List<EquipmentItem> _equipment = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _repository.getEquipment();
    if (!mounted) return;
    setState(() {
      _equipment = list;
      _isLoading = false;
    });
  }

  Future<void> _showEditor({EquipmentItem? existing}) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final categoryController =
        TextEditingController(text: existing?.category ?? 'Tools & Equipment');
    final brandController = TextEditingController(text: existing?.brand ?? '');
    final serialController =
        TextEditingController(text: existing?.serialNumber ?? '');
    final priceController =
        TextEditingController(text: existing?.purchasePrice?.toString() ?? '');
    final notesController =
        TextEditingController(text: existing?.maintenanceNotes ?? '');
    DateTime purchaseDate = existing?.purchaseDate ?? DateTime.now();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'Add Equipment' : 'Edit Equipment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                    labelText: 'Equipment Name *',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                    labelText: 'Category (e.g. Loom, Winder)',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: brandController,
                decoration: const InputDecoration(
                    labelText: 'Brand / Maker', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: serialController,
                decoration: const InputDecoration(
                    labelText: 'Serial Number / ID',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'Purchase Price (£)',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                    labelText: 'Maintenance & Service Notes',
                    border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save')),
        ],
      ),
    );

    if (confirmed != true) return;
    if (nameController.text.trim().isEmpty) return;

    final item = EquipmentItem(
      id: existing?.id ?? const Uuid().v4(),
      name: nameController.text.trim(),
      category: categoryController.text.trim().isEmpty
          ? 'Tools'
          : categoryController.text.trim(),
      brand: brandController.text.trim().isEmpty
          ? null
          : brandController.text.trim(),
      serialNumber: serialController.text.trim().isEmpty
          ? null
          : serialController.text.trim(),
      purchaseDate: purchaseDate,
      purchasePrice: double.tryParse(priceController.text.trim()),
      maintenanceNotes: notesController.text.trim().isEmpty
          ? null
          : notesController.text.trim(),
    );

    await _repository.saveEquipment(item);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: PersonalAppBar(
        title: const Text('Studio Equipment Ledger'),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _equipment.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.handyman_outlined,
                            size: 64, color: colors.primary),
                        const SizedBox(height: 16),
                        Text('No studio equipment recorded',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        const Text(
                            'Track looms, ball winders, blocking mats, and machinery along with service notes.'),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: () => _showEditor(),
                          icon: const Icon(Icons.add),
                          label: const Text('Add equipment'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _equipment.length,
                  itemBuilder: (context, index) {
                    final item = _equipment[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colors.primaryContainer,
                          child: Icon(Icons.handyman,
                              color: colors.onPrimaryContainer),
                        ),
                        title: Text(item.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          '${item.category}${item.brand != null ? ' · ${item.brand}' : ''}\nPurchased ${item.purchaseDate.toLocal().toString().split(' ').first}${item.purchasePrice != null ? ' · £${item.purchasePrice!.toStringAsFixed(2)}' : ''}',
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _showEditor(existing: item),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditor(),
        icon: const Icon(Icons.add),
        label: const Text('Add equipment'),
      ),
    );
  }
}
