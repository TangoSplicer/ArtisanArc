import 'dart:math' as math;

import 'package:uuid/uuid.dart';

import '../../inventory/data/inventory_model.dart';
import '../../inventory/domain/inventory_service.dart';
import '../../project/data/production_run_model.dart';
import '../../project/data/production_run_repository.dart';
import '../../project/data/project_model.dart';
import '../../project/domain/entities/supply_need.dart';
import '../../project/domain/project_service.dart';
import '../../recipes/data/make_recipe_model.dart';
import '../../recipes/data/make_recipe_repository.dart';
import '../../recipes/domain/make_recipe_service.dart';
import '../data/maker_collection_model.dart';
import '../data/maker_collection_repository.dart';

class CollectionPlanningSnapshot {
  const CollectionPlanningSnapshot({
    required this.collection,
    required this.recipeProgress,
    required this.estimatedMinutesRemaining,
    required this.availableCapacityMinutes,
    required this.weeksRemaining,
  });

  final MakerCollection collection;
  final List<CollectionRecipeProgress> recipeProgress;
  final int estimatedMinutesRemaining;
  final int availableCapacityMinutes;
  final int weeksRemaining;

  bool get isWithinCapacity =>
      estimatedMinutesRemaining <= availableCapacityMinutes;

  int get capacityDifferenceMinutes =>
      availableCapacityMinutes - estimatedMinutesRemaining;

  List<CollectionRecipeProgress> get recommendedNextMakes => recipeProgress
      .where((progress) => progress.remainingQuantity > 0)
      .toList(growable: false)
    ..sort((a, b) {
      if (a.isReadyToMake != b.isReadyToMake) {
        return a.isReadyToMake ? -1 : 1;
      }
      return b.estimatedMinutesRemaining.compareTo(a.estimatedMinutesRemaining);
    });
}

class CollectionRecipeProgress {
  const CollectionRecipeProgress({
    required this.target,
    required this.recipe,
    required this.producedQuantity,
    required this.remainingQuantity,
    required this.estimatedMinutesRemaining,
    required this.materialReadiness,
    required this.activeProjectCount,
  });

  final CollectionRecipeTarget target;
  final MakeRecipe recipe;
  final int producedQuantity;
  final int remainingQuantity;
  final int estimatedMinutesRemaining;
  final List<CollectionMaterialReadiness> materialReadiness;
  final int activeProjectCount;

  bool get isReadyToMake => materialReadiness.every((status) => status.isReady);

  int get suggestedBatchQuantity => math.max(1,
      math.min(remainingQuantity, math.max(1, recipe.defaultOutputQuantity)));

  String get statusLabel {
    if (remainingQuantity <= 0) return 'Target reached';
    if (!isReadyToMake) return 'Needs materials';
    if (activeProjectCount > 0) return 'Project in progress';
    return 'Ready to make';
  }
}

class CollectionMaterialReadiness {
  const CollectionMaterialReadiness({
    required this.supplyNeed,
    required this.requiredQuantity,
    required this.inventoryItem,
    required this.isUnitCompatible,
  });

  final SupplyNeed supplyNeed;
  final double requiredQuantity;
  final InventoryItem? inventoryItem;
  final bool isUnitCompatible;

  bool get isLinked => inventoryItem != null;
  bool get isReady =>
      !supplyNeed.isConsumable ||
      (isLinked &&
          isUnitCompatible &&
          inventoryItem!.availableStockQuantity >= requiredQuantity);

  String get issue {
    if (!supplyNeed.isConsumable) return 'Reusable tool';
    if (!isLinked) return 'Link this material in the Make Recipe.';
    if (!isUnitCompatible) {
      return 'Tracked in ${inventoryItem!.measurementUnit}; recipe uses ${supplyNeed.unit}.';
    }
    final short = requiredQuantity - inventoryItem!.availableStockQuantity;
    if (short > 0) return 'Short by ${_format(short)} ${supplyNeed.unit}.';
    return 'Ready';
  }

  static String _format(double amount) => amount == amount.roundToDouble()
      ? amount.toInt().toString()
      : amount.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '');
}

/// Uses only local Hive-backed records to plan a production collection. It does
/// not reserve, deduct, or alter materials until a maker deliberately creates
/// and completes a project through the existing workflow.
class CollectionPlanningService {
  CollectionPlanningService(
    this._collectionRepository,
    this._recipeRepository,
    this._recipeService,
    this._projectService,
    this._productionRunRepository,
    this._inventoryService,
  );

  final MakerCollectionRepository _collectionRepository;
  final MakeRecipeRepository _recipeRepository;
  final MakeRecipeService _recipeService;
  final ProjectService _projectService;
  final ProductionRunRepository _productionRunRepository;
  final InventoryService _inventoryService;
  final Uuid _uuid = const Uuid();

  Future<List<MakerCollection>> getCollections() =>
      _collectionRepository.getCollections();

  Future<MakerCollection?> getCollectionById(String id) =>
      _collectionRepository.getCollectionById(id);

