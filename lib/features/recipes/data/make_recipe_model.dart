import 'package:hive/hive.dart';

import '../../project/domain/entities/supply_need.dart';

part 'make_recipe_model.g.dart';

/// A reusable, maker-authored product plan. Pattern references are intentionally
/// descriptive only: the app does not store or reproduce commercial patterns.
@HiveType(typeId: 14)
class MakeRecipe extends HiveObject {
  MakeRecipe({
    required this.id,
    required this.name,
    required this.productCategory,
    required this.craftFocus,
    this.patternReference,
    this.patternSource,
    this.hookSize,
    this.gaugeNote,
    this.defaultOutputQuantity = 1,
    this.estimatedMakeMinutes,
    this.targetMarginPercent,
    List<SupplyNeed>? supplyNeeds,
    List<RecipeVariant>? variants,
    required this.createdAt,
    required this.updatedAt,
  })  : supplyNeeds = supplyNeeds ?? [],
        variants = variants ?? [];

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String productCategory;

  @HiveField(3)
  final String craftFocus;

  /// A user-provided title, filename, URL or location for the original source.
  @HiveField(4)
  final String? patternReference;

  /// Optional designer, book, publication or source credit.
  @HiveField(5)
  final String? patternSource;

  @HiveField(6)
  final String? hookSize;

  @HiveField(7)
  final String? gaugeNote;

  @HiveField(8, defaultValue: 1)
  final int defaultOutputQuantity;

  @HiveField(9)
  final int? estimatedMakeMinutes;

  @HiveField(10)
  final double? targetMarginPercent;

  @HiveField(11)
  final List<SupplyNeed> supplyNeeds;

  @HiveField(12)
  final List<RecipeVariant> variants;

  @HiveField(13)
  final DateTime createdAt;

  @HiveField(14)
  final DateTime updatedAt;

  MakeRecipe copyWith({
    String? id,
    String? name,
    String? productCategory,
    String? craftFocus,
    String? patternReference,
    bool clearPatternReference = false,
    String? patternSource,
    bool clearPatternSource = false,
    String? hookSize,
    bool clearHookSize = false,
    String? gaugeNote,
    bool clearGaugeNote = false,
    int? defaultOutputQuantity,
    int? estimatedMakeMinutes,
    bool clearEstimatedMakeMinutes = false,
    double? targetMarginPercent,
    bool clearTargetMarginPercent = false,
    List<SupplyNeed>? supplyNeeds,
    List<RecipeVariant>? variants,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      MakeRecipe(
        id: id ?? this.id,
        name: name ?? this.name,
        productCategory: productCategory ?? this.productCategory,
        craftFocus: craftFocus ?? this.craftFocus,
        patternReference: clearPatternReference
            ? null
            : patternReference ?? this.patternReference,
        patternSource:
            clearPatternSource ? null : patternSource ?? this.patternSource,
        hookSize: clearHookSize ? null : hookSize ?? this.hookSize,
        gaugeNote: clearGaugeNote ? null : gaugeNote ?? this.gaugeNote,
        defaultOutputQuantity:
            defaultOutputQuantity ?? this.defaultOutputQuantity,
        estimatedMakeMinutes: clearEstimatedMakeMinutes
            ? null
            : estimatedMakeMinutes ?? this.estimatedMakeMinutes,
        targetMarginPercent: clearTargetMarginPercent
            ? null
            : targetMarginPercent ?? this.targetMarginPercent,
        supplyNeeds: supplyNeeds ?? List<SupplyNeed>.from(this.supplyNeeds),
        variants: variants ?? List<RecipeVariant>.from(this.variants),
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

@HiveType(typeId: 15)
class RecipeVariant extends HiveObject {
  RecipeVariant({
    required this.id,
    required this.name,
    this.detail,
    this.outputQuantity = 1,
    this.estimatedMakeMinutes,
    List<SupplyNeed>? supplyNeeds,
  }) : supplyNeeds = supplyNeeds ?? [];

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? detail;

  @HiveField(3, defaultValue: 1)
  final int outputQuantity;

  @HiveField(4)
  final int? estimatedMakeMinutes;

  @HiveField(5)
  final List<SupplyNeed> supplyNeeds;

  RecipeVariant copyWith({
    String? id,
    String? name,
    String? detail,
    bool clearDetail = false,
    int? outputQuantity,
    int? estimatedMakeMinutes,
    bool clearEstimatedMakeMinutes = false,
    List<SupplyNeed>? supplyNeeds,
  }) =>
      RecipeVariant(
        id: id ?? this.id,
        name: name ?? this.name,
        detail: clearDetail ? null : detail ?? this.detail,
        outputQuantity: outputQuantity ?? this.outputQuantity,
        estimatedMakeMinutes: clearEstimatedMakeMinutes
            ? null
            : estimatedMakeMinutes ?? this.estimatedMakeMinutes,
        supplyNeeds: supplyNeeds ?? List<SupplyNeed>.from(this.supplyNeeds),
      );
}
