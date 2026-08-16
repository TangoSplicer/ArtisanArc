import 'package:artisanarc/core/di/di.dart';
import 'package:artisanarc/core/widgets/personal_app_bar.dart';
import 'package:artisanarc/features/recipes/data/make_recipe_model.dart';
import 'package:artisanarc/features/recipes/domain/make_recipe_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MakeRecipeListScreen extends StatefulWidget {
  const MakeRecipeListScreen({super.key});

  @override
  State<MakeRecipeListScreen> createState() => _MakeRecipeListScreenState();
}

class _MakeRecipeListScreenState extends State<MakeRecipeListScreen> {
  final _recipeService = getIt<MakeRecipeService>();
  List<MakeRecipe> _recipes = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    setState(() => _isLoading = true);
    try {
      final recipes = await _recipeService.getRecipes();
      if (mounted) setState(() => _recipes = recipes);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load Make Recipes: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: PersonalAppBar(
        title: const Text('Make Recipes'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.pushNamed('addMakeRecipe').then((_) => _loadRecipes()),
        icon: const Icon(Icons.add),
        label: const Text('New recipe'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadRecipes,
              child: _recipes.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        Icon(Icons.menu_book_outlined,
                            size: 56, color: theme.colorScheme.primary),
                        const SizedBox(height: 16),
                        Text('Build a crochet recipe library',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleLarge),
                        const SizedBox(height: 8),
                        const Text(
                          'Save your own product plan, pattern reference, hook, gauge, expected time and material list. Recipes never copy commercial pattern instructions.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: () => context
                              .pushNamed('addMakeRecipe')
                              .then((_) => _loadRecipes()),
                          icon: const Icon(Icons.add),
                          label: const Text('Create your first recipe'),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                      itemCount: _recipes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final recipe = _recipes[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              child: Icon(Icons.menu_book_outlined,
                                  color: theme.colorScheme.onPrimaryContainer),
                            ),
                            title: Text(recipe.name),
                            subtitle: Text(
                              [
                                recipe.craftFocus,
                                recipe.productCategory,
                                if (recipe.hookSize?.isNotEmpty == true)
                                  'Hook ${recipe.hookSize}',
                                '${recipe.supplyNeeds.length} supplies',
                                if (recipe.variants.isNotEmpty)
                                  '${recipe.variants.length} variants',
                              ].join(' · '),
                            ),
                            isThreeLine: true,
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => context.pushNamed(
                              'makeRecipeDetail',
                              pathParameters: {'id': recipe.id},
                            ).then((_) => _loadRecipes()),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
