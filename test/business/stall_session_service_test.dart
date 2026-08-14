import 'package:artisanarc/features/business/data/business_repository.dart';
import 'package:artisanarc/features/business/data/sale_model.dart';
import 'package:artisanarc/features/business/data/stall_session_model.dart';
import 'package:artisanarc/features/business/data/stall_session_repository.dart';
import 'package:artisanarc/features/business/domain/stall_session_service.dart';
import 'package:artisanarc/features/inventory/data/inventory_model.dart';
import 'package:artisanarc/features/inventory/data/inventory_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryBusinessRepository implements BusinessRepository {
  final Map<String, SaleRecord> _sales = {};

  @override
  Future<void> createSale(SaleRecord sale) async => _sales[sale.id] = sale;

  @override
  Future<void> deleteSale(String id) async => _sales.remove(id);

  @override
  Future<List<SaleRecord>> getSales() async => _sales.values.toList();

  @override
  Future<void> updateSale(SaleRecord sale) async => _sales[sale.id] = sale;
}

class MemoryInventoryRepository implements InventoryRepository {
  MemoryInventoryRepository(Iterable<InventoryItem> initial)
      : _items = {for (final item in initial) item.id: item};

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

class MemoryStallSessionRepository implements StallSessionRepository {
  final Map<String, StallSession> _sessions = {};

  @override
  Future<StallSession?> getActiveSession() async {
    final active = _sessions.values
        .where((session) => !session.isClosed)
        .toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return active.isEmpty ? null : active.first;
  }

  @override
  Future<StallSession?> getSessionById(String id) async => _sessions[id];

  @override
  Future<List<StallSession>> getSessions() async => _sessions.values.toList();

  @override
  Future<void> saveSession(StallSession session) async =>
      _sessions[session.id] = session;
}

InventoryItem finishedItem({int quantity = 5}) => InventoryItem(
      id: 'bee',
      name: 'Crochet Bee Keyring',
      category: 'Finished Crochet Makes',
      quantity: quantity,
      price: 5.0,
      lastUpdated: DateTime(2026, 8, 15),
      itemType: 'finished',
    );

void main() {
  late MemoryStallSessionRepository sessions;
  late MemoryBusinessRepository sales;
  late MemoryInventoryRepository inventory;
  late StallSessionService service;

  setUp(() {
    sessions = MemoryStallSessionRepository();
    sales = MemoryBusinessRepository();
    inventory = MemoryInventoryRepository([finishedItem()]);
    service = StallSessionService(sessions, sales, inventory);
  });

  test(
      'records discounted basket sale, reduces tally, returns stock and calculates cash-up',
      () async {
    final session = await service.startSession(
      name: 'Saturday Makers Market',
      venue: 'Table 12',
      cashFloat: 10,
      tableFee: 15,
      travelCost: 5,
    );
    final item = (await inventory.getItemById('bee'))!;

    final records = await service.recordBasket(
      session: session,
      basket: {item: 2},
      paymentMethod: 'cash',
      discountAmount: 1,
    );

    expect(records.single.total, 9.0);
    expect((await inventory.getItemById('bee'))!.quantity, 3);
    var summary = await service.getSummary(session);
    expect(summary.netRevenue, 9.0);
    expect(summary.cashRevenue, 9.0);
    expect(summary.expectedCash, 19.0);
    expect(summary.netAfterDirectCosts, -11.0);

    final returned = await service.returnSale(
      originalSale: records.single,
      quantity: 1,
      reason: 'Customer changed their mind',
    );

    expect(returned.total, -4.5);
    expect((await inventory.getItemById('bee'))!.quantity, 4);
    summary = await service.getSummary(session);
    expect(summary.netRevenue, 4.5);
    expect(summary.expectedCash, 14.5);
    expect(summary.itemsReturned, 1);

    final closed = await service.closeSession(
      session: session,
      countedCash: 14.5,
      notes: 'All balanced.',
    );
    expect(closed.isClosed, isTrue);
    expect((await service.getSummary(closed)).cashDifference, 0.0);
  });

  test('void preserves the audit record, excludes revenue and restores tally',
      () async {
    final session = await service.startSession(name: 'Village Hall Fair');
    final item = (await inventory.getItemById('bee'))!;
    final sale = (await service.recordBasket(
      session: session,
      basket: {item: 1},
      paymentMethod: 'card',
    ))
        .single;

    final voided =
        await service.voidSale(sale: sale, reason: 'Duplicate entry');

    expect(voided.isVoid, isTrue);
    expect(voided.total, 0.0);
    expect((await inventory.getItemById('bee'))!.quantity, 5);
    final summary = await service.getSummary(session);
    expect(summary.netRevenue, 0.0);
    expect(summary.itemsSold, 0);
  });
}
