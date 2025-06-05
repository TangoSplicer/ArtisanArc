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
  String? storageLocation; // Made mutable for consistency if needed for editing

  @HiveField(6)
  List<String>? imagePaths; // New field for image paths

  @HiveField(7)
  DateTime lastUpdated; // Added lastUpdated

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    this.price,
    this.storageLocation,
    this.imagePaths, // Added to constructor
    required this.lastUpdated, // Added to constructor
  });

  // copyWith method for easy updates
  InventoryItem copyWith({
    String? id,
    String? name,
    String? category,
    int? quantity,
    double? price,
    String? storageLocation,
    List<String>? imagePaths,
    DateTime? lastUpdated,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      storageLocation: storageLocation ?? this.storageLocation,
      imagePaths: imagePaths ?? this.imagePaths,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}