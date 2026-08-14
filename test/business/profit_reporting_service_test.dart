import 'package:artisanarc/features/business/data/business_repository.dart';
import 'package:artisanarc/features/business/data/sale_model.dart';
import 'package:artisanarc/features/business/data/stall_session_model.dart';
import 'package:artisanarc/features/business/data/stall_session_repository.dart';
import 'package:artisanarc/features/business/domain/profit_reporting_service.dart';
import 'package:artisanarc/features/inventory/data/inventory_model.dart';
import 'package:artisanarc/features/inventory/data/inventory_repository.dart';
import 'package:artisanarc/features/project/data/production_run_model.dart';
import 'package:artisanarc/features/project/data/production_run_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeBusinessRepository implements BusinessRepository {
  FakeBusinessRepository(this.sales);

  final List<SaleRecord> sales;

  @override
  Future<void> createSale(SaleRecord sale) async => sales.add(sale);

  @override
  Future<void> deleteSale(String id) async =>
      sales.removeWhere((sale) => sale.id == id);

  @override
  Future<List<SaleRecord>> getSales() async => List.of(sales);

  @override
  Future<void> updateSale(SaleRecord sale) async {
    final index = sales.indexWhere((current) => current.id == sale.id);
    sales[index] = sale;
  }
}

class FakeInventoryRepository implements InventoryRepository {
  FakeInventoryRepository(this.items);

  final List<InventoryItem> items;

  @override
  Future<void> addItem(InventoryItem item) async => items.add(item);

  @override
  Future<void> deleteItem(String id) async =>
      items.removeWhere((item) => item.id == id);

  @override
  Future<List<InventoryItem>> getAllItems() async => List.of(items);

  @override
  Future<InventoryItem?> getItemById(String id) async {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Future<void> updateItem(InventoryItem item) async {
    final index = items.indexWhere((current) => current.id == item.id);
    items[index] = item;
  }
}

class FakeProductionRunRepository implements ProductionRunRepository {
  FakeProductionRunRepository(this.runs);

  final List<ProductionRun> runs;

  @override
  Future<List<ProductionRun>> getRuns() async => List.of(runs);

  @override
  Future<void> saveRun(ProductionRun run) async => runs.add(run);
}

class FakeSessionRepository implements StallSessionRepository {
  FakeSessionRepository(this.sessions);

  final List<StallSession> sessions;

  @override
  Future<StallSession?> getActiveSession() async => null;

  @override
  Future<StallSession?> getSessionById(String id) async {
    for (final session in sessions) {
      if (session.id == id) return session;
    }
    return null;
  }

  @override
  Future<List<StallSession>> getSessions() async => List.of(sessions);

  @override
  Future<void> saveSession(StallSession session) async => sessions.add(session);
}

void main() {
  test(
      'calculates material-cost profit, session direct costs, and finished stock movements',
      () async {
    final now = DateTime(2026, 8, 15, 12);
    final item = InventoryItem(
      id: 'bee',
      name: 'Crochet Bee Keyring',
      category: 'Finished Crochet Makes',
      quantity: 2,
      price: 5,
      lastUpdated: now,
      itemType: 'finished',
    );
    final sales = [
      SaleRecord(
        id: 'sale-1',
        itemId: 'bee',
        quantity: 2,
        pricePerUnit: 5,
        date: now,
        sessionId: 'market',
        paymentMethod: 'cash',
      ),
      SaleRecord(
        id: 'return-1',
        itemId: 'bee',
        quantity: 1,
        pricePerUnit: 5,
        date: now.add(const Duration(minutes: 5)),
        sessionId: 'market',
        paymentMethod: 'cash',
        isReturn: true,
        relatedSaleId: 'sale-1',
      ),
    ];
    final service = ProfitReportingService(
      FakeBusinessRepository(sales),
      FakeInventoryRepository([item]),
      FakeProductionRunRepository([
        ProductionRun(
          id: 'run-1',
          projectId: 'project-1',
          finishedItemId: 'bee',
          finishedItemName: item.name,
          outputQuantity: 3,
          materialCost: 6,
          completedAt: now.subtract(const Duration(days: 1)),
        ),
      ]),
      FakeSessionRepository([
        StallSession(
          id: 'market',
          name: 'Saturday Market',
          startedAt: now,
          tableFee: 1,
          travelCost: 1,
        ),
      ]),
    );

    final summary = await service.getSummary();
    final performance = await service.getItemPerformance();
    final sessions = await service.getSessionProfitability();
    final movements = await service.getFinishedItemMovements();

    expect(summary.revenue, 5);
    expect(summary.materialCostOfSales, 2);
    expect(summary.grossProfit, 3);
    expect(summary.itemsSold, 1);
    expect(performance.single.profit, 3);
    expect(performance.single.remainingQuantity, 2);
    expect(sessions.single.profitAfterDirectCosts, 1);
    expect(movements.map((movement) => movement.quantityChange),
        containsAll([3, -2, 1]));
  });
}