  Future<MakerCollection> saveCollection({
    String? id,
    required String name,
    String? description,
    String? season,
    DateTime? targetDate,
    required int weeklyCapacityMinutes,
    required List<CollectionRecipeTarget> recipeTargets,
    MakerCollection? existing,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) throw ArgumentError('Collection name is required.');
    if (weeklyCapacityMinutes < 1) {
      throw ArgumentError('Weekly capacity must be at least one minute.');
    }
    final recipeIds = recipeTargets.map((target) => target.recipeId).toSet();
    if (recipeIds.length != recipeTargets.length ||
        recipeTargets.any((target) => target.targetQuantity < 1)) {
      throw ArgumentError('Each recipe needs one positive, unique target.');
    }
    final now = DateTime.now();
    final collection = MakerCollection(
      id: id ?? existing?.id ?? _uuid.v4(),
      name: cleanName,
      description: _clean(description),
      season: _clean(season),
      targetDate: targetDate,
      weeklyCapacityMinutes: weeklyCapacityMinutes,
      recipeTargets: List.unmodifiable(recipeTargets),
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    await _collectionRepository.saveCollection(collection);
    return collection;
  }

  Future<void> deleteCollection(String id) =>
      _collectionRepository.deleteCollection(id);

  Future<Project> createProjectForRecipeTarget({
    required MakerCollection collection,
    required MakeRecipe recipe,
  }) async {
    final project = await _recipeService.createProjectFromRecipe(recipe);
    final linked = project.copyWith(
      collectionId: collection.id,
      lastUpdatedAt: DateTime.now(),
    );
    await _projectService.updateProject(linked);
    return linked;
  }

  Future<CollectionPlanningSnapshot> getSnapshot(
    MakerCollection collection, {
    DateTime? now,
  }) async {
    final current = now ?? DateTime.now();
    final results = await Future.wait<dynamic>([
      _recipeRepository.getRecipes(),
      _projectService.fetchProjects(),
      _productionRunRepository.getRuns(),
      _inventoryService.fetchItems(),
    ]);
    final recipes = results[0] as List<MakeRecipe>;
    final projects = results[1] as List<Project>;
    final runs = results[2] as List<ProductionRun>;
    final inventory = results[3] as List<InventoryItem>;
    final recipesById = {for (final recipe in recipes) recipe.id: recipe};
    final projectsById = {
      for (final project in projects.where((project) =>
          project.collectionId == collection.id && project.recipeId != null))
        project.id: project,
    };
    final producedByRecipeId = <String, int>{};
    for (final run in runs) {
      final project = projectsById[run.projectId];
      final recipeId = project?.recipeId;
      if (recipeId != null) {
        producedByRecipeId[recipeId] =
            (producedByRecipeId[recipeId] ?? 0) + run.outputQuantity;
      }
    }
    final activeByRecipeId = <String, int>{};
    for (final project in projectsById.values) {
      if (_isProjectActive(project)) {
        final recipeId = project.recipeId!;
        activeByRecipeId[recipeId] = (activeByRecipeId[recipeId] ?? 0) + 1;
      }
    }
    final inventoryById = {
      for (final item in inventory.where((item) => !item.isArchived))
        item.id: item,
    };
    final progress = <CollectionRecipeProgress>[];
    for (final target in collection.recipeTargets) {
      final recipe = recipesById[target.recipeId];
      if (recipe == null) continue;
      final produced = producedByRecipeId[recipe.id] ?? 0;
      final remaining = math.max(0, target.targetQuantity - produced);
      final batchQuantity = math.max(
          1, math.min(remaining, math.max(1, recipe.defaultOutputQuantity)));
      final readiness = recipe.supplyNeeds
          .map((need) => _readinessFor(
                need,
                batchQuantity,
                recipe.defaultOutputQuantity,
                inventoryById,
              ))
          .toList(growable: false);
      final estimated = _estimatedMinutes(recipe, remaining);
      progress.add(CollectionRecipeProgress(
        target: target,
        recipe: recipe,
        producedQuantity: produced,
        remainingQuantity: remaining,
        estimatedMinutesRemaining: estimated,
        materialReadiness: readiness,
        activeProjectCount: activeByRecipeId[recipe.id] ?? 0,
      ));
    }
    final totalMinutes = progress.fold<int>(
        0, (total, item) => total + item.estimatedMinutesRemaining);
    final weeks = _weeksRemaining(collection.targetDate, current);
    return CollectionPlanningSnapshot(
      collection: collection,
      recipeProgress: List.unmodifiable(progress),
      estimatedMinutesRemaining: totalMinutes,
      availableCapacityMinutes: collection.weeklyCapacityMinutes * weeks,
      weeksRemaining: weeks,
    );
  }

  CollectionMaterialReadiness _readinessFor(
    SupplyNeed need,
    int batchQuantity,
    int defaultOutput,
    Map<String, InventoryItem> inventoryById,
  ) {
    final item = need.inventoryItemId == null
        ? null
        : inventoryById[need.inventoryItemId];
    final factor = batchQuantity / math.max(1, defaultOutput);
    final required = need.quantityNeeded * factor;
    final compatible = item == null ||
        !item.usesMeasuredQuantity ||
        item.measurementUnit!.trim().toLowerCase() ==
            need.unit.trim().toLowerCase();
    return CollectionMaterialReadiness(
      supplyNeed: need,
      requiredQuantity: required,
      inventoryItem: item,
      isUnitCompatible: compatible,
    );
  }

  int _estimatedMinutes(MakeRecipe recipe, int outputQuantity) {
    final minutes = recipe.estimatedMakeMinutes;
    if (minutes == null || minutes <= 0 || outputQuantity <= 0) return 0;
    return (minutes *
            outputQuantity /
            math.max(1, recipe.defaultOutputQuantity))
        .ceil();
  }

  int _weeksRemaining(DateTime? targetDate, DateTime now) {
    if (targetDate == null) return 1;
    final start = DateTime(now.year, now.month, now.day);
    final end = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final days = end.difference(start).inDays;
    return math.max(1, (days / 7).ceil());
  }

  bool _isProjectActive(Project project) =>
      project.milestones.isEmpty ||
      project.milestones.any((milestone) => !milestone.isCompleted);

  String? _clean(String? value) {
    final clean = value?.trim();
    return clean == null || clean.isEmpty ? null : clean;
  }
}
