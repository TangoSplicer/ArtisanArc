import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/personal_app_bar.dart';
import '../data/maker_collection_model.dart';
import '../domain/collection_planning_service.dart';

class MakerCollectionDetailScreen extends StatefulWidget {
  const MakerCollectionDetailScreen({super.key, required this.collectionId});

  final String collectionId;

  @override
  State<MakerCollectionDetailScreen> createState() =>
      _MakerCollectionDetailScreenState();
}

class _MakerCollectionDetailScreenState
    extends State<MakerCollectionDetailScreen> {
  final CollectionPlanningService _planningService =
      GetIt.I<CollectionPlanningService>();

  MakerCollection? _collection;
  CollectionPlanningSnapshot? _snapshot;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCollection();
  }

  Future<void> _loadCollection() async {
    setState(() => _isLoading = true);
    try {
      final collection =
          await _planningService.getCollectionById(widget.collectionId);
      if (collection != null) {
        final snapshot = await _planningService.getSnapshot(collection);
        if (mounted) {
          setState(() {
            _collection = collection;
            _snapshot = snapshot;
            _isLoading = false;
          });
          return;
        }
      }
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load collection details: $error')),
        );
      }
    }
  }

  Future<void> _deleteCollection() async {
    final collection = _collection;
    if (collection == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete collection?'),
        content: Text(
          'Delete "${collection.name}"? Linked projects and inventory will not be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _planningService.deleteCollection(collection.id);
      if (mounted) context.pop();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete collection: $error')),
        );
      }
    }
  }

  Future<void> _createProject(CollectionRecipeProgress progress) async {
    final collection = _collection;
    if (collection == null) return;
    try {
      final project = await _planningService.createProjectForRecipeTarget(
        collection: collection,
        recipe: progress.recipe,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Created project "${project.name}" for collection.')),
      );
      context
          .push('/projects/detail/${project.id}')
          .then((_) => _loadCollection());
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not create project: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final collection = _collection;
    final snapshot = _snapshot;

    if (_isLoading) {
      return Scaffold(
        appBar: PersonalAppBar(
          title: const Text('Collection'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (collection == null || snapshot == null) {
      return Scaffold(
        appBar: PersonalAppBar(
          title: const Text('Collection not found'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('This collection could not be found.'),
                const SizedBox(height: 16),
                FilledButton(
                    onPressed: () => context.pop(),
                    child: const Text('Back to collections')),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: PersonalAppBar(
        title: Text(collection.name),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit collection',
            onPressed: () => context
                .push('/collections/edit/${collection.id}')
                .then((_) => _loadCollection()),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete collection',
            onPressed: _deleteCollection,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (collection.description?.isNotEmpty == true) ...[
            Text(collection.description!, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 16),
          ],
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Capacity & timing', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _metricBox(
                          'Estimated work',
                          '${snapshot.estimatedMinutesRemaining ~/ 60} hrs ${snapshot.estimatedMinutesRemaining % 60} mins',
                          Icons.schedule_outlined,
                          theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _metricBox(
                          'Available capacity',
                          '${snapshot.availableCapacityMinutes ~/ 60} hrs (${snapshot.weeksRemaining} wks)',
                          snapshot.isWithinCapacity
                              ? Icons.check_circle_outline
                              : Icons.warning_amber_outlined,
                          snapshot.isWithinCapacity
                              ? Colors.green.shade700
                              : theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    snapshot.isWithinCapacity
                        ? 'Estimated making time fits within your ${collection.weeklyCapacityMinutes} min/week capacity.'
                        : 'Estimated time exceeds available capacity by ${(-snapshot.capacityDifferenceMinutes) ~/ 60} hrs. Consider adjusting targets or weekly making hours.',
                    style: TextStyle(
                      color: snapshot.isWithinCapacity
                          ? Colors.green.shade800
                          : theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Recipe targets & progress', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          ...snapshot.recipeProgress.map((progress) => Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              progress.recipe.name,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Chip(
                            label: Text(progress.statusLabel),
                            backgroundColor: progress.remainingQuantity <= 0
                                ? Colors.green.shade100
                                : progress.isReadyToMake
                                    ? theme.colorScheme.primaryContainer
                                    : theme.colorScheme.errorContainer,
                            labelStyle: TextStyle(
                              color: progress.remainingQuantity <= 0
                                  ? Colors.green.shade900
                                  : progress.isReadyToMake
                                      ? theme.colorScheme.onPrimaryContainer
                                      : theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Target: ${progress.target.targetQuantity} pieces · Produced: ${progress.producedQuantity} · Remaining: ${progress.remainingQuantity}',
                        style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 12),
                      const Text('Material readiness:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      ...progress.materialReadiness.map((readiness) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Icon(
                                  readiness.isReady
                                      ? Icons.check_circle
                                      : Icons.error_outline,
                                  size: 16,
                                  color: readiness.isReady
                                      ? Colors.green.shade700
                                      : theme.colorScheme.error,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${readiness.supplyNeed.itemName} (${CollectionMaterialReadiness._format(readiness.requiredQuantity)} ${readiness.supplyNeed.unit}): ${readiness.issue}',
                                    style: TextStyle(
                                      color: readiness.isReady
                                          ? theme.colorScheme.onSurface
                                          : theme.colorScheme.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      if (progress.remainingQuantity > 0) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: progress.isReadyToMake
                                ? () => _createProject(progress)
                                : null,
                            icon: const Icon(Icons.playlist_add_outlined),
                            label: Text(
                              'Start project for batch (${progress.suggestedBatchQuantity} pcs)',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _metricBox(
      String title, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}
