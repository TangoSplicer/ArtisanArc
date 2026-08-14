import 'package:hive/hive.dart';

import 'production_run_model.dart';

abstract class ProductionRunRepository {
  Future<void> saveRun(ProductionRun run);
  Future<List<ProductionRun>> getRuns();
}

class ProductionRunRepositoryImpl implements ProductionRunRepository {
  static const _boxName = 'productionRunsBox';

  Future<Box<ProductionRun>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<ProductionRun>(_boxName);
    }
    return Hive.box<ProductionRun>(_boxName);
  }

  @override
  Future<List<ProductionRun>> getRuns() async {
    final box = await _getBox();
    final runs = box.values.toList();
    runs.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return runs;
  }

  @override
  Future<void> saveRun(ProductionRun run) async {
    final box = await _getBox();
    await box.put(run.id, run);
  }
}
