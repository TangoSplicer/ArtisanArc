import 'package:hive/hive.dart';

part 'stock_adjustment_model.g.dart';

/// Records a local physical-count correction without deleting the prior stock
/// context. Sales and production changes remain their own records; this model
/// is exclusively for deliberate manual adjustments such as a stocktake.
@HiveType(typeId: 10)
class StockAdjustment extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String itemId;

  @HiveField(2)
  final String itemName;

  @HiveField(3)
  final int previousQuantity;

  @HiveField(4)
  final int countedQuantity;

  @HiveField(5)
  final int quantityChange;

  @HiveField(6)
  final DateTime recordedAt;

  @HiveField(7)
  final String reason;

  @HiveField(8)
  final String? note;

  StockAdjustment({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.previousQuantity,
    required this.countedQuantity,
    required this.quantityChange,
    required this.recordedAt,
    required this.reason,
    this.note,
  });
}
