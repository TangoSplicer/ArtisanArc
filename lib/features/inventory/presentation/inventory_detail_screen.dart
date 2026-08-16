import 'dart:io';
import 'package:flutter/material.dart';
import 'package:artisanarc/core/widgets/personal_app_bar.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../data/inventory_model.dart';
import '../domain/inventory_service.dart';
import '../domain/stocktake_service.dart';
import '../../qr/presentation/qr_generator_widget.dart';
import '../../../core/constants/selection_options.dart';
import '../../../core/widgets/searchable_selection_field.dart';

class InventoryDetailScreen extends StatefulWidget {
  final String itemId;

  const InventoryDetailScreen({super.key, required this.itemId});

  @override
  State<InventoryDetailScreen> createState() => _InventoryDetailScreenState();
}

class _InventoryDetailScreenState extends State<InventoryDetailScreen> {
  final InventoryService _service = GetIt.I<InventoryService>();
  final StocktakeService _stocktakeService = GetIt.I<StocktakeService>();
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  InventoryItem? _item;
  bool _isLoading = true;
  bool _isEditing = false;

  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late TextEditingController _locationController;
  late TextEditingController _reorderPointController;
  late TextEditingController _yarnBrandController;
  late TextEditingController _yarnRangeController;
  late TextEditingController _yarnColourController;
  late TextEditingController _dyeLotController;
  late TextEditingController _yarnWeightGramsController;
  late TextEditingController _yarnLengthMetresController;
  late TextEditingController _gaugeNoteController;
  String? _measurementUnit;
  String? _yarnWeight;
  String? _yarnFibre;
  String? _recommendedHookSize;

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  bool get _isYarnCategory =>
      _item?.isMaterialStock == true &&
      _categoryController.text.toLowerCase().startsWith('yarn');

  Future<void> _loadItem() async {
    setState(() => _isLoading = true);
    try {
      final item = await _service.getItemById(widget.itemId);
      if (item != null) {
        setState(() => _item = item);
        _initializeControllers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading item: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: _item?.name);
    _categoryController = TextEditingController(text: _item?.category);
    _quantityController = TextEditingController(
      text: _item?.isMaterialStock == true
          ? _item!.availableStockQuantity.toString()
          : _item?.quantity.toString(),
    );
    _priceController =
        TextEditingController(text: _item?.price?.toString() ?? '');
    _locationController =
        TextEditingController(text: _item?.storageLocation ?? '');
    _reorderPointController = TextEditingController(
      text: _item?.activeReorderPoint?.toString() ?? '',
    );
    _measurementUnit = _item?.measurementUnit;
    _yarnBrandController = TextEditingController(text: _item?.yarnBrand ?? '');
    _yarnRangeController = TextEditingController(text: _item?.yarnRange ?? '');
    _yarnColourController =
        TextEditingController(text: _item?.yarnColour ?? '');
    _dyeLotController = TextEditingController(text: _item?.dyeLot ?? '');
    _yarnWeightGramsController =
        TextEditingController(text: _item?.yarnWeightGrams?.toString() ?? '');
    _yarnLengthMetresController =
        TextEditingController(text: _item?.yarnLengthMetres?.toString() ?? '');
    _gaugeNoteController = TextEditingController(text: _item?.gaugeNote ?? '');
    _yarnWeight = _item?.yarnWeight;
    _yarnFibre = _item?.yarnFibre;
    _recommendedHookSize = _item?.recommendedHookSize;
  }

  Future<void> _saveChanges() async {
    if (_item == null) return;

    final amount = double.tryParse(_quantityController.text);
    if (amount == null || amount < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter an amount of zero or more.')),
      );
      return;
    }
    if (_item!.isMaterialStock && (_measurementUnit ?? '').trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a stock unit for this material.')),
      );
      return;
    }

