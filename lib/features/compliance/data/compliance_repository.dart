import 'package:hive/hive.dart';
import 'compliance_model.dart';

abstract class ComplianceRepository {
  Future<void> addEntry(ComplianceEntry entry);
  Future<List<ComplianceEntry>> getAllEntries();
  Future<void> deleteEntry(String id);
}

class ComplianceRepositoryImpl implements ComplianceRepository {
  static const _boxName = 'complianceBox';

  Future<Box<ComplianceEntry>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<ComplianceEntry>(_boxName);
    }
    return Hive.box<ComplianceEntry>(_boxName);
  }

  @override
  Future<void> addEntry(ComplianceEntry entry) async {
    final box = await _getBox();
    await box.put(entry.id, entry);
  }

  @override
  Future<List<ComplianceEntry>> getAllEntries() async {
    final box = await _getBox();
    return box.values.toList();
  }

  @override
  Future<void> deleteEntry(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }
}