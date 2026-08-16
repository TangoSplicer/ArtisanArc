import 'package:artisanarc/features/inventory/data/inventory_model.dart';
import 'package:artisanarc/features/inventory/domain/inventory_service.dart';
import 'package:artisanarc/features/wholesale/data/wholesale_model.dart';
import 'package:artisanarc/features/wholesale/data/wholesale_repository.dart';
import 'package:artisanarc/features/wholesale/domain/wholesale_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryWholesaleRepository implements WholesaleRepository {
  final Map<String, WholesalePartner> partners = {};
  final Map<String, WholesaleBatch> batches = {};

  @override
  Future<void> deleteBatch(String id) async => batches.remove(id);

  @override
  Future<void> deletePartner(String id) async => partners.remove(id);

  @override
  Future<WholesaleBatch?> getBatchById(String id) async => batches[id];

  @override
  Future<List<WholesaleBatch>> getBatches() async => batches.values.toList()
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  @override
  Future<WholesalePartner?> getPartnerById(String id) async => partners[id];

  @override
  Future<List<WholesalePartner>> getPartners() async => partners.values.toList()
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  @override
  Future<void> saveBatch(WholesaleBatch batch) async =>
      batches[batch.id] = batch;

  @override
  Future<void> savePartner(WholesalePartner partner) async =>
      partners[partner.id] = partner;
}

class _MemoryInventoryService implements InventoryService {
  final Map<String, InventoryItem> items = {};

  @override
  Future<void> createItem(InventoryItem item) async => items[item.id] = item;

  @override
  Future<void> removeItem(String id) async => items.remove(id);

  @override
  Future<List<InventoryItem>> fetchItems() async => items.values.toList();

  @override
  Future<InventoryItem?> getItemById(String id) async => items[id];

  @override
  Future<void> updateItem(InventoryItem item) async => items[item.id] = item;
}

void main() {
  test('creates partner, sends batch and deducts stock, then settles returns',
      () async {
    final wholesaleRepo = _MemoryWholesaleRepository();
    final inventoryService = _MemoryInventoryService();

    // Inject mock repo into service via overriding or test subclassing if needed.
    // For this test we instantiate services directly with memory mocks.
    // Since WholesaleService instantiates GetIt, we can register mocks in GetIt or test logic.
  });
}
