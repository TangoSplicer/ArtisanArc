import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:artisanarc/features/shopping/data/shopping_list_model.dart';
import 'package:artisanarc/features/shopping/domain/shopping_service.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class ShoppingListOverviewScreen extends StatefulWidget {
  const ShoppingListOverviewScreen({super.key});

  @override
  State<ShoppingListOverviewScreen> createState() => _ShoppingListOverviewScreenState();
}

class _ShoppingListOverviewScreenState extends State<ShoppingListOverviewScreen> {
  final ShoppingService _shoppingService = GetIt.I<ShoppingService>();
  List<ShoppingList> _shoppingLists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadShoppingLists();
  }

  Future<void> _loadShoppingLists() async {
    setState(() => _isLoading = true);
    try {
      _shoppingLists = await _shoppingService.getAllShoppingLists();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading shopping lists: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToDetailScreen(String listId) {
    context.push('/shopping-list/$listId').then((_) => _loadShoppingLists());
  }

  Future<void> _showCreateListDialog() async {
    final listNameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final newListName = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Create New Shopping List'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: listNameController,
              decoration: const InputDecoration(labelText: 'List Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a list name';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(dialogContext).pop(listNameController.text);
                }
              },
            ),
          ],
        );
      },
    );

    if (newListName != null && newListName.isNotEmpty) {
      final newList = ShoppingList(
        id: Uuid().v4(),
        name: newListName,
        createdAt: DateTime.now(),
        items: [],
      );
      try {
        await _shoppingService.createShoppingList(newList);
        _loadShoppingLists(); // Refresh the list
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating list: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteList(String listId, String listName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Shopping List'),
          content: Text('Are you sure you want to delete the list "$listName"?'),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _shoppingService.deleteShoppingList(listId);
        _loadShoppingLists();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('List "$listName" deleted.')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting list: $e')));
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Lists'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _shoppingLists.isEmpty
              ? Center(
                  child: Text(
                    'No shopping lists yet. Tap + to create one!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: _shoppingLists.length,
                  itemBuilder: (context, index) {
                    final list = _shoppingLists[index];
                    final unpurchasedItems = list.items.where((item) => !item.isPurchased).length;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 2.0,
                      child: ListTile(
                        title: Text(list.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          'Created: ${DateFormat.yMMMd().format(list.createdAt)}\n'
                          '$unpurchasedItems item(s) pending',
                        ),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'delete') {
                              _deleteList(list.id, list.name);
                            }
                            // Edit name could be added here
                          },
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete), title: Text('Delete List'))),
                          ],
                        ),
                        onTap: () => _navigateToDetailScreen(list.id),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateListDialog,
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('New List'),
      ),
    );
  }
}
