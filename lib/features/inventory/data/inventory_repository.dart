import 'package:hive/hive.dart';
import 'inventory_model.dart';

abstract class InventoryRepository {
  Future<void> addItem(InventoryItem item);
  Future<InventoryItem?> getItemById(String id); // Added
  Future<List<InventoryItem>> getAllItems();
  Future<void> updateItem(InventoryItem item);
  Future<void> deleteItem(String id);
}

class InventoryRepositoryImpl implements InventoryRepository {
  static const _boxName = 'inventoryBox';

  Future<Box<InventoryItem>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<InventoryItem>(_boxName);
    }
    return Hive.box<InventoryItem>(_boxName);
  }

  @override
  Future<InventoryItem?> getItemById(String id) async {
    final box = await _getBox();
    return box.get(id);
  }

  @override
  Future<void> addItem(InventoryItem item) async {
    final box = await _getBox();
    await box.put(item.id, item);
  }

  @override
  Future<List<InventoryItem>> getAllItems() async {
    final box = await _getBox();
    return box.values.toList();
  }

  @override
  Future<void> updateItem(InventoryItem item) async {
    final box = await _getBox();
    await box.put(item.id, item);
  }

  @override
  Future<void> deleteItem(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }
}