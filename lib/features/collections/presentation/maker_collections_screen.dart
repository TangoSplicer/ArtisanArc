import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/personal_app_bar.dart';
import '../data/maker_collection_model.dart';
import '../domain/collection_planning_service.dart';

class MakerCollectionsScreen extends StatefulWidget {
  const MakerCollectionsScreen({super.key});

  @override
  State<MakerCollectionsScreen> createState() => _MakerCollectionsScreenState();
}

class _MakerCollectionsScreenState extends State<MakerCollectionsScreen> {
  final CollectionPlanningService _planningService =
      GetIt.I<CollectionPlanningService>();

  List<MakerCollection> _collections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    setState(() => _isLoading = true);
    try {
      final collections = await _planningService.getCollections();
      if (mounted) {
        setState(() {
          _collections = collections;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load collections: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: PersonalAppBar(
        title: const Text('Maker Collections'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _collections.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome_outlined,
                            size: 64, color: theme.colorScheme.primary),
                        const SizedBox(height: 16),
                        Text('No production collections yet',
                            style: theme.styleTextIfPossible?.titleLarge ??
                                const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text(
                          'Plan a seasonal range, market stall, or gifting collection to track recipe targets, making capacity, and next-make queues.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () => context
                              .push('/collections/new')
                              .then((_) => _loadCollections()),
                          icon: const Icon(Icons.add),
                          label: const Text('Create collection'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _collections.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Card(
                          color: theme.colorScheme.primaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(Icons.psychology_outlined,
                                    color:
                                        theme.colorScheme.onPrimaryContainer),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Group crochet Make Recipes into seasonal collections. The app calculates required making time against your weekly capacity and checks material readiness.',
                                    style: TextStyle(
                                        color: theme
                                            .colorScheme.onPrimaryContainer),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    final collection = _collections[index - 1];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => context
                            .push('/collections/detail/${collection.id}')
                            .then((_) => _loadCollections()),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      collection.name,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  if (collection.season?.isNotEmpty == true)
                                    Chip(
                                      label: Text(collection.season!),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                ],
                              ),
                              if (collection.description?.isNotEmpty ==
                                  true) ...[
                                const SizedBox(height: 6),
                                Text(
                                  collection.description!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color:
                                          theme.colorScheme.onSurfaceVariant),
                                ),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.inventory_2_outlined,
                                      size: 16,
                                      color: theme.colorScheme.primary),
                                  const SizedBox(width: 6),
                                  Text(
                                      '${collection.recipeTargets.length} recipe target${collection.recipeTargets.length == 1 ? '' : 's'}'),
                                  const SizedBox(width: 16),
                                  Icon(Icons.schedule_outlined,
                                      size: 16,
                                      color: theme.colorScheme.primary),
                                  const SizedBox(width: 6),
                                  Text(
                                      '${collection.weeklyCapacityMinutes} min/week capacity'),
                                ],
                              ),
                              if (collection.targetDate != null) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.event_outlined,
                                        size: 16,
                                        color: theme.colorScheme.primary),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Target date: ${collection.targetDate!.toLocal().toString().split(' ').first}',
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.push('/collections/new').then((_) => _loadCollections()),
        icon: const Icon(Icons.add),
        label: const Text('New collection'),
      ),
    );
  }
}
