import 'package:hive/hive.dart';
import 'package:artisanarc/features/shopping/data/shopping_list_model.dart';

abstract class ShoppingRepository {
  Future<void> saveList(ShoppingList list);
  Future<List<ShoppingList>> getAllLists();
  Future<ShoppingList?> getListById(String id);
  Future<void> deleteList(String id);
  // Item specific operations could be here or managed via saving the whole list
}

class ShoppingRepositoryImpl implements ShoppingRepository {
  static const _boxName = 'shoppingListsBox';

  Future<Box<ShoppingList>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<ShoppingList>(_boxName);
    }
    return Hive.box<ShoppingList>(_boxName);
  }

  @override
  Future<void> saveList(ShoppingList list) async {
    final box = await _getBox();
    await box.put(list.id, list); // Assumes list.id is the key
  }

  @override
  Future<List<ShoppingList>> getAllLists() async {
    final box = await _getBox();
    return box.values.toList();
  }

  @override
  Future<ShoppingList?> getListById(String id) async {
    final box = await _getBox();
    return box.get(id);
  }

  @override
  Future<void> deleteList(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }
}
