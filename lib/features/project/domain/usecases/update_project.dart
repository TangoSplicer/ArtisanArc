import 'package:artisanarc/features/project/data/project_model.dart';
import 'package:artisanarc/features/project/domain/project_service.dart';

class UpdateProject {
  final ProjectService _service;

  UpdateProject(this._service);

  Future<void> call(Project project) {
    return _service.updateProject(project);
  }
}
