import 'package:uuid/uuid.dart';

import '../../inventory/data/inventory_model.dart';
import '../../inventory/data/inventory_repository.dart';
import '../data/project_model.dart';
import '../data/project_repository.dart';
import '../data/production_run_model.dart';
import '../data/production_run_repository.dart';
import 'entities/supply_need.dart';

/// A material requirement resolved against the current local material stock.
class MaterialStockStatus {
  const MaterialStockStatus({
    required this.supplyNeed,
    required this.inventoryItem,
    required this.quantityToReserve,
    required this.quantityToConsume,
    required this.usesMeasuredQuantity,
    required this.isUnitCompatible,
  });

  final SupplyNeed supplyNeed;
  final InventoryItem? inventoryItem;

  /// The material amount allocated to the requested project output.
  final double quantityToReserve;

  /// The amount that will actually be deducted. This remains zero for linked
  /// reusable tools such as hooks and needles.
  final double quantityToConsume;

  final bool usesMeasuredQuantity;
  final bool isUnitCompatible;

  bool get isLinked => inventoryItem != null;

  double get availableQuantity => inventoryItem?.availableStockQuantity ?? 0;

  bool get hasEnoughStock =>
      isLinked && isUnitCompatible && availableQuantity >= quantityToReserve;

  String get issue {
    if (!isLinked)
      return 'Link this supply to Materials Stock before completing the make.';
    if (!isUnitCompatible) {
      return 'This material is tracked in ${inventoryItem?.measurementUnit}; the project requires ${supplyNeed.unit}.';
    }
    if (!hasEnoughStock) {
      return 'Short by ${_format(quantityToReserve - availableQuantity)} ${supplyNeed.unit}.';
    }
    return '';
  }

  String get formattedAvailableQuantity => _format(availableQuantity);
  String get formattedReservedQuantity => _format(quantityToReserve);
  String get formattedConsumptionQuantity => _format(quantityToConsume);
  String get formattedShortageQuantity =>
      _format(quantityToReserve - availableQuantity);

  static String _format(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value
          .toStringAsFixed(2)
          .replaceFirst(RegExp(r'0+$'), '')
          .replaceFirst(RegExp(r'\.$'), '');
}

/// The stock check used both by the project detail screen and the completion
/// confirmation dialog. It keeps all production decisions local to the device.
class MakeToSellPreview {
  const MakeToSellPreview({
    required this.project,
    required this.outputQuantity,
    required this.materials,
  });

  final Project project;
  final int outputQuantity;
  final List<MaterialStockStatus> materials;

  bool get canComplete => materials
      .where((status) => status.supplyNeed.isConsumable)
      .every((status) => status.hasEnoughStock);

  List<MaterialStockStatus> get issues => materials
      .where(
          (status) => status.supplyNeed.isConsumable && !status.hasEnoughStock)
      .toList();
}

class CompletedMakeResult {
  const CompletedMakeResult({
    required this.finishedItem,
    required this.updatedProject,
    required this.materialsConsumed,
    required this.productionRun,
  });

  final InventoryItem finishedItem;
  final Project updatedProject;
  final List<InventoryItem> materialsConsumed;
  final ProductionRun productionRun;
}

/// Coordinates a project completion using the existing offline Hive
/// repositories. A make is only completed when every linked consumable has
/// enough available stock; reusable tools remain linked but are not deducted.
class MakeToSellService {
  MakeToSellService(
    this._inventoryRepository,
    this._projectRepository,
    this._productionRunRepository,
  );

  final InventoryRepository _inventoryRepository;
  final ProjectRepository _projectRepository;
  final ProductionRunRepository _productionRunRepository;
  final Uuid _uuid = const Uuid();

  Future<MakeToSellPreview> preview(Project project,
      {int outputQuantity = 1}) async {
    if (outputQuantity < 1) {
      throw ArgumentError.value(
          outputQuantity, 'outputQuantity', 'Must be at least one.');
    }

    final inventory = await _inventoryRepository.getAllItems();
    final materialById = {
      for (final item in inventory.where((item) => item.isMaterialStock))
        item.id: item,
    };

    final materials = project.supplyNeeds.map(
      (supply) {
        final material = supply.inventoryItemId == null
            ? null
            : materialById[supply.inventoryItemId];
        final usesMeasuredQuantity = material?.usesMeasuredQuantity ?? false;
        final isUnitCompatible = !usesMeasuredQuantity ||
            _sameUnit(material!.measurementUnit!, supply.unit);
        final requestedQuantity = supply.quantityNeeded * outputQuantity;
        final reservedQuantity = usesMeasuredQuantity
            ? requestedQuantity
            : _wholeStockQuantity(requestedQuantity).toDouble();
        return MaterialStockStatus(
          supplyNeed: supply,
          inventoryItem: material,
          quantityToReserve: reservedQuantity,
          quantityToConsume: supply.isConsumable ? reservedQuantity : 0,
          usesMeasuredQuantity: usesMeasuredQuantity,
          isUnitCompatible: isUnitCompatible,
        );
      },
    ).toList(growable: false);

    return MakeToSellPreview(
      project: project,
      outputQuantity: outputQuantity,
      materials: materials,
    );
  }

