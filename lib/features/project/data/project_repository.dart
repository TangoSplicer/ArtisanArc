import 'package:hive/hive.dart';
import 'project_model.dart';

abstract class ProjectRepository {
  Future<void> saveProject(Project project);
  Future<List<Project>> getAllProjects();
  Future<void> deleteProject(String id);
}

class ProjectRepositoryImpl implements ProjectRepository {
  static const _boxName = 'projectsBox';

  Future<Box<Project>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<Project>(_boxName);
    }
    return Hive.box<Project>(_boxName);
  }

  @override
  Future<void> saveProject(Project project) async {
    final box = await _getBox();
    await box.put(project.id, project);
  }

  @override
  Future<List<Project>> getAllProjects() async {
    final box = await _getBox();
    return box.values.toList();
  }

  @override
  Future<void> deleteProject(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }
}