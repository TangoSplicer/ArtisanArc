import 'package:artisanarc/features/project/data/project_model.dart';
import 'package:artisanarc/features/project/domain/project_service.dart';
import 'package:artisanarc/features/project/domain/entities/supply_need.dart';
import 'package:uuid/uuid.dart';

import '../data/make_recipe_model.dart';
import '../data/make_recipe_repository.dart';

class MakeRecipeService {
  MakeRecipeService(this._repository, this._projectService);

  final MakeRecipeRepository _repository;
  final ProjectService _projectService;
  final Uuid _uuid = const Uuid();

  Future<List<MakeRecipe>> getRecipes() => _repository.getRecipes();

  Future<MakeRecipe?> getRecipeById(String id) => _repository.getRecipeById(id);

  Future<MakeRecipe> saveRecipe({
    String? id,
    required String name,
    required String productCategory,
    required String craftFocus,
    String? patternReference,
    String? patternSource,
    String? hookSize,
    String? gaugeNote,
    int defaultOutputQuantity = 1,
    int? estimatedMakeMinutes,
    double? targetMarginPercent,
    List<SupplyNeed>? supplyNeeds,
    List<RecipeVariant>? variants,
    DateTime? createdAt,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'A recipe name is required.');
    }
    if (defaultOutputQuantity < 1) {
      throw ArgumentError.value(
        defaultOutputQuantity,
        'defaultOutputQuantity',
        'Output quantity must be at least one.',
      );
    }
    if (estimatedMakeMinutes != null && estimatedMakeMinutes < 0) {
      throw ArgumentError.value(
        estimatedMakeMinutes,
        'estimatedMakeMinutes',
        'Estimated time cannot be negative.',
      );
    }
    if (targetMarginPercent != null &&
        (!targetMarginPercent.isFinite ||
            targetMarginPercent < 0 ||
            targetMarginPercent >= 100)) {
      throw ArgumentError.value(
        targetMarginPercent,
        'targetMarginPercent',
        'Target margin must be from 0% up to (but not including) 100%.',
      );
    }
    final now = DateTime.now();
    final recipe = MakeRecipe(
      id: id ?? _uuid.v4(),
      name: cleanName,
      productCategory: productCategory.trim(),
      craftFocus: craftFocus.trim(),
      patternReference: _optional(patternReference),
      patternSource: _optional(patternSource),
      hookSize: _optional(hookSize),
      gaugeNote: _optional(gaugeNote),
      defaultOutputQuantity: defaultOutputQuantity,
      estimatedMakeMinutes: estimatedMakeMinutes,
      targetMarginPercent: targetMarginPercent,
      supplyNeeds: List<SupplyNeed>.from(supplyNeeds ?? const []),
      variants: List<RecipeVariant>.from(variants ?? const []),
      createdAt: createdAt ?? now,
      updatedAt: now,
    );
    await _repository.saveRecipe(recipe);
    return recipe;
  }

  Future<Project> createProjectFromRecipe(
    MakeRecipe recipe, {
    RecipeVariant? variant,
    DateTime? endDate,
  }) async {
    final supplies = variant == null || variant.supplyNeeds.isEmpty
        ? recipe.supplyNeeds
        : variant.supplyNeeds;
    final outputQuantity =
        variant?.outputQuantity ?? recipe.defaultOutputQuantity;
    final estimatedMinutes =
        variant?.estimatedMakeMinutes ?? recipe.estimatedMakeMinutes;
    final now = DateTime.now();
    final project = Project(
      id: _uuid.v4(),
      name: variant == null ? recipe.name : '${recipe.name} · ${variant.name}',
      description: _recipeProjectDescription(recipe, variant),
      craftType: recipe.craftFocus,
      startDate: now,
      endDate: endDate,
      supplyNeeds: supplies.map((need) => need.copyWith()).toList(),
      estimatedLabourMinutes: estimatedMinutes,
      targetMarginPercent: recipe.targetMarginPercent,
      recipeId: recipe.id,
      recipeName: recipe.name,
      plannedOutputQuantity: outputQuantity,
      finishedItemCategory: recipe.productCategory,
      createdAt: now,
      lastUpdatedAt: now,
    );
    await _projectService.createProject(project);
    return project;
  }

  Future<void> deleteRecipe(String id) => _repository.deleteRecipe(id);

  String? _optional(String? value) {
    final clean = value?.trim();
    return clean == null || clean.isEmpty ? null : clean;
  }

  String? _recipeProjectDescription(MakeRecipe recipe, RecipeVariant? variant) {
    final parts = <String>[
      if (recipe.patternReference?.isNotEmpty == true)
        'Pattern reference: ${recipe.patternReference}',
      if (recipe.patternSource?.isNotEmpty == true)
        'Source: ${recipe.patternSource}',
      if (recipe.hookSize?.isNotEmpty == true) 'Hook: ${recipe.hookSize}',
      if (recipe.gaugeNote?.isNotEmpty == true) 'Gauge: ${recipe.gaugeNote}',
      if (variant?.detail?.isNotEmpty == true) 'Variant: ${variant!.detail}',
    ];
    return parts.isEmpty ? null : parts.join('\n');
  }
}
