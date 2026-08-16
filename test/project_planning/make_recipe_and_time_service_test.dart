import 'package:artisanarc/features/project/data/project_model.dart';
import 'package:artisanarc/features/project/domain/entities/supply_need.dart';
import 'package:artisanarc/features/project/domain/project_service.dart';
import 'package:artisanarc/features/project/domain/project_time_service.dart';
import 'package:artisanarc/features/recipes/data/make_recipe_model.dart';
import 'package:artisanarc/features/recipes/data/make_recipe_repository.dart';
import 'package:artisanarc/features/recipes/domain/make_recipe_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryRecipeRepository implements MakeRecipeRepository {
  final Map<String, MakeRecipe> _recipes = {};

  @override
  Future<void> deleteRecipe(String id) async => _recipes.remove(id);

  @override
  Future<MakeRecipe?> getRecipeById(String id) async => _recipes[id];

  @override
  Future<List<MakeRecipe>> getRecipes() async => _recipes.values.toList();

  @override
  Future<void> saveRecipe(MakeRecipe recipe) async =>
      _recipes[recipe.id] = recipe;
}

class _MemoryProjectService implements ProjectService {
  final Map<String, Project> projects = {};

  @override
  Future<void> createProject(Project project) async =>
      projects[project.id] = project;

  @override
  Future<void> deleteProject(String id) async => projects.remove(id);

  @override
  Future<List<Project>> fetchProjects() async => projects.values.toList();

  @override
  Future<Project?> getProjectById(String id) async => projects[id];

  @override
  Future<void> updateProject(Project project) async =>
      projects[project.id] = project;
}

void main() {
  test('creates a tracked crochet project from a selected Make Recipe variant',
      () async {
    final recipes = _MemoryRecipeRepository();
    final projects = _MemoryProjectService();
    final service = MakeRecipeService(recipes, projects);

    final recipe = await service.saveRecipe(
      name: 'Pocket Bee',
      productCategory: 'Crochet Amigurumi & Plush',
      craftFocus: 'Amigurumi',
      hookSize: '2.50 mm',
      estimatedMakeMinutes: 45,
      targetMarginPercent: 50,
      supplyNeeds: [
        SupplyNeed(
          id: 'cotton',
          itemName: 'Cotton yarn',
          quantityNeeded: 18,
          unit: 'gram',
          inventoryItemId: 'cotton-stock',
        ),
      ],
      variants: [
        RecipeVariant(
          id: 'large',
          name: 'Large bee',
          outputQuantity: 2,
          estimatedMakeMinutes: 90,
          supplyNeeds: [
            SupplyNeed(
              id: 'large-cotton',
              itemName: 'Cotton yarn',
              quantityNeeded: 45,
              unit: 'gram',
              inventoryItemId: 'cotton-stock',
            ),
          ],
        ),
      ],
    );

    final project = await service.createProjectFromRecipe(
      recipe,
      variant: recipe.variants.single,
    );

    expect(project.recipeId, recipe.id);
    expect(project.recipeName, 'Pocket Bee');
    expect(project.name, 'Pocket Bee · Large bee');
    expect(project.craftType, 'Amigurumi');
    expect(project.plannedOutputQuantity, 2);
    expect(project.estimatedLabourMinutes, 90);
    expect(project.supplyNeeds.single.quantityNeeded, 45);
    expect(projects.projects[project.id], same(project));
  });

  test('persists elapsed local timer minutes when a maker pauses a project',
      () async {
    final projects = _MemoryProjectService();
    final time = ProjectTimeService(projects);
    final original = Project(
      id: 'project-time',
      name: 'Pumpkin',
      actualLabourMinutes: 15,
      createdAt: DateTime(2026, 8, 16),
    );

    final started = await time.start(
      original,
      now: DateTime(2026, 8, 16, 9),
    );
    final paused = await time.pause(
      started,
      now: DateTime(2026, 8, 16, 10, 35),
    );

    expect(started.activeTimerStartedAt, DateTime(2026, 8, 16, 9));
    expect(paused.activeTimerStartedAt, isNull);
    expect(paused.actualLabourMinutes, 110);
    expect(projects.projects[paused.id]?.actualLabourMinutes, 110);
  });
}
