import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:artisanarc/features/project/domain/project_service.dart';
import 'package:artisanarc/features/project/domain/usecases/get_projects.dart';
import 'package:artisanarc/features/project/domain/usecases/delete_project.dart';
import 'package:artisanarc/features/project/data/project_model.dart';
import 'package:artisanarc/core/widgets/empty_state_widget.dart';
import 'package:artisanarc/core/utils/date_helpers.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  final GetProjects _getProjectsUseCase = GetIt.I<GetProjects>();
  final DeleteProject _deleteProjectUseCase = GetIt.I<DeleteProject>();
  List<Project> _projects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoading = true);
    try {
      final projects = await _getProjectsUseCase();
      setState(() {
        _projects = projects;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading projects: $e')),
        );
      }
    }
  }

  void _navigateToAddProject() async {
    // Navigate to ProjectPlannerScreen for adding a new project.
    // ProjectPlannerScreen will handle creation and pop.
    // We expect a boolean result: true if a project was added/modified.
    final result = await context.push('/projects/add'); // Assuming '/projects/add' will be the route for ProjectPlannerScreen
    if (result == true) {
      _loadProjects(); // Refresh list if a project was added
    }
  }

  void _navigateToEditProject(Project project) async {
    final result = await context.push('/projects/edit/${project.id}'); // Route for editing
    if (result == true) {
      _loadProjects(); // Refresh list
    }
  }

  Future<void> _confirmDeleteProject(Project project) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Project'),
          content: Text('Are you sure you want to delete "${project.name}"? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              child: const Text('Delete'),
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _deleteProjectUseCase(project.id);
        _loadProjects(); // Refresh list
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('"${project.name}" deleted.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting project: $e')),
          );
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Projects'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _projects.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.timeline,
                  title: 'No Projects Yet',
                  subtitle: 'Create your first project to start organizing your craft work',
                  actionText: 'Create Project',
                  onAction: _navigateToAddProject,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: _projects.length,
                  itemBuilder: (context, index) {
                    final project = _projects[index];
                    final completedMilestones = project.milestones.where((m) => m.isCompleted).length;
                    final totalMilestones = project.milestones.length;
                    final progress = totalMilestones > 0 ? completedMilestones / totalMilestones : 0.0;
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text(project.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(project.description ?? 'No description'),
                            const SizedBox(height: 4),
                            Text(
                              '${project.startDate != null ? DateHelpers.formatForDisplay(project.startDate!) : 'No start date'} - ${project.endDate != null ? DateHelpers.formatForDisplay(project.endDate!) : 'No end date'}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$completedMilestones of $totalMilestones milestones completed',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _navigateToEditProject(project);
                            } else if (value == 'delete') {
                              _confirmDeleteProject(project);
                            }
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: ListTile(leading: Icon(Icons.edit), title: Text('Edit')),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: ListTile(leading: Icon(Icons.delete), title: Text('Delete')),
                            ),
                          ],
                        ),
                        onTap: () {
                          context.push('/projects/detail/${project.id}').then((_) => _loadProjects());
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddProject,
        icon: const Icon(Icons.add),
        label: const Text('New Project'),
      ),
    );
  }
}
