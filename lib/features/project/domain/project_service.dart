import '../data/project_model.dart';
import '../data/project_repository.dart';

abstract class ProjectService {
  Future<void> createProject(Project project);
  Future<List<Project>> fetchProjects();
}

class ProjectServiceImpl implements ProjectService {
  final ProjectRepository _repo;

  ProjectServiceImpl(this._repo);

  @override
  Future<void> createProject(Project project) => _repo.saveProject(project);

  @override
  Future<List<Project>> fetchProjects() => _repo.getAllProjects();
}