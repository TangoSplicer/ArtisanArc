import 'package:uuid/uuid.dart';

import '../data/inventory_model.dart';
import '../data/inventory_repository.dart';
import '../data/stock_adjustment_model.dart';
import '../data/stock_adjustment_repository.dart';

class StocktakeResult {
  const StocktakeResult({
    required this.updatedItems,
    required this.adjustments,
  });

  final List<InventoryItem> updatedItems;
  final List<StockAdjustment> adjustments;

  int get adjustedLineCount => adjustments.length;
}

/// Applies a real-world count to the existing on-device tally. Every changed
/// line receives a local, chronological adjustment record so makers can explain
/// a variance without deleting sales, production, or prior stock data.
class StocktakeService {
  StocktakeService(this._inventoryRepository, this._adjustmentRepository);

  final InventoryRepository _inventoryRepository;
  final StockAdjustmentRepository _adjustmentRepository;
  final Uuid _uuid = const Uuid();

  Future<List<InventoryItem>> getActiveItems({String? itemType}) async {
    final items = await _inventoryRepository.getAllItems();
    final filtered = items.where((item) {
      if (item.isArchived) return false;
      return itemType == null || item.itemType == itemType;
    }).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return filtered;
  }

  Future<StocktakeResult> applyStocktake({
    required Map<InventoryItem, int> countedQuantities,
    String reason = 'Stocktake',
    String? note,
  }) async {
    final cleanReason = reason.trim();
    if (cleanReason.isEmpty) {
      throw ArgumentError.value(
          reason, 'reason', 'An adjustment reason is required.');
    }
    if (countedQuantities.values.any((quantity) => quantity < 0)) {
      throw ArgumentError.value(
          countedQuantities, 'countedQuantities', 'Counts cannot be negative.');
    }

    final now = DateTime.now();
    final updatedItems = <InventoryItem>[];
    final adjustments = <StockAdjustment>[];
    for (final entry in countedQuantities.entries) {
      final item = entry.key;
      final counted = entry.value;
      if (item.quantity == counted) continue;

      final updated = item.copyWith(quantity: counted, lastUpdated: now);
      final adjustment = StockAdjustment(
        id: _uuid.v4(),
        itemId: item.id,
        itemName: item.name,
        previousQuantity: item.quantity,
        countedQuantity: counted,
        quantityChange: counted - item.quantity,
        recordedAt: now,
        reason: cleanReason,
        note: note?.trim().isEmpty ?? true ? null : note!.trim(),
      );
      await _inventoryRepository.updateItem(updated);
      await _adjustmentRepository.saveAdjustment(adjustment);
      updatedItems.add(updated);
      adjustments.add(adjustment);
    }
    return StocktakeResult(
        updatedItems: updatedItems, adjustments: adjustments);
  }

  Future<InventoryItem> setArchived(InventoryItem item, bool archived) async {
    final updated =
        item.copyWith(isArchived: archived, lastUpdated: DateTime.now());
    await _inventoryRepository.updateItem(updated);
    return updated;
  }

  Future<List<StockAdjustment>> getAdjustmentHistory({String? itemId}) =>
      _adjustmentRepository.getAdjustments(itemId: itemId);
}
