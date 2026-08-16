import 'package:artisanarc/features/inventory/data/inventory_model.dart';
import 'package:artisanarc/features/inventory/data/inventory_repository.dart';
import 'package:artisanarc/features/inventory/domain/inventory_csv_import_service.dart';
import 'package:artisanarc/features/export/utils/export_helper.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryInventoryRepository implements InventoryRepository {
  _MemoryInventoryRepository(Iterable<InventoryItem> items)
      : items = {for (final item in items) item.id: item};

  final Map<String, InventoryItem> items;

  @override
  Future<void> addItem(InventoryItem item) async => items[item.id] = item;

  @override
  Future<void> deleteItem(String id) async => items.remove(id);

  @override
  Future<List<InventoryItem>> getAllItems() async => items.values.toList();

  @override
  Future<InventoryItem?> getItemById(String id) async => items[id];

  @override
  Future<void> updateItem(InventoryItem item) async => items[item.id] = item;
}

void main() {
  test(
      'previews valid CSV rows, preserves measured stock, and never overwrites duplicates',
      () async {
    final repository = _MemoryInventoryRepository([
      InventoryItem(
        id: 'existing-tote',
        name: 'Existing Tote',
        category: 'Finished Makes',
        quantity: 1,
        itemType: 'finished',
        lastUpdated: DateTime(2026, 8, 15),
      ),
    ]);
    final service = InventoryCsvImportService(repository);
    const csv = '''Name,Type,Category,Quantity,Price,Location,Unit,Reorder Point
Crochet Bee Keyring,Created Item,Finished Crochet Makes,3,5.00,Display Shelf,,
Cotton Yarn,Material Stock,Yarn & Fibre,125.5,0.02,Yarn Shelf,gram,40
Existing Tote,Created Item,Finished Makes,2,12.00,Display Shelf,,
Broken Item,Created Item,Finished Makes,not-a-number,10.00,Display Shelf,,
''';

    final preview = await service.previewCsv(csv);

    expect(preview.totalDataRows, 4);
    expect(preview.validRowCount, 2);
    expect(preview.skippedRowCount, 1);
    expect(preview.invalidRowCount, 1);
    final yarn =
        preview.items.singleWhere((item) => item.name == 'Cotton Yarn');
    expect(yarn.usesMeasuredQuantity, isTrue);
    expect(yarn.measuredQuantity, 125.5);
    expect(yarn.measurementUnit, 'gram');
    expect(yarn.measuredReorderPoint, 40);

    final imported = await service.importPreview(preview);
    expect(imported, 2);
    expect(
        repository.items.values.where((item) => item.name == 'Existing Tote'),
        hasLength(1));
    expect(repository.items.values.where((item) => item.name == 'Cotton Yarn'),
        hasLength(1));
  });

  test('exports a measured material in a form accepted by the local importer',
      () async {
    final service = InventoryCsvImportService(_MemoryInventoryRepository([]));
    final csv = ExportHelper.generateCsvFromInventory([
      InventoryItem(
        id: 'cotton',
        name: 'Cotton Yarn',
        category: 'Yarn & Fibre',
        quantity: 125,
        measuredQuantity: 125.5,
        measurementUnit: 'gram',
        measuredReorderPoint: 40,
        price: 0.02,
        yarnBrand: 'Willow Yarns',
        yarnRange: 'Soft Cotton',
        yarnColour: 'Sage',
        dyeLot: 'S24-118',
        yarnWeight: 'Light / DK',
        yarnFibre: 'Cotton',
        yarnWeightGrams: 50,
        yarnLengthMetres: 125,
        recommendedHookSize: '4.00 mm',
        gaugeNote: '22 stitches per 10 cm',
        itemType: 'material',
        lastUpdated: DateTime(2026, 8, 15),
      ),
    ]);

    final preview = await service.previewCsv(csv);

    expect(preview.validRowCount, 1);
    expect(preview.items.single.measuredQuantity, 125.5);
    expect(preview.items.single.measurementUnit, 'gram');
    expect(preview.items.single.measuredReorderPoint, 40);
    expect(preview.items.single.yarnBrand, 'Willow Yarns');
    expect(preview.items.single.yarnRange, 'Soft Cotton');
    expect(preview.items.single.yarnColour, 'Sage');
    expect(preview.items.single.dyeLot, 'S24-118');
    expect(preview.items.single.yarnWeight, 'Light / DK');
    expect(preview.items.single.yarnFibre, 'Cotton');
    expect(preview.items.single.yarnWeightGrams, 50);
    expect(preview.items.single.yarnLengthMetres, 125);
    expect(preview.items.single.recommendedHookSize, '4.00 mm');
    expect(preview.items.single.gaugeNote, '22 stitches per 10 cm');
  });
}
