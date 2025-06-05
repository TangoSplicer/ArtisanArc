import 'package:hive/hive.dart';

part 'inventory_model.g.dart';

@HiveType(typeId: 0)
class InventoryItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final int quantity;

  @HiveField(4)
  final double? price;

  @HiveField(5)
  final String? storageLocation;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    this.price,
    this.storageLocation,
  });
}