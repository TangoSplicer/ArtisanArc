import 'package:hive/hive.dart';

part 'production_run_model.g.dart';

/// A local record of one completed make. It preserves the material cost at the
/// time of production rather than recalculating historic profit from a later
/// replacement cost.
@HiveType(typeId: 9)
class ProductionRun extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String projectId;

  @HiveField(2)
  final String finishedItemId;

  @HiveField(3)
  final String finishedItemName;

  @HiveField(4)
  final int outputQuantity;

  @HiveField(5)
  final double materialCost;

  @HiveField(6)
  final DateTime completedAt;

  @HiveField(7)
  final String? notes;

  /// Total project making minutes recorded when this run was completed. It is a
  /// historical snapshot and is never recalculated from later timer edits.
  @HiveField(8, defaultValue: 0)
  final int labourMinutesAtCompletion;

  ProductionRun({
    required this.id,
    required this.projectId,
    required this.finishedItemId,
    required this.finishedItemName,
    required this.outputQuantity,
    required this.materialCost,
    required this.completedAt,
    this.notes,
    this.labourMinutesAtCompletion = 0,
  });

  double get materialCostPerItem =>
      outputQuantity == 0 ? 0 : materialCost / outputQuantity;
}
