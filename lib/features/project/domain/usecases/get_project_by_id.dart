import 'package:artisanarc/features/project/data/project_model.dart';
import 'package:artisanarc/features/project/domain/project_service.dart';

class GetProjectById {
  final ProjectService _service;

  GetProjectById(this._service);

  Future<Project?> call(String id) {
    return _service.getProjectById(id);
  }
}
