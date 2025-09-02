import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../domain/usecases/get_project_by_id.dart';
import '../domain/usecases/update_project.dart';
import '../data/project_model.dart';
import '../../ai/presentation/craft_ai_widget.dart';
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
  
  Project? _project;
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
      setState(() => _project = project);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading project: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
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
        appBar: AppBar(title: const Text('Project Not Found')),
        body: const Center(child: Text('Project not found')),
      );
    }

    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_project!.name),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          if (_project!.craftType != null && _project!.craftType!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.lightbulb_outline),
              onPressed: () {
                context.push('/ai-assistant/${Uri.encodeComponent(_project!.craftType!)}');
              },
            ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push('/projects/edit/${_project!.id}').then((_) => _loadProject());
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
            if (_project!.description != null && _project!.description!.isNotEmpty) ...[
              Text('Description', style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(_project!.description!),
              const SizedBox(height: 16),
            ],
            if (_project!.craftType != null && _project!.craftType!.isNotEmpty) ...[
              Text('Craft Type', style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Chip(
                label: Text(_project!.craftType!),
                backgroundColor: theme.colorScheme.primaryContainer,
              ),
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
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
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
                  final isOverdue = DateHelpers.isOverdue(milestone.dueDate) && !milestone.isCompleted;
                  final isDueSoon = DateHelpers.isDueSoon(milestone.dueDate) && !milestone.isCompleted;
                  
                  return ListTile(
                    leading: IconButton(
                      icon: Icon(
                        milestone.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
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
                        decoration: milestone.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Due: ${DateHelpers.formatForDisplay(milestone.dueDate)}',
                          style: TextStyle(
                            color: isOverdue ? Colors.red : isDueSoon ? Colors.orange : null,
                          ),
                        ),
                        if (milestone.description != null && milestone.description!.isNotEmpty)
                          Text(milestone.description!),
                      ],
                    ),
                    isThreeLine: milestone.description != null && milestone.description!.isNotEmpty,
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
                  
                  return ListTile(
                    leading: IconButton(
                      icon: Icon(
                        supply.isSourced ? Icons.check_box : Icons.check_box_outline_blank,
                        color: supply.isSourced ? Colors.green : null,
                      ),
                      onPressed: () => _toggleSupplyNeed(index),
                    ),
                    title: Text(
                      supply.itemName,
                      style: TextStyle(
                        decoration: supply.isSourced ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Text(
                      '${supply.quantityNeeded} ${supply.unit}',
                      style: TextStyle(
                        decoration: supply.isSourced ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}