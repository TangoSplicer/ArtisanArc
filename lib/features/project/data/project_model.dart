import 'package:hive/hive.dart';
import '../domain/entities/supply_need.dart'; // Ensure this path is correct

part 'project_model.g.dart';

// Note: The typeId for Project was 1 in a previous edit, now it's 3 from file.
// Sticking with 3 for Project, 2 for Milestone (was 4 from file, but 2 in previous edit),
// and 4 for SupplyNeed (as defined). This needs to be consistent.
// For this change, I will use the typeIds as they were in the file I just read: Project (3), Milestone (4).
// And assign a new one for SupplyNeed, e.g. 5.

@HiveType(typeId: 3) // Was 3 in the file read
class Project extends HiveObject {
  @HiveField(0)
  String
      id; // Assuming it can be final if set by Uuid, but making it non-final for flexibility if Hive needs to set it.

  @HiveField(1)
  String name;

  @HiveField(2)
  String? description; // Added

  @HiveField(3)
  String? craftType; // Was final, making it mutable. Index was 2, now 3.

  @HiveField(4)
  DateTime? startDate; // Added

  @HiveField(5)
  DateTime? endDate; // Added

  @HiveField(6)
  List<Milestone> milestones; // Was index 3, now 6

  @HiveField(7)
  DateTime createdAt; // Was index 4, now 7

  @HiveField(8)
  DateTime? lastUpdatedAt; // Added

  @HiveField(9)
  List<SupplyNeed> supplyNeeds; // Added

  /// Finished inventory tallies created from this project.
  @HiveField(10)
  List<String> finishedItemIds;

  /// Local-only notes recorded for each completed make, including partial
  /// production and any waste note supplied by the maker.
  @HiveField(11)
  List<String> productionNotes;

  /// Optional planning input used only by the Cost & Price preview.
  @HiveField(12)
  int? estimatedLabourMinutes;

  /// Optional hourly maker rate used only by the Cost & Price preview.
  @HiveField(13)
  double? labourRatePerHour;

  /// Optional target profit margin expressed as a percentage of sale price.
  @HiveField(14)
  double? targetMarginPercent;

  /// Minutes actually worked by the maker. This is local production evidence,
  /// kept separately from the planning estimate used in the original quote.
  @HiveField(15, defaultValue: 0)
  int actualLabourMinutes;

  /// When non-null, the project timer is running. Persisting the start time
  /// keeps a timer trustworthy across navigation and an app restart.
  @HiveField(16)
  DateTime? activeTimerStartedAt;

  /// Optional link back to a reusable, reference-only Make Recipe.
  @HiveField(17)
  String? recipeId;

  @HiveField(18)
  String? recipeName;

  /// The planned number of saleable pieces from this project or recipe.
  @HiveField(19, defaultValue: 1)
  int plannedOutputQuantity;

  /// Optional crochet-first finished-product category supplied by a Make Recipe.
  @HiveField(20)
  String? finishedItemCategory;

  Project({
    required this.id,
    required this.name,
    this.description,
    this.craftType,
    this.startDate,
    this.endDate,
    List<Milestone>? milestones,
    List<SupplyNeed>? supplyNeeds,
    List<String>? finishedItemIds,
    List<String>? productionNotes,
    this.estimatedLabourMinutes,
    this.labourRatePerHour,
    this.targetMarginPercent,
    this.actualLabourMinutes = 0,
    this.activeTimerStartedAt,
    this.recipeId,
    this.recipeName,
    this.plannedOutputQuantity = 1,
    this.finishedItemCategory,
    required this.createdAt,
    this.lastUpdatedAt,
  })  : milestones = milestones ?? [],
        supplyNeeds = supplyNeeds ?? [],
        finishedItemIds = finishedItemIds ?? [],
        productionNotes = productionNotes ?? [];

  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? craftType,
    DateTime? startDate,
    DateTime? endDate,
    List<Milestone>? milestones,
    List<SupplyNeed>? supplyNeeds,
    List<String>? finishedItemIds,
    List<String>? productionNotes,
    int? estimatedLabourMinutes,
    bool clearEstimatedLabourMinutes = false,
    double? labourRatePerHour,
    bool clearLabourRatePerHour = false,
    double? targetMarginPercent,
    bool clearTargetMarginPercent = false,
    int? actualLabourMinutes,
    DateTime? activeTimerStartedAt,
    bool clearActiveTimerStartedAt = false,
    String? recipeId,
    bool clearRecipeId = false,
    String? recipeName,
    bool clearRecipeName = false,
    int? plannedOutputQuantity,
    String? finishedItemCategory,
    bool clearFinishedItemCategory = false,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      craftType: craftType ?? this.craftType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      milestones: milestones ??
          List<Milestone>.from(
              this.milestones.map((m) => m.copyWith())), // Deep copy
      supplyNeeds: supplyNeeds ??
          List<SupplyNeed>.from(
              this.supplyNeeds.map((s) => s.copyWith())), // Deep copy
      finishedItemIds:
          finishedItemIds ?? List<String>.from(this.finishedItemIds),
      productionNotes:
          productionNotes ?? List<String>.from(this.productionNotes),
      estimatedLabourMinutes: clearEstimatedLabourMinutes
          ? null
          : estimatedLabourMinutes ?? this.estimatedLabourMinutes,
      labourRatePerHour: clearLabourRatePerHour
          ? null
          : labourRatePerHour ?? this.labourRatePerHour,
      targetMarginPercent: clearTargetMarginPercent
          ? null
          : targetMarginPercent ?? this.targetMarginPercent,
      actualLabourMinutes: actualLabourMinutes ?? this.actualLabourMinutes,
      activeTimerStartedAt: clearActiveTimerStartedAt
          ? null
          : activeTimerStartedAt ?? this.activeTimerStartedAt,
      recipeId: clearRecipeId ? null : recipeId ?? this.recipeId,
      recipeName: clearRecipeName ? null : recipeName ?? this.recipeName,
      plannedOutputQuantity:
          plannedOutputQuantity ?? this.plannedOutputQuantity,
      finishedItemCategory: clearFinishedItemCategory
          ? null
          : finishedItemCategory ?? this.finishedItemCategory,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }
}

@HiveType(typeId: 5) // Changed from 2 to 5 to resolve collision
class Milestone extends HiveObject {
  // Extended HiveObject
  @HiveField(0)
  String id; // Added ID

  @HiveField(1)
  String name; // Was index 0

  @HiveField(2)
  String? description; // Added

  @HiveField(3)
  DateTime dueDate; // Was index 1

  @HiveField(4)
  bool isCompleted; // Was index 2

  Milestone({
    required this.id,
    required this.name,
    this.description,
    required this.dueDate,
    this.isCompleted = false,
  });

  Milestone copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return Milestone(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
