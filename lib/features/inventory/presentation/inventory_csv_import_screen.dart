import 'dart:convert';
import 'dart:io';

import 'package:artisanarc/core/di/di.dart';
import 'package:artisanarc/core/widgets/personal_app_bar.dart';
import 'package:artisanarc/features/inventory/domain/inventory_csv_import_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InventoryCsvImportScreen extends StatefulWidget {
  const InventoryCsvImportScreen({super.key});

  @override
  State<InventoryCsvImportScreen> createState() =>
      _InventoryCsvImportScreenState();
}

class _InventoryCsvImportScreenState extends State<InventoryCsvImportScreen> {
  final _importService = getIt<InventoryCsvImportService>();

  InventoryImportPreview? _preview;
  String? _fileName;
  bool _isReading = false;
  bool _isImporting = false;

  Future<void> _chooseCsv() async {
    setState(() {
      _isReading = true;
      _preview = null;
      _fileName = null;
    });
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['csv'],
        withData: true,
      );
      if (result == null) return;
      final file = result.files.single;
      final bytes = file.bytes ??
          (file.path == null ? null : await File(file.path!).readAsBytes());
      if (bytes == null) {
        throw StateError('The selected CSV could not be read.');
      }
      final preview = await _importService.previewCsv(utf8.decode(bytes));
      if (mounted) {
        setState(() {
          _preview = preview;
          _fileName = file.name;
        });
      }
    } on FormatException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not preview CSV: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isReading = false);
    }
  }

  Future<void> _importPreview() async {
    final preview = _preview;
    if (preview == null || !preview.hasImportableItems) return;
    final shouldImport = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Import local inventory?'),
        content: Text(
          '${preview.validRowCount} new ${preview.validRowCount == 1 ? 'record' : 'records'} will be added. Existing records are never replaced or changed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Import'),
          ),
        ],
      ),
    );
    if (shouldImport != true) return;

    setState(() => _isImporting = true);
    try {
      final imported = await _importService.importPreview(preview);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$imported ${imported == 1 ? 'record' : 'records'} added to local inventory.',
          ),
        ),
      );
      context.pop(true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not import inventory: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preview = _preview;
    return Scaffold(
      appBar: PersonalAppBar(
        title: const Text('Import inventory CSV'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: theme.colorScheme.primaryContainer,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shield_outlined),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Preview before import. This offline tool only adds new inventory records; it never changes or overwrites an existing item.',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('CSV columns', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
            'Required: Name, Type, Quantity. Optional: Category, Price, Location, Unit, Reorder Point. Use Type values Created Item/Finished or Material Stock/Material. A material with a Unit is imported as measured stock.',
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _isReading ? null : _chooseCsv,
            icon: _isReading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.upload_file_outlined),
            label: Text(_isReading ? 'Reading CSV…' : 'Choose CSV file'),
          ),
          if (_fileName != null) ...[
            const SizedBox(height: 12),
            Text('Previewing: $_fileName', style: theme.textTheme.titleSmall),
          ],
          if (preview != null) ...[
            const SizedBox(height: 20),
            Text('Preview', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _metricChip(
                  Icons.table_rows_outlined,
                  '${preview.totalDataRows} rows read',
                  theme.colorScheme.primary,
                ),
                _metricChip(
                  Icons.add_circle_outline,
                  '${preview.validRowCount} ready to add',
                  Colors.green.shade700,
                ),
                if (preview.skippedRowCount > 0)
                  _metricChip(
                    Icons.skip_next_outlined,
                    '${preview.skippedRowCount} duplicates skipped',
                    Colors.orange.shade800,
                  ),
                if (preview.invalidRowCount > 0)
                  _metricChip(
                    Icons.error_outline,
                    '${preview.invalidRowCount} invalid',
                    theme.colorScheme.error,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (preview.items.isNotEmpty)
              Card(
                child: Column(
                  children: preview.items
                      .take(12)
                      .map(
                        (item) => ListTile(
                          leading: Icon(
                            item.isFinishedItem
                                ? Icons.inventory_2_outlined
                                : Icons.yard_outlined,
                          ),
                          title: Text(item.name),
                          subtitle: Text(
                            '${item.isFinishedItem ? 'Created item' : 'Material stock'} · ${item.formattedStockQuantity}${item.price == null ? '' : ' · £${item.price!.toStringAsFixed(2)}'}',
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
            if (preview.issues.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Rows needing attention',
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              ...preview.issues.take(20).map(
                    (issue) => Card(
                      child: ListTile(
                        leading: Icon(
                          issue.kind == InventoryImportIssueKind.invalid
                              ? Icons.error_outline
                              : Icons.skip_next_outlined,
                          color: issue.kind == InventoryImportIssueKind.invalid
                              ? theme.colorScheme.error
                              : Colors.orange.shade800,
                        ),
                        title: Text('Row ${issue.rowNumber}'),
                        subtitle: Text(issue.message),
                      ),
                    ),
                  ),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _isImporting || !preview.hasImportableItems
                  ? null
                  : _importPreview,
              icon: _isImporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.playlist_add_outlined),
              label: Text(
                _isImporting
                    ? 'Importing…'
                    : 'Import ${preview.validRowCount} new ${preview.validRowCount == 1 ? 'record' : 'records'}',
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _metricChip(IconData icon, String label, Color color) => Chip(
        avatar: Icon(icon, size: 18, color: color),
        label: Text(label),
        side: BorderSide(color: color.withOpacity(0.3)),
      );
}
