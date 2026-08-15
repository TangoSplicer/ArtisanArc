import 'package:hive/hive.dart';

part 'material_purchase_model.g.dart';

@HiveType(typeId: 12)
class MaterialPurchase extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String inventoryItemId;

  @HiveField(2)
  final String materialName;

  @HiveField(3)
  final String? supplierId;

  @HiveField(4)
  final String? supplierName;

  @HiveField(5)
  final DateTime purchasedAt;

  @HiveField(6)
  final double quantityPurchased;

  @HiveField(7)
  final String unit;

  @HiveField(8)
  final double totalPaid;

  @HiveField(9)
  final String? note;

  MaterialPurchase({
    required this.id,
    required this.inventoryItemId,
    required this.materialName,
    this.supplierId,
    this.supplierName,
    required this.purchasedAt,
    required this.quantityPurchased,
    required this.unit,
    required this.totalPaid,
    this.note,
  });

  double get unitCost =>
      quantityPurchased == 0 ? 0 : totalPaid / quantityPurchased;
}
