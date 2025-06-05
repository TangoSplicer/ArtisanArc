import 'package:artisanarc/features/project/data/project_model.dart';
import 'package:artisanarc/features/project/domain/project_service.dart';

class GetProjects {
  final ProjectService _service;

  GetProjects(this._service);

  Future<List<Project>> call() {
    return _service.fetchProjects();
  }
}
