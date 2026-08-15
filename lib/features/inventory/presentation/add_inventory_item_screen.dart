import 'dart:io'; // For File operations
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For FilteringTextInputFormatter
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart'; // Added image_picker
import 'package:path_provider/path_provider.dart'; // Added path_provider
import 'package:path/path.dart' as path; // For path manipulation
import 'package:artisanarc/features/inventory/data/inventory_model.dart';
import 'package:artisanarc/features/inventory/domain/inventory_service.dart';
import 'package:uuid/uuid.dart'; // For generating unique IDs
import 'package:artisanarc/core/utils/validators.dart';
import 'package:artisanarc/core/services/permission_service.dart';
import 'package:artisanarc/core/constants/selection_options.dart';
import 'package:artisanarc/core/widgets/personal_app_bar.dart';
import 'package:artisanarc/core/widgets/searchable_selection_field.dart';

class AddInventoryItemScreen extends StatefulWidget {
  final String itemType;

  const AddInventoryItemScreen({super.key, this.itemType = 'finished'});

  @override
  State<AddInventoryItemScreen> createState() => _AddInventoryItemScreenState();
}

class _AddInventoryItemScreenState extends State<AddInventoryItemScreen> {
  bool get _isFinishedItem => widget.itemType == 'finished';

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _storageLocationController = TextEditingController();
  final _reorderPointController = TextEditingController();
  String? _measurementUnit;
  List<String> _selectedImagePaths = []; // To store paths of copied images
  final ImagePicker _picker = ImagePicker();

  final InventoryService _inventoryService = GetIt.I<InventoryService>();
  final Uuid _uuid = Uuid();

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _storageLocationController.dispose();
    _reorderPointController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final enteredQuantity = double.parse(_quantityController.text);
      final newItem = InventoryItem(
        id: _uuid.v4(), // Generate unique ID
        name: _nameController.text,
        category: _categoryController.text,
        quantity:
            _isFinishedItem ? enteredQuantity.toInt() : enteredQuantity.ceil(),
        price: double.tryParse(_priceController.text),
        storageLocation: _storageLocationController.text.isNotEmpty
            ? _storageLocationController.text
            : null,
        imagePaths: _selectedImagePaths, // Pass the stored image paths
        lastUpdated: DateTime.now(),
        itemType: widget.itemType,
        reorderPoint: _isFinishedItem ? null : null,
        measuredQuantity: _isFinishedItem ? null : enteredQuantity,
        measurementUnit: _isFinishedItem ? null : _measurementUnit,
        measuredReorderPoint: _isFinishedItem
            ? null
            : double.tryParse(_reorderPointController.text),
      );

