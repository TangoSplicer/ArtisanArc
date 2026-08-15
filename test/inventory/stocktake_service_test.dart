import 'package:artisanarc/features/inventory/data/inventory_model.dart';
import 'package:artisanarc/features/inventory/data/inventory_repository.dart';
import 'package:artisanarc/features/inventory/data/stock_adjustment_model.dart';
import 'package:artisanarc/features/inventory/data/stock_adjustment_repository.dart';
import 'package:artisanarc/features/inventory/domain/stocktake_service.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryInventoryRepository implements InventoryRepository {
  MemoryInventoryRepository(Iterable<InventoryItem> items)
      : _items = {for (final item in items) item.id: item};

  final Map<String, InventoryItem> _items;

  @override
  Future<void> addItem(InventoryItem item) async => _items[item.id] = item;

  @override
  Future<void> deleteItem(String id) async => _items.remove(id);

  @override
  Future<List<InventoryItem>> getAllItems() async => _items.values.toList();

  @override
  Future<InventoryItem?> getItemById(String id) async => _items[id];

  @override
  Future<void> updateItem(InventoryItem item) async => _items[item.id] = item;
}

class MemoryStockAdjustmentRepository implements StockAdjustmentRepository {
  final List<StockAdjustment> adjustments = [];

  @override
  Future<List<StockAdjustment>> getAdjustments({String? itemId}) async =>
      adjustments
          .where((adjustment) => itemId == null || adjustment.itemId == itemId)
          .toList();

  @override
  Future<void> saveAdjustment(StockAdjustment adjustment) async =>
      adjustments.add(adjustment);
}

InventoryItem item(
        {required String id,
        required int quantity,
        required String itemType}) =>
    InventoryItem(
      id: id,
      name: id == 'yarn' ? 'Cotton yarn' : 'Crochet Bee Keyring',
      category:
          itemType == 'material' ? 'Yarn & Fibre' : 'Finished Crochet Makes',
      quantity: quantity,
      itemType: itemType,
      lastUpdated: DateTime(2026, 8, 15),
    );

void main() {
  late MemoryInventoryRepository inventory;
  late MemoryStockAdjustmentRepository adjustments;
  late StocktakeService service;

  setUp(() {
    inventory = MemoryInventoryRepository([
      item(id: 'yarn', quantity: 5, itemType: 'material'),
      item(id: 'bee', quantity: 3, itemType: 'finished'),
    ]);
    adjustments = MemoryStockAdjustmentRepository();
    service = StocktakeService(inventory, adjustments);
  });

  test(
      'saves only physical-count variances with clear before-and-after history',
      () async {
    final yarn = (await inventory.getItemById('yarn'))!;
    final bee = (await inventory.getItemById('bee'))!;

    final result = await service.applyStocktake(
      countedQuantities: {yarn: 4, bee: 3},
      reason: 'Spring count',
      note: 'One ball used for samples.',
    );

    expect(result.adjustedLineCount, 1);
    expect((await inventory.getItemById('yarn'))!.quantity, 4);
    expect((await inventory.getItemById('bee'))!.quantity, 3);
    expect(adjustments.adjustments.single.previousQuantity, 5);
    expect(adjustments.adjustments.single.countedQuantity, 4);
    expect(adjustments.adjustments.single.quantityChange, -1);
    expect(adjustments.adjustments.single.reason, 'Spring count');
  });

  test(
      'archives an item without deleting it and excludes it from active stocktake items',
      () async {
    final bee = (await inventory.getItemById('bee'))!;
    final archived = await service.setArchived(bee, true);

    expect(archived.isArchived, isTrue);
    expect((await inventory.getItemById('bee'))!.isArchived, isTrue);
    expect((await service.getActiveItems()).map((item) => item.id),
        isNot(contains('bee')));
  });
}