    final updatedItem = _item!.copyWith(
      name: _nameController.text,
      category: _categoryController.text,
      quantity: _item!.isFinishedItem ? amount.round() : amount.ceil(),
      price: double.tryParse(_priceController.text),
      storageLocation:
          _locationController.text.isEmpty ? null : _locationController.text,
      clearReorderPoint:
          _item!.isMaterialStock || _reorderPointController.text.trim().isEmpty,
      measuredQuantity: _item!.isMaterialStock ? amount : null,
      measurementUnit: _item!.isMaterialStock ? _measurementUnit : null,
      measuredReorderPoint: _item!.isMaterialStock
          ? double.tryParse(_reorderPointController.text)
          : null,
      clearMeasuredReorderPoint:
          _item!.isMaterialStock && _reorderPointController.text.trim().isEmpty,
      yarnBrand: _isYarnCategory ? _optional(_yarnBrandController.text) : null,
      yarnRange: _isYarnCategory ? _optional(_yarnRangeController.text) : null,
      yarnColour:
          _isYarnCategory ? _optional(_yarnColourController.text) : null,
      dyeLot: _isYarnCategory ? _optional(_dyeLotController.text) : null,
      yarnWeight: _isYarnCategory ? _yarnWeight : null,
      yarnFibre: _isYarnCategory ? _yarnFibre : null,
      yarnWeightGrams: _isYarnCategory
          ? double.tryParse(_yarnWeightGramsController.text)
          : null,
      yarnLengthMetres: _isYarnCategory
          ? double.tryParse(_yarnLengthMetresController.text)
          : null,
      recommendedHookSize: _isYarnCategory ? _recommendedHookSize : null,
      gaugeNote: _isYarnCategory ? _optional(_gaugeNoteController.text) : null,
      clearYarnBrand:
          !_isYarnCategory || _yarnBrandController.text.trim().isEmpty,
      clearYarnRange:
          !_isYarnCategory || _yarnRangeController.text.trim().isEmpty,
      clearYarnColour:
          !_isYarnCategory || _yarnColourController.text.trim().isEmpty,
      clearDyeLot: !_isYarnCategory || _dyeLotController.text.trim().isEmpty,
      clearYarnWeight: !_isYarnCategory || _yarnWeight == null,
      clearYarnFibre: !_isYarnCategory || _yarnFibre == null,
      clearYarnWeightGrams:
          !_isYarnCategory || _yarnWeightGramsController.text.trim().isEmpty,
      clearYarnLengthMetres:
          !_isYarnCategory || _yarnLengthMetresController.text.trim().isEmpty,
      clearRecommendedHookSize:
          !_isYarnCategory || _recommendedHookSize == null,
      clearGaugeNote:
          !_isYarnCategory || _gaugeNoteController.text.trim().isEmpty,
      lastUpdated: DateTime.now(),
    );

    try {
      await _service.updateItem(updatedItem);
      setState(() {
        _item = updatedItem;
        _isEditing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating item: $e')),
        );
      }
    }
  }

  Future<void> _addImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (pickedFile != null && _item != null) {
        final appDocDir = await getApplicationDocumentsDirectory();
        final imagesDir = Directory(p.join(appDocDir.path, 'inventory_images'));

        if (!await imagesDir.exists()) {
          await imagesDir.create(recursive: true);
        }

        final fileName = '${_uuid.v4()}${p.extension(pickedFile.path)}';
        final localImagePath = p.join(imagesDir.path, fileName);

        final File imageFile = File(pickedFile.path);
        await imageFile.copy(localImagePath);

        final updatedPaths = List<String>.from(_item!.imagePaths ?? [])
          ..add(fileName);
        final updatedItem = _item!.copyWith(
          imagePaths: updatedPaths,
          lastUpdated: DateTime.now(),
        );

        await _service.updateItem(updatedItem);
        setState(() => _item = updatedItem);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding image: $e')),
        );
      }
    }
  }

  Future<void> _toggleArchive() async {
    if (_item == null) return;
    final shouldArchive = !_item!.isArchived;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(shouldArchive ? 'Archive item' : 'Restore item'),
        content: Text(
          shouldArchive
              ? 'Archive "${_item!.name}"? It will be hidden from everyday inventory and sales, but its history will remain.'
              : 'Restore "${_item!.name}" to everyday inventory?',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(shouldArchive ? 'Archive' : 'Restore'),
          ),
        ],
      ),
    );
    if (confirmed != true || _item == null) return;
    try {
      final updated =
          await _stocktakeService.setArchived(_item!, shouldArchive);
      if (!mounted) return;
      setState(() => _item = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(shouldArchive
                ? 'Item archived.'
                : 'Item restored to inventory.')),
      );
      if (shouldArchive) context.pop(true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not update archive state: $error')));
      }
    }
  }

  Future<void> _showAdjustmentHistory() async {
    if (_item == null) return;
    final adjustments =
        await _stocktakeService.getAdjustmentHistory(itemId: _item!.id);
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * 0.65,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Stock adjustments',
                    style: Theme.of(sheetContext).textTheme.titleLarge),
              ),
              const Divider(height: 1),
              Expanded(
                child: adjustments.isEmpty
                    ? const Center(
                        child: Text(
                            'No stocktake adjustments recorded for this item.'))
                    : ListView.separated(
                        itemCount: adjustments.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final adjustment = adjustments[index];
                          final change = adjustment.measuredQuantityChange ??
                              adjustment.quantityChange.toDouble();
                          final previous =
                              adjustment.previousMeasuredQuantity ??
                                  adjustment.previousQuantity.toDouble();
                          final counted = adjustment.countedMeasuredQuantity ??
                              adjustment.countedQuantity.toDouble();
                          String format(double value) =>
                              value == value.roundToDouble()
                                  ? value.toInt().toString()
                                  : value
                                      .toStringAsFixed(2)
                                      .replaceFirst(RegExp(r'0+$'), '')
                                      .replaceFirst(RegExp(r'\\.$'), '');
                          final unit = adjustment.measurementUnit ?? '';
                          final sign = change >= 0 ? '+' : '';
                          return ListTile(
                            leading: Icon(change >= 0
                                ? Icons.add_circle_outline
                                : Icons.remove_circle_outline),
                            title: Text(
                                '$sign${format(change)}${unit.isEmpty ? '' : ' $unit'} · ${adjustment.reason}'),
                            subtitle: Text(
                                '${format(previous)}${unit.isEmpty ? '' : ' $unit'} recorded → ${format(counted)}${unit.isEmpty ? '' : ' $unit'} counted${adjustment.note == null ? '' : ' · ${adjustment.note}'}'),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteItem() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${_item?.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && _item != null) {
      try {
        await _service.removeItem(_item!.id);
        if (mounted) {
          context.pop(true); // Return to inventory screen
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting item: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_item == null) {
      return Scaffold(
        appBar: PersonalAppBar(title: const Text('Item Not Found')),
        body: const Center(child: Text('Item not found')),
      );
    }

    return Scaffold(
      appBar: PersonalAppBar(
        title: Text(_item!.name),
        actions: [
          if (_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveChanges,
            ),
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () => setState(() => _isEditing = false),
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
            IconButton(
              icon: const Icon(Icons.qr_code),
              onPressed: () => _showQRCode(),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') _deleteItem();
                if (value == 'archive') _toggleArchive();
                if (value == 'history') _showAdjustmentHistory();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'history',
                  child: ListTile(
                    leading: Icon(Icons.history_outlined),
                    title: Text('Stock adjustment history'),
                  ),
                ),
                PopupMenuItem(
                  value: 'archive',
                  child: ListTile(
                    leading: Icon(_item!.isArchived
                        ? Icons.unarchive_outlined
                        : Icons.archive_outlined),
                    title: Text(
                        _item!.isArchived ? 'Restore item' : 'Archive item'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete Item'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageGallery(),
            const SizedBox(height: 24),
            _buildItemDetails(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addImage,
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget _buildImageGallery() {
    final images = _item?.imagePaths ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Photos', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (images.isEmpty)
              const Center(
                child: Text('No photos yet. Tap + to add some!'),
              )
            else
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder<String>(
                      future: getApplicationDocumentsDirectory().then(
                        (dir) =>
                            p.join(dir.path, 'inventory_images', images[index]),
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final imageFile = File(snapshot.data!);
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 120,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                imageFile,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.broken_image),
                                  );
                                },
                              ),
                            ),
                          );
                        }
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 120,
                          color: Colors.grey[300],
                          child:
                              const Center(child: CircularProgressIndicator()),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Details', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (_isEditing) ...[
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 16),
              SearchableSelectionField<String>(
                options: _item!.isFinishedItem
                    ? SelectionOptions.finishedItemCategories
                    : SelectionOptions.materialStockCategories,
                value: _categoryController.text.isEmpty
                    ? null
                    : _categoryController.text,
                labelText: 'Category',
                hintText: _item!.isFinishedItem
                    ? 'Search finished-make categories'
                    : 'Search yarn, tools, and supply categories',
                itemLabel: (category) => category,
                onChanged: (category) =>
                    setState(() => _categoryController.text = category ?? ''),
                customValueBuilder: (query) => query,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: _item!.isFinishedItem
                      ? 'Created / available tally'
                      : 'Amount available to work with',
                  helperText: _item!.isFinishedItem
                      ? null
                      : 'Use decimals for measured stock, such as 250 g or 1.5 m.',
                ),
                keyboardType: _item!.isFinishedItem
                    ? TextInputType.number
                    : const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(
                    labelText: _item!.isFinishedItem
                        ? 'Sale price each (£)'
                        : 'Replacement cost (£)'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              if (_item!.isMaterialStock) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _reorderPointController,
                  decoration: const InputDecoration(
                    labelText: 'Reorder point (optional)',
                    helperText:
                        'Show this material as low stock at or below this amount.',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                SearchableSelectionField<String>(
                  options: SelectionOptions.supplyUnits,
                  value: _measurementUnit,
                  labelText: 'Stock unit',
                  hintText: 'Search grams, metres, balls, pieces, and more',
                  itemLabel: (unit) => unit,
                  onChanged: (unit) => setState(() => _measurementUnit = unit),
                  customValueBuilder: (query) => query,
                ),
              ],
              if (_isYarnCategory) ...[
                const SizedBox(height: 24),
                _buildYarnDetailsEditor(),
              ],
              const SizedBox(height: 16),
              SearchableSelectionField<String>(
                options: SelectionOptions.storageLocations,
                value: _locationController.text.isEmpty
                    ? null
                    : _locationController.text,
                labelText: 'Storage location',
                hintText: 'Search a room, box, drawer, or shelf',
                itemLabel: (location) => location,
                onChanged: (location) =>
                    setState(() => _locationController.text = location ?? ''),
                customValueBuilder: (query) => query,
                allowClear: true,
              ),
            ] else ...[
              _buildDetailRow('Name', _item!.name),
              _buildDetailRow('Type',
                  _item!.isFinishedItem ? 'Created item' : 'Material stock'),
              _buildDetailRow(
                  'Status', _item!.isArchived ? 'Archived' : 'Active'),
              _buildDetailRow('Category', _item!.category),
              _buildDetailRow(
                  _item!.isFinishedItem
                      ? 'Created / available tally'
                      : 'Amount available',
                  _item!.isMaterialStock
                      ? _item!.formattedStockQuantity
                      : _item!.quantity.toString()),
              _buildDetailRow(
                  _item!.isFinishedItem ? 'Sale price' : 'Replacement cost',
                  _item!.price != null
                      ? '£${_item!.price!.toStringAsFixed(2)}'
                      : 'Not set'),
              if (_item!.isMaterialStock)
                _buildDetailRow(
                  'Reorder point',
                  _item!.activeReorderPoint == null
                      ? 'Use global threshold'
                      : '${_item!.activeReorderPoint} ${_item!.measurementUnit ?? 'units'}',
                ),
              if (_item!.isYarnOrFibre) ...[
                const Divider(height: 28),
                Text('Yarn & fibre details',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (_item!.yarnDetailSummary.isNotEmpty)
                  _buildDetailRow('Yarn', _item!.yarnDetailSummary),
                if (_item!.dyeLot?.isNotEmpty == true)
                  _buildDetailRow('Dye lot', _item!.dyeLot!),
                if (_item!.yarnWeightGrams != null)
                  _buildDetailRow(
                      'Skein weight', '${_item!.yarnWeightGrams} g'),
                if (_item!.yarnLengthMetres != null)
                  _buildDetailRow(
                      'Skein length', '${_item!.yarnLengthMetres} m'),
                if (_item!.recommendedHookSize?.isNotEmpty == true)
                  _buildDetailRow(
                      'Recommended hook', _item!.recommendedHookSize!),
                if (_item!.gaugeNote?.isNotEmpty == true)
                  _buildDetailRow('Gauge / notes', _item!.gaugeNote!),
                if (_item!.yarnDetailSummary.isEmpty &&
                    _item!.dyeLot?.isEmpty != false &&
                    _item!.yarnWeightGrams == null &&
                    _item!.yarnLengthMetres == null &&
                    _item!.recommendedHookSize?.isEmpty != false &&
                    _item!.gaugeNote?.isEmpty != false)
                  const Text('No yarn details added yet.'),
              ],
              _buildDetailRow(
                  'Storage Location', _item!.storageLocation ?? 'Not set'),
              _buildDetailRow(
                  'Last Updated', _item!.lastUpdated.toString().split(' ')[0]),
            ],
          ],
        ),
      ),
    );
  }

  String? _optional(String value) {
    final clean = value.trim();
    return clean.isEmpty ? null : clean;
  }

  Widget _buildYarnDetailsEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Yarn & fibre details',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        const Text(
            'Optional: use these fields for dye-lot matching, substitution and hook choice.'),
        const SizedBox(height: 12),
        TextField(
            controller: _yarnBrandController,
            decoration: const InputDecoration(
                labelText: 'Brand', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(
            controller: _yarnRangeController,
            decoration: const InputDecoration(
                labelText: 'Range / line', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(
            controller: _yarnColourController,
            decoration: const InputDecoration(
                labelText: 'Colour / shade', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(
            controller: _dyeLotController,
            decoration: const InputDecoration(
                labelText: 'Dye lot', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        SearchableSelectionField<String>(
          options: SelectionOptions.yarnWeights,
          value: _yarnWeight,
          labelText: 'Yarn weight',
          hintText: 'Search yarn weight',
          itemLabel: (value) => value,
          searchTerms: (value) => [value],
          onChanged: (value) => setState(() => _yarnWeight = value),
          allowClear: true,
        ),
        const SizedBox(height: 12),
        SearchableSelectionField<String>(
          options: SelectionOptions.yarnFibres,
          value: _yarnFibre,
          labelText: 'Main fibre',
          hintText: 'Search fibre',
          itemLabel: (value) => value,
          searchTerms: (value) => [value],
          onChanged: (value) => setState(() => _yarnFibre = value),
          allowClear: true,
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: TextField(
                  controller: _yarnWeightGramsController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      labelText: 'Skein weight (g)',
                      border: OutlineInputBorder()))),
          const SizedBox(width: 12),
          Expanded(
              child: TextField(
                  controller: _yarnLengthMetresController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      labelText: 'Skein length (m)',
                      border: OutlineInputBorder()))),
        ]),
        const SizedBox(height: 12),
        SearchableSelectionField<String>(
          options: SelectionOptions.crochetHookSizes,
          value: _recommendedHookSize,
          labelText: 'Recommended hook size',
          hintText: 'Search hook size',
          itemLabel: (value) => value,
          searchTerms: (value) => [value],
          onChanged: (value) => setState(() => _recommendedHookSize = value),
          allowClear: true,
        ),
        const SizedBox(height: 12),
        TextField(
            controller: _gaugeNoteController,
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(
                labelText: 'Gauge or substitution note',
                border: OutlineInputBorder())),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _showQRCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('QR Code for ${_item!.name}'),
        content: SizedBox(
          width: 250,
          height: 250,
          child: QRGeneratorWidget(data: _item!.id),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _reorderPointController.dispose();
    _yarnBrandController.dispose();
    _yarnRangeController.dispose();
    _yarnColourController.dispose();
    _dyeLotController.dispose();
    _yarnWeightGramsController.dispose();
    _yarnLengthMetresController.dispose();
    _gaugeNoteController.dispose();
    super.dispose();
  }
}
