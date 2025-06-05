import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import '../../domain/project_service.dart';
import '../../data/project_model.dart';

class ProjectPlannerScreen extends StatefulWidget {
  const ProjectPlannerScreen({super.key});

  @override
  State<ProjectPlannerScreen> createState() => _ProjectPlannerScreenState();
}

class _ProjectPlannerScreenState extends State<ProjectPlannerScreen> {
  final ProjectService _service = GetIt.I<ProjectService>();
  final _nameController = TextEditingController();
  final _craftController = TextEditingController();
  final List<Milestone> _milestones = [];

  void _addMilestone() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        DateTime due = DateTime.now().add(const Duration(days: 7));

        return AlertDialog(
          title: const Text('Add Milestone'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Milestone Name'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: due,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    due = picked;
                  }
                },
                child: const Text('Select Due Date'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    _milestones.add(Milestone(name: nameController.text, dueDate: due));
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveProject() async {
    final project = Project(
      id: const Uuid().v4(),
      name: _nameController.text,
      craftType: _craftController.text,
      milestones: _milestones,
      createdAt: DateTime.now(),
    );
    await _service.createProject(project);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Project saved')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Planner'),
        backgroundColor: color.primary,
        foregroundColor: color.onPrimary,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [color.surface, color.background, color.primary.withOpacity(0.05)],
            center: Alignment.bottomRight,
            radius: 1.3,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Project Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _craftController,
              decoration: const InputDecoration(labelText: 'Craft Type'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _addMilestone,
              icon: const Icon(Icons.flag),
              label: const Text('Add Milestone'),
            ),
            const SizedBox(height: 20),
            ..._milestones.map((m) => Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(m.name),
                    subtitle: Text('Due: ${m.dueDate.toLocal().toString().split(' ')[0]}'),
                    trailing: const Icon(Icons.check_circle_outline),
                  ),
                )),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _saveProject,
              icon: const Icon(Icons.save),
              label: const Text('Save Project'),
            ),
          ],
        ),
      ),
    );
  }
}