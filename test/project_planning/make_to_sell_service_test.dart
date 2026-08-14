import 'package:artisanarc/features/inventory/data/inventory_model.dart';
import 'package:artisanarc/features/inventory/data/inventory_repository.dart';
import 'package:artisanarc/features/project/data/project_model.dart';
import 'package:artisanarc/features/project/data/project_repository.dart';
import 'package:artisanarc/features/project/domain/entities/supply_need.dart';
import 'package:artisanarc/features/project/domain/make_to_sell_service.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryInventoryRepository implements InventoryRepository {
  MemoryInventoryRepository(Iterable<InventoryItem> initialItems)
      : _items = {for (final item in initialItems) item.id: item};

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

class MemoryProjectRepository implements ProjectRepository {
  MemoryProjectRepository(Iterable<Project> initialProjects)
      : _projects = {
          for (final project in initialProjects) project.id: project
        };

  final Map<String, Project> _projects;

  @override
  Future<void> deleteProject(String id) async => _projects.remove(id);

  @override
  Future<List<Project>> getAllProjects() async => _projects.values.toList();

  @override
  Future<Project?> getProjectById(String id) async => _projects[id];

  @override
  Future<void> saveProject(Project project) async =>
      _projects[project.id] = project;
}

InventoryItem material({
  required String id,
  required String name,
  required int quantity,
}) {
  return InventoryItem(
    id: id,
    name: name,
    category: 'Yarn & Fibre',
    quantity: quantity,
    lastUpdated: DateTime(2026, 8, 15),
    itemType: 'material',
  );
}

Project projectWithSupplies({required List<SupplyNeed> supplyNeeds}) {
  return Project(
    id: 'project-tote',
    name: 'Crochet Market Tote',
    craftType: 'Crochet',
    supplyNeeds: supplyNeeds,
    createdAt: DateTime(2026, 8, 15),
  );
}

void main() {
  group('MakeToSellService', () {
    test(
        'deducts linked consumables, keeps reusable tools, and creates a finished tally',
        () async {
      final inventory = MemoryInventoryRepository([
        material(id: 'cotton', name: 'Cotton yarn', quantity: 5),
        material(id: 'hook', name: '4 mm hook', quantity: 1),
      ]);
      final project = projectWithSupplies(
        supplyNeeds: [
          SupplyNeed(
            id: 'cotton-need',
            itemName: 'Cotton yarn',
            quantityNeeded: 2.0,
            unit: 'ball',
            inventoryItemId: 'cotton',
          ),
          SupplyNeed(
            id: 'hook-need',
            itemName: '4 mm hook',
            quantityNeeded: 1.0,
            unit: 'piece',
            inventoryItemId: 'hook',
            isConsumable: false,
          ),
        ],
      );
      final projects = MemoryProjectRepository([project]);
      final service = MakeToSellService(inventory, projects);

      final result = await service.complete(
        project: project,
        outputQuantity: 2,
        salePrice: 18.0,
        notes: 'One extra square was kept as a sample.',
      );

      expect((await inventory.getItemById('cotton'))!.quantity, 1);
      expect((await inventory.getItemById('hook'))!.quantity, 1);
      expect(result.finishedItem.itemType, 'finished');
      expect(result.finishedItem.quantity, 2);
      expect(result.finishedItem.category, 'Finished Crochet Makes');
      expect(result.finishedItem.price, 18.0);
      expect(result.updatedProject.finishedItemIds, [result.finishedItem.id]);
      expect(result.updatedProject.productionNotes.single,
          contains('One extra square'));
      expect(
          (await projects.getProjectById(project.id))!.finishedItemIds.single,
          result.finishedItem.id);
    });

    test(
        'does not write material, finished, or project records when linked stock is short',
        () async {
      final inventory = MemoryInventoryRepository([
        material(id: 'cotton', name: 'Cotton yarn', quantity: 1),
      ]);
      final project = projectWithSupplies(
        supplyNeeds: [
          SupplyNeed(
            id: 'cotton-need',
            itemName: 'Cotton yarn',
            quantityNeeded: 2.0,
            unit: 'ball',
            inventoryItemId: 'cotton',
          ),
        ],
      );
      final projects = MemoryProjectRepository([project]);
      final service = MakeToSellService(inventory, projects);

      await expectLater(
        service.complete(project: project, outputQuantity: 1),
        throwsA(isA<StateError>()),
      );

      expect((await inventory.getItemById('cotton'))!.quantity, 1);
      expect(
          (await inventory.getAllItems()).where((item) => item.isFinishedItem),
          isEmpty);
      expect((await projects.getProjectById(project.id))!.finishedItemIds,
          isEmpty);
    });
  });
}
