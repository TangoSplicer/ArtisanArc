import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import '../domain/project_service.dart';
import '../data/project_model.dart';


class ProjectPlannerScreen extends StatelessWidget {
  const ProjectPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
 
    return ChangeNotifierProvider(
      create: (_) => ProjectViewModel(),
      child: const ProjectPlannerView(),
    );
  }
}

class ProjectViewModel extends ChangeNotifier {
  final ProjectService _projectService = GetIt.I<ProjectService>();
  List<Project> _projects = [];
  bool _isLoading = false;

  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;

  ProjectViewModel() {
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    _isLoading = true;
    notifyListeners();
    _projects = await _projectService.fetchProjects();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addProject(Project project) async {
    await _projectService.addProject(project);
    await fetchProjects();
  }
}

class ProjectPlannerView extends StatelessWidget {
  const ProjectPlannerView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ProjectViewModel>(context);

    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Planner'),
        backgroundColor: color.primary,
        foregroundColor: color.onPrimary,
      ),

      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.projects.isEmpty
              ? const Center(child: Text('No projects found.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: viewModel.projects.length,
                  itemBuilder: (context, index) {
                    final project = viewModel.projects[index];
                    return _buildProjectCard(
                      context,
                      title: project.name,
                      subtitle: project.description,
                      icon: Icons.palette,
                      color: color.primary,
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateProjectDialog(context, viewModel),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildProjectCard(
            context,
            title: 'Summer Collection',
            subtitle: 'A collection of summer-themed crafts',
            icon: Icons.wb_sunny,
            color: color.primary,
          ),
          _buildProjectCard(
            context,
            title: 'Winter Wonderland',
            subtitle: 'A collection of winter-themed crafts',
            icon: Icons.ac_unit,
            color: color.secondary,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement create new project functionality
        },

        backgroundColor: color.primary,
        child: const Icon(Icons.add),
      ),
    );
  }


  void _showCreateProjectDialog(BuildContext context, ProjectViewModel viewModel) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Project'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Project Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Project Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newProject = Project(
                  id: DateTime.now().toString(),
                  name: nameController.text,
                  description: descriptionController.text,
                );
                viewModel.addProject(newProject);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Project created successfully!')),
                );
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }



  Widget _buildProjectCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: color.withOpacity(0.4),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: color.withOpacity(0.08),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}