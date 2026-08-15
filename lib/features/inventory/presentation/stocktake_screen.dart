import 'package:artisanarc/core/widgets/personal_app_bar.dart';
import 'package:artisanarc/features/inventory/data/inventory_model.dart';
import 'package:artisanarc/features/inventory/domain/stocktake_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class StocktakeScreen extends StatefulWidget {
  const StocktakeScreen({super.key});

  @override
  State<StocktakeScreen> createState() => _StocktakeScreenState();
}

class _StocktakeScreenState extends State<StocktakeScreen> {
  final StocktakeService _stocktakeService = GetIt.I<StocktakeService>();
  final TextEditingController _reasonController =
      TextEditingController(text: 'Stocktake');
  final TextEditingController _noteController = TextEditingController();
  final Map<String, TextEditingController> _countControllers = {};

  List<InventoryItem> _items = [];
  String? _itemType;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _noteController.dispose();
    for (final controller in _countControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    final items = await _stocktakeService.getActiveItems(itemType: _itemType);
    if (!mounted) return;
    for (final controller in _countControllers.values) {
      controller.dispose();
    }
    _countControllers.clear();
    for (final item in items) {
      _countControllers[item.id] =
          TextEditingController(text: '${item.quantity}');
    }
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  int get _varianceCount => _items.where((item) {
        return int.tryParse(_countControllers[item.id]?.text ?? '') !=
            item.quantity;
      }).length;

  Future<void> _saveStocktake() async {
    if (_isSaving) return;
    final counts = <InventoryItem, int>{};
    for (final item in _items) {
      final count = int.tryParse(_countControllers[item.id]?.text ?? '');
      if (count == null || count < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Enter a whole count of zero or more for ${item.name}.')),
        );
        return;
      }
      if (count != item.quantity) counts[item] = count;
    }
    if (counts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No differences to save.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final result = await _stocktakeService.applyStocktake(
        countedQuantities: counts,
        reason: _reasonController.text,
        note: _noteController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Saved ${result.adjustedLineCount} stock adjustment${result.adjustedLineCount == 1 ? '' : 's'}.')),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save stocktake: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PersonalAppBar(title: Text('Stocktake')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    children: [
                      SegmentedButton<String?>(
                        segments: const [
                          ButtonSegment(value: null, label: Text('All')),
                          ButtonSegment(
                              value: 'finished', label: Text('Created')),
                          ButtonSegment(
                              value: 'material', label: Text('Materials')),
                        ],
                        selected: {_itemType},
                        onSelectionChanged: (selection) {
                          setState(() => _itemType = selection.first);
                          _loadItems();
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _reasonController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Adjustment reason',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _noteController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Stocktake note (optional)',
                          hintText: 'e.g. Spring market count',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _items.isEmpty
                      ? const Center(
                          child: Text('No active inventory records to count.'))
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          itemCount: _items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            final controller = _countControllers[item.id]!;
                            return Semantics(
                              label:
                                  '${item.name}. Recorded quantity ${item.quantity}. Enter physical count.',
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(item.name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall),
                                            Text(
                                                '${item.isFinishedItem ? 'Created item' : 'Material'} · Recorded: ${item.quantity}'),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 96,
                                        child: TextField(
                                          controller: controller,
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          onChanged: (_) => setState(() {}),
                                          decoration: const InputDecoration(
                                            labelText: 'Counted',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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
        child: FilledButton.icon(
          onPressed: _isSaving || _varianceCount == 0 ? null : _saveStocktake,
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.fact_check_outlined),
          label: Text(_varianceCount == 0
              ? 'Enter a different physical count to adjust'
              : 'Save $_varianceCount adjustment${_varianceCount == 1 ? '' : 's'}'),
        ),
      ),
    );
  }
}
