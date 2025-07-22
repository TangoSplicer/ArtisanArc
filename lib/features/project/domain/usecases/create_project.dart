import 'package:artisanarc/features/project/data/project_model.dart';
import 'package:artisanarc/features/project/domain/project_service.dart';

class CreateProject {
  final ProjectService _service;

  CreateProject(this._service);

  Future<void> call(Project project) {
    return _service.createProject(project);
  }
}
