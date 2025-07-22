import 'package:artisanarc/features/shopping/data/shopping_list_model.dart';
import 'package:artisanarc/features/shopping/data/shopping_repository.dart';
import 'package:uuid/uuid.dart';

abstract class ShoppingService {
  Future<void> createShoppingList(ShoppingList list);
  Future<List<ShoppingList>> getAllShoppingLists();
  Future<ShoppingList?> getShoppingListById(String id);
  Future<void> updateShoppingList(ShoppingList list);
  Future<void> deleteShoppingList(String id);

  Future<void> addItemToList(String listId, ShoppingListItem item);
  Future<void> removeItemFromList(String listId, String itemId);
  Future<void> toggleItemPurchased(String listId, String itemId, bool isPurchased);
  Future<void> updateListItem(String listId, ShoppingListItem item);
}

class ShoppingServiceImpl implements ShoppingService {
  final ShoppingRepository _repository;
  final Uuid _uuid = Uuid();

  ShoppingServiceImpl(this._repository);

  @override
  Future<void> createShoppingList(ShoppingList list) {
    // Ensure list has an ID if not provided, though UI should handle this
    list.id ??= _uuid.v4();
    return _repository.saveList(list);
  }

  @override
  Future<List<ShoppingList>> getAllShoppingLists() {
    return _repository.getAllLists();
  }

  @override
  Future<ShoppingList?> getShoppingListById(String id) {
    return _repository.getListById(id);
  }

  @override
  Future<void> updateShoppingList(ShoppingList list) {
    // This typically involves renaming the list or other list-level properties
    return _repository.saveList(list);
  }

  @override
  Future<void> deleteShoppingList(String id) {
    return _repository.deleteList(id);
  }

  @override
  Future<void> addItemToList(String listId, ShoppingListItem item) async {
    final list = await getShoppingListById(listId);
    if (list != null) {
      // Ensure item has an ID
      item.id ??= _uuid.v4();
      list.items.add(item);
      await _repository.saveList(list);
    } else {
      throw Exception('Shopping list not found with id: $listId');
    }
  }

  @override
  Future<void> removeItemFromList(String listId, String itemId) async {
    final list = await getShoppingListById(listId);
    if (list != null) {
      list.items.removeWhere((item) => item.id == itemId);
      await _repository.saveList(list);
    } else {
      throw Exception('Shopping list not found with id: $listId');
    }
  }

  @override
  Future<void> toggleItemPurchased(String listId, String itemId, bool isPurchased) async {
    final list = await getShoppingListById(listId);
    if (list != null) {
      final itemIndex = list.items.indexWhere((item) => item.id == itemId);
      if (itemIndex != -1) {
        list.items[itemIndex].isPurchased = isPurchased;
        await _repository.saveList(list);
      } else {
        throw Exception('Item not found in list with id: $itemId');
      }
    } else {
      throw Exception('Shopping list not found with id: $listId');
    }
  }

  @override
  Future<void> updateListItem(String listId, ShoppingListItem updatedItem) async {
    final list = await getShoppingListById(listId);
    if (list != null) {
      final itemIndex = list.items.indexWhere((item) => item.id == updatedItem.id);
      if (itemIndex != -1) {
        list.items[itemIndex] = updatedItem;
        await _repository.saveList(list);
      } else {
        throw Exception('Item not found in list with id: ${updatedItem.id}');
      }
    } else {
      throw Exception('Shopping list not found with id: $listId');
    }
  }
}
