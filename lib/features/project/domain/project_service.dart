import '../data/project_model.dart';
import '../data/project_repository.dart';

abstract class ProjectService {
  Future<void> createProject(Project project);
  Future<Project?> getProjectById(String id);
  Future<List<Project>> fetchProjects();
  Future<void> updateProject(Project project);
  Future<void> deleteProject(String id);
}

class ProjectServiceImpl implements ProjectService {
  final ProjectRepository _repo;

  ProjectServiceImpl(this._repo);

  @override
  Future<void> createProject(Project project) => _repo.saveProject(project);

  @override
  Future<Project?> getProjectById(String id) => _repo.getProjectById(id);

  @override
  Future<List<Project>> fetchProjects() => _repo.getAllProjects();

  @override
  Future<void> updateProject(Project project) => _repo.saveProject(project); // Hive's put handles create/update

  @override
  Future<void> deleteProject(String id) => _repo.deleteProject(id);
}