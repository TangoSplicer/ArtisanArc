import 'package:hive/hive.dart';

part 'pattern_model.g.dart';

@HiveType(typeId: 21)
class StoredPattern extends HiveObject {
  StoredPattern({
    required this.id,
    required this.title,
    this.designer,
    required this.localFilePath,
    this.linkedRecipeId,
    this.linkedProjectId,
    required this.createdAt,
    required this.updatedAt,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? designer;

  @HiveField(3)
  final String localFilePath;

  @HiveField(4)
  final String? linkedRecipeId;

  @HiveField(5)
  final String? linkedProjectId;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime updatedAt;

  StoredPattern copyWith({
    String? title,
    String? designer,
    String? localFilePath,
    String? linkedRecipeId,
    String? linkedProjectId,
    DateTime? updatedAt,
  }) {
    return StoredPattern(
      id: id,
      title: title ?? this.title,
      designer: designer ?? this.designer,
      localFilePath: localFilePath ?? this.localFilePath,
      linkedRecipeId: linkedRecipeId ?? this.linkedRecipeId,
      linkedProjectId: linkedProjectId ?? this.linkedProjectId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

@HiveType(typeId: 22)
class RowCounter extends HiveObject {
  RowCounter({
    required this.id,
    required this.title,
    required this.count,
    this.targetCount,
    this.linkedProjectId,
    required this.updatedAt,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final int count;

  @HiveField(3)
  final int? targetCount;

  @HiveField(4)
  final String? linkedProjectId;

  @HiveField(5)
  final DateTime updatedAt;

  RowCounter copyWith({
    String? title,
    int? count,
    int? targetCount,
    String? linkedProjectId,
    DateTime? updatedAt,
  }) {
    return RowCounter(
      id: id,
      title: title ?? this.title,
      count: count ?? this.count,
      targetCount: targetCount ?? this.targetCount,
      linkedProjectId: linkedProjectId ?? this.linkedProjectId,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
