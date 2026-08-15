import 'package:artisanarc/core/widgets/personal_app_bar.dart';
import 'package:artisanarc/features/business/data/sale_model.dart';
import 'package:artisanarc/features/business/domain/business_service.dart';
import 'package:artisanarc/features/inventory/data/inventory_model.dart';
import 'package:artisanarc/features/inventory/domain/inventory_service.dart';
import 'package:artisanarc/features/project/data/project_model.dart';
import 'package:artisanarc/features/project/domain/project_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class SmartSearchScreen extends StatefulWidget {
  const SmartSearchScreen({super.key});

  @override
  State<SmartSearchScreen> createState() => _SmartSearchScreenState();
}

class _SmartSearchScreenState extends State<SmartSearchScreen> {
  final InventoryService _inventoryService = GetIt.I<InventoryService>();
  final ProjectService _projectService = GetIt.I<ProjectService>();
  final BusinessService _businessService = GetIt.I<BusinessService>();
  final TextEditingController _searchController = TextEditingController();

  List<InventoryItem> _items = [];
  List<Project> _projects = [];
  List<SaleRecord> _sales = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final items = await _inventoryService.fetchItems();
      final projects = await _projectService.fetchProjects();
      final sales = await _businessService.fetchSales();
      if (!mounted) return;
      setState(() {
        _items = items;
        _projects = projects;
        _sales = sales;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not search local records: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String get _query => _searchController.text.trim().toLowerCase();

  List<InventoryItem> get _matchingItems => _items.where((item) {
        if (_query.isEmpty) return false;
        return '${item.name} ${item.category} ${item.itemType} ${item.storageLocation ?? ''}'
            .toLowerCase()
            .contains(_query);
      }).toList();

  List<Project> get _matchingProjects => _projects.where((project) {
        if (_query.isEmpty) return false;
        return '${project.name} ${project.craftType ?? ''} ${project.description ?? ''}'
            .toLowerCase()
            .contains(_query);
      }).toList();

  List<SaleRecord> get _matchingSales {
    if (_query.isEmpty) return [];
    final itemNames = {for (final item in _items) item.id: item.name};
    return _sales.where((sale) {
      final text =
          '${itemNames[sale.itemId] ?? sale.itemId} ${sale.eventName ?? ''} '
          '${sale.eventLocation ?? ''} ${sale.paymentMethod} ${sale.adjustmentReason ?? ''}';
      return text.toLowerCase().contains(_query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _matchingItems;
    final projects = _matchingProjects;
    final sales = _matchingSales;
    final resultCount = items.length + projects.length + sales.length;

    return Scaffold(
      appBar: const PersonalAppBar(title: Text('Smart Search')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Semantics(
                  textField: true,
                  label: 'Search your items, materials, projects and sales',
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Search everything',
                      hintText: 'Try a make, material, project or event',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear search',
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.clear),
                            ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_query.isEmpty)
                  const _SearchGuidance()
                else if (resultCount == 0)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child:
                        Center(child: Text('No matching local records found.')),
                  )
                else ...[
                  Text(
                      '$resultCount local result${resultCount == 1 ? '' : 's'}',
                      style: Theme.of(context).textTheme.bodySmall),
                  if (items.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _sectionTitle(context, 'Created items and materials'),
                    ...items.map(_buildItemResult),
                  ],
                  if (projects.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _sectionTitle(context, 'Projects'),
                    ...projects.map(_buildProjectResult),
                  ],
                  if (sales.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _sectionTitle(context, 'Sales'),
                    ...sales.map(_buildSaleResult),
                  ],
                ],
              ],
            ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );

  Widget _buildItemResult(InventoryItem item) => Card(
        child: ListTile(
          onTap: () => context.pushNamed(
            'inventoryDetail',
            pathParameters: {'itemId': item.id},
          ),
          leading: Icon(item.isFinishedItem
              ? Icons.inventory_2_outlined
              : Icons.yard_outlined),
          title: Text(item.name),
          subtitle: Text(
              '${item.isFinishedItem ? 'Created item' : 'Material'} · ${item.category} · ${item.quantity} available'),
          trailing: const Icon(Icons.chevron_right),
        ),
      );

  Widget _buildProjectResult(Project project) => Card(
        child: ListTile(
          onTap: () => context.pushNamed(
            'projectDetail',
            pathParameters: {'id': project.id},
          ),
          leading: const Icon(Icons.timeline_outlined),
          title: Text(project.name),
          subtitle: Text(project.craftType ?? 'Project'),
          trailing: const Icon(Icons.chevron_right),
        ),
      );

  Widget _buildSaleResult(SaleRecord sale) {
    InventoryItem? item;
    for (final candidate in _items) {
      if (candidate.id == sale.itemId) {
        item = candidate;
        break;
      }
    }
    final status = sale.isVoid
        ? 'Voided'
        : sale.isReturn
            ? 'Return'
            : sale.paymentMethod;
    return Card(
      child: ListTile(
        onTap: () => context.pushNamed('dailySales'),
        leading: const Icon(Icons.receipt_long_outlined),
        title: Text(item?.name ?? 'Removed inventory item'),
        subtitle: Text(
            '${DateFormat.yMMMd().format(sale.date)} · $status${sale.eventName == null ? '' : ' · ${sale.eventName}'}'),
        trailing: Text('£${sale.total.toStringAsFixed(2)}'),
      ),
    );
  }
}

class _SearchGuidance extends StatelessWidget {
  const _SearchGuidance();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        child: Column(
          children: [
            Icon(Icons.manage_search_outlined,
                size: 56, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text('Find anything in your Personal Edition',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            const Text(
              'Search works entirely on your device across created items, materials, projects and sales records.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}
