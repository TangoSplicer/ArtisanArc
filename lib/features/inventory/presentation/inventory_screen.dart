import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:artisanarc/core/services/analytics_service.dart';
import 'package:artisanarc/core/widgets/empty_state_widget.dart';
import 'package:artisanarc/core/widgets/personal_app_bar.dart';
import 'package:artisanarc/features/inventory/data/inventory_model.dart';
import 'package:artisanarc/features/inventory/domain/inventory_service.dart';
import 'package:artisanarc/features/qr/presentation/qr_generator_widget.dart';

enum InventoryViewMode { finishedItems, materialsStock }

class InventoryScreen extends StatefulWidget {
  final InventoryViewMode viewMode;

  const InventoryScreen({
    super.key,
    this.viewMode = InventoryViewMode.finishedItems,
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final InventoryService _service = GetIt.I<InventoryService>();
  List<InventoryItem> _items = [];

  bool get _isFinishedView =>
      widget.viewMode == InventoryViewMode.finishedItems;
  String get _title =>
      _isFinishedView ? 'Inventory · Created Items' : 'Materials Stock';
  String get _emptyTitle =>
      _isFinishedView ? 'No Created Items Yet' : 'No Materials Stock Yet';
  String get _emptySubtitle => _isFinishedView
      ? 'Add the pieces you have made to keep a clear tally of what is ready.'
      : 'Add yarn, hooks, notions, and supplies so you can see what is available to work with.';

  @override
  void initState() {
    super.initState();
    _loadItems();
    AnalyticsService.trackFeatureUsage(
        _isFinishedView ? 'created_items_view' : 'materials_stock_view');
  }

  Future<void> _loadItems() async {
    final allItems = await _service.fetchItems();
    final filtered = allItems
        .where((item) => !item.isArchived)
        .where((item) =>
            _isFinishedView ? item.isFinishedItem : item.isMaterialStock)
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    if (mounted) setState(() => _items = filtered);
  }

  Future<void> _navigateToAddItemForm() async {
    final result =
        await context.push(_isFinishedView ? '/inventory/add' : '/stock/add');
    if (result == true) _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final totalQuantity =
        _items.fold<int>(0, (sum, item) => sum + item.quantity);
    final finishedValue = _items.fold<double>(
        0, (sum, item) => sum + item.quantity * (item.price ?? 0));

    return Scaffold(
      appBar: PersonalAppBar(
        title: Text(_title),
        backgroundColor: color.primary,
        foregroundColor: color.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.fact_check_outlined),
            tooltip: 'Run stocktake',
            onPressed: () async {
              await context.pushNamed('stocktake');
              _loadItems();
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan item QR code',
            onPressed: () async {
              final result = await context.pushNamed('scanQrCode');
              if (result is InventoryItem && mounted) _showScannedItem(result);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddItemForm,
        backgroundColor: color.primary,
        icon: const Icon(Icons.add),
        label: Text(_isFinishedView ? 'Add created item' : 'Add material'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              color.surface,
              color.background,
              color.primary.withOpacity(0.05)
            ],
            radius: 1.3,
            center: Alignment.topRight,
          ),
        ),
        child: _items.isEmpty
            ? EmptyStateWidget(
                icon: _isFinishedView
                    ? Icons.inventory_2_outlined
                    : Icons.yard_outlined,
                title: _emptyTitle,
                subtitle: _emptySubtitle,
                actionText:
                    _isFinishedView ? 'Add created item' : 'Add material',
                onAction: _navigateToAddItemForm,
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                itemCount: _items.length + 1,
                itemBuilder: (_, index) {
                  if (index == 0) {
                    return Card(
                      color: color.primaryContainer,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: Icon(
                            _isFinishedView
                                ? Icons.widgets_outlined
                                : Icons.yard_outlined,
                            color: color.onPrimaryContainer),
                        title: Text(
                          _isFinishedView
                              ? '$totalQuantity item${totalQuantity == 1 ? '' : 's'} currently tallied'
                              : '$totalQuantity units available to work with',
                          style: TextStyle(
                              color: color.onPrimaryContainer,
                              fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          _isFinishedView
                              ? '${_items.length} created-item line${_items.length == 1 ? '' : 's'} · £${finishedValue.toStringAsFixed(2)} potential sales value'
                              : '${_items.length} material line${_items.length == 1 ? '' : 's'} · yarn, tools, and supplies',
                          style: TextStyle(color: color.onPrimaryContainer),
                        ),
                      ),
                    );
                  }

                  final item = _items[index - 1];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      leading: _buildItemLeadingWidget(item, color),
                      title: Text(item.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        _isFinishedView
                            ? 'Tally: ${item.quantity} made / available · ${item.category}\nSale price: ${item.price != null ? '£${item.price!.toStringAsFixed(2)}' : 'Not set'} · Location: ${item.storageLocation ?? 'Not set'}'
                            : 'Available: ${item.quantity} · ${item.category}\nLocation: ${item.storageLocation ?? 'Not set'}${item.price == null ? '' : ' · Replacement cost: £${item.price!.toStringAsFixed(2)}'}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.qr_code_2),
                        tooltip: 'Show QR code',
                        onPressed: () => _showQrCode(item),
                      ),
                      isThreeLine: true,
                      onTap: () => context
                          .push('/inventory/detail/${item.id}')
                          .then((_) => _loadItems()),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _showScannedItem(InventoryItem item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(item.name),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text(
                  'Type: ${item.isFinishedItem ? 'Created item' : 'Material stock'}'),
              Text('Category: ${item.category}'),
              Text(item.isFinishedItem
                  ? 'Tally: ${item.quantity}'
                  : 'Available: ${item.quantity}'),
              Text(
                  'Price: ${item.price != null ? '£${item.price!.toStringAsFixed(2)}' : 'Not set'}'),
              Text('Location: ${item.storageLocation ?? 'Not set'}'),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'))
        ],
      ),
    );
  }

  void _showQrCode(InventoryItem item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${item.name} QR Code'),
        content: SizedBox(
            width: 250, height: 250, child: QRGeneratorWidget(data: item.id)),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'))
        ],
      ),
    );
  }

  Widget _buildItemLeadingWidget(InventoryItem item, ColorScheme colorScheme) {
    if (item.imagePaths != null && item.imagePaths!.isNotEmpty) {
      return FutureBuilder<String>(
        future: getApplicationDocumentsDirectory().then((dir) =>
            p.join(dir.path, 'inventory_images', item.imagePaths!.first)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            final imageFile = File(snapshot.data!);
            if (imageFile.existsSync()) {
              return SizedBox(
                width: 50,
                height: 50,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(imageFile, fit: BoxFit.cover)),
              );
            }
          }
          return CircleAvatar(
            backgroundColor: colorScheme.secondaryContainer,
            child: Icon(item.isFinishedItem
                ? Icons.inventory_2_outlined
                : Icons.yard_outlined),
          );
        },
      );
    }
    return CircleAvatar(
      backgroundColor: colorScheme.secondaryContainer,
      child: Text(item.name.isNotEmpty ? item.name[0].toUpperCase() : '?'),
    );
  }
}
