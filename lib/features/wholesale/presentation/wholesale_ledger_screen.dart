import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/personal_app_bar.dart';
import '../data/wholesale_model.dart';
import '../domain/wholesale_service.dart';

class WholesaleLedgerScreen extends StatefulWidget {
  const WholesaleLedgerScreen({super.key});

  @override
  State<WholesaleLedgerScreen> createState() => _WholesaleLedgerScreenState();
}

class _WholesaleLedgerScreenState extends State<WholesaleLedgerScreen>
    with SingleTickerProviderStateMixin {
  final WholesaleService _service = GetIt.I<WholesaleService>();
  late final TabController _tabController;
  List<WholesalePartner> _partners = [];
  List<WholesaleBatch> _batches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final partners = await _service.getPartners();
      final batches = await _service.getBatches();
      if (!mounted) return;
      setState(() {
        _partners = partners;
        _batches = batches;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load wholesale ledger: $error')),
      );
    }
  }

  Future<void> _settleBatch(WholesaleBatch batch) async {
    final settledItems = batch.items
        .map(
          (item) => WholesaleBatchItem(
            id: item.id,
            inventoryItemId: item.inventoryItemId,
            itemName: item.itemName,
            quantitySent: item.quantitySent,
            quantitySold: item.quantitySold,
            quantityReturned: item.quantityReturned,
            agreedUnitPrice: item.agreedUnitPrice,
          ),
        )
        .toList();
    final notesController = TextEditingController();
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('Settle ${batch.referenceNumber}'),
          content: StatefulBuilder(
            builder: (context, setDialogState) => SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter sold and returned quantities. Returned pieces will be restored to Created Items stock.',
                  ),
                  const SizedBox(height: 16),
                  ...settledItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.itemName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: item.quantitySold.toString(),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Sold',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  onChanged: (value) {
                                    setDialogState(() {
                                      settledItems[index] = WholesaleBatchItem(
                                        id: item.id,
                                        inventoryItemId: item.inventoryItemId,
                                        itemName: item.itemName,
                                        quantitySent: item.quantitySent,
                                        quantitySold: int.tryParse(value) ?? 0,
                                        quantityReturned: item.quantityReturned,
                                        agreedUnitPrice: item.agreedUnitPrice,
                                      );
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  initialValue:
                                      item.quantityReturned.toString(),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Returned',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  onChanged: (value) {
                                    setDialogState(() {
                                      final current = settledItems[index];
                                      settledItems[index] = WholesaleBatchItem(
                                        id: current.id,
                                        inventoryItemId:
                                            current.inventoryItemId,
                                        itemName: current.itemName,
                                        quantitySent: current.quantitySent,
                                        quantitySold: current.quantitySold,
                                        quantityReturned:
                                            int.tryParse(value) ?? 0,
                                        agreedUnitPrice:
                                            current.agreedUnitPrice,
                                      );
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Sent: ${item.quantitySent} · Remaining must be sold or returned',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    );
                  }),
                  TextField(
                    controller: notesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Settlement note (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Settle batch'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      for (final item in settledItems) {
        if (item.quantitySold < 0 ||
            item.quantityReturned < 0 ||
            item.quantitySold + item.quantityReturned > item.quantitySent) {
          throw StateError(
              '${item.itemName}: sold plus returned cannot exceed quantity sent.');
        }
      }
      await _service.settleBatch(
        batch: batch,
        settledItems: settledItems,
        notes: notesController.text,
      );
      await _load();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not settle batch: $error')),
        );
      }
    } finally {
      notesController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: PersonalAppBar(
        title: const Text('Wholesale & Consignment'),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        bottom: TabBar(
          controller: _tabController,
          labelColor: colors.onPrimary,
          unselectedLabelColor: colors.onPrimary.withOpacity(0.7),
          tabs: const [
            Tab(
                icon: Icon(Icons.store_mall_directory_outlined),
                text: 'Partners'),
            Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Batches'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'New partner',
            icon: const Icon(Icons.person_add_alt_1_outlined),
            onPressed: () =>
                context.push('/wholesale/new-partner').then((_) => _load()),
          ),
          IconButton(
            tooltip: 'New wholesale batch',
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () =>
                context.push('/wholesale/new-batch').then((_) => _load()),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPartners(colors),
                _buildBatches(colors),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.push('/wholesale/new-batch').then((_) => _load()),
        icon: const Icon(Icons.local_shipping_outlined),
        label: const Text('Send batch'),
      ),
    );
  }

  Widget _buildPartners(ColorScheme colors) {
    if (_partners.isEmpty) {
      return _emptyState(
        icon: Icons.store_mall_directory_outlined,
        title: 'No wholesale partners yet',
        message:
            'Keep retailer and gallery contacts locally, then record what was sent and what came back.',
        actionLabel: 'Add partner',
        onAction: () =>
            context.push('/wholesale/new-partner').then((_) => _load()),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _partners.length,
        itemBuilder: (context, index) {
          final partner = _partners[index];
          final partnerBatches =
              _batches.where((batch) => batch.partnerId == partner.id).toList();
          final outstanding = partnerBatches
              .where((batch) => batch.status == 'sent')
              .fold<double>(0, (sum, batch) => sum + batch.totalWholesaleValue);
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: colors.primaryContainer,
                child: Icon(
                  partner.partnerType == 'consignment'
                      ? Icons.handshake_outlined
                      : Icons.storefront_outlined,
                  color: colors.onPrimaryContainer,
                ),
              ),
              title: Text(partner.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${partner.partnerType == 'consignment' ? 'Consignment' : 'Wholesale'} · ${partner.commissionRatePercent.toStringAsFixed(1)}% partner share\n${partner.contactName.isEmpty ? 'No contact name' : partner.contactName}${outstanding > 0 ? '\n£${outstanding.toStringAsFixed(2)} outstanding' : ''}',
                ),
              ),
              isThreeLine: true,
              trailing: IconButton(
                tooltip: 'Edit partner',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context
                    .push('/wholesale/edit-partner/${partner.id}')
                    .then((_) => _load()),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBatches(ColorScheme colors) {
    if (_batches.isEmpty) {
      return _emptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No wholesale batches yet',
        message:
            'Record a delivery to a shop, gallery, or consignment partner. Stock is deducted when the batch is sent.',
        actionLabel: 'Send first batch',
        onAction: () =>
            context.push('/wholesale/new-batch').then((_) => _load()),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _batches.length,
        itemBuilder: (context, index) {
          final batch = _batches[index];
          final isOpen = batch.status == 'sent';
          final statusColor = isOpen ? colors.tertiary : Colors.green.shade700;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(batch.referenceNumber,
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold)),
                      ),
                      Chip(
                        label: Text(isOpen ? 'Outstanding' : 'Settled'),
                        avatar: Icon(
                          isOpen
                              ? Icons.schedule_outlined
                              : Icons.check_circle_outline,
                          size: 16,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(batch.partnerName),
                  const SizedBox(height: 6),
                  Text(
                    '${batch.items.length} line${batch.items.length == 1 ? '' : 's'} · Sent ${batch.sentDate.toLocal().toString().split(' ').first} · Due ${batch.dueDate.toLocal().toString().split(' ').first}',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Wholesale value: £${batch.totalWholesaleValue.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (isOpen)
                        OutlinedButton.icon(
                          onPressed: () => _settleBatch(batch),
                          icon: const Icon(Icons.done_all_outlined),
                          label: const Text('Settle'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
