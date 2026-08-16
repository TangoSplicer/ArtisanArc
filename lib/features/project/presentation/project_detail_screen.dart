import 'package:flutter/material.dart';
import 'package:artisanarc/core/widgets/personal_app_bar.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../domain/usecases/get_project_by_id.dart';
import '../domain/usecases/update_project.dart';
import '../data/project_model.dart';
import '../domain/entities/supply_need.dart';
import '../domain/make_to_sell_service.dart';
import '../domain/project_time_service.dart';
import 'project_costing_card.dart';
import '../../../core/utils/date_helpers.dart';

class ProjectDetailScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final GetProjectById _getProjectUseCase = GetIt.I<GetProjectById>();
  final UpdateProject _updateProjectUseCase = GetIt.I<UpdateProject>();
  final MakeToSellService _makeToSellService = GetIt.I<MakeToSellService>();
  final ProjectTimeService _projectTimeService = GetIt.I<ProjectTimeService>();

  Project? _project;
  Map<String, MaterialStockStatus> _stockStatusBySupplyId = const {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProject();
  }

  Future<void> _loadProject() async {
    setState(() => _isLoading = true);
    try {
      final project = await _getProjectUseCase(widget.projectId);
      if (!mounted) return;
      setState(() => _project = project);
      if (project != null) await _loadMaterialStatuses(project);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading project: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMaterialStatuses(Project project) async {
    try {
      final preview = await _makeToSellService.preview(project);
      if (!mounted) return;
      setState(() {
        _stockStatusBySupplyId = {
          for (final status in preview.materials) status.supplyNeed.id: status,
        };
      });
    } catch (_) {
      // The project itself remains usable if a material record was removed.
      if (mounted) setState(() => _stockStatusBySupplyId = const {});
    }
  }

  Future<void> _toggleMilestone(int index) async {
    if (_project == null) return;

    final updatedMilestones = List<Milestone>.from(_project!.milestones);
    updatedMilestones[index] = updatedMilestones[index].copyWith(
      isCompleted: !updatedMilestones[index].isCompleted,
    );

    final updatedProject = _project!.copyWith(
      milestones: updatedMilestones,
      lastUpdatedAt: DateTime.now(),
    );

    try {
      await _updateProjectUseCase(updatedProject);
      setState(() => _project = updatedProject);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating milestone: $e')),
        );
      }
    }
  }

  Future<void> _toggleSupplyNeed(int index) async {
    if (_project == null) return;

    final updatedSupplyNeeds = List<SupplyNeed>.from(_project!.supplyNeeds);
    updatedSupplyNeeds[index] = updatedSupplyNeeds[index].copyWith(
      isSourced: !updatedSupplyNeeds[index].isSourced,
    );

    final updatedProject = _project!.copyWith(
      supplyNeeds: updatedSupplyNeeds,
      lastUpdatedAt: DateTime.now(),
    );

    try {
      await _updateProjectUseCase(updatedProject);
      setState(() => _project = updatedProject);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating supply need: $e')),
        );
      }
    }
  }

  Future<void> _toggleProjectTimer() async {
    final project = _project;
    if (project == null) return;
    try {
      final updated = project.activeTimerStartedAt == null
          ? await _projectTimeService.start(project)
          : await _projectTimeService.pause(project);
      if (!mounted) return;
      setState(() => _project = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updated.activeTimerStartedAt == null
                ? 'Making timer paused. Actual time is saved locally.'
                : 'Making timer started for ${updated.name}.',
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update making timer: $error')),
        );
      }
    }
  }

  Future<void> _openCompleteMakeDialog() async {
    final project = _project;
    if (project == null) return;

    final quantityController = TextEditingController(text: '1');
    final priceController = TextEditingController();
    final notesController = TextEditingController();
    MakeToSellPreview preview = await _makeToSellService.preview(project);
    if (!mounted) return;
    bool isWorking = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> refreshPreview(String value) async {
            final quantity = int.tryParse(value) ?? 1;
            if (quantity < 1) return;
            final refreshed = await _makeToSellService.preview(
              project,
              outputQuantity: quantity,
            );
            if (Navigator.of(dialogContext).mounted) {
              setDialogState(() => preview = refreshed);
            }
          }

          return AlertDialog(
            title: const Text('Complete Make'),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(project.name,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    const Text(
                        'Record a finished-item tally and deduct only linked consumable materials.'),
                    const SizedBox(height: 16),
                    TextField(
                      controller: quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Finished items made',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: refreshPreview,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      decoration: const InputDecoration(
                        labelText: 'Sale price per item (optional)',
                        prefixText: '£ ',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 16),
                    Text('Material check',
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 6),
                    if (preview.materials.isEmpty)
                      const Text(
                          'No supply requirements are attached to this project.')
                    else
                      ...preview.materials.map(
                        (status) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            status.hasEnoughStock
                                ? Icons.check_circle_outline
                                : Icons.error_outline,
                            color: status.hasEnoughStock
                                ? Colors.green
                                : Theme.of(context).colorScheme.error,
                          ),
                          title: Text(status.supplyNeed.itemName),
                          subtitle: Text(
                            status.isLinked
                                ? '${status.formattedAvailableQuantity} ${status.supplyNeed.unit} available · ${status.formattedReservedQuantity} reserved${status.isUnitCompatible ? '' : ' · ${status.issue}'}'
                                : status.issue,
                          ),
                          trailing: Text(
                            status.supplyNeed.isConsumable
                                ? 'Use ${status.formattedConsumptionQuantity} ${status.supplyNeed.unit}'
                                : 'Reusable',
                          ),
                        ),
                      ),
                    if (!preview.canComplete) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Link or replenish the highlighted consumables before completing this make.',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Partial / waste note (optional)',
                        hintText: 'For example: one item had a yarn flaw',
                        border: OutlineInputBorder(),
                      ),
                      minLines: 2,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed:
                    isWorking ? null : () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                onPressed: isWorking || !preview.canComplete
                    ? null
                    : () async {
                        final quantity = int.tryParse(quantityController.text);
                        if (quantity == null || quantity < 1) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Enter a whole number of finished items.')),
                          );
                          return;
                        }
                        setDialogState(() => isWorking = true);
                        try {
                          final result = await _makeToSellService.complete(
                            project: project,
                            outputQuantity: quantity,
                            salePrice: double.tryParse(priceController.text),
                            notes: notesController.text,
                          );
                          if (!Navigator.of(dialogContext).mounted) return;
                          Navigator.of(dialogContext).pop();
                          if (!mounted) return;
                          setState(() => _project = result.updatedProject);
                          await _loadMaterialStatuses(result.updatedProject);
                          if (!mounted) return;
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '${result.finishedItem.quantity} finished item(s) added to Inventory.'),
                              action: SnackBarAction(
                                label: 'View',
                                onPressed: () => this.context.push(
                                    '/inventory/detail/${result.finishedItem.id}'),
                              ),
                            ),
                          );
                        } catch (e) {
                          if (Navigator.of(dialogContext).mounted) {
                            setDialogState(() => isWorking = false);
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                  content: Text('Could not complete make: $e')),
                            );
                          }
                        }
                      },
                icon: const Icon(Icons.check_circle_outline),
                label: Text(isWorking ? 'Completing…' : 'Complete Make'),
              ),
            ],
          );
        },
      ),
    );

    quantityController.dispose();
    priceController.dispose();
    notesController.dispose();
  }

  double get _projectProgress {
    if (_project == null || _project!.milestones.isEmpty) return 0.0;
    final completed = _project!.milestones.where((m) => m.isCompleted).length;
    return completed / _project!.milestones.length;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_project == null) {
      return Scaffold(
        appBar: PersonalAppBar(title: const Text('Project Not Found')),
        body: const Center(child: Text('Project not found')),
      );
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: PersonalAppBar(
        title: Text(_project!.name),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          if (_project!.craftType != null && _project!.craftType!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.lightbulb_outline),
              onPressed: () {
                context.push(
                    '/ai-assistant/${Uri.encodeComponent(_project!.craftType!)}');
              },
            ),
          IconButton(
            icon: Icon(
              _project!.activeTimerStartedAt == null
                  ? Icons.timer_outlined
                  : Icons.pause_circle_outline,
            ),
            tooltip: _project!.activeTimerStartedAt == null
                ? 'Start making timer'
                : 'Pause making timer',
            onPressed: _toggleProjectTimer,
          ),
          IconButton(
            icon: const Icon(Icons.inventory_2_outlined),
            tooltip: 'Complete Make',
            onPressed: _openCompleteMakeDialog,
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context
                  .push('/projects/edit/${_project!.id}')
                  .then((_) => _loadProject());
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProject,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildProjectOverview(theme),
            const SizedBox(height: 16),
            _buildProgressCard(theme),
            const SizedBox(height: 16),
            _buildMakingTimeCard(theme),
            const SizedBox(height: 16),
            ProjectCostingCard(
              project: _project!,
              onProjectUpdated: (updated) {
                if (mounted) setState(() => _project = updated);
              },
            ),
            const SizedBox(height: 16),
            _buildMilestonesCard(theme),
            const SizedBox(height: 16),
            _buildSupplyNeedsCard(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectOverview(ThemeData theme) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Project Overview', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            if (_project!.description != null &&
                _project!.description!.isNotEmpty) ...[
              Text('Description', style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(_project!.description!),
              const SizedBox(height: 16),
            ],
            if (_project!.craftType != null &&
                _project!.craftType!.isNotEmpty) ...[
              Text('Craft Type', style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Chip(
                label: Text(_project!.craftType!),
                backgroundColor: theme.colorScheme.primaryContainer,
              ),
              const SizedBox(height: 16),
            ],
            if (_project!.recipeName != null &&
                _project!.recipeName!.isNotEmpty) ...[
              Text('Make Recipe', style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                  '${_project!.recipeName} · planned output ${_project!.plannedOutputQuantity}'),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Start Date', style: theme.textTheme.titleMedium),
                      Text(_project!.startDate != null
                          ? DateHelpers.formatForDisplay(_project!.startDate!)
                          : 'Not set'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('End Date', style: theme.textTheme.titleMedium),
                      Text(_project!.endDate != null
                          ? DateHelpers.formatForDisplay(_project!.endDate!)
                          : 'Not set'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(ThemeData theme) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Progress', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _projectProgress,
              backgroundColor: theme.colorScheme.surfaceVariant,
              valueColor:
                  AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Text(
              '${(_projectProgress * 100).toStringAsFixed(1)}% Complete',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${_project!.milestones.where((m) => m.isCompleted).length} of ${_project!.milestones.length} milestones completed',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMakingTimeCard(ThemeData theme) {
    final project = _project!;
    final isRunning = project.activeTimerStartedAt != null;
    final hours = project.actualLabourMinutes ~/ 60;
    final minutes = project.actualLabourMinutes % 60;
    final recorded = hours == 0
        ? '$minutes min'
        : '$hours h${minutes == 0 ? '' : ' $minutes min'}';
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Making Time', style: theme.textTheme.titleLarge),
                ),
                FilledButton.icon(
                  onPressed: _toggleProjectTimer,
                  icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(isRunning ? 'Pause' : 'Start'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Recorded: $recorded${isRunning ? ' · timer running' : ''}'),
            const SizedBox(height: 4),
            const Text(
              'Actual time stays separate from the original estimate and feeds the Cost & Price price floor.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestonesCard(ThemeData theme) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Milestones', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            if (_project!.milestones.isEmpty)
              const Text('No milestones added yet')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _project!.milestones.length,
                itemBuilder: (context, index) {
                  final milestone = _project!.milestones[index];
                  final isOverdue = DateHelpers.isOverdue(milestone.dueDate) &&
                      !milestone.isCompleted;
                  final isDueSoon = DateHelpers.isDueSoon(milestone.dueDate) &&
                      !milestone.isCompleted;

                  return ListTile(
                    leading: IconButton(
                      icon: Icon(
                        milestone.isCompleted
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: milestone.isCompleted
                            ? Colors.green
                            : isOverdue
                                ? Colors.red
                                : isDueSoon
                                    ? Colors.orange
                                    : null,
                      ),
                      onPressed: () => _toggleMilestone(index),
                    ),
                    title: Text(
                      milestone.name,
                      style: TextStyle(
                        decoration: milestone.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Due: ${DateHelpers.formatForDisplay(milestone.dueDate)}',
                          style: TextStyle(
                            color: isOverdue
                                ? Colors.red
                                : isDueSoon
                                    ? Colors.orange
                                    : null,
                          ),
                        ),
                        if (milestone.description != null &&
                            milestone.description!.isNotEmpty)
                          Text(milestone.description!),
                      ],
                    ),
                    isThreeLine: milestone.description != null &&
                        milestone.description!.isNotEmpty,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplyNeedsCard(ThemeData theme) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Supply Needs', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            if (_project!.supplyNeeds.isEmpty)
              const Text('No supply needs added yet')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _project!.supplyNeeds.length,
                itemBuilder: (context, index) {
                  final supply = _project!.supplyNeeds[index];
                  final status = _stockStatusBySupplyId[supply.id];
                  final linked = status != null && status.isLinked;
                  final short = linked && !status.hasEnoughStock;
                  final availability = status == null
                      ? 'Not linked to Materials Stock'
                      : !linked
                          ? 'Linked material was removed'
                          : '${status.formattedAvailableQuantity} ${status.supplyNeed.unit} available · ${status.formattedReservedQuantity} reserved'
                              '${short ? ' · Short by ${status.formattedShortageQuantity}' : ''}';

                  return ListTile(
                    leading: IconButton(
                      icon: Icon(
                        supply.isSourced
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: supply.isSourced ? Colors.green : null,
                      ),
                      onPressed: () => _toggleSupplyNeed(index),
                    ),
                    title: Text(
                      supply.itemName,
                      style: TextStyle(
                        decoration: supply.isSourced
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: Text(
                      '${supply.quantityNeeded} ${supply.unit} · '
                      '${supply.isConsumable ? 'Consumed on completion' : 'Reusable tool'}\n'
                      '$availability',
                      style: TextStyle(
                        color: short ? theme.colorScheme.error : null,
                        decoration: supply.isSourced
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    trailing: Icon(
                      !linked
                          ? Icons.link_off_outlined
                          : short
                              ? Icons.warning_amber_rounded
                              : Icons.link_outlined,
                      color: !linked
                          ? theme.colorScheme.outline
                          : short
                              ? theme.colorScheme.error
                              : Colors.green,
                    ),
                    isThreeLine: true,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
