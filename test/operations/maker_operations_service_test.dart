import 'package:artisanarc/features/business/data/business_repository.dart';
import 'package:artisanarc/features/business/data/sale_model.dart';
import 'package:artisanarc/features/business/data/stall_session_model.dart';
import 'package:artisanarc/features/business/data/stall_session_repository.dart';
import 'package:artisanarc/features/business/domain/business_service.dart';
import 'package:artisanarc/features/business/domain/stall_session_service.dart';
import 'package:artisanarc/features/commissions/data/commission_model.dart';
import 'package:artisanarc/features/commissions/data/commission_repository.dart';
import 'package:artisanarc/features/commissions/domain/commission_service.dart';
import 'package:artisanarc/features/inventory/data/inventory_model.dart';
import 'package:artisanarc/features/inventory/data/inventory_repository.dart';
import 'package:artisanarc/features/inventory/domain/inventory_service.dart';
import 'package:artisanarc/features/operations/domain/maker_operations_service.dart';
import 'package:artisanarc/features/project/data/project_model.dart';
import 'package:artisanarc/features/project/data/project_repository.dart';
import 'package:artisanarc/features/project/domain/project_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _InventoryRepository implements InventoryRepository {
  _InventoryRepository(Iterable<InventoryItem> values)
      : items = {for (final item in values) item.id: item};

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

class _ProjectRepository implements ProjectRepository {
  _ProjectRepository(Iterable<Project> values)
      : projects = {for (final project in values) project.id: project};

  final Map<String, Project> projects;

  @override
  Future<void> deleteProject(String id) async => projects.remove(id);
  @override
  Future<List<Project>> getAllProjects() async => projects.values.toList();
  @override
  Future<Project?> getProjectById(String id) async => projects[id];
  @override
  Future<void> saveProject(Project project) async =>
      projects[project.id] = project;
}

class _CommissionRepository implements CommissionRepository {
  final Map<String, Commission> records = {};

  @override
  Future<void> deleteCommission(String id) async => records.remove(id);
  @override
  Future<Commission?> getCommissionById(String id) async => records[id];
  @override
  Future<List<Commission>> getCommissions() async => records.values.toList();
  @override
  Future<void> saveCommission(Commission commission) async =>
      records[commission.id] = commission;
}

class _BusinessService implements BusinessService {
  _BusinessService(this.sales);
  final List<SaleRecord> sales;

  @override
  double calculateTotalRevenue(List<SaleRecord> records) =>
      records.fold(0, (total, sale) => total + sale.total);
  @override
  Future<void> createSale(SaleRecord record) async => sales.add(record);
  @override
  Future<List<SaleRecord>> fetchSales() async => sales;
}

class _BusinessRepository implements BusinessRepository {
  @override
  Future<void> createSale(SaleRecord sale) async {}
  @override
  Future<void> deleteSale(String id) async {}
  @override
  Future<List<SaleRecord>> getSales() async => const [];
  @override
  Future<void> updateSale(SaleRecord sale) async {}
}

class _StallRepository implements StallSessionRepository {
  _StallRepository(this.active);
  final StallSession? active;

  @override
  Future<StallSession?> getActiveSession() async => active;
  @override
  Future<StallSession?> getSessionById(String id) async =>
      active?.id == id ? active : null;
  @override
  Future<List<StallSession>> getSessions() async =>
      active == null ? const [] : [active!];
  @override
  Future<void> saveSession(StallSession session) async {}
}

void main() {
  test(
      'aggregates actionable local stock, deadlines, sales and active-stall work',
      () async {
    final inventory = InventoryServiceImpl(_InventoryRepository([
      InventoryItem(
        id: 'low-yarn',
        name: 'Cotton Yarn',
        category: 'Yarn & Fibre',
        quantity: 2,
        itemType: 'material',
        reorderPoint: 3,
        lastUpdated: DateTime(2026, 8, 15),
      ),
      InventoryItem(
        id: 'finished',
        name: 'Tote',
        category: 'Finished Makes',
        quantity: 1,
        itemType: 'finished',
        lastUpdated: DateTime(2026, 8, 15),
      ),
    ]));
    final projects = ProjectServiceImpl(_ProjectRepository([
      Project(
        id: 'overdue',
        name: 'Overdue project',
        endDate: DateTime(2026, 8, 14),
        createdAt: DateTime(2026, 8, 1),
      ),
      Project(
        id: 'soon',
        name: 'Soon project',
        endDate: DateTime(2026, 8, 21),
        createdAt: DateTime(2026, 8, 1),
      ),
    ]));
    final commissionRepository = _CommissionRepository();
    final commissions = CommissionService(commissionRepository);
    await commissions.saveCommission(
      customerName: 'Overdue order',
      totalAmount: 30,
      dueDate: DateTime(2026, 8, 14),
    );
    await commissions.saveCommission(
      customerName: 'Soon order',
      totalAmount: 40,
      dueDate: DateTime(2026, 8, 20),
      status: CommissionStatus.confirmed,
    );
    final stall = StallSessionService(
      _StallRepository(StallSession(
        id: 'active-stall',
        name: 'Town Hall Market',
        venue: 'Table 12',
        startedAt: DateTime(2026, 8, 15),
      )),
      _BusinessRepository(),
      _InventoryRepository(const []),
    );
    final service = MakerOperationsService(
      inventory,
      projects,
      commissions,
      _BusinessService([
        SaleRecord(
          id: 'this-week',
          itemId: 'finished',
          quantity: 2,
          pricePerUnit: 10,
          date: DateTime(2026, 8, 12),
        ),
        SaleRecord(
          id: 'last-week',
          itemId: 'finished',
          quantity: 1,
          pricePerUnit: 8,
          date: DateTime(2026, 8, 1),
        ),
      ]),
      stall,
    );

    final snapshot = await service.getSnapshot(now: DateTime(2026, 8, 15));

    expect(snapshot.lowMaterials.single.id, 'low-yarn');
    expect(snapshot.overdueProjects.single.id, 'overdue');
    expect(snapshot.projectsDueSoon.single.id, 'soon');
    expect(snapshot.overdueCommissions, hasLength(1));
    expect(snapshot.commissionsDueSoon, hasLength(1));
    expect(snapshot.salesThisWeek, 20);
    expect(snapshot.activeStall?.id, 'active-stall');
    expect(snapshot.urgentActionCount, 3);
  });
}
