import 'package:hive/hive.dart';

import 'stock_adjustment_model.dart';

abstract class StockAdjustmentRepository {
  Future<void> saveAdjustment(StockAdjustment adjustment);
  Future<List<StockAdjustment>> getAdjustments({String? itemId});
}

class StockAdjustmentRepositoryImpl implements StockAdjustmentRepository {
  static const _boxName = 'stockAdjustmentsBox';

  Future<Box<StockAdjustment>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<StockAdjustment>(_boxName);
    }
    return Hive.box<StockAdjustment>(_boxName);
  }

  @override
  Future<List<StockAdjustment>> getAdjustments({String? itemId}) async {
    final box = await _getBox();
    final adjustments = box.values
        .where((adjustment) => itemId == null || adjustment.itemId == itemId)
        .toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return adjustments;
  }

  @override
  Future<void> saveAdjustment(StockAdjustment adjustment) async {
    final box = await _getBox();
    await box.put(adjustment.id, adjustment);
  }
}
