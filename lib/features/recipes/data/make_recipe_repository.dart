import 'package:hive/hive.dart';

import 'make_recipe_model.dart';

abstract class MakeRecipeRepository {
  Future<List<MakeRecipe>> getRecipes();
  Future<MakeRecipe?> getRecipeById(String id);
  Future<void> saveRecipe(MakeRecipe recipe);
  Future<void> deleteRecipe(String id);
}

class MakeRecipeRepositoryImpl implements MakeRecipeRepository {
  static const boxName = 'makeRecipesBox';

  Future<Box<MakeRecipe>> _box() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<MakeRecipe>(boxName);
    }
    return Hive.box<MakeRecipe>(boxName);
  }

  @override
  Future<List<MakeRecipe>> getRecipes() async {
    final recipes = (await _box()).values.toList();
    recipes
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return recipes;
  }

  @override
  Future<MakeRecipe?> getRecipeById(String id) async => (await _box()).get(id);

  @override
  Future<void> saveRecipe(MakeRecipe recipe) async =>
      (await _box()).put(recipe.id, recipe);

  @override
  Future<void> deleteRecipe(String id) async => (await _box()).delete(id);
}
