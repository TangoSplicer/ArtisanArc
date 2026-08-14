import 'package:hive/hive.dart';

part 'supply_need.g.dart'; // Will be generated if this becomes a HiveType

// For now, not making it a HiveType directly, but it will be part of Project.
// If it needs to be stored independently or queried, it should become a HiveType.
@HiveType(typeId: 4) // Ensure typeId is unique across your Hive objects
class SupplyNeed extends HiveObject {
  // Extending HiveObject for potential future direct storage
  @HiveField(0)
  final String id;

  @HiveField(1)
  String itemName;

  @HiveField(2)
  double quantityNeeded; // Using double for flexibility (e.g., 0.5 meters)

  @HiveField(3)
  String unit; // e.g., meters, pieces, grams

  @HiveField(4)
  bool isSourced; // Has this supply been acquired/allocated?

  /// Optional link to the exact local material-stock record used by this make.
  @HiveField(5)
  String? inventoryItemId;

  /// Optional planner estimate per required unit, retained for later offline
  /// cost and profit reporting.
  @HiveField(6)
  double? estimatedCostEach;

  /// Consumables are reduced when a completed make is recorded. Hooks, needles
  /// and reusable tools remain linked but are never deducted.
  @HiveField(7, defaultValue: true)
  bool isConsumable;

  SupplyNeed({
    required this.id,
    required this.itemName,
    required this.quantityNeeded,
    required this.unit,
    this.isSourced = false,
    this.inventoryItemId,
    this.estimatedCostEach,
    this.isConsumable = true,
  });

  SupplyNeed copyWith({
    String? id,
    String? itemName,
    double? quantityNeeded,
    String? unit,
    bool? isSourced,
    String? inventoryItemId,
    double? estimatedCostEach,
    bool? isConsumable,
  }) {
    return SupplyNeed(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      quantityNeeded: quantityNeeded ?? this.quantityNeeded,
      unit: unit ?? this.unit,
      isSourced: isSourced ?? this.isSourced,
      inventoryItemId: inventoryItemId ?? this.inventoryItemId,
      estimatedCostEach: estimatedCostEach ?? this.estimatedCostEach,
      isConsumable: isConsumable ?? this.isConsumable,
    );
  }
}
