import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/widgets/personal_app_bar.dart';
import '../../inventory/data/inventory_model.dart';
import '../../inventory/domain/inventory_service.dart';
import '../data/sale_model.dart';
import '../data/stall_session_model.dart';
import '../domain/stall_session_service.dart';

class StallSessionScreen extends StatefulWidget {
  const StallSessionScreen({super.key});

  @override
  State<StallSessionScreen> createState() => _StallSessionScreenState();
}

class _StallSessionScreenState extends State<StallSessionScreen> {
  final StallSessionService _sessionService = GetIt.I<StallSessionService>();
  final InventoryService _inventoryService = GetIt.I<InventoryService>();

  final Map<String, int> _basket = {};
  final _discountController = TextEditingController();
  String _paymentMethod = 'cash';
  List<InventoryItem> _items = [];
  StallSession? _session;
  StallSessionSummary? _summary;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final session = await _sessionService.getActiveSession();
      final items = await _inventoryService.fetchItems();
      final summary =
          session == null ? null : await _sessionService.getSummary(session);
      if (!mounted) return;
      setState(() {
        _session = session;
        _summary = summary;
        _items = items
          ..sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load stall session: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<InventoryItem> get _saleableItems => _items
      .where((item) =>
          item.isFinishedItem && item.quantity > 0 && item.price != null)
      .toList();

  int get _basketItemCount =>
      _basket.values.fold(0, (total, quantity) => total + quantity);

  double get _basketSubtotal => _items.fold(0.0, (total, item) {
        return total + (item.price ?? 0) * (_basket[item.id] ?? 0);
      });

  double get _basketDiscount => double.tryParse(_discountController.text) ?? 0;

  double get _basketTotal =>
      (_basketSubtotal - _basketDiscount).clamp(0, double.infinity);

  void _adjustQuantity(InventoryItem item, int change) {
    final current = _basket[item.id] ?? 0;
    final next = (current + change).clamp(0, item.quantity);
    setState(() {
      if (next == 0) {
        _basket.remove(item.id);
      } else {
        _basket[item.id] = next;
      }
    });
  }

  Future<void> _showStartSessionDialog() async {
    final nameController = TextEditingController();
    final venueController = TextEditingController();
    final floatController = TextEditingController(text: '0');
    final feeController = TextEditingController(text: '0');
    final travelController = TextEditingController(text: '0');
    bool saving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Start Stall Session'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Event or session name',
                    hintText: 'e.g. Saturday Makers Market',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: venueController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Table, stall or venue (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: floatController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Cash float',
                    prefixText: '£ ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: feeController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Table fee (optional)',
                    prefixText: '£ ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: travelController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Travel cost (optional)',
                    prefixText: '£ ',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed:
                  saving ? null : () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: saving
                  ? null
                  : () async {
                      if (nameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(
                              content: Text('Enter a session name.')),
                        );
                        return;
                      }
                      setDialogState(() => saving = true);
                      try {
                        await _sessionService.startSession(
                          name: nameController.text,
                          venue: venueController.text,
                          cashFloat: double.tryParse(floatController.text) ?? 0,
                          tableFee: double.tryParse(feeController.text) ?? 0,
                          travelCost:
                              double.tryParse(travelController.text) ?? 0,
                        );
                        if (!Navigator.of(dialogContext).mounted) return;
                        Navigator.of(dialogContext).pop();
                        await _load();
                      } catch (error) {
                        if (Navigator.of(dialogContext).mounted) {
                          setDialogState(() => saving = false);
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Could not start session: $error')),
                          );
                        }
                      }
                    },
              icon: const Icon(Icons.play_circle_outline),
              label: Text(saving ? 'Starting…' : 'Start Session'),
            ),
          ],
        ),
      ),
    );

    nameController.dispose();
    venueController.dispose();
    floatController.dispose();
    feeController.dispose();
    travelController.dispose();
  }

  Future<void> _recordBasket() async {
    final session = _session;
    if (session == null || _basket.isEmpty || _isSaving) return;
    if (_basketDiscount > _basketSubtotal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Discount cannot be greater than the basket subtotal.')),
      );
      return;
    }

    final basket = <InventoryItem, int>{};
    for (final item in _items) {
      final quantity = _basket[item.id] ?? 0;
      if (quantity > 0) basket[item] = quantity;
    }

    final recordedItemCount = _basketItemCount;
    final recordedTotal = _basketTotal;
    setState(() => _isSaving = true);
    try {
      final records = await _sessionService.recordBasket(
        session: session,
        basket: basket,
        paymentMethod: _paymentMethod,
        discountAmount: _basketDiscount,
      );
      if (!mounted) return;
      final receipt = _receiptText(session, records);
      setState(() {
        _basket.clear();
        _discountController.clear();
      });
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Recorded $recordedItemCount item(s) · £${recordedTotal.toStringAsFixed(2)}'),
          action: SnackBarAction(
            label: 'Share receipt',
            onPressed: () =>
                Share.share(receipt, subject: '${session.name} receipt'),
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not record basket: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _receiptText(StallSession session, List<SaleRecord> records) {
    final lines = records.map(
      (record) =>
          '• ${record.quantity} item(s) · £${record.total.toStringAsFixed(2)}',
    );
    final total = records.fold<double>(0, (sum, record) => sum + record.total);
    return [
      'ArtisanArc Personal — ${session.name}',
      if (session.venue != null) session.venue!,
      'Payment: ${_paymentMethod[0].toUpperCase()}${_paymentMethod.substring(1)}',
      ...lines,
      'Total: £${total.toStringAsFixed(2)}',
      'Recorded locally on ${DateTime.now().toLocal().toString().split('.').first}',
    ].join('\n');
  }

  Future<void> _showHistory() async {
    final summary = _summary;
    if (summary == null) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * 0.75,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long_outlined),
                    const SizedBox(width: 8),
                    Text('Session transactions',
                        style: Theme.of(sheetContext).textTheme.titleLarge),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: summary.sales.isEmpty
                    ? const Center(
                        child: Text('No sales recorded in this session yet.'))
                    : ListView.separated(
                        itemCount: summary.sales.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final sale = summary.sales.reversed.elementAt(index);
                          InventoryItem? item;
                          for (final candidate in _items) {
                            if (candidate.id == sale.itemId) {
                              item = candidate;
                              break;
                            }
                          }
                          final label = item?.name ?? 'Removed inventory item';
                          final stateLabel = sale.isVoid
                              ? 'Voided'
                              : sale.isReturn
                                  ? 'Return'
                                  : sale.paymentMethod;
                          return ListTile(
                            title: Text(label),
                            subtitle: Text(
                              '${sale.quantity} item(s) · $stateLabel'
                              '${sale.adjustmentReason == null ? '' : ' · ${sale.adjustmentReason}'}',
                            ),
                            trailing: sale.isReturn
                                ? Text('−£${(-sale.total).toStringAsFixed(2)}')
                                : Text('£${sale.total.toStringAsFixed(2)}'),
                            onTap: sale.isVoid || sale.isReturn
                                ? null
                                : () => _showSaleActions(sheetContext, sale),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSaleActions(
      BuildContext sheetContext, SaleRecord sale) async {
    await showModalBottomSheet<void>(
      context: sheetContext,
      builder: (actionContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.keyboard_return_outlined),
              title: const Text('Record return'),
              subtitle: const Text(
                  'Restores the finished-item tally and keeps an audit record.'),
              onTap: () {
                Navigator.of(actionContext).pop();
                _showReturnDialog(sale);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel_outlined),
              title: const Text('Void sale'),
              subtitle: const Text(
                  'Requires a reason and restores the finished-item tally.'),
              onTap: () {
                Navigator.of(actionContext).pop();
                _showVoidDialog(sale);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showReturnDialog(SaleRecord sale) async {
    final quantityController = TextEditingController(text: '1');
    final reasonController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Record return'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: 'Quantity (up to ${sale.quantity})'),
            ),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Reason (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              try {
                await _sessionService.returnSale(
                  originalSale: sale,
                  quantity: int.tryParse(quantityController.text) ?? 0,
                  reason: reasonController.text,
                );
                if (!Navigator.of(dialogContext).mounted) return;
                Navigator.of(dialogContext).pop();
                await _load();
              } catch (error) {
                if (Navigator.of(dialogContext).mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text('Could not record return: $error')),
                  );
                }
              }
            },
            child: const Text('Record return'),
          ),
        ],
      ),
    );
    quantityController.dispose();
    reasonController.dispose();
  }

  Future<void> _showVoidDialog(SaleRecord sale) async {
    final reasonController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Void sale'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Reason',
            hintText: 'e.g. Entered twice by mistake',
          ),
          minLines: 2,
          maxLines: 3,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              try {
                await _sessionService.voidSale(
                    sale: sale, reason: reasonController.text);
                if (!Navigator.of(dialogContext).mounted) return;
                Navigator.of(dialogContext).pop();
                await _load();
              } catch (error) {
                if (Navigator.of(dialogContext).mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text('Could not void sale: $error')),
                  );
                }
              }
            },
            child: const Text('Void sale'),
          ),
        ],
      ),
    );
    reasonController.dispose();
  }

  Future<void> _showCashUp() async {
    final session = _session;
    final summary = _summary;
    if (session == null || summary == null) return;
    final cashController =
        TextEditingController(text: summary.expectedCash.toStringAsFixed(2));
    final notesController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cash-up and close'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _summaryRow('Net sales', summary.netRevenue),
              _summaryRow('Cash sales', summary.cashRevenue),
              _summaryRow('Card sales', summary.cardRevenue),
              _summaryRow('Bank transfer', summary.bankTransferRevenue),
              _summaryRow('Cash float', session.cashFloat),
              _summaryRow('Expected cash', summary.expectedCash, bold: true),
              _summaryRow('Table and travel', -summary.directCosts),
              _summaryRow('After direct costs', summary.netAfterDirectCosts,
                  bold: true),
              const SizedBox(height: 16),
              TextField(
                controller: cashController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Counted cash',
                  prefixText: '£ ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Closeout notes (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel')),
          FilledButton.icon(
            onPressed: () async {
              final countedCash = double.tryParse(cashController.text);
              if (countedCash == null || countedCash < 0) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                      content: Text('Enter a valid counted cash amount.')),
                );
                return;
              }
              try {
                await _sessionService.closeSession(
                  session: session,
                  countedCash: countedCash,
                  notes: notesController.text,
                );
                if (!Navigator.of(dialogContext).mounted) return;
                Navigator.of(dialogContext).pop();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Session closed · Cash difference £${(countedCash - summary.expectedCash).toStringAsFixed(2)}',
                    ),
                  ),
                );
                context.pop(true);
              } catch (error) {
                if (Navigator.of(dialogContext).mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text('Could not close session: $error')),
                  );
                }
              }
            },
            icon: const Icon(Icons.lock_outline),
            label: const Text('Close session'),
          ),
        ],
      ),
    );
    cashController.dispose();
    notesController.dispose();
  }

  Widget _summaryRow(String label, double value, {bool bold = false}) {
    final style = bold ? const TextStyle(fontWeight: FontWeight.bold) : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text('£${value.toStringAsFixed(2)}', style: style)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_session == null) {
      return Scaffold(
        appBar: const PersonalAppBar(title: Text('Stall Session')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.storefront_outlined,
                    size: 64, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text('Start a stall session',
                    style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                const Text(
                  'Set your event details, cash float and costs once. Record baskets, returns and cash-up entirely offline.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _showStartSessionDialog,
                  icon: const Icon(Icons.play_circle_outline),
                  label: const Text('Start Stall Session'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final summary = _summary!;
    return Scaffold(
      appBar: PersonalAppBar(
        title: Text(_session!.name),
        actions: [
          IconButton(
            tooltip: 'Session transactions',
            onPressed: _showHistory,
            icon: const Icon(Icons.receipt_long_outlined),
          ),
          IconButton(
            tooltip: 'Cash-up and close',
            onPressed: _showCashUp,
            icon: const Icon(Icons.account_balance_wallet_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(Icons.storefront,
                        color: theme.colorScheme.onPrimaryContainer),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Active session',
                              style: TextStyle(
                                  color: theme.colorScheme.onPrimaryContainer)),
                          Text(
                            _session!.venue ?? 'Venue not set',
                            style: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('£${summary.netRevenue.toStringAsFixed(2)}',
                            style: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold)),
                        Text('${summary.itemsSold} sold',
                            style: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _paymentMethod,
                    decoration: const InputDecoration(
                        labelText: 'Payment', border: OutlineInputBorder()),
                    items: const ['cash', 'card', 'bank transfer', 'other']
                        .map((method) => DropdownMenuItem(
                              value: method,
                              child: Text(method[0].toUpperCase() +
                                  method.substring(1)),
                            ))
                        .toList(),
                    onChanged: (method) =>
                        setState(() => _paymentMethod = method ?? 'cash'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _discountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Basket discount',
                      prefixText: '£ ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _saleableItems.isEmpty
                ? const Center(
                    child: Text(
                        'Add finished created items with sale prices before recording a basket.'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    itemCount: _saleableItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = _saleableItems[index];
                      final selected = _basket[item.id] ?? 0;
                      final available = item.quantity - selected;
                      return Card(
                        child: Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                title: Text(item.name),
                                subtitle: Text(
                                    '£${item.price!.toStringAsFixed(2)} · $available available'),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Remove one ${item.name}',
                              onPressed: selected == 0
                                  ? null
                                  : () => _adjustQuantity(item, -1),
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            SizedBox(
                                width: 28,
                                child: Text('$selected',
                                    textAlign: TextAlign.center)),
                            IconButton(
                              tooltip: 'Add one ${item.name}',
                              onPressed: available == 0
                                  ? null
                                  : () => _adjustQuantity(item, 1),
                              icon: const Icon(Icons.add_circle),
                              color: theme.colorScheme.primary,
                            ),
                          ],
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
          onPressed: _basket.isEmpty || _isSaving ? null : _recordBasket,
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.shopping_basket_outlined),
          label: Text(
            _basket.isEmpty
                ? 'Add items to basket'
                : 'Record $_basketItemCount item(s) · £${_basketTotal.toStringAsFixed(2)}',
          ),
        ),
      ),
    );
  }
}
