import 'dart:io'; // For File operations
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For FilteringTextInputFormatter
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart'; // Added image_picker
import 'package:path_provider/path_provider.dart'; // Added path_provider
import 'package:path/path.dart' as path; // For path manipulation
import 'package:artisanarc/features/inventory/data/inventory_model.dart';
import 'package:artisanarc/features/inventory/domain/usecases/add_inventory_item_usecase.dart';
import 'package:uuid/uuid.dart'; // For generating unique IDs

class AddInventoryItemScreen extends StatefulWidget {
  const AddInventoryItemScreen({super.key});

  @override
  State<AddInventoryItemScreen> createState() => _AddInventoryItemScreenState();
}

class _AddInventoryItemScreenState extends State<AddInventoryItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _storageLocationController = TextEditingController();
  List<String> _selectedImagePaths = []; // To store paths of copied images
  final ImagePicker _picker = ImagePicker();

  final AddInventoryItemUseCase _addInventoryItemUseCase = GetIt.I<AddInventoryItemUseCase>();
  final Uuid _uuid = Uuid();

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _storageLocationController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final newItem = InventoryModel(
        id: _uuid.v4(), // Generate a unique ID
        name: _nameController.text,
        category: _categoryController.text,
        quantity: int.parse(_quantityController.text),
        price: double.parse(_priceController.text),
        storageLocation: _storageLocationController.text.isNotEmpty ? _storageLocationController.text : null,
        imagePaths: _selectedImagePaths, // Pass the stored image paths
        lastUpdated: DateTime.now(),
      );

      try {
        await _addInventoryItemUseCase(newItem);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${newItem.name} added to inventory')),
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
      appBar: AppBar(
        title: const Text('Add Inventory Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name*', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the item name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category*', border: OutlineInputBorder()),
                 validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity*', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the quantity';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid positive quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price (Optional)', border: OutlineInputBorder(), prefixText: '\$ '),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                 validator: (value) {
                  if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _storageLocationController,
                decoration: const InputDecoration(labelText: 'Storage Location (Optional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              _buildImagePickerSection(), // Added image picker section
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
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
                    label: Text(path.basename(imagePath)), // Display only the filename
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
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        imageQuality: 80, // Compress images slightly
      );

      if (pickedFiles.isNotEmpty) {
        final appDocDir = await getApplicationDocumentsDirectory();
        final imagesDir = Directory(path.join(appDocDir.path, 'inventory_images'));

        if (!await imagesDir.exists()) {
          await imagesDir.create(recursive: true);
        }

        List<String> newImagePaths = [];
        for (XFile pickedFile in pickedFiles) {
          final fileName = '${_uuid.v4()}${path.extension(pickedFile.path)}'; // Create a unique filename
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
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking images: $e')),
        );
      }
    }
  }
}
