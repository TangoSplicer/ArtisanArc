import '../data/inventory_model.dart';
import '../data/inventory_repository.dart';

abstract class InventoryService {
  Future<void> createItem(InventoryItem item);
  Future<InventoryItem?> getItemById(String id);
  Future<List<InventoryItem>> fetchItems();
  Future<void> updateItem(InventoryItem item);
  Future<void> removeItem(String id);
}

class InventoryServiceImpl implements InventoryService {
  final InventoryRepository _repository;

  InventoryServiceImpl(this._repository);

  @override
  Future<void> createItem(InventoryItem item) => _repository.addItem(item);

  @override
  Future<InventoryItem?> getItemById(String id) => _repository.getItemById(id);

  @override
  Future<List<InventoryItem>> fetchItems() => _repository.getAllItems();

  @override
  Future<void> updateItem(InventoryItem item) => _repository.updateItem(item);

  @override
  Future<void> removeItem(String id) => _repository.deleteItem(id);
}
