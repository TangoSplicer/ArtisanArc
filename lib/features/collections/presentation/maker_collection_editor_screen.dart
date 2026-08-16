import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/personal_app_bar.dart';
import '../../../core/widgets/searchable_selection_field.dart';
import '../../recipes/data/make_recipe_model.dart';
import '../../recipes/data/make_recipe_repository.dart';
import '../data/maker_collection_model.dart';
import '../domain/collection_planning_service.dart';

class MakerCollectionEditorScreen extends StatefulWidget {
  const MakerCollectionEditorScreen({super.key, this.collectionId});

  final String? collectionId;

  @override
  State<MakerCollectionEditorScreen> createState() =>
      _MakerCollectionEditorScreenState();
}

class _MakerCollectionEditorScreenState
    extends State<MakerCollectionEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final CollectionPlanningService _planningService =
      GetIt.I<CollectionPlanningService>();
  final MakeRecipeRepository _recipeRepository =
      GetIt.I<MakeRecipeRepository>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _season;
  DateTime? _targetDate;
  int _weeklyCapacityMinutes = 180;

  List<MakeRecipe> _availableRecipes = [];
  final List<_EditableRecipeTarget> _editableTargets = [];
  bool _isLoading = true;
  bool _isSaving = false;

  bool get _isEditing => widget.collectionId != null;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final recipes = await _recipeRepository.getRecipes();
      MakerCollection? collection;
      if (_isEditing) {
        collection =
            await _planningService.getCollectionById(widget.collectionId!);
        if (collection != null) {
          _nameController.text = collection.name;
          _descriptionController.text = collection.description ?? '';
          _season = collection.season;
          _targetDate = collection.targetDate;
          _weeklyCapacityMinutes = collection.weeklyCapacityMinutes;
          _editableTargets.addAll(
            collection.recipeTargets.map(
              (target) => _EditableRecipeTarget(
                id: target.id,
                recipeId: target.recipeId,
                targetQuantity: target.targetQuantity,
              ),
            ),
          );
        }
      }
      if (mounted) {
        setState(() {
          _availableRecipes = recipes;
          if (!_isEditing && recipes.isNotEmpty && _editableTargets.isEmpty) {
            _editableTargets.add(_EditableRecipeTarget(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              recipeId: recipes.first.id,
              targetQuantity: recipes.first.defaultOutputQuantity * 5,
            ));
          }
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load collection editor: $error')),
        );
      }
    }
  }

  void _addTarget() {
    if (_availableRecipes.isEmpty) return;
    setState(() {
      _editableTargets.add(_EditableRecipeTarget(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        recipeId: _availableRecipes.first.id,
        targetQuantity: 5,
      ));
    });
  }

  void _removeTarget(int index) {
    setState(() {
      _editableTargets.removeAt(index);
    });
  }

  Future<void> _pickTargetDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) {
      setState(() => _targetDate = picked);
    }
  }

  Future<void> _saveCollection() async {
    if (!_formKey.currentState!.validate()) return;
    if (_availableRecipes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create at least one Make Recipe first.')),
      );
      return;
    }
    if (_editableTargets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Add at least one recipe target to the collection.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final targets = _editableTargets
          .map((item) => CollectionRecipeTarget(
                id: item.id,
                recipeId: item.recipeId,
                targetQuantity: item.targetQuantity,
              ))
          .toList(growable: false);

      final existing = _isEditing
          ? await _planningService.getCollectionById(widget.collectionId!)
          : null;

      await _planningService.saveCollection(
        id: widget.collectionId,
        name: _nameController.text,
        description: _descriptionController.text,
        season: _season,
        targetDate: _targetDate,
        weeklyCapacityMinutes: _weeklyCapacityMinutes,
        recipeTargets: targets,
        existing: existing,
      );

      if (mounted) context.pop();
    } catch (error) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save collection: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: PersonalAppBar(
        title: Text(_isEditing ? 'Edit collection' : 'New collection'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Collection name *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Name is required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SearchableSelectionField<String>(
                    options: const [
                      'Spring Market',
                      'Summer Range',
                      'Autumn Craft Fair',
                      'Winter Gifting',
                      'Year-Round Stock',
                      'Custom Order Run',
                    ],
                    value: _season,
                    labelText: 'Season or occasion (optional)',
                    hintText: 'Select season',
                    itemLabel: (value) => value,
                    searchTerms: (value) => [value],
                    onChanged: (value) => setState(() => _season = value),
                    allowClear: true,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _targetDate == null
                              ? 'Target deadline: Not set'
                              : 'Target deadline: ${_targetDate!.toLocal().toString().split(' ').first}',
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _pickTargetDate,
                        icon: const Icon(Icons.event_outlined),
                        label:
                            Text(_targetDate == null ? 'Set date' : 'Change'),
                      ),
                      if (_targetDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          tooltip: 'Clear deadline',
                          onPressed: () => setState(() => _targetDate = null),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Weekly making capacity: $_weeklyCapacityMinutes mins (~${_weeklyCapacityMinutes ~/ 60} hrs/wk)',
                    style: theme.textTheme.titleMedium,
                  ),
                  Slider(
                    value: _weeklyCapacityMinutes.toDouble(),
                    min: 60,
                    max: 1200,
                    divisions: 38,
                    label: '$_weeklyCapacityMinutes mins',
                    onChanged: (value) =>
                        setState(() => _weeklyCapacityMinutes = value.round()),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Recipe targets',
                            style: theme.textTheme.titleLarge),
                      ),
                      FilledButton.icon(
                        onPressed:
                            _availableRecipes.isEmpty ? null : _addTarget,
                        icon: const Icon(Icons.add),
                        label: const Text('Add recipe'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_availableRecipes.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'You need to create at least one Make Recipe before adding targets to a collection.',
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                    )
                  else
                    ..._editableTargets.asMap().entries.map((entry) {
                      final index = entry.key;
                      final target = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _availableRecipes.any(
                                              (r) => r.id == target.recipeId)
                                          ? target.recipeId
                                          : _availableRecipes.first.id,
                                      decoration: const InputDecoration(
                                        labelText: 'Make Recipe',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                      items: _availableRecipes
                                          .map((recipe) => DropdownMenuItem(
                                                value: recipe.id,
                                                child: Text(recipe.name),
                                              ))
                                          .toList(growable: false),
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(() {
                                            target.recipeId = value;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  if (_editableTargets.length > 1)
                                    IconButton(
                                      icon: Icon(Icons.delete_outline,
                                          color: theme.colorScheme.error),
                                      onPressed: () => _removeTarget(index),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                initialValue: target.targetQuantity.toString(),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Target quantity (pieces)',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                validator: (value) {
                                  final parsed = int.tryParse(value ?? '');
                                  if (parsed == null || parsed < 1) {
                                    return 'Enter a positive target quantity';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  target.targetQuantity =
                                      int.tryParse(value) ?? 1;
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _saveCollection,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(_isSaving ? 'Saving…' : 'Save collection'),
                  ),
                ],
              ),
            ),
    );
  }
}

class _EditableRecipeTarget {
  _EditableRecipeTarget({
    required this.id,
    required this.recipeId,
    required this.targetQuantity,
  });

  final String id;
  String recipeId;
  int targetQuantity;
}
