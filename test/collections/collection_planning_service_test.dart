import 'package:artisanarc/features/collections/data/maker_collection_model.dart';
import 'package:artisanarc/features/collections/data/maker_collection_repository.dart';
import 'package:artisanarc/features/collections/domain/collection_planning_service.dart';
import 'package:artisanarc/features/inventory/data/inventory_model.dart';
import 'package:artisanarc/features/inventory/domain/inventory_service.dart';
import 'package:artisanarc/features/project/data/production_run_model.dart';
import 'package:artisanarc/features/project/data/production_run_repository.dart';
import 'package:artisanarc/features/project/data/project_model.dart';
import 'package:artisanarc/features/project/domain/entities/supply_need.dart';
import 'package:artisanarc/features/project/domain/project_service.dart';
import 'package:artisanarc/features/recipes/data/make_recipe_model.dart';
import 'package:artisanarc/features/recipes/data/make_recipe_repository.dart';
import 'package:artisanarc/features/recipes/domain/make_recipe_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryCollectionRepository implements MakerCollectionRepository {
  final Map<String, MakerCollection> items = {};

  @override
  Future<void> deleteCollection(String id) async => items.remove(id);

  @override
  Future<MakerCollection?> getCollectionById(String id) async => items[id];

  @override
  Future<List<MakerCollection>> getCollections() async =>
      items.values.toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  @override
  Future<void> saveCollection(MakerCollection collection) async =>
      items[collection.id] = collection;
}

class _MemoryRecipeRepository implements MakeRecipeRepository {
  final Map<String, MakeRecipe> items = {};

  @override
  Future<void> deleteRecipe(String id) async => items.remove(id);

  @override
  Future<MakeRecipe?> getRecipeById(String id) async => items[id];

  @override
  Future<List<MakeRecipe>> getRecipes() async => items.values.toList();

  @override
  Future<void> saveRecipe(MakeRecipe recipe) async => items[recipe.id] = recipe;
}

class _MemoryProjectService implements ProjectService {
  final Map<String, Project> items = {};

  @override
  Future<Project> createProject(Project project) async {
    items[project.id] = project;
    return project;
  }

  @override
  Future<void> deleteProject(String id) async => items.remove(id);

  @override
  Future<List<Project>> fetchProjects() async => items.values.toList();

  @override
  Future<Project?> getProjectById(String id) async => items[id];

  @override
  Future<void> updateProject(Project project) async =>
      items[project.id] = project;
}

class _MemoryProductionRunRepository implements ProductionRunRepository {
  final Map<String, ProductionRun> items = {};

  @override
  Future<void> saveRun(ProductionRun run) async => items[run.id] = run;

  @override
  Future<List<ProductionRun>> getRuns() async => items.values.toList();
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
  test('calculates collection progress, material readiness and capacity',
      () async {
    final collectionRepo = _MemoryCollectionRepository();
    final recipeRepo = _MemoryRecipeRepository();
    final projectService = _MemoryProjectService();
    final productionRepo = _MemoryProductionRunRepository();
    final inventoryService = _MemoryInventoryService();
    final recipeService = MakeRecipeService(recipeRepo, projectService);

    final planningService = CollectionPlanningService(
      collectionRepo,
      recipeRepo,
      recipeService,
      projectService,
      productionRepo,
      inventoryService,
    );

    // Add inventory material
    await inventoryService.createItem(InventoryItem(
      id: 'yarn-1',
      name: 'DK Cotton Yarn',
      category: 'Yarn',
      quantity: 5,
      measuredQuantity: 500,
      measurementUnit: 'grams',
      itemType: 'material',
      lastUpdated: DateTime.now(),
    ));

    // Add Make Recipe
    final recipe = MakeRecipe(
      id: 'recipe-bunny',
      name: 'Amigurumi Bunny',
      productCategory: 'Crochet Amigurumi & Plush',
      craftFocus: 'Crochet',
      defaultOutputQuantity: 1,
      estimatedMakeMinutes: 120,
      supplyNeeds: [
        SupplyNeed(
          id: 'need-1',
          itemName: 'DK Cotton Yarn',
          quantityNeeded: 100,
          unit: 'grams',
          inventoryItemId: 'yarn-1',
          isConsumable: true,
        ),
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await recipeRepo.saveRecipe(recipe);

    // Create Collection
    final collection = await planningService.saveCollection(
      name: 'Spring Amigurumi Run',
      weeklyCapacityMinutes: 300,
      recipeTargets: [
        CollectionRecipeTarget(
          id: 'target-bunny',
          recipeId: recipe.id,
          targetQuantity: 4,
        ),
      ],
    );

    final snapshot = await planningService.getSnapshot(collection);

    expect(snapshot.collection.name, 'Spring Amigurumi Run');
    expect(snapshot.recipeProgress, hasLength(1));
    final progress = snapshot.recipeProgress.first;
    expect(progress.target.targetQuantity, 4);
    expect(progress.remainingQuantity, 4);
    expect(progress.isReadyToMake, isTrue);
    expect(snapshot.estimatedMinutesRemaining, 480); // 4 * 120 mins
    expect(snapshot.availableCapacityMinutes, greaterThanOrEqualTo(300));
  });
}