  Future<CompletedMakeResult> complete({
    required Project project,
    required int outputQuantity,
    String? finishedItemName,
    double? salePrice,
    String? notes,
  }) async {
    final stockPreview = await preview(project, outputQuantity: outputQuantity);
    if (!stockPreview.canComplete) {
      final details = stockPreview.issues
          .map((status) => '${status.supplyNeed.itemName}: ${status.issue}')
          .join(' ');
      throw StateError('Cannot complete this make. $details');
    }

    final now = DateTime.now();
    final activeTimerStart = project.activeTimerStartedAt;
    final activeTimerMinutes =
        activeTimerStart != null && now.isAfter(activeTimerStart)
            ? now.difference(activeTimerStart).inMinutes
            : 0;
    final labourMinutesAtCompletion =
        project.actualLabourMinutes + activeTimerMinutes;
    final updatedMaterials = <InventoryItem>[];
    var materialCost = 0.0;
    for (final status in stockPreview.materials
        .where((status) => status.supplyNeed.isConsumable)) {
      final material = status.inventoryItem!;
      final updated = status.usesMeasuredQuantity
          ? material.copyWith(
              measuredQuantity:
                  material.measuredQuantity! - status.quantityToConsume,
              lastUpdated: now,
            )
          : material.copyWith(
              quantity: material.quantity - status.quantityToConsume.round(),
              lastUpdated: now,
            );
      await _inventoryRepository.updateItem(updated);
      updatedMaterials.add(updated);
      final costEach =
          status.supplyNeed.estimatedCostEach ?? material.price ?? 0;
      materialCost += costEach * status.quantityToConsume;
    }

    final outputName = (finishedItemName ?? '').trim().isEmpty
        ? project.name.trim()
        : finishedItemName!.trim();
    final craft = project.craftType?.trim();
    final finishedItem = InventoryItem(
      id: _uuid.v4(),
      name: outputName,
      category: project.finishedItemCategory?.trim().isNotEmpty == true
          ? project.finishedItemCategory!.trim()
          : craft == null || craft.isEmpty
              ? 'Finished Makes'
              : 'Finished $craft Makes',
      quantity: outputQuantity,
      price: salePrice,
      storageLocation: 'Finished items',
      lastUpdated: now,
      itemType: 'finished',
    );
    await _inventoryRepository.addItem(finishedItem);

    final noteParts = <String>[
      'Completed $outputQuantity ${outputQuantity == 1 ? 'item' : 'items'} on ${now.toLocal().toString().split('.').first}.',
    ];
    final cleanNotes = notes?.trim();
    if (cleanNotes != null && cleanNotes.isNotEmpty) noteParts.add(cleanNotes);

    final updatedProject = project.copyWith(
      finishedItemIds: [...project.finishedItemIds, finishedItem.id],
      productionNotes: [...project.productionNotes, noteParts.join(' ')],
      actualLabourMinutes: labourMinutesAtCompletion,
      clearActiveTimerStartedAt: activeTimerStart != null,
      lastUpdatedAt: now,
    );
    await _projectRepository.saveProject(updatedProject);

    final productionRun = ProductionRun(
      id: _uuid.v4(),
      projectId: project.id,
      finishedItemId: finishedItem.id,
      finishedItemName: finishedItem.name,
      outputQuantity: outputQuantity,
      materialCost: materialCost,
      completedAt: now,
      notes: cleanNotes,
      labourMinutesAtCompletion: labourMinutesAtCompletion,
    );
    await _productionRunRepository.saveRun(productionRun);

    return CompletedMakeResult(
      finishedItem: finishedItem,
      updatedProject: updatedProject,
      materialsConsumed: updatedMaterials,
      productionRun: productionRun,
    );
  }

  int _wholeStockQuantity(double quantity) => quantity.ceil();

  bool _sameUnit(String a, String b) =>
      a.trim().toLowerCase() == b.trim().toLowerCase();
}
