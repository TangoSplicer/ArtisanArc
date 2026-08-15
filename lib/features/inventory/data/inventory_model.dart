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

  /// `finished` records are created items ready to tally or sell.
  /// `material` records are yarn, tools, and supplies available to work with.
  /// Null is retained for older data and inferred from its existing category.
  @HiveField(8)
  final String? itemType;

  /// Optional material-specific low-stock threshold. When it is unset, the
  /// global low-stock threshold remains in effect.
  @HiveField(9)
  final int? reorderPoint;

  /// Archived records remain in local history and reports but are hidden from
  /// everyday inventory and sales views until explicitly restored.
  @HiveField(10, defaultValue: false)
  final bool isArchived;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    this.price,
    this.storageLocation,
    this.imagePaths, // Added to constructor
    required this.lastUpdated, // Added lastUpdated
    this.itemType,
    this.reorderPoint,
    this.isArchived = false,
  });

  bool get isFinishedItem =>
      itemType == 'finished' ||
      (itemType == null && category.startsWith('Finished'));

  bool get isMaterialStock => !isFinishedItem;

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
    String? itemType,
    int? reorderPoint,
    bool? isArchived,
    bool clearReorderPoint = false,
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
      itemType: itemType ?? this.itemType,
      reorderPoint:
          clearReorderPoint ? null : reorderPoint ?? this.reorderPoint,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
