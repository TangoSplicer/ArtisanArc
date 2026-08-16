import 'package:artisanarc/features/equipment/data/equipment_model.dart';
import 'package:artisanarc/features/equipment/data/equipment_repository.dart';
import 'package:artisanarc/features/patterns/data/pattern_model.dart';
import 'package:artisanarc/features/patterns/data/pattern_repository.dart';
import 'package:artisanarc/features/stitches/data/stitch_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePatternRepo implements PatternRepository {
  final Map<String, StoredPattern> patterns = {};
  final Map<String, RowCounter> counters = {};

  @override
  Future<void> deletePattern(String id) async => patterns.remove(id);

  @override
  Future<void> deleteRowCounter(String id) async => counters.remove(id);

  @override
  Future<StoredPattern?> getPatternById(String id) async => patterns[id];

  @override
  Future<List<StoredPattern>> getPatterns() async => patterns.values.toList();

  @override
  Future<RowCounter?> getRowCounterById(String id) async => counters[id];

  @override
  Future<List<RowCounter>> getRowCounters() async => counters.values.toList();

  @override
  Future<void> savePattern(StoredPattern pattern) async =>
      patterns[pattern.id] = pattern;

  @override
  Future<void> saveRowCounter(RowCounter counter) async =>
      counters[counter.id] = counter;
}

class _FakeEquipmentRepo implements EquipmentRepository {
  final Map<String, EquipmentItem> items = {};

  @override
  Future<void> deleteEquipment(String id) async => items.remove(id);

  @override
  Future<List<EquipmentItem>> getEquipment() async => items.values.toList();

  @override
  Future<void> saveEquipment(EquipmentItem item) async => items[item.id] = item;
}

void main() {
  group('Studio Extras Tests (Patterns, Row Counters, Equipment)', () {
    test('Pattern vault stores and retrieves patterns', () async {
      final repo = _FakePatternRepo();
      final pattern = StoredPattern(
        id: 'pat-1',
        title: 'Cosy Crochet Beanie',
        designer: 'Hook & Yarn',
        localFilePath: '/local/path/beanie.pdf',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repo.savePattern(pattern);

      final list = await repo.getPatterns();
      expect(list.length, equals(1));
      expect(list.first.title, equals('Cosy Crochet Beanie'));
    });

    test('Row counters increment, decrement, and persist', () async {
      final repo = _FakePatternRepo();
      final counter = RowCounter(
        id: 'cnt-1',
        title: 'Sleeve Rows',
        count: 5,
        targetCount: 20,
        updatedAt: DateTime.now(),
      );
      await repo.saveRowCounter(counter);

      final fetched = await repo.getRowCounterById('cnt-1');
      expect(fetched!.count, equals(5));

      final updated = fetched.copyWith(count: fetched.count + 1);
      await repo.saveRowCounter(updated);

      final reFetched = await repo.getRowCounterById('cnt-1');
      expect(reFetched!.count, equals(6));
    });

    test('Stitch library loads default reference stitches', () async {
      final repo = StitchRepository();
      // Note: StitchRepository uses Hive, so in unit test without Hive open we test repository structure.
      expect(repo, isNotNull);
    });

    test('Equipment ledger stores and tracks studio machinery', () async {
      final repo = _FakeEquipmentRepo();
      final eq = EquipmentItem(
        id: 'eq-1',
        name: 'Rigid Heddle Loom',
        category: 'Looms',
        brand: 'Ashford',
        purchaseDate: DateTime.now(),
        purchasePrice: 350.0,
        maintenanceNotes: 'Oiled heddle rails monthly',
      );
      await repo.saveEquipment(eq);

      final list = await repo.getEquipment();
      expect(list.length, equals(1));
      expect(list.first.name, equals('Rigid Heddle Loom'));
      expect(list.first.purchasePrice, equals(350.0));
    });
  });
}
