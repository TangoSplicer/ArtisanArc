import 'package:flutter/material.dart';
import 'package:artisanarc/core/widgets/personal_app_bar.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:artisanarc/features/inventory/domain/inventory_service.dart';
import 'package:artisanarc/features/qr/presentation/qr_scanner_widget.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final InventoryService _inventoryService = GetIt.I<InventoryService>();
  bool _isProcessing = false;
  int _scanAttempt = 0;

  Future<void> _handleScanResult(String payload) async {
    if (_isProcessing || payload.trim().isEmpty) return;
    setState(() => _isProcessing = true);

    try {
      final itemId = _itemIdFromPayload(payload);
      final item = await _inventoryService.getItemById(itemId);
      if (!mounted) return;
      if (item == null) {
        _showRetryMessage('Item not found for this QR code.');
      } else if (!item.isFinishedItem || item.isArchived) {
        _showRetryMessage(
          'This code is not an active created item available to sell.',
        );
      } else {
        context.pop(item);
      }
    } catch (error) {
      if (mounted) _showRetryMessage('Could not read this QR code: $error');
    }
  }

  String _itemIdFromPayload(String payload) {
    const prefix = 'artisanarc:item:';
    final clean = payload.trim();
    return clean.toLowerCase().startsWith(prefix)
        ? clean.substring(prefix.length).trim()
        : clean;
  }

  void _showRetryMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    setState(() {
      _isProcessing = false;
      _scanAttempt++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PersonalAppBar(
        title: const Text('Scan Item QR Code'),
      ),
      body: Center(
        child: _isProcessing
            ? const CircularProgressIndicator()
            : QRScannerWidget(
                key: ValueKey(_scanAttempt),
                onScan: _handleScanResult,
              ),
      ),
    );
  }
}
