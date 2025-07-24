import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:artisanarc/features/project/domain/project_service.dart';
import 'package:artisanarc/features/project/domain/usecases/get_projects.dart';
import 'package:artisanarc/features/project/domain/usecases/delete_project.dart';
import 'package:artisanarc/features/project/presentation/project_planner_screen.dart'; // For navigation if needed directly

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
              ? Center(
                  child: Text(
                    'No projects yet. Tap the + button to create one!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: _projects.length,
                  itemBuilder: (context, index) {
                    final project = _projects[index];
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
                              '${project.startDate != null ? DateFormat.yMMMd().format(project.startDate!) : 'No start date'} - ${project.endDate != null ? DateFormat.yMMMd().format(project.endDate!) : 'No end date'}',
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
                           _navigateToEditProject(project); // Or navigate to a dedicated detail view
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