      try {
        await _inventoryService.createItem(newItem);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    '${newItem.name} added to ${_isFinishedItem ? 'created items' : 'materials stock'}')),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add item: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PersonalAppBar(
        title:
            Text(_isFinishedItem ? 'Add Created Item' : 'Add Material Stock'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: _isFinishedItem
                      ? 'Created item name*'
                      : 'Material or tool name*',
                  border: const OutlineInputBorder(),
                ),
                validator: Validators.validateItemName,
              ),
              const SizedBox(height: 16),
              SearchableSelectionField<String>(
                options: _isFinishedItem
                    ? SelectionOptions.finishedItemCategories
                    : SelectionOptions.materialStockCategories,
                value: _categoryController.text.isEmpty
                    ? null
                    : _categoryController.text,
                labelText: 'Category*',
                hintText: _isFinishedItem
                    ? 'Search finished-make categories'
                    : 'Search yarn, tools, and supply categories',
                itemLabel: (category) => category,
                onChanged: (category) =>
                    setState(() => _categoryController.text = category ?? ''),
                customValueBuilder: (query) => query,
                validator: (category) => Validators.validateRequired(category,
                    fieldName: 'Category'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: _isFinishedItem
                      ? 'Number created / available*'
                      : 'Amount available to work with*',
                  helperText: _isFinishedItem
                      ? null
                      : 'Use decimals for measured stock, such as 250 g or 1.5 m.',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: _isFinishedItem
                    ? TextInputType.number
                    : const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: _isFinishedItem
                    ? <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ]
                    : <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                validator: (value) {
                  final amount = double.tryParse(value ?? '');
                  if (amount == null || amount <= 0)
                    return 'Enter an amount greater than zero';
                  if (_isFinishedItem && amount != amount.roundToDouble())
                    return 'Finished-item tally must be a whole number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: _isFinishedItem
                      ? 'Sale price each (optional)'
                      : 'Replacement cost (optional)',
                  border: const OutlineInputBorder(),
                  prefixText: '£ ',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: Validators.validatePrice,
              ),
              if (!_isFinishedItem) ...[
                const SizedBox(height: 16),
                SearchableSelectionField<String>(
                  options: SelectionOptions.supplyUnits,
                  value: _measurementUnit,
                  labelText: 'Stock unit*',
                  hintText: 'Search grams, metres, balls, pieces, and more',
                  itemLabel: (unit) => unit,
                  onChanged: (unit) => setState(() => _measurementUnit = unit),
                  customValueBuilder: (query) => query,
                  validator: (unit) => unit == null || unit.trim().isEmpty
                      ? 'Select a stock unit'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _reorderPointController,
                  decoration: const InputDecoration(
                    labelText: 'Reorder point (optional)',
                    helperText:
                        'Flag this material as low stock at or below this amount.',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              SearchableSelectionField<String>(
                options: SelectionOptions.storageLocations,
                value: _storageLocationController.text.isEmpty
                    ? null
                    : _storageLocationController.text,
                labelText: 'Storage location',
                hintText: 'Search a room, box, drawer, or shelf',
                itemLabel: (location) => location,
                onChanged: (location) => setState(
                    () => _storageLocationController.text = location ?? ''),
                customValueBuilder: (query) => query,
                allowClear: true,
              ),
              const SizedBox(height: 24),
              _buildImagePickerSection(), // Added image picker section
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label:
                    Text(_isFinishedItem ? 'Add Created Item' : 'Add Material'),
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Images', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.add_a_photo),
          label: const Text('Add Images'),
          onPressed: _pickImages,
        ),
        const SizedBox(height: 8),
        _selectedImagePaths.isEmpty
            ? const Text('No images selected.')
            : Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _selectedImagePaths.map((imagePath) {
                  // Since we are storing relative paths to files in app docs,
                  // we need to reconstruct the full path to display them using Image.file
                  // However, during selection, we only have the filename part here.
                  // For simplicity, just show filename. Thumbnails would need full path reconstruction.
                  return Chip(
                    label: Text(
                        path.basename(imagePath)), // Display only the filename
                    onDeleted: () {
                      setState(() {
                        _selectedImagePaths.remove(imagePath);
                        // TODO: Optionally delete the file from app documents directory if needed
                      });
                    },
                  );
                }).toList(),
              ),
      ],
    );
  }

  Future<void> _pickImages() async {
    try {
      // Check camera permission
      final hasPermission = await PermissionService.requestCameraPermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Camera permission is required to add images')),
          );
        }
        return;
      }

      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        imageQuality: 80, // Compress images slightly
      );

      if (pickedFiles.isNotEmpty) {
        final appDocDir = await getApplicationDocumentsDirectory();
        final imagesDir =
            Directory(path.join(appDocDir.path, 'inventory_images'));

        if (!await imagesDir.exists()) {
          await imagesDir.create(recursive: true);
        }

        List<String> newImagePaths = [];
        for (XFile pickedFile in pickedFiles) {
          final fileName =
              '${_uuid.v4()}${path.extension(pickedFile.path)}'; // Create a unique filename
          final localImagePath = path.join(imagesDir.path, fileName);

          final File imageFile = File(pickedFile.path);
          await imageFile.copy(localImagePath);

          // Store the relative path (filename) for Hive, assuming all images are in 'inventory_images'
          newImagePaths.add(fileName);
        }
        setState(() {
          _selectedImagePaths.addAll(newImagePaths);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking images: $e')),
        );
      }
    }
  }
}
