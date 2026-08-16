import 'package:hive/hive.dart';

part 'maker_collection_model.g.dart';

/// A local, maker-owned production collection, such as a spring market range or
/// winter gifting plan. It contains goals and timing only; source recipes and
/// projects remain in their existing offline features.
@HiveType(typeId: 16)
class MakerCollection extends HiveObject {
  MakerCollection({
    required this.id,
    required this.name,
    this.description,
    this.season,
    this.targetDate,
    this.weeklyCapacityMinutes = 180,
    List<CollectionRecipeTarget>? recipeTargets,
    required this.createdAt,
    required this.updatedAt,
  }) : recipeTargets = recipeTargets ?? [];

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String? season;

  @HiveField(4)
  final DateTime? targetDate;

  /// Planned making time available each week for this collection.
  @HiveField(5, defaultValue: 180)
  final int weeklyCapacityMinutes;

  @HiveField(6)
  final List<CollectionRecipeTarget> recipeTargets;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime updatedAt;

  MakerCollection copyWith({
    String? id,
    String? name,
    String? description,
    bool clearDescription = false,
    String? season,
    bool clearSeason = false,
    DateTime? targetDate,
    bool clearTargetDate = false,
    int? weeklyCapacityMinutes,
    List<CollectionRecipeTarget>? recipeTargets,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      MakerCollection(
        id: id ?? this.id,
        name: name ?? this.name,
        description: clearDescription ? null : description ?? this.description,
        season: clearSeason ? null : season ?? this.season,
        targetDate: clearTargetDate ? null : targetDate ?? this.targetDate,
        weeklyCapacityMinutes:
            weeklyCapacityMinutes ?? this.weeklyCapacityMinutes,
        recipeTargets: recipeTargets ??
            List<CollectionRecipeTarget>.from(this.recipeTargets),
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

/// The desired number of finished pieces from a reusable Make Recipe.
@HiveType(typeId: 17)
class CollectionRecipeTarget extends HiveObject {
  CollectionRecipeTarget({
    required this.id,
    required this.recipeId,
    required this.targetQuantity,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String recipeId;

  @HiveField(2)
  final int targetQuantity;

  CollectionRecipeTarget copyWith({
    String? id,
    String? recipeId,
    int? targetQuantity,
  }) =>
      CollectionRecipeTarget(
        id: id ?? this.id,
        recipeId: recipeId ?? this.recipeId,
        targetQuantity: targetQuantity ?? this.targetQuantity,
      );
}
