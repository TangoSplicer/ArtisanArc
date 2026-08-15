import 'package:hive/hive.dart';

import 'commission_model.dart';

abstract class CommissionRepository {
  Future<void> saveCommission(Commission commission);
  Future<Commission?> getCommissionById(String id);
  Future<List<Commission>> getCommissions();
  Future<void> deleteCommission(String id);
}

class CommissionRepositoryImpl implements CommissionRepository {
  static const _boxName = 'commissionsBox';

  Future<Box<Commission>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<Commission>(_boxName);
    }
    return Hive.box<Commission>(_boxName);
  }

  @override
  Future<void> saveCommission(Commission commission) async {
    final box = await _getBox();
    await box.put(commission.id, commission);
  }

  @override
  Future<Commission?> getCommissionById(String id) async {
    final box = await _getBox();
    return box.get(id);
  }

  @override
  Future<List<Commission>> getCommissions() async {
    final box = await _getBox();
    final commissions = box.values.toList();
    commissions.sort((a, b) {
      final aDate = a.dueDate ?? DateTime(9999);
      final bDate = b.dueDate ?? DateTime(9999);
      final byDueDate = aDate.compareTo(bDate);
      return byDueDate != 0 ? byDueDate : b.updatedAt.compareTo(a.updatedAt);
    });
    return commissions;
  }

  @override
  Future<void> deleteCommission(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }
}
