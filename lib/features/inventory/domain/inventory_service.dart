import '../data/inventory_model.dart';
import '../data/inventory_repository.dart';

abstract class InventoryService {
  Future<void> createItem(InventoryItem item);
  Future<InventoryItem?> getItemById(String id); // Added
  Future<List<InventoryItem>> fetchItems();
  Future<void> updateItem(InventoryItem item); // Added to match repo, might be useful
  Future<void> removeItem(String id);
  int getFreeTierLimit(); // Assuming this was added in a previous task for InventoryScreen
}

class InventoryServiceImpl implements InventoryService {
  final InventoryRepository _repository;
  static const int _freeTierItemLimit = 5; // Example limit

  InventoryServiceImpl(this._repository);

  @override
  Future<void> createItem(InventoryItem item) => _repository.addItem(item);

  @override
  Future<InventoryItem?> getItemById(String id) => _repository.getItemById(id); // Added

  @override
  Future<List<InventoryItem>> fetchItems() => _repository.getAllItems();

  @override
  Future<void> updateItem(InventoryItem item) => _repository.updateItem(item); // Added

  @override
  Future<void> removeItem(String id) => _repository.deleteItem(id);

  @override
  int getFreeTierLimit() => _freeTierItemLimit; // Implementation for the limit
}