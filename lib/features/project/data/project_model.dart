import 'package:hive/hive.dart';

part 'project_model.g.dart';

@HiveType(typeId: 3)
class Project extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String craftType;

  @HiveField(3)
  final List<Milestone> milestones;

  @HiveField(4)
  final DateTime createdAt;

  Project({
    required this.id,
    required this.name,
    required this.craftType,
    required this.milestones,
    required this.createdAt,
  });
}

@HiveType(typeId: 4)
class Milestone {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final DateTime dueDate;

  @HiveField(2)
  final bool isComplete;

  Milestone({
    required this.name,
    required this.dueDate,
    this.isComplete = false,
  });
}