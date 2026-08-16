import 'package:artisanarc/core/constants/selection_options.dart';
import 'package:artisanarc/core/di/di.dart';
import 'package:artisanarc/core/widgets/personal_app_bar.dart';
import 'package:artisanarc/core/widgets/searchable_selection_field.dart';
import 'package:artisanarc/features/inventory/data/inventory_model.dart';
import 'package:artisanarc/features/inventory/domain/inventory_service.dart';
import 'package:artisanarc/features/project/domain/entities/supply_need.dart';
import 'package:artisanarc/features/recipes/data/make_recipe_model.dart';
import 'package:artisanarc/features/recipes/domain/make_recipe_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

class MakeRecipeEditorScreen extends StatefulWidget {
  const MakeRecipeEditorScreen({super.key, this.recipeId});

  final String? recipeId;

  @override
  State<MakeRecipeEditorScreen> createState() => _MakeRecipeEditorScreenState();
}

class _MakeRecipeEditorScreenState extends State<MakeRecipeEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipeService = getIt<MakeRecipeService>();
  final _inventoryService = getIt<InventoryService>();
  final _uuid = const Uuid();
  final _nameController = TextEditingController();
  final _patternReferenceController = TextEditingController();
  final _patternSourceController = TextEditingController();
  final _gaugeController = TextEditingController();
  final _outputController = TextEditingController(text: '1');
  final _minutesController = TextEditingController();
  final _marginController = TextEditingController();

  List<InventoryItem> _materials = const [];
  List<SupplyNeed> _supplies = [];
  List<RecipeVariant> _variants = [];
  MakeRecipe? _existing;
  String? _category;
  String? _craftFocus;
  String? _hookSize;
  bool _isLoading = true;
  bool _isSaving = false;

  bool get _isEditMode => widget.recipeId != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _patternReferenceController.dispose();
    _patternSourceController.dispose();
    _gaugeController.dispose();
    _outputController.dispose();
    _minutesController.dispose();
    _marginController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final materials = (await _inventoryService.fetchItems())
          .where((item) => item.isMaterialStock && !item.isArchived)
          .toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      MakeRecipe? existing;
      if (_isEditMode)
        existing = await _recipeService.getRecipeById(widget.recipeId!);
      if (!mounted) return;
      setState(() {
        _materials = materials;
        _existing = existing;
        if (existing != null) {
          _nameController.text = existing.name;
          _patternReferenceController.text = existing.patternReference ?? '';
          _patternSourceController.text = existing.patternSource ?? '';
          _gaugeController.text = existing.gaugeNote ?? '';
          _outputController.text = existing.defaultOutputQuantity.toString();
          _minutesController.text =
              existing.estimatedMakeMinutes?.toString() ?? '';
          _marginController.text =
              existing.targetMarginPercent?.toStringAsFixed(0) ?? '';
          _category = existing.productCategory;
          _craftFocus = existing.craftFocus;
          _hookSize = existing.hookSize;
          _supplies = List<SupplyNeed>.from(
              existing.supplyNeeds.map((item) => item.copyWith()));
          _variants = List<RecipeVariant>.from(existing.variants);
        }
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load recipe editor: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openSupplyDialog({SupplyNeed? existing, int? index}) async {
    final itemNameController =
        TextEditingController(text: existing?.itemName ?? '');
    final quantityController = TextEditingController(
      text: existing?.quantityNeeded.toString() ?? '',
    );
    final costController = TextEditingController(
      text: existing?.estimatedCostEach?.toStringAsFixed(2) ?? '',
    );
    InventoryItem? selectedMaterial = _materials
        .where((item) => item.id == existing?.inventoryItemId)
        .cast<InventoryItem?>()
        .firstOrNull;
    String? unit = existing?.unit;
    var consumable = existing?.isConsumable ?? true;
    String? errorText;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existing == null
              ? 'Add recipe material'
              : 'Edit recipe material'),
          content: SizedBox(
            width: 430,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SearchableSelectionField<InventoryItem>(
                    options: _materials,
                    value: selectedMaterial,
                    labelText: 'Link Materials Stock (optional)',
                    hintText: 'Search yarn, hooks, notions or supplies',
                    emptyMessage: 'No matching active material stock',
                    itemLabel: (item) => item.name,
                    itemSubtitle: (item) =>
                        '${item.category} · ${item.formattedStockQuantity}',
                    searchTerms: (item) =>
                        [item.name, item.category, item.measurementUnit ?? ''],
                    onChanged: (item) {
                      setDialogState(() {
                        selectedMaterial = item;
                        if (item != null) {
                          itemNameController.text = item.name;
                          unit = item.measurementUnit ?? unit ?? 'piece';
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: itemNameController,
                    decoration: const InputDecoration(
                      labelText: 'Material or tool name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: quantityController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Quantity needed',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SearchableSelectionField<String>(
                    options: _withCurrent(SelectionOptions.supplyUnits, unit),
                    value: unit,
                    labelText: 'Unit',
                    hintText: 'Search units',
                    itemLabel: (value) => value,
                    searchTerms: (value) => [value],
                    onChanged: (value) => setDialogState(() => unit = value),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: costController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Unit cost estimate (optional)',
                      prefixText: '£ ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Consumable'),
                    subtitle: const Text(
                        'Only consumables are deducted when a make is completed.'),
                    value: consumable,
                    onChanged: (value) =>
                        setDialogState(() => consumable = value),
                  ),
                  if (errorText != null)
                    Text(errorText!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final quantity =
                    double.tryParse(quantityController.text.trim());
                final costText = costController.text.trim();
                final cost =
                    costText.isEmpty ? null : double.tryParse(costText);
                if (itemNameController.text.trim().isEmpty ||
                    quantity == null ||
                    quantity <= 0 ||
                    unit == null ||
                    unit!.trim().isEmpty ||
                    (costText.isNotEmpty && (cost == null || cost < 0))) {
                  setDialogState(() => errorText =
                      'Enter a material, positive quantity, unit and valid optional cost.');
                  return;
                }
                final supply = SupplyNeed(
                  id: existing?.id ?? _uuid.v4(),
                  itemName: itemNameController.text.trim(),
                  quantityNeeded: quantity,
                  unit: unit!,
                  inventoryItemId: selectedMaterial?.id,
                  estimatedCostEach: cost,
                  isSourced: existing?.isSourced ?? false,
                  isConsumable: consumable,
                );
                setState(() {
                  if (index == null) {
                    _supplies.add(supply);
                  } else {
                    _supplies[index] = supply;
                  }
                });
                Navigator.of(dialogContext).pop();
              },
              child: Text(existing == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
    itemNameController.dispose();
    quantityController.dispose();
    costController.dispose();
  }

  Future<void> _openVariantDialog({RecipeVariant? existing, int? index}) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final detailController =
        TextEditingController(text: existing?.detail ?? '');
    final outputController =
        TextEditingController(text: (existing?.outputQuantity ?? 1).toString());
    final minutesController = TextEditingController(
        text: existing?.estimatedMakeMinutes?.toString() ?? '');
    String? errorText;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
              existing == null ? 'Add recipe variant' : 'Edit recipe variant'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                        labelText: 'Variant name',
                        border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(
                    controller: detailController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                        labelText: 'Variant note (optional)',
                        border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(
                    controller: outputController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Output quantity',
                        border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(
                    controller: minutesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Estimated making time (minutes, optional)',
                        border: OutlineInputBorder())),
                const SizedBox(height: 8),
                const Text(
                    'This simple variant begins with the recipe material list. Create its project to adjust supply needs for a specific order.'),
                if (errorText != null)
                  Text(errorText!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final output = int.tryParse(outputController.text.trim());
                final minutesText = minutesController.text.trim();
                final minutes =
                    minutesText.isEmpty ? null : int.tryParse(minutesText);
                if (nameController.text.trim().isEmpty ||
                    output == null ||
                    output < 1 ||
                    (minutesText.isNotEmpty &&
                        (minutes == null || minutes < 0))) {
                  setDialogState(() => errorText =
                      'Enter a variant name, output of at least one and valid optional time.');
                  return;
                }
                final variant = RecipeVariant(
                  id: existing?.id ?? _uuid.v4(),
                  name: nameController.text.trim(),
                  detail: detailController.text.trim().isEmpty
                      ? null
                      : detailController.text.trim(),
                  outputQuantity: output,
                  estimatedMakeMinutes: minutes,
                  supplyNeeds:
                      _supplies.map((item) => item.copyWith()).toList(),
                );
                setState(() {
                  if (index == null) {
                    _variants.add(variant);
                  } else {
                    _variants[index] = variant;
                  }
                });
                Navigator.of(dialogContext).pop();
              },
              child: Text(existing == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
    nameController.dispose();
    detailController.dispose();
    outputController.dispose();
    minutesController.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final output = int.tryParse(_outputController.text.trim());
    final minutesText = _minutesController.text.trim();
    final minutes = minutesText.isEmpty ? null : int.tryParse(minutesText);
    final marginText = _marginController.text.trim();
    final margin = marginText.isEmpty ? null : double.tryParse(marginText);
    if (_category == null ||
        _craftFocus == null ||
        output == null ||
        output < 1 ||
        (minutesText.isNotEmpty && (minutes == null || minutes < 0)) ||
        (marginText.isNotEmpty &&
            (margin == null || margin < 0 || margin >= 100))) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Choose crochet details and enter valid output, time and margin values.')));
      return;
    }
    setState(() => _isSaving = true);
    try {
      final recipe = await _recipeService.saveRecipe(
        id: _existing?.id,
        name: _nameController.text,
        productCategory: _category!,
        craftFocus: _craftFocus!,
        patternReference: _patternReferenceController.text,
        patternSource: _patternSourceController.text,
        hookSize: _hookSize,
        gaugeNote: _gaugeController.text,
        defaultOutputQuantity: output,
        estimatedMakeMinutes: minutes,
        targetMarginPercent: margin,
        supplyNeeds: _supplies,
        variants: _variants,
        createdAt: _existing?.createdAt,
      );
      if (!mounted) return;
      context.pop(recipe);
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not save Make Recipe: $error')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final theme = Theme.of(context);
    return Scaffold(
      appBar: PersonalAppBar(
        title: Text(_isEditMode ? 'Edit Make Recipe' : 'New Make Recipe'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            Text('Recipe identity', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                  labelText: 'Product or recipe name',
                  hintText: 'e.g. Bee keyring — classic',
                  border: OutlineInputBorder()),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a recipe name.'
                  : null,
            ),
            const SizedBox(height: 12),
            SearchableSelectionField<String>(
              options: _withCurrent(
                  SelectionOptions.finishedItemCategories, _category),
              value: _category,
              labelText: 'Product category',
              hintText: 'Search crochet product types',
              itemLabel: (value) => value,
              searchTerms: (value) => [value],
              onChanged: (value) => setState(() => _category = value),
              validator: (value) =>
                  value == null ? 'Choose a product category.' : null,
            ),
            const SizedBox(height: 12),
            SearchableSelectionField<String>(
              options: _withCurrent(SelectionOptions.craftTypes, _craftFocus),
              value: _craftFocus,
              labelText: 'Crochet focus',
              hintText: 'Search crochet technique or related fibre craft',
              itemLabel: (value) => value,
              searchTerms: (value) => [value],
              onChanged: (value) => setState(() => _craftFocus = value),
              validator: (value) =>
                  value == null ? 'Choose a crochet focus.' : null,
            ),
            const SizedBox(height: 20),
            Text('Pattern reference', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            const Text(
                'Store your own title, link, filename or location—not copied pattern instructions.'),
            const SizedBox(height: 12),
            TextField(
                controller: _patternReferenceController,
                decoration: const InputDecoration(
                    labelText: 'Pattern reference (optional)',
                    border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(
                controller: _patternSourceController,
                decoration: const InputDecoration(
                    labelText: 'Designer or source credit (optional)',
                    border: OutlineInputBorder())),
            const SizedBox(height: 12),
            SearchableSelectionField<String>(
              options:
                  _withCurrent(SelectionOptions.crochetHookSizes, _hookSize),
              value: _hookSize,
              labelText: 'Crochet hook size (optional)',
              hintText: 'Search hook size',
              itemLabel: (value) => value,
              searchTerms: (value) => [value],
              onChanged: (value) => setState(() => _hookSize = value),
              allowClear: true,
            ),
            const SizedBox(height: 12),
            TextField(
                controller: _gaugeController,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Gauge or construction note (optional)',
                    border: OutlineInputBorder())),
            const SizedBox(height: 20),
            Text('Plan & price', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
                controller: _outputController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Planned output quantity',
                    border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(
                controller: _minutesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Estimated making time (minutes, optional)',
                    border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(
                controller: _marginController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'Target margin (optional)',
                    suffixText: '%',
                    border: OutlineInputBorder())),
            const SizedBox(height: 20),
            _buildSupplies(theme),
            const SizedBox(height: 20),
            _buildVariants(theme),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save_outlined),
              label: Text(_isSaving ? 'Saving…' : 'Save Make Recipe'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplies(ThemeData theme) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text('Recipe materials',
                      style: theme.textTheme.titleLarge)),
              TextButton.icon(
                  onPressed: () => _openSupplyDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add')),
            ],
          ),
          const Text(
              'Link yarn and notions to Materials Stock now, or add them later to the project.'),
          const SizedBox(height: 8),
          if (_supplies.isEmpty)
            const Card(
                child: Padding(
                    padding: EdgeInsets.all(14),
                    child: Text('No materials added yet.')))
          else
            Card(
              child: Column(
                children: _supplies
                    .asMap()
                    .entries
                    .map((entry) => ListTile(
                          title: Text(entry.value.itemName),
                          subtitle: Text(
                              '${entry.value.quantityNeeded} ${entry.value.unit} · ${entry.value.isConsumable ? 'Consumable' : 'Reusable tool'}'),
                          trailing:
                              Row(mainAxisSize: MainAxisSize.min, children: [
                            IconButton(
                                tooltip: 'Edit material',
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => _openSupplyDialog(
                                    existing: entry.value, index: entry.key)),
                            IconButton(
                                tooltip: 'Remove material',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => setState(
                                    () => _supplies.removeAt(entry.key))),
                          ]),
                        ))
                    .toList(growable: false),
              ),
            ),
        ],
      );

  Widget _buildVariants(ThemeData theme) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text('Variants', style: theme.textTheme.titleLarge)),
              TextButton.icon(
                  onPressed: () => _openVariantDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add')),
            ],
          ),
          const Text(
              'Use variants for size, colourway or product format. Each starts with this recipe’s material plan.'),
          const SizedBox(height: 8),
          if (_variants.isEmpty)
            const Card(
                child: Padding(
                    padding: EdgeInsets.all(14),
                    child: Text('No variants added.')))
          else
            Card(
                child: Column(
                    children: _variants
                        .asMap()
                        .entries
                        .map((entry) => ListTile(
                              title: Text(entry.value.name),
                              subtitle: Text(
                                  'Output ${entry.value.outputQuantity}${entry.value.estimatedMakeMinutes == null ? '' : ' · ${entry.value.estimatedMakeMinutes} min estimate'}'),
                              trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                        tooltip: 'Edit variant',
                                        icon: const Icon(Icons.edit_outlined),
                                        onPressed: () => _openVariantDialog(
                                            existing: entry.value,
                                            index: entry.key)),
                                    IconButton(
                                        tooltip: 'Remove variant',
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () => setState(() =>
                                            _variants.removeAt(entry.key))),
                                  ]),
                            ))
                        .toList(growable: false))),
        ],
      );

  List<String> _withCurrent(List<String> options, String? current) {
    final values = {
      ...options,
      if (current != null && current.isNotEmpty) current
    }.toList();
    return values;
  }
}
