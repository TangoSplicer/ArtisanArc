import 'package:artisanarc/features/inventory/data/inventory_model.dart';
import 'package:artisanarc/features/inventory/data/inventory_repository.dart';
import 'package:artisanarc/features/inventory/data/material_purchase_model.dart';
import 'package:artisanarc/features/inventory/data/material_purchase_repository.dart';
import 'package:artisanarc/features/inventory/data/supplier_model.dart';
import 'package:artisanarc/features/inventory/data/supplier_repository.dart';
import 'package:artisanarc/features/inventory/domain/procurement_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryInventoryRepository implements InventoryRepository {
  _MemoryInventoryRepository(InventoryItem item) : _items = {item.id: item};

  final Map<String, InventoryItem> _items;

  @override
  Future<void> addItem(InventoryItem item) async => _items[item.id] = item;

  @override
  Future<void> deleteItem(String id) async => _items.remove(id);

  @override
  Future<List<InventoryItem>> getAllItems() async => _items.values.toList();

  @override
  Future<InventoryItem?> getItemById(String id) async => _items[id];

  @override
  Future<void> updateItem(InventoryItem item) async => _items[item.id] = item;
}

class _MemorySupplierRepository implements SupplierRepository {
  final Map<String, Supplier> _suppliers = {};

  @override
  Future<void> deleteSupplier(String id) async => _suppliers.remove(id);

  @override
  Future<List<Supplier>> getSuppliers() async => _suppliers.values.toList();

  @override
  Future<void> saveSupplier(Supplier supplier) async =>
      _suppliers[supplier.id] = supplier;
}

class _MemoryPurchaseRepository implements MaterialPurchaseRepository {
  final List<MaterialPurchase> purchases = [];

  @override
  Future<List<MaterialPurchase>> getPurchases(
          {String? inventoryItemId}) async =>
      purchases
          .where((purchase) =>
              inventoryItemId == null ||
              purchase.inventoryItemId == inventoryItemId)
          .toList();

  @override
  Future<void> savePurchase(MaterialPurchase purchase) async =>
      purchases.add(purchase);
}

void main() {
  late InventoryItem cotton;
  late _MemoryInventoryRepository inventory;
  late _MemoryPurchaseRepository purchases;
  late ProcurementService service;

  setUp(() {
    cotton = InventoryItem(
      id: 'cotton',
      name: 'Cotton yarn',
      category: 'Yarn & Fibre',
      quantity: 100,
      itemType: 'material',
      lastUpdated: DateTime(2026, 8, 15),
    );
    inventory = _MemoryInventoryRepository(cotton);
    purchases = _MemoryPurchaseRepository();
    service =
        ProcurementService(inventory, _MemorySupplierRepository(), purchases);
  });

  test(
      'records a local purchase, updates measured material stock, and stores a transparent unit cost',
      () async {
    final supplier = await service.saveSupplier(name: 'Local Yarn Shop');
    final purchase = await service.recordPurchase(
      material: cotton,
      supplier: supplier,
      quantityPurchased: 50,
      unit: 'gram',
      totalPaid: 5,
      note: 'Natural cotton refill',
    );

    final updated = (await inventory.getItemById('cotton'))!;
    expect(purchase.unitCost, 0.10);
    expect(updated.measuredQuantity, 150);
    expect(updated.measurementUnit, 'gram');
    expect(updated.price, 0.10);
    expect(purchases.purchases.single.supplierName, 'Local Yarn Shop');
    expect(purchases.purchases.single.note, 'Natural cotton refill');
  });

  test(
      'rejects a purchase recorded in a different unit from existing measured stock',
      () async {
    final measured =
        cotton.copyWith(measuredQuantity: 100, measurementUnit: 'gram');
    await inventory.updateItem(measured);

    await expectLater(
      service.recordPurchase(
        material: measured,
        quantityPurchased: 1,
        unit: 'metre',
        totalPaid: 2,
      ),
      throwsA(isA<StateError>()),
    );
  });
}
