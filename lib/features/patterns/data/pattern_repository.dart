import 'package:hive/hive.dart';
import 'pattern_model.dart';

class PatternRepository {
  static const String _patternsBoxName = 'storedPatternsBox';
  static const String _rowCountersBoxName = 'rowCountersBox';

  Future<Box<StoredPattern>> _openPatternsBox() async {
    if (!Hive.isBoxOpen(_patternsBoxName)) {
      return await Hive.openBox<StoredPattern>(_patternsBoxName);
    }
    return Hive.box<StoredPattern>(_patternsBoxName);
  }

  Future<Box<RowCounter>> _openCountersBox() async {
    if (!Hive.isBoxOpen(_rowCountersBoxName)) {
      return await Hive.openBox<RowCounter>(_rowCountersBoxName);
    }
    return Hive.box<RowCounter>(_rowCountersBoxName);
  }

  Future<List<StoredPattern>> getPatterns() async {
    final box = await _openPatternsBox();
    return box.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<StoredPattern?> getPatternById(String id) async {
    final box = await _openPatternsBox();
    return box.get(id);
  }

  Future<void> savePattern(StoredPattern pattern) async {
    final box = await _openPatternsBox();
    await box.put(pattern.id, pattern);
  }

  Future<void> deletePattern(String id) async {
    final box = await _openPatternsBox();
    await box.delete(id);
  }

  Future<List<RowCounter>> getRowCounters() async {
    final box = await _openCountersBox();
    return box.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<RowCounter?> getRowCounterById(String id) async {
    final box = await _openCountersBox();
    return box.get(id);
  }

  Future<void> saveRowCounter(RowCounter counter) async {
    final box = await _openCountersBox();
    await box.put(counter.id, counter);
  }

  Future<void> deleteRowCounter(String id) async {
    final box = await _openCountersBox();
    await box.delete(id);
  }
}
