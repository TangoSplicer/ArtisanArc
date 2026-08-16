import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/personal_app_bar.dart';
import '../../../core/widgets/searchable_selection_field.dart';
import '../../inventory/data/inventory_model.dart';
import '../../inventory/domain/inventory_service.dart';
import '../data/wholesale_model.dart';
import '../domain/wholesale_service.dart';

class WholesaleBatchEditorScreen extends StatefulWidget {
  const WholesaleBatchEditorScreen({super.key});

  @override
  State<WholesaleBatchEditorScreen> createState() =>
      _WholesaleBatchEditorScreenState();
}

class _WholesaleBatchEditorScreenState
    extends State<WholesaleBatchEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final WholesaleService _service = GetIt.I<WholesaleService>();
  final InventoryService _inventoryService = GetIt.I<InventoryService>();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();
  WholesalePartner? _partner;
  List<WholesalePartner> _partners = [];
  List<InventoryItem> _saleableItems = [];
  final List<_BatchLine> _lines = [];
  DateTime _sentDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _notesController.dispose();
    for (final line in _lines) {
      line.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final partners = await _service.getPartners();
      final items = await _inventoryService.fetchItems();
      if (!mounted) return;
      setState(() {
        _partners = partners;
        _saleableItems = items
            .where((item) =>
                item.isFinishedItem &&
                !item.isArchived &&
                item.quantity > 0 &&
                item.price != null)
            .toList()
          ..sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        _partner = partners.isNotEmpty ? partners.first : null;
        if (_saleableItems.isNotEmpty) {
          _lines.add(_BatchLine(item: _saleableItems.first));
        }
        _isLoading = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load batch options: $error')),
        );
      }
    }
  }

  Future<void> _pickDate({required bool dueDate}) async {
    final current = dueDate ? _dueDate : _sentDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: dueDate ? _sentDate : DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked == null) return;
    setState(() {
      if (dueDate) {
        _dueDate = picked;
      } else {
        _sentDate = picked;
        if (_dueDate.isBefore(picked)) _dueDate = picked;
      }
    });
  }

  void _addLine() {
    if (_saleableItems.isEmpty) return;
    setState(() => _lines.add(_BatchLine(item: _saleableItems.first)));
  }

  void _removeLine(int index) {
    setState(() {
      _lines[index].dispose();
      _lines.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_partner == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a partner before sending a batch.')),
      );
      return;
    }
    if (_lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one finished item.')),
      );
      return;
    }
    try {
      final items = <WholesaleBatchItem>[];
      for (final line in _lines) {
        final quantity = int.tryParse(line.quantityController.text.trim());
        final price = double.tryParse(line.priceController.text.trim());
        if (quantity == null || quantity < 1) {
          throw StateError('${line.item.name}: enter a positive quantity.');
        }
        if (price == null || price < 0) {
          throw StateError('${line.item.name}: enter a valid agreed price.');
        }
        if (quantity > line.item.quantity) {
          throw StateError(
              '${line.item.name}: only ${line.item.quantity} piece(s) are available.');
        }
        items.add(WholesaleBatchItem(
          id: '${DateTime.now().microsecondsSinceEpoch}-${items.length}',
          inventoryItemId: line.item.id,
          itemName: line.item.name,
          quantitySent: quantity,
          quantitySold: 0,
          quantityReturned: 0,
          agreedUnitPrice: price,
        ));
      }
      setState(() => _isSaving = true);
      await _service.createBatch(
        partner: _partner!,
        referenceNumber: _referenceController.text,
        items: items,
        sentDate: _sentDate,
        dueDate: _dueDate,
        notes: _notesController.text,
      );
      if (mounted) context.pop();
    } catch (error) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not send batch: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: PersonalAppBar(
        title: const Text('Send wholesale batch'),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_partners.isEmpty)
                    Card(
                      color: colors.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: colors.onErrorContainer),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Create a wholesale or consignment partner first.',
                                style:
                                    TextStyle(color: colors.onErrorContainer),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SearchableSelectionField<WholesalePartner>(
                      options: _partners,
                      value: _partner,
                      labelText: 'Partner *',
                      hintText: 'Search shops and venues',
                      itemLabel: (partner) => partner.name,
                      itemSubtitle: (partner) =>
                          '${partner.partnerType == 'consignment' ? 'Consignment' : 'Wholesale'} · ${partner.contactName}',
                      searchTerms: (partner) => [
                        partner.name,
                        partner.contactName,
                        partner.email,
                        partner.address,
                      ],
                      onChanged: (value) => setState(() => _partner = value),
                    ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _referenceController,
                    decoration: const InputDecoration(
                      labelText: 'Batch reference (optional)',
                      hintText: 'e.g. SUMMER-01',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.tag_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          _dateRow(
                            title: 'Sent date',
                            date: _sentDate,
                            onPressed: () => _pickDate(dueDate: false),
                          ),
                          const Divider(),
                          _dateRow(
                            title: 'Payment / settlement due',
                            date: _dueDate,
                            onPressed: () => _pickDate(dueDate: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Finished items',
                            style: Theme.of(context).textTheme.titleLarge),
                      ),
                      FilledButton.icon(
                        onPressed: _saleableItems.isEmpty ? null : _addLine,
                        icon: const Icon(Icons.add),
                        label: const Text('Add line'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_saleableItems.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'No saleable Created Items with a price and stock are available. Add finished pieces to Inventory first.',
                          style: TextStyle(color: colors.error),
                        ),
                      ),
                    )
                  else
                    ..._lines.asMap().entries.map((entry) {
                      final index = entry.key;
                      final line = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child:
                                        SearchableSelectionField<InventoryItem>(
                                      options: _saleableItems,
                                      value: line.item,
                                      labelText: 'Created Item',
                                      hintText: 'Search finished pieces',
                                      itemLabel: (item) => item.name,
                                      itemSubtitle: (item) =>
                                          '${item.quantity} available · £${(item.price ?? 0).toStringAsFixed(2)} each',
                                      searchTerms: (item) => [
                                        item.name,
                                        item.category,
                                        item.storageLocation ?? '',
                                      ],
                                      onChanged: (value) {
                                        if (value == null) return;
                                        setState(() {
                                          line.item = value;
                                          if (line.priceController.text
                                                  .isEmpty ||
                                              line.priceController.text ==
                                                  line.previousPriceText) {
                                            line.priceController.text =
                                                (value.price ?? 0)
                                                    .toStringAsFixed(2);
                                          }
                                          line.previousPriceText =
                                              line.priceController.text;
                                        });
                                      },
                                    ),
                                  ),
                                  if (_lines.length > 1)
                                    IconButton(
                                      tooltip: 'Remove line',
                                      icon: Icon(Icons.delete_outline,
                                          color: colors.error),
                                      onPressed: () => _removeLine(index),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: line.quantityController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Quantity sent',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                      validator: (value) =>
                                          int.tryParse(value?.trim() ?? '') ==
                                                  null
                                              ? 'Enter a quantity'
                                              : null,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      controller: line.priceController,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      decoration: const InputDecoration(
                                        labelText: 'Agreed unit price (£)',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                      validator: (value) => double.tryParse(
                                                  value?.trim() ?? '') ==
                                              null
                                          ? 'Enter a price'
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _notesController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _isSaving || _partners.isEmpty || _lines.isEmpty
                        ? null
                        : _save,
                    icon: _isSaving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.local_shipping_outlined),
                    label: Text(
                        _isSaving ? 'Sending…' : 'Send batch & deduct stock'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _dateRow({
    required String title,
    required DateTime date,
    required VoidCallback onPressed,
  }) {
    return Row(
      children: [
        const Icon(Icons.event_outlined),
        const SizedBox(width: 10),
        Expanded(
            child:
                Text('$title: ${date.toLocal().toString().split(' ').first}')),
        OutlinedButton(onPressed: onPressed, child: const Text('Change')),
      ],
    );
  }
}

class _BatchLine {
  _BatchLine({required this.item}) {
    quantityController = TextEditingController(text: '1');
    priceController = TextEditingController(
      text: (item.price ?? 0).toStringAsFixed(2),
    );
    previousPriceText = priceController.text;
  }

  InventoryItem item;
  late final TextEditingController quantityController;
  late final TextEditingController priceController;
  String previousPriceText = '';

  void dispose() {
    quantityController.dispose();
    priceController.dispose();
  }
}
