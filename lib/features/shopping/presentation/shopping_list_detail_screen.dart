import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:artisanarc/features/shopping/data/shopping_list_model.dart';
import 'package:artisanarc/features/shopping/domain/shopping_service.dart';
import 'package:uuid/uuid.dart'; // For generating item IDs

class ShoppingListDetailScreen extends StatefulWidget {
  final String shoppingListId;
  const ShoppingListDetailScreen({super.key, required this.shoppingListId});

  @override
  State<ShoppingListDetailScreen> createState() => _ShoppingListDetailScreenState();
}

class _ShoppingListDetailScreenState extends State<ShoppingListDetailScreen> {
  final ShoppingService _shoppingService = GetIt.I<ShoppingService>();
  final Uuid _uuid = Uuid();
  ShoppingList? _shoppingList;
  bool _isLoading = true;
  TextEditingController _listNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadListDetails();
  }

  Future<void> _loadListDetails() async {
    setState(() => _isLoading = true);
    try {
      _shoppingList = await _shoppingService.getShoppingListById(widget.shoppingListId);
      if (_shoppingList != null) {
        _listNameController.text = _shoppingList!.name;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading list details: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateListName() async {
    if (_shoppingList == null || _listNameController.text.isEmpty || _shoppingList!.name == _listNameController.text) {
      return;
    }
    try {
      _shoppingList!.name = _listNameController.text;
      await _shoppingService.updateShoppingList(_shoppingList!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('List name updated!')));
      }
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating list name: $e')));
       }
       // Optionally revert controller text if save fails
       _listNameController.text = _shoppingList?.name ?? '';
    }
  }


  Future<void> _showAddItemDialog({ShoppingListItem? existingItem}) async {
    final itemNameController = TextEditingController(text: existingItem?.itemName);
    final quantityController = TextEditingController(text: existingItem?.quantity);
    final notesController = TextEditingController(text: existingItem?.notes);
    final formKey = GlobalKey<FormState>();
    bool isEditing = existingItem != null;

    final result = await showDialog<ShoppingListItem>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Item' : 'Add New Item'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: itemNameController,
                    decoration: const InputDecoration(labelText: 'Item Name*'),
                    validator: (value) => (value == null || value.isEmpty) ? 'Enter item name' : null,
                  ),
                  TextFormField(
                    controller: quantityController,
                    decoration: const InputDecoration(labelText: 'Quantity (e.g., 2 packs)'),
                  ),
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(labelText: 'Notes (Optional)'),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
            TextButton(
              child: Text(isEditing ? 'Save' : 'Add'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(dialogContext).pop(ShoppingListItem(
                    id: existingItem?.id ?? _uuid.v4(),
                    itemName: itemNameController.text,
                    quantity: quantityController.text,
                    notes: notesController.text,
                    isPurchased: existingItem?.isPurchased ?? false,
                  ));
                }
              },
            ),
          ],
        );
      },
    );

    if (result != null) {
      try {
        if (isEditing) {
          await _shoppingService.updateListItem(widget.shoppingListId, result);
        } else {
          await _shoppingService.addItemToList(widget.shoppingListId, result);
        }
        _loadListDetails(); // Refresh list
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving item: $e')));
        }
      }
    }
  }

  Future<void> _togglePurchased(ShoppingListItem item) async {
    try {
      await _shoppingService.toggleItemPurchased(widget.shoppingListId, item.id, !item.isPurchased);
      _loadListDetails(); // Refresh list
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating item: $e')));
      }
    }
  }

  Future<void> _deleteItem(ShoppingListItem item) async {
     final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.itemName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _shoppingService.removeItemFromList(widget.shoppingListId, item.id);
        _loadListDetails(); // Refresh list
      } catch (e) {
         if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting item: $e')));
         }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: _isLoading || _shoppingList == null
            ? const Text('Loading List...')
            : TextField( // Allow editing list name in AppBar
                controller: _listNameController,
                decoration: InputDecoration(
                  hintText: 'List Name',
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.save_alt_outlined),
                    onPressed: _updateListName,
                    tooltip: 'Save List Name',
                  )
                ),
                style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary),
                onSubmitted: (_) => _updateListName(),
              ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _shoppingList == null
              ? const Center(child: Text('Shopping list not found.'))
              : RefreshIndicator(
                  onRefresh: _loadListDetails,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _shoppingList!.items.length,
                    itemBuilder: (context, index) {
                      final item = _shoppingList!.items[index];
                      return Card(
                        elevation: 1.0,
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ListTile(
                          leading: Checkbox(
                            value: item.isPurchased,
                            onChanged: (bool? value) {
                              if (value != null) {
                                _togglePurchased(item);
                              }
                            },
                          ),
                          title: Text(
                            item.itemName,
                            style: TextStyle(
                              decoration: item.isPurchased ? TextDecoration.lineThrough : null,
                              color: item.isPurchased ? Colors.grey : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (item.quantity != null && item.quantity!.isNotEmpty) Text('Qty: ${item.quantity}'),
                              if (item.notes != null && item.notes!.isNotEmpty) Text('Notes: ${item.notes}'),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') _showAddItemDialog(existingItem: item);
                              if (value == 'delete') _deleteItem(item);
                            },
                            itemBuilder: (BuildContext context) => [
                              const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit), title: Text('Edit'))),
                              const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete), title: Text('Delete'))),
                            ],
                          ),
                          onTap: () => _showAddItemDialog(existingItem: item), // Tap to edit
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(),
        tooltip: 'Add Item to List',
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _listNameController.dispose();
    super.dispose();
  }
}
