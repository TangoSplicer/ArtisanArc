import 'dart:io'; // For File
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart'; // Added go_router
import 'package:path_provider/path_provider.dart'; // For getApplicationDocumentsDirectory
import 'package:path/path.dart' as p; // For path.join
import '../../../core/utils/premium_checker.dart';
import 'package:artisanarc/features/inventory/domain/inventory_service.dart';
import 'package:artisanarc/features/inventory/data/inventory_model.dart'; // Corrected to use entity
import 'package:artisanarc/core/widgets/premium_prompt.dart';
import 'package:artisanarc/features/qr/presentation/qr_generator_widget.dart'; // Added QR Generator Widget
import 'package:artisanarc/core/widgets/empty_state_widget.dart';
import 'package:artisanarc/core/services/analytics_service.dart';

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
    AnalyticsService.trackFeatureUsage('inventory_view');
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
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan Item QR Code',
            onPressed: () async { // Make onPressed async to await the result
              final result = await context.pushNamed('scanQrCode');

              if (result is InventoryItem && mounted) {
                // Display the item's details in a dialog
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return AlertDialog(
                      title: Text(result.name),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Text('ID: ${result.id}'), // Good to show ID for confirmation
                            Text('Category: ${result.category}'),
                            Text('Quantity: ${result.quantity}'),
                            Text('Price: ${result.price != null ? '\$${result.price!.toStringAsFixed(2)}' : 'N/A'}'),
                            Text('Storage Location: ${result.storageLocation ?? 'N/A'}'),
                            Text('Last Updated: ${result.lastUpdated.toLocal().toString().split(' ')[0]}'),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            },
          ),
        ],
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
            ? EmptyStateWidget(
                icon: Icons.inventory_2,
                title: 'No Items Yet',
                subtitle: 'Start building your craft inventory by adding your first item',
                actionText: 'Add First Item',
                onAction: _navigateToAddItemForm,
              )
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
                      leading: _buildItemLeadingWidget(item, color), // Updated leading widget
                      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          'Qty: ${item.quantity} • Category: ${item.category}\n'
                          'Price: ${item.price != null ? '£${item.price!.toStringAsFixed(2)}' : 'N/A'}\n'
                          'Location: ${item.storageLocation ?? 'N/A'}',
                          ),
                      trailing: IconButton( // Removed _isPremium check
                        icon: const Icon(Icons.qr_code_2),
                        tooltip: 'Show QR Code',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                title: const Text('Item QR Code'),
                                content: SizedBox( // Constrain the size of the QR code
                                  width: 250,
                                  height: 250,
                                  child: QRGeneratorWidget(data: item.id),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Close'),
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      isThreeLine: true,
                      onTap: () {
                        context.push('/inventory/detail/${item.id}').then((_) => _loadItems());
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildItemLeadingWidget(InventoryItem item, ColorScheme colorScheme) {
    if (item.imagePaths != null && item.imagePaths!.isNotEmpty) {
      // Attempt to display the first image
      return FutureBuilder<String>(
        future: getApplicationDocumentsDirectory().then((dir) => p.join(dir.path, 'inventory_images', item.imagePaths!.first)),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            final imageFile = File(snapshot.data!);
            return SizedBox(
              width: 50, // Standard ListTile leading width
              height: 50,
              child: imageFile.existsSync()
                  ? ClipRRect( // Rounded corners for the image
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.file(
                        imageFile,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return CircleAvatar( // Fallback if image file fails to load
                            backgroundColor: colorScheme.secondaryContainer,
                            child: const Icon(Icons.broken_image),
                          );
                        },
                      ),
                    )
                  : CircleAvatar( // Fallback if image file doesn't exist at path
                      backgroundColor: colorScheme.secondaryContainer,
                      child: const Icon(Icons.image_not_supported),
                    ),
            );
          } else if (snapshot.hasError) {
             return CircleAvatar( // Fallback on error
                backgroundColor: colorScheme.errorContainer,
                child: const Icon(Icons.error_outline),
              );
          } else {
            // Show a placeholder while loading the path or if no image
            return CircleAvatar(
              backgroundColor: colorScheme.secondaryContainer,
              child: const CircularProgressIndicator(),
            );
          }
        },
      );
    } else {
      // Default placeholder if no images
      return CircleAvatar(
        backgroundColor: colorScheme.secondaryContainer,
        child: Text(item.name.isNotEmpty ? item.name[0].toUpperCase() : '?'),
      );
    }
  }
}