import 'package:artisanarc/features/project/domain/project_service.dart';

class DeleteProject {
  final ProjectService _service;

  DeleteProject(this._service);

  Future<void> call(String projectId) {
    return _service.deleteProject(projectId);
  }
}
