import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../data/inventory_model.dart';
import '../domain/inventory_service.dart';
import '../../qr/presentation/qr_generator_widget.dart';

class InventoryDetailScreen extends StatefulWidget {
  final String itemId;

  const InventoryDetailScreen({super.key, required this.itemId});

  @override
  State<InventoryDetailScreen> createState() => _InventoryDetailScreenState();
}

class _InventoryDetailScreenState extends State<InventoryDetailScreen> {
  final InventoryService _service = GetIt.I<InventoryService>();
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

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

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
    _quantityController = TextEditingController(text: _item?.quantity.toString());
    _priceController = TextEditingController(text: _item?.price?.toString() ?? '');
    _locationController = TextEditingController(text: _item?.storageLocation ?? '');
  }

  Future<void> _saveChanges() async {
    if (_item == null) return;

    final updatedItem = _item!.copyWith(
      name: _nameController.text,
      category: _categoryController.text,
      quantity: int.tryParse(_quantityController.text) ?? _item!.quantity,
      price: double.tryParse(_priceController.text),
      storageLocation: _locationController.text.isEmpty ? null : _locationController.text,
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

        final updatedPaths = List<String>.from(_item!.imagePaths ?? [])..add(fileName);
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
        appBar: AppBar(title: const Text('Item Not Found')),
        body: const Center(child: Text('Item not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
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
              },
              itemBuilder: (context) => [
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
                        (dir) => p.join(dir.path, 'inventory_images', images[index]),
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
                          child: const Center(child: CircularProgressIndicator()),
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
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price (£)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Storage Location'),
              ),
            ] else ...[
              _buildDetailRow('Name', _item!.name),
              _buildDetailRow('Category', _item!.category),
              _buildDetailRow('Quantity', _item!.quantity.toString()),
              _buildDetailRow('Price', _item!.price != null ? '£${_item!.price!.toStringAsFixed(2)}' : 'Not set'),
              _buildDetailRow('Storage Location', _item!.storageLocation ?? 'Not set'),
              _buildDetailRow('Last Updated', _item!.lastUpdated.toString().split(' ')[0]),
            ],
          ],
        ),
      ),
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
    if (_isEditing) {
      _nameController.dispose();
      _categoryController.dispose();
      _quantityController.dispose();
      _priceController.dispose();
      _locationController.dispose();
    }
    super.dispose();
  }
}