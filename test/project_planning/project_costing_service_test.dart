import 'package:artisanarc/features/inventory/data/inventory_model.dart';
import 'package:artisanarc/features/inventory/data/inventory_repository.dart';
import 'package:artisanarc/features/inventory/data/material_purchase_model.dart';
import 'package:artisanarc/features/inventory/data/material_purchase_repository.dart';
import 'package:artisanarc/features/inventory/data/supplier_model.dart';
import 'package:artisanarc/features/inventory/data/supplier_repository.dart';
import 'package:artisanarc/features/inventory/domain/procurement_service.dart';
import 'package:artisanarc/features/project/data/production_run_model.dart';
import 'package:artisanarc/features/project/data/production_run_repository.dart';
import 'package:artisanarc/features/project/data/project_model.dart';
import 'package:artisanarc/features/project/domain/entities/supply_need.dart';
import 'package:artisanarc/features/project/domain/project_costing_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryInventoryRepository implements InventoryRepository {
  @override
  Future<void> addItem(InventoryItem item) async {}

  @override
  Future<void> deleteItem(String id) async {}

  @override
  Future<List<InventoryItem>> getAllItems() async => const [];

  @override
  Future<InventoryItem?> getItemById(String id) async => null;

  @override
  Future<void> updateItem(InventoryItem item) async {}
}

class _MemorySupplierRepository implements SupplierRepository {
  @override
  Future<void> deleteSupplier(String id) async {}

  @override
  Future<List<Supplier>> getSuppliers() async => const [];

  @override
  Future<void> saveSupplier(Supplier supplier) async {}
}

class _MemoryPurchaseRepository implements MaterialPurchaseRepository {
  _MemoryPurchaseRepository(this.purchases);

  final List<MaterialPurchase> purchases;

  @override
  Future<List<MaterialPurchase>> getPurchases({String? inventoryItemId}) async {
    final matches = purchases
        .where((purchase) =>
            inventoryItemId == null ||
            purchase.inventoryItemId == inventoryItemId)
        .toList()
      ..sort((a, b) => b.purchasedAt.compareTo(a.purchasedAt));
    return matches;
  }

  @override
  Future<void> savePurchase(MaterialPurchase purchase) async =>
      purchases.add(purchase);
}

class _MemoryProductionRunRepository implements ProductionRunRepository {
  _MemoryProductionRunRepository(this.runs);

  final List<ProductionRun> runs;

  @override
  Future<List<ProductionRun>> getRuns() async => runs;

  @override
  Future<void> saveRun(ProductionRun run) async => runs.add(run);
}

void main() {
  test(
      'uses planner cost first, falls back to latest local purchase, and keeps historical production separate',
      () async {
    final purchases = _MemoryPurchaseRepository([
      MaterialPurchase(
        id: 'purchase-cotton',
        inventoryItemId: 'cotton',
        materialName: 'Cotton yarn',
        purchasedAt: DateTime(2026, 8, 15),
        quantityPurchased: 2,
        unit: 'ball',
        totalPaid: 10,
      ),
    ]);
    final procurement = ProcurementService(
      _MemoryInventoryRepository(),
      _MemorySupplierRepository(),
      purchases,
    );
    final productionRuns = _MemoryProductionRunRepository([
      ProductionRun(
        id: 'run-1',
        projectId: 'project-1',
        finishedItemId: 'finished-1',
        finishedItemName: 'Tote',
        outputQuantity: 3,
        materialCost: 24,
        completedAt: DateTime(2026, 8, 14),
      ),
    ]);
    final service = ProjectCostingService(procurement, productionRuns);
    final project = Project(
      id: 'project-1',
      name: 'Tote',
      createdAt: DateTime(2026, 8, 1),
      estimatedLabourMinutes: 60,
      labourRatePerHour: 20,
      targetMarginPercent: 50,
      actualLabourMinutes: 90,
      plannedOutputQuantity: 2,
      supplyNeeds: [
        SupplyNeed(
          id: 'explicit',
          itemName: 'Handle webbing',
          quantityNeeded: 3,
          unit: 'metre',
          estimatedCostEach: 4,
        ),
        SupplyNeed(
          id: 'purchase-cost',
          itemName: 'Cotton yarn',
          quantityNeeded: 2,
          unit: 'ball',
          inventoryItemId: 'cotton',
        ),
      ],
    );

    final preview = await service.preview(project);

    expect(preview.supplyLines[0].source, ProjectCostSource.plannerEstimate);
    expect(preview.supplyLines[1].source,
        ProjectCostSource.latestRecordedPurchase);
    expect(preview.estimatedMaterialCost, 22);
    expect(preview.estimatedLabourCost, 20);
    expect(preview.estimatedDirectCost, 42);
    expect(preview.suggestedSalePrice, 84);
    expect(preview.recordedProductionMaterialCost, 24);
    expect(preview.recordedMaterialCostPerItem, 8);
    expect(preview.recordedActualLabourMinutes, 90);
    expect(preview.actualLabourCost, 30);
    expect(preview.actualDirectCost, 52);
    expect(preview.actualPriceFloorPerItem, 26);
    expect(preview.actualSuggestedSalePricePerItem, 52);
  });
}
