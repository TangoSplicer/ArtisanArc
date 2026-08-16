import 'package:hive/hive.dart';

part 'equipment_model.g.dart';

@HiveType(typeId: 24)
class EquipmentItem extends HiveObject {
  EquipmentItem({
    required this.id,
    required this.name,
    required this.category, // e.g., 'Loom', 'Ball Winder', 'Blocking Mats'
    this.brand,
    this.serialNumber,
    required this.purchaseDate,
    this.purchasePrice,
    this.maintenanceNotes,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final String? brand;

  @HiveField(4)
  final String? serialNumber;

  @HiveField(5)
  final DateTime purchaseDate;

  @HiveField(6)
  final double? purchasePrice;

  @HiveField(7)
  final String? maintenanceNotes;
}
