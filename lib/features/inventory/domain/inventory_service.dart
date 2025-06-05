import '../data/inventory_model.dart';
import '../data/inventory_repository.dart';

abstract class InventoryService {
  Future<void> createItem(InventoryItem item);
  Future<List<InventoryItem>> fetchItems();
  Future<void> removeItem(String id);
}

class InventoryServiceImpl implements InventoryService {
  final InventoryRepository _repository;

  InventoryServiceImpl(this._repository);

  @override
  Future<void> createItem(InventoryItem item) => _repository.addItem(item);

  @override
  Future<List<InventoryItem>> fetchItems() => _repository.getAllItems();

  @override
  Future<void> removeItem(String id) => _repository.deleteItem(id);
}