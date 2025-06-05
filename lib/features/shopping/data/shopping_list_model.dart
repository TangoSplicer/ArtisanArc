import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'shopping_list_model.g.dart';

@HiveType(typeId: 6) // New unique typeId
class ShoppingList extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  List<ShoppingListItem> items;

  ShoppingList({
    required this.id,
    required this.name,
    required this.createdAt,
    List<ShoppingListItem>? items,
  }) : items = items ?? [];

  ShoppingList copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    List<ShoppingListItem>? items,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? List<ShoppingListItem>.from(this.items.map((item) => item.copyWith())), // Deep copy
    );
  }
}

@HiveType(typeId: 7) // New unique typeId
class ShoppingListItem extends HiveObject {
  @HiveField(0)
  String id; // Globally unique ID for simplicity if items might move or be referenced elsewhere

  @HiveField(1)
  String itemName;

  @HiveField(2)
  String? quantity; // e.g., "2 packs", "1 meter"

  @HiveField(3)
  bool isPurchased;

  @HiveField(4)
  String? notes;

  ShoppingListItem({
    required this.id,
    required this.itemName,
    this.quantity,
    this.isPurchased = false,
    this.notes,
  });

  ShoppingListItem copyWith({
    String? id,
    String? itemName,
    String? quantity,
    bool? isPurchased,
    String? notes,
  }) {
    return ShoppingListItem(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      isPurchased: isPurchased ?? this.isPurchased,
      notes: notes ?? this.notes,
    );
  }
}
// Helper to generate UUIDs if needed elsewhere for these items
String generateShoppingItemId() => Uuid().v4();
String generateShoppingListId() => Uuid().v4();
