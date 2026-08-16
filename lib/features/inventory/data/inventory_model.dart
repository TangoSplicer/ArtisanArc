import 'package:hive/hive.dart';

part 'inventory_model.g.dart';

@HiveType(typeId: 0)
class InventoryItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final int quantity;

  @HiveField(4)
  final double? price;

  @HiveField(5)
  String? storageLocation; // Made mutable for consistency if needed for editing

  @HiveField(6)
  List<String>? imagePaths; // New field for image paths

  @HiveField(7)
  DateTime lastUpdated; // Added lastUpdated

  /// `finished` records are created items ready to tally or sell.
  /// `material` records are yarn, tools, and supplies available to work with.
  /// Null is retained for older data and inferred from its existing category.
  @HiveField(8)
  final String? itemType;

  /// Optional material-specific low-stock threshold. When it is unset, the
  /// global low-stock threshold remains in effect.
  @HiveField(9)
  final int? reorderPoint;

  /// Archived records remain in local history and reports but are hidden from
  /// everyday inventory and sales views until explicitly restored.
  @HiveField(10, defaultValue: false)
  final bool isArchived;

  /// Optional decimal amount for material stock such as 250 g, 1.5 m, or
  /// 0.75 L. Finished-item tallies continue to use the integer quantity field.
  @HiveField(11)
  final double? measuredQuantity;

  @HiveField(12)
  final String? measurementUnit;

  @HiveField(13)
  final double? measuredReorderPoint;

  /// Optional crochet yarn and fibre details. They are deliberately additive so
  /// existing material, tool and finished-item records remain compatible.
  @HiveField(14)
  final String? yarnBrand;

  @HiveField(15)
  final String? yarnRange;

  @HiveField(16)
  final String? yarnColour;

  @HiveField(17)
  final String? dyeLot;

  @HiveField(18)
  final String? yarnWeight;

  @HiveField(19)
  final String? yarnFibre;

  @HiveField(20)
  final double? yarnWeightGrams;

  @HiveField(21)
  final double? yarnLengthMetres;

  @HiveField(22)
  final String? recommendedHookSize;

  @HiveField(23)
  final String? gaugeNote;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    this.price,
    this.storageLocation,
    this.imagePaths, // Added to constructor
    required this.lastUpdated, // Added lastUpdated
    this.itemType,
    this.reorderPoint,
    this.isArchived = false,
    this.measuredQuantity,
    this.measurementUnit,
    this.measuredReorderPoint,
    this.yarnBrand,
    this.yarnRange,
    this.yarnColour,
    this.dyeLot,
    this.yarnWeight,
    this.yarnFibre,
    this.yarnWeightGrams,
    this.yarnLengthMetres,
    this.recommendedHookSize,
    this.gaugeNote,
  });

  bool get isFinishedItem =>
      itemType == 'finished' ||
      (itemType == null && category.startsWith('Finished'));

  bool get isMaterialStock => !isFinishedItem;

  bool get usesMeasuredQuantity =>
      isMaterialStock && measuredQuantity != null && measurementUnit != null;

  bool get isYarnOrFibre =>
      isMaterialStock && category.toLowerCase().startsWith('yarn');

  String get yarnDetailSummary {
    final details = <String>[
      if (yarnBrand?.trim().isNotEmpty == true) yarnBrand!.trim(),
      if (yarnRange?.trim().isNotEmpty == true) yarnRange!.trim(),
      if (yarnColour?.trim().isNotEmpty == true) yarnColour!.trim(),
      if (yarnWeight?.trim().isNotEmpty == true) yarnWeight!.trim(),
      if (yarnFibre?.trim().isNotEmpty == true) yarnFibre!.trim(),
    ];
    return details.join(' · ');
  }

  double get availableStockQuantity =>
      usesMeasuredQuantity ? measuredQuantity! : quantity.toDouble();

  double? get activeReorderPoint =>
      usesMeasuredQuantity ? measuredReorderPoint : reorderPoint?.toDouble();

  String get formattedStockQuantity {
    final amount = availableStockQuantity;
    final display = amount == amount.roundToDouble()
        ? amount.toInt().toString()
        : amount
            .toStringAsFixed(2)
            .replaceFirst(RegExp(r'0+$'), '')
            .replaceFirst(RegExp(r'\.$'), '');
    return usesMeasuredQuantity ? '$display $measurementUnit' : display;
  }

  // copyWith method for easy updates
  InventoryItem copyWith({
    String? id,
    String? name,
    String? category,
    int? quantity,
    double? price,
    String? storageLocation,
    List<String>? imagePaths,
    DateTime? lastUpdated,
    String? itemType,
    int? reorderPoint,
    bool? isArchived,
    double? measuredQuantity,
    String? measurementUnit,
    double? measuredReorderPoint,
    bool clearReorderPoint = false,
    bool clearMeasuredQuantity = false,
    bool clearMeasurementUnit = false,
    bool clearMeasuredReorderPoint = false,
    String? yarnBrand,
    String? yarnRange,
    String? yarnColour,
    String? dyeLot,
    String? yarnWeight,
    String? yarnFibre,
    double? yarnWeightGrams,
    double? yarnLengthMetres,
    String? recommendedHookSize,
    String? gaugeNote,
    bool clearYarnBrand = false,
    bool clearYarnRange = false,
    bool clearYarnColour = false,
    bool clearDyeLot = false,
    bool clearYarnWeight = false,
    bool clearYarnFibre = false,
    bool clearYarnWeightGrams = false,
    bool clearYarnLengthMetres = false,
    bool clearRecommendedHookSize = false,
    bool clearGaugeNote = false,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      storageLocation: storageLocation ?? this.storageLocation,
      imagePaths: imagePaths ?? this.imagePaths,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      itemType: itemType ?? this.itemType,
      reorderPoint:
          clearReorderPoint ? null : reorderPoint ?? this.reorderPoint,
      isArchived: isArchived ?? this.isArchived,
      measuredQuantity: clearMeasuredQuantity
          ? null
          : measuredQuantity ?? this.measuredQuantity,
      measurementUnit:
          clearMeasurementUnit ? null : measurementUnit ?? this.measurementUnit,
      measuredReorderPoint: clearMeasuredReorderPoint
          ? null
          : measuredReorderPoint ?? this.measuredReorderPoint,
      yarnBrand: clearYarnBrand ? null : yarnBrand ?? this.yarnBrand,
      yarnRange: clearYarnRange ? null : yarnRange ?? this.yarnRange,
      yarnColour: clearYarnColour ? null : yarnColour ?? this.yarnColour,
      dyeLot: clearDyeLot ? null : dyeLot ?? this.dyeLot,
      yarnWeight: clearYarnWeight ? null : yarnWeight ?? this.yarnWeight,
      yarnFibre: clearYarnFibre ? null : yarnFibre ?? this.yarnFibre,
      yarnWeightGrams:
          clearYarnWeightGrams ? null : yarnWeightGrams ?? this.yarnWeightGrams,
      yarnLengthMetres: clearYarnLengthMetres
          ? null
          : yarnLengthMetres ?? this.yarnLengthMetres,
      recommendedHookSize: clearRecommendedHookSize
          ? null
          : recommendedHookSize ?? this.recommendedHookSize,
      gaugeNote: clearGaugeNote ? null : gaugeNote ?? this.gaugeNote,
    );
  }
}
