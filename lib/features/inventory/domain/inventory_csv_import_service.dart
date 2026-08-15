import 'package:csv/csv.dart';
import 'package:uuid/uuid.dart';

import '../data/inventory_model.dart';
import '../data/inventory_repository.dart';

enum InventoryImportIssueKind { skipped, invalid }

class InventoryImportIssue {
  const InventoryImportIssue({
    required this.rowNumber,
    required this.kind,
    required this.message,
  });

  final int rowNumber;
  final InventoryImportIssueKind kind;
  final String message;
}

class InventoryImportPreview {
  const InventoryImportPreview({
    required this.totalDataRows,
    required this.items,
    required this.issues,
  });

  final int totalDataRows;
  final List<InventoryItem> items;
  final List<InventoryImportIssue> issues;

  int get validRowCount => items.length;
  int get skippedRowCount => issues
      .where((issue) => issue.kind == InventoryImportIssueKind.skipped)
      .length;
  int get invalidRowCount => issues
      .where((issue) => issue.kind == InventoryImportIssueKind.invalid)
      .length;
  bool get hasImportableItems => items.isNotEmpty;
}

/// Imports maker-owned CSV data entirely on-device. The workflow previews rows
/// before writing anything, never updates an existing record, and rejects
/// duplicate name/type combinations instead of guessing the user's intent.
class InventoryCsvImportService {
  InventoryCsvImportService(this._inventoryRepository);

  final InventoryRepository _inventoryRepository;
  final Uuid _uuid = const Uuid();

