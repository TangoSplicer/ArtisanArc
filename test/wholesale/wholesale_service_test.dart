import 'package:artisanarc/features/inventory/data/inventory_model.dart';
import 'package:artisanarc/features/inventory/domain/inventory_service.dart';
import 'package:artisanarc/features/wholesale/data/wholesale_model.dart';
import 'package:artisanarc/features/wholesale/data/wholesale_repository.dart';
import 'package:artisanarc/features/wholesale/domain/wholesale_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

class _FakeWholesaleRepo implements WholesaleRepository {
  final Map<String, WholesalePartner> partners = {};
  final Map<String, WholesaleBatch> batches = {};

  @override
  Future<void> deleteBatch(String id) async => batches.remove(id);

  @override
  Future<void> deletePartner(String id) async => partners.remove(id);

  @override
  Future<WholesaleBatch?> getBatchById(String id) async => batches[id];

  @override
  Future<List<WholesaleBatch>> getBatches() async => batches.values.toList();

  @override
  Future<WholesalePartner?> getPartnerById(String id) async => partners[id];

  @override
  Future<List<WholesalePartner>> getPartners() async => partners.values.toList();

  @override
  Future<void> saveBatch(WholesaleBatch batch) async => batches[batch.id] = batch;

  @override
  Future<void> savePartner(WholesalePartner partner) async =>
      partners[partner.id] = partner;
}

class _FakeInventoryService implements InventoryService {
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
  group('WholesaleService Tests', () {
    late _FakeWholesaleRepo wholesaleRepo;
    late _FakeInventoryService inventoryService;
    late WholesaleService wholesaleService;

    setUp(() {
      GetIt.I.reset();
      wholesaleRepo = _FakeWholesaleRepo();
      inventoryService = _FakeInventoryService();
      GetIt.I.registerLazySingleton<WholesaleRepository>(() => wholesaleRepo);
      GetIt.I.registerLazySingleton<InventoryService>(() => inventoryService);
      wholesaleService = WholesaleService();
    });

    test('creates and retrieves wholesale partners', () async {
      await wholesaleService.savePartner(
        id: 'partner-1',
        name: 'Craft & Co Gallery',
        contactName: 'Jane Smith',
        email: 'jane@craftco.test',
        phone: '555-0199',
        address: '123 High Street',
        partnerType: 'consignment',
        commissionRatePercent: 35.0,
      );

      final fetched = await wholesaleService.getPartnerById('partner-1');
      expect(fetched, isNotNull);
      expect(fetched!.name, equals('Craft & Co Gallery'));
      expect(fetched.commissionRatePercent, equals(35.0));
      expect(fetched.partnerType, equals('consignment'));
    });

    test('sends batch, deducts finished inventory stock, and settles returns',
        () async {
      // 1. Setup inventory item with 5 pieces in stock
      final item = InventoryItem(
        id: 'item-1',
        name: 'Amigurumi Bunny',
        category: 'Finished Toys',
        quantity: 5,
        price: 25.0,
        lastUpdated: DateTime.now(),
        itemType: 'finished',
      );
      await inventoryService.createItem(item);

      // 2. Create partner
      await wholesaleService.savePartner(
        id: 'partner-1',
        name: 'Boutique Shop',
        contactName: 'Bob',
        email: 'bob@shop.test',
        phone: '',
        address: '',
        partnerType: 'wholesale',
        commissionRatePercent: 20.0,
      );
      final partner = await wholesaleService.getPartnerById('partner-1');

      // 3. Send batch of 3 pieces
      final batchItem = WholesaleBatchItem(
        id: 'bi-1',
        inventoryItemId: 'item-1',
        itemName: 'Amigurumi Bunny',
        quantitySent: 3,
        quantitySold: 0,
        quantityReturned: 0,
        agreedUnitPrice: 20.0,
      );

      await wholesaleService.createBatch(
        partner: partner!,
        referenceNumber: 'BATCH-001',
        items: [batchItem],
        sentDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 30)),
        notes: 'Test consignment',
      );

      final batches = await wholesaleService.getBatches();
      expect(batches.length, equals(1));
      final batch = batches.first;
      expect(batch.status, equals('sent'));

      // Check that inventory stock was reduced from 5 to 2
      final updatedItem = await inventoryService.getItemById('item-1');
      expect(updatedItem!.quantity, equals(2));

      // 4. Settle batch: 2 sold, 1 returned
      final settledItem = WholesaleBatchItem(
        id: 'bi-1',
        inventoryItemId: 'item-1',
        itemName: 'Amigurumi Bunny',
        quantitySent: 3,
        quantitySold: 2,
        quantityReturned: 1,
        agreedUnitPrice: 20.0,
      );

      await wholesaleService.settleBatch(
        batch: batch,
        settledItems: [settledItem],
        notes: 'Settled successfully',
      );

      final settledBatch = await wholesaleRepo.getBatchById(batch.id);
      expect(settledBatch!.status, equals('settled'));

      // Check that the returned 1 piece was restored to inventory (2 + 1 = 3)
      final finalItem = await inventoryService.getItemById('item-1');
      expect(finalItem!.quantity, equals(3));
    });
  });
}
