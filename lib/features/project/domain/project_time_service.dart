import '../data/project_model.dart';
import 'project_service.dart';

class ProjectTimeService {
  ProjectTimeService(this._projectService);

  final ProjectService _projectService;

  Future<Project> start(Project project, {DateTime? now}) async {
    if (project.activeTimerStartedAt != null) return project;
    final updated = project.copyWith(
      activeTimerStartedAt: now ?? DateTime.now(),
      lastUpdatedAt: now ?? DateTime.now(),
    );
    await _projectService.updateProject(updated);
    return updated;
  }

  Future<Project> pause(Project project, {DateTime? now}) async {
    final startedAt = project.activeTimerStartedAt;
    if (startedAt == null) return project;
    final finishedAt = now ?? DateTime.now();
    final elapsedMinutes = finishedAt.isAfter(startedAt)
        ? finishedAt.difference(startedAt).inMinutes
        : 0;
    final updated = project.copyWith(
      actualLabourMinutes: project.actualLabourMinutes + elapsedMinutes,
      clearActiveTimerStartedAt: true,
      lastUpdatedAt: finishedAt,
    );
    await _projectService.updateProject(updated);
    return updated;
  }

  Future<Project> setActualMinutes(Project project, int minutes) async {
    if (minutes < 0) {
      throw ArgumentError.value(minutes, 'minutes', 'Time cannot be negative.');
    }
    final updated = project.copyWith(
      actualLabourMinutes: minutes,
      lastUpdatedAt: DateTime.now(),
    );
    await _projectService.updateProject(updated);
    return updated;
  }
}
