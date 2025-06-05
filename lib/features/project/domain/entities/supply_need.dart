import 'package:hive/hive.dart';

part 'supply_need.g.dart'; // Will be generated if this becomes a HiveType

// For now, not making it a HiveType directly, but it will be part of Project.
// If it needs to be stored independently or queried, it should become a HiveType.
@HiveType(typeId: 4) // Ensure typeId is unique across your Hive objects
class SupplyNeed extends HiveObject { // Extending HiveObject for potential future direct storage
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

  SupplyNeed({
    required this.id,
    required this.itemName,
    required this.quantityNeeded,
    required this.unit,
    this.isSourced = false,
  });

  SupplyNeed copyWith({
    String? id,
    String? itemName,
    double? quantityNeeded,
    String? unit,
    bool? isSourced,
  }) {
    return SupplyNeed(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      quantityNeeded: quantityNeeded ?? this.quantityNeeded,
      unit: unit ?? this.unit,
      isSourced: isSourced ?? this.isSourced,
    );
  }
}