  Future<InventoryImportPreview> previewCsv(String content) async {
    final decoded = const CsvToListConverter(shouldParseNumbers: false)
        .convert(content, eol: '\n');
    if (decoded.isEmpty) {
      throw const FormatException('The CSV file is empty.');
    }

    final headers = decoded.first
        .map((value) => _normaliseHeader(value.toString()))
        .toList(growable: false);
    final nameColumn = _findColumn(headers, const ['name', 'item name']);
    final typeColumn = _findColumn(headers, const ['type', 'item type']);
    final quantityColumn = _findColumn(headers, const ['quantity', 'qty']);
    if (nameColumn == null || typeColumn == null || quantityColumn == null) {
      throw const FormatException(
        'CSV needs Name, Type, and Quantity columns. Export an inventory CSV first to use as a template.',
      );
    }

    final categoryColumn = _findColumn(headers, const ['category']);
    final priceColumn = _findColumn(headers, const ['price', 'unit price']);
    final locationColumn =
        _findColumn(headers, const ['location', 'storage location']);
    final unitColumn = _findColumn(headers, const ['unit', 'measurement unit']);
    final reorderColumn =
        _findColumn(headers, const ['reorder point', 'reorder', 'minimum']);

    final existing = await _inventoryRepository.getAllItems();
    final knownKeys = <String>{
      for (final item in existing)
        _uniqueKey(item.name, item.isFinishedItem ? 'finished' : 'material'),
    };
    final previewKeys = <String>{};
    final items = <InventoryItem>[];
    final issues = <InventoryImportIssue>[];

    for (var index = 1; index < decoded.length; index++) {
      final rowNumber = index + 1;
      final row = decoded[index];
      if (row.every((cell) => cell.toString().trim().isEmpty)) continue;
      final rowValue = (int column) =>
          column < row.length ? row[column].toString().trim() : '';
      final name = rowValue(nameColumn);
      final itemType = _itemType(rowValue(typeColumn));
      final quantityText = rowValue(quantityColumn);
      final unit = unitColumn == null ? '' : rowValue(unitColumn);
      final category = categoryColumn == null ? '' : rowValue(categoryColumn);
      final priceText = priceColumn == null ? '' : rowValue(priceColumn);
      final location = locationColumn == null ? '' : rowValue(locationColumn);
      final reorderText = reorderColumn == null ? '' : rowValue(reorderColumn);

      if (name.isEmpty) {
        issues.add(InventoryImportIssue(
          rowNumber: rowNumber,
          kind: InventoryImportIssueKind.invalid,
          message: 'Name is required.',
        ));
        continue;
      }
      if (itemType == null) {
        issues.add(InventoryImportIssue(
          rowNumber: rowNumber,
          kind: InventoryImportIssueKind.invalid,
          message:
              'Type must be Created Item/Finished or Material Stock/Material.',
        ));
        continue;
      }
      final quantity = double.tryParse(quantityText);
      if (quantity == null || !quantity.isFinite || quantity < 0) {
        issues.add(InventoryImportIssue(
          rowNumber: rowNumber,
          kind: InventoryImportIssueKind.invalid,
          message: 'Quantity must be a number of zero or more.',
        ));
        continue;
      }
      if (itemType == 'finished' && quantity != quantity.roundToDouble()) {
        issues.add(InventoryImportIssue(
          rowNumber: rowNumber,
          kind: InventoryImportIssueKind.invalid,
          message: 'Created-item quantity must be a whole number.',
        ));
        continue;
      }
      final price = priceText.isEmpty ? null : double.tryParse(priceText);
      if (priceText.isNotEmpty &&
          (price == null || !price.isFinite || price < 0)) {
        issues.add(InventoryImportIssue(
          rowNumber: rowNumber,
          kind: InventoryImportIssueKind.invalid,
          message: 'Price must be blank or a number of zero or more.',
        ));
        continue;
      }
      final reorder = reorderText.isEmpty ? null : double.tryParse(reorderText);
      if (reorderText.isNotEmpty &&
          (reorder == null || !reorder.isFinite || reorder < 0)) {
        issues.add(InventoryImportIssue(
          rowNumber: rowNumber,
          kind: InventoryImportIssueKind.invalid,
          message: 'Reorder point must be blank or a number of zero or more.',
        ));
        continue;
      }

      final key = _uniqueKey(name, itemType);
      if (knownKeys.contains(key) || !previewKeys.add(key)) {
        issues.add(InventoryImportIssue(
          rowNumber: rowNumber,
          kind: InventoryImportIssueKind.skipped,
          message:
              'Skipped duplicate $itemType name; existing records are never overwritten.',
        ));
        continue;
      }

      final measuredMaterial = itemType == 'material' && unit.isNotEmpty;
      items.add(InventoryItem(
        id: _uuid.v4(),
        name: name,
        category: category.isEmpty
            ? (itemType == 'finished' ? 'Finished Makes' : 'Materials Stock')
            : category,
        quantity: measuredMaterial ? quantity.round() : quantity.round(),
        price: price,
        storageLocation: location.isEmpty ? null : location,
        lastUpdated: DateTime.now(),
        itemType: itemType,
        reorderPoint: measuredMaterial ? null : reorder?.round(),
        measuredQuantity: measuredMaterial ? quantity : null,
        measurementUnit: measuredMaterial ? unit : null,
        measuredReorderPoint: measuredMaterial ? reorder : null,
      ));
    }

    return InventoryImportPreview(
      totalDataRows: decoded.length - 1,
      items: List.unmodifiable(items),
      issues: List.unmodifiable(issues),
    );
  }

  Future<int> importPreview(InventoryImportPreview preview) async {
    final existing = await _inventoryRepository.getAllItems();
    final existingKeys = <String>{
      for (final item in existing)
        _uniqueKey(item.name, item.isFinishedItem ? 'finished' : 'material'),
    };
    var imported = 0;
    for (final item in preview.items) {
      final key = _uniqueKey(item.name, item.itemType ?? 'material');
      if (existingKeys.contains(key)) continue;
      await _inventoryRepository.addItem(item);
      existingKeys.add(key);
      imported++;
    }
    return imported;
  }

  int? _findColumn(List<String> headers, List<String> acceptedNames) {
    for (final name in acceptedNames) {
      final index = headers.indexOf(_normaliseHeader(name));
      if (index >= 0) return index;
    }
    return null;
  }

  String? _itemType(String value) {
    switch (_normaliseHeader(value)) {
      case 'created item':
      case 'created items':
      case 'finished':
      case 'finished item':
      case 'finished items':
        return 'finished';
      case 'material':
      case 'materials':
      case 'material stock':
      case 'stock':
        return 'material';
    }
    return null;
  }

  String _uniqueKey(String name, String itemType) =>
      '${itemType.trim().toLowerCase()}|${name.trim().toLowerCase()}';

  String _normaliseHeader(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[_-]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ');
}
