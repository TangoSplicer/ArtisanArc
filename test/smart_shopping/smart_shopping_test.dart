import 'package:flutter_test/flutter_test.dart';
import 'package:artisanarc/features/shopping/data/shopping_list_model.dart';

void main() {
  group('SmartShopping', () {
    test('create a new shopping list', () {
      final shoppingList = ShoppingList(
        id: 'sl1',
        name: 'Spring Collection Supplies',
        createdAt: DateTime.now(),
        items: [],
      );
      expect(shoppingList.name, 'Spring Collection Supplies');
      expect(shoppingList.items, isEmpty);
    });

    test('add an item to a shopping list', () {
      final shoppingList = ShoppingList(
        id: 'sl1',
        name: 'Spring Collection Supplies',
        createdAt: DateTime.now(),
        items: [],
      );
      final item = ShoppingListItem(
        id: 'item1',
        itemName: 'Blue Silk Fabric',
        quantity: '10 yards',
        isPurchased: false,
      );
      shoppingList.items.add(item);
      expect(shoppingList.items, isNotEmpty);
      expect(shoppingList.items.first.itemName, 'Blue Silk Fabric');
    });

    test('mark an item as purchased', () {
      final item = ShoppingListItem(
        id: 'item1',
        itemName: 'Blue Silk Fabric',
        quantity: '10 yards',
        isPurchased: false,
      );
      // Mark as purchased
      item.isPurchased = true;
      expect(item.isPurchased, isTrue);
    });

    test('shopping list correctly updates item status', () {
      final item1 = ShoppingListItem(
        id: 'item1',
        itemName: 'Blue Silk Fabric',
        quantity: '10 yards',
        isPurchased: false,
      );
      final item2 = ShoppingListItem(
        id: 'item2',
        itemName: 'Red Cotton Thread',
        quantity: '5 spools',
        isPurchased: false,
      );
      final shoppingList = ShoppingList(
        id: 'sl1',
        name: 'Spring Collection Supplies',
        createdAt: DateTime.now(),
        items: [item1, item2],
      );

      // Mark item1 as purchased
      shoppingList.items.firstWhere((it) => it.id == 'item1').isPurchased = true;

      expect(shoppingList.items.firstWhere((it) => it.id == 'item1').isPurchased, isTrue);
      expect(shoppingList.items.firstWhere((it) => it.id == 'item2').isPurchased, isFalse);
    });
  });
}
