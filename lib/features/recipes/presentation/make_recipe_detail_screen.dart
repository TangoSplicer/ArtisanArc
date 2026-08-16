import 'package:artisanarc/core/di/di.dart';
import 'package:artisanarc/core/widgets/personal_app_bar.dart';
import 'package:artisanarc/features/recipes/data/make_recipe_model.dart';
import 'package:artisanarc/features/recipes/domain/make_recipe_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MakeRecipeDetailScreen extends StatefulWidget {
  const MakeRecipeDetailScreen({super.key, required this.recipeId});

  final String recipeId;

  @override
  State<MakeRecipeDetailScreen> createState() => _MakeRecipeDetailScreenState();
}

class _MakeRecipeDetailScreenState extends State<MakeRecipeDetailScreen> {
  final _recipeService = getIt<MakeRecipeService>();
  MakeRecipe? _recipe;
  RecipeVariant? _selectedVariant;
  bool _isLoading = true;
  bool _isCreatingProject = false;

  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }

  Future<void> _loadRecipe() async {
    setState(() => _isLoading = true);
    try {
      final recipe = await _recipeService.getRecipeById(widget.recipeId);
      if (mounted) {
        setState(() {
          _recipe = recipe;
          if (_selectedVariant != null &&
              !recipe!.variants
                  .any((variant) => variant.id == _selectedVariant!.id)) {
            _selectedVariant = null;
          }
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load Make Recipe: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createProject() async {
    final recipe = _recipe;
    if (recipe == null) return;
    setState(() => _isCreatingProject = true);
    try {
      final project = await _recipeService.createProjectFromRecipe(
        recipe,
        variant: _selectedVariant,
      );
      if (!mounted) return;
      context.pushNamed('projectDetail', pathParameters: {'id': project.id});
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not create project: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreatingProject = false);
    }
  }

  Future<void> _deleteRecipe() async {
    final recipe = _recipe;
    if (recipe == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Make Recipe?'),
        content: Text(
          '“${recipe.name}” will be removed from your local recipe library. Projects already created from it are kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _recipeService.deleteRecipe(recipe.id);
    if (mounted) context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final recipe = _recipe;
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (recipe == null) {
      return Scaffold(
        appBar: const PersonalAppBar(title: Text('Recipe Not Found')),
        body:
            const Center(child: Text('This local Make Recipe was not found.')),
      );
    }
    final theme = Theme.of(context);
    final activeVariant = _selectedVariant;
    final supplies = activeVariant == null || activeVariant.supplyNeeds.isEmpty
        ? recipe.supplyNeeds
        : activeVariant.supplyNeeds;
    final output =
        activeVariant?.outputQuantity ?? recipe.defaultOutputQuantity;
    final minutes =
        activeVariant?.estimatedMakeMinutes ?? recipe.estimatedMakeMinutes;

    return Scaffold(
      appBar: PersonalAppBar(
        title: Text(recipe.name),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            tooltip: 'Edit recipe',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.pushNamed('editMakeRecipe',
                pathParameters: {'id': recipe.id}).then((_) => _loadRecipe()),
          ),
          IconButton(
            tooltip: 'Delete recipe',
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteRecipe,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe.name, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text(recipe.craftFocus)),
                      Chip(label: Text(recipe.productCategory)),
                      if (recipe.hookSize?.isNotEmpty == true)
                        Chip(label: Text('Hook ${recipe.hookSize}')),
                    ],
                  ),
                  if (recipe.gaugeNote?.isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    Text('Gauge & construction',
                        style: theme.textTheme.titleSmall),
                    Text(recipe.gaugeNote!),
                  ],
                  if (recipe.patternReference?.isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    Text('Pattern reference',
                        style: theme.textTheme.titleSmall),
                    Text(recipe.patternReference!),
                    if (recipe.patternSource?.isNotEmpty == true)
                      Text('Source: ${recipe.patternSource}'),
                  ],
                ],
              ),
            ),
          ),
          if (recipe.variants.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Choose a variant', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Default'),
                  selected: activeVariant == null,
                  onSelected: (_) => setState(() => _selectedVariant = null),
                ),
                ...recipe.variants.map(
                  (variant) => ChoiceChip(
                    label: Text(variant.name),
                    selected: activeVariant?.id == variant.id,
                    onSelected: (_) =>
                        setState(() => _selectedVariant = variant),
                  ),
                ),
              ],
            ),
            if (activeVariant?.detail?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(activeVariant!.detail!),
            ],
          ],
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Make plan', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                      'Planned output: $output ${output == 1 ? 'piece' : 'pieces'}'),
                  if (minutes != null)
                    Text('Estimated making time: ${_formatMinutes(minutes)}'),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _isCreatingProject ? null : _createProject,
                    icon: _isCreatingProject
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.playlist_add_outlined),
                    label: Text(
                      _isCreatingProject
                          ? 'Creating project…'
                          : 'Create tracked project',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Materials', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          if (supplies.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No supplies have been added to this Make Recipe.'),
              ),
            )
          else
            Card(
              child: Column(
                children: supplies
                    .map(
                      (supply) => ListTile(
                        leading: Icon(
                          supply.isConsumable
                              ? Icons.yard_outlined
                              : Icons.handyman_outlined,
                        ),
                        title: Text(supply.itemName),
                        subtitle: Text(
                          '${_formatQuantity(supply.quantityNeeded)} ${supply.unit} · ${supply.isConsumable ? 'Consumable' : 'Reusable tool'}',
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    if (hours == 0) return '$remainder min';
    return '$hours h${remainder == 0 ? '' : ' $remainder min'}';
  }

  String _formatQuantity(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toString();
}
