import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:artisanarc/features/inventory/domain/inventory_service.dart';
import 'package:artisanarc/features/inventory/data/inventory_model.dart';
import 'package:artisanarc/features/qr/presentation/qr_scanner_widget.dart'; // Assuming this is the correct path

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final InventoryService _inventoryService = GetIt.I<InventoryService>();
  bool _isProcessing = false;

  void _handleScanResult(String? itemId) async {
    if (_isProcessing || itemId == null || itemId.isEmpty) {
      return;
    }
    setState(() => _isProcessing = true);

    try {
      final InventoryItem? item = await _inventoryService.getItemById(itemId); // Assuming service has getItemById

      if (mounted) {
        if (item != null) {
          // Pop the scanner page and pass the found item back as a result.
          context.pop(item);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item not found for the scanned QR code.')),
          );
          // Restart scanning or allow user to retry
          setState(() => _isProcessing = false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching item: $e')),
        );
        setState(() => _isProcessing = false);
      }
    }
    // If item found, we already popped. If not found or error, and want to allow rescan,
    // ensure QRScannerWidget can be "restarted" or continues scanning.
    // For this example, if not found, _isProcessing is reset, which might re-enable the scanner widget.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Item QR Code'),
      ),
      body: Center(
        child: _isProcessing
            ? const CircularProgressIndicator()
            : QRScannerWidget( // Assuming QRScannerWidget is designed to be embedded
                onScan: _handleScanResult,
              ),
      ),
    );
  }
}
