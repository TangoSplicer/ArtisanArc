import '../../inventory/data/material_purchase_model.dart';
import '../../inventory/domain/procurement_service.dart';
import '../data/production_run_model.dart';
import '../data/production_run_repository.dart';
import '../data/project_model.dart';
import 'entities/supply_need.dart';

enum ProjectCostSource {
  plannerEstimate,
  latestRecordedPurchase,
  noCostAvailable,
  unitMismatch,
}

class ProjectSupplyCostLine {
  const ProjectSupplyCostLine({
    required this.supplyNeed,
    required this.unitCost,
    required this.totalCost,
    required this.source,
    this.latestPurchase,
  });

  final SupplyNeed supplyNeed;
  final double? unitCost;
  final double? totalCost;
  final ProjectCostSource source;
  final MaterialPurchase? latestPurchase;

  String get sourceLabel {
    switch (source) {
      case ProjectCostSource.plannerEstimate:
        return 'Planner estimate';
      case ProjectCostSource.latestRecordedPurchase:
        return 'Latest local purchase';
      case ProjectCostSource.noCostAvailable:
        return 'No unit cost recorded';
      case ProjectCostSource.unitMismatch:
        return 'Purchase unit differs';
    }
  }
}

class ProjectCostingPreview {
  const ProjectCostingPreview({
    required this.project,
    required this.supplyLines,
    required this.estimatedMaterialCost,
    required this.estimatedLabourCost,
    required this.estimatedDirectCost,
    required this.suggestedSalePrice,
    required this.recordedProductionMaterialCost,
    required this.recordedOutputQuantity,
    required this.recordedRunCount,
  });

  final Project project;
  final List<ProjectSupplyCostLine> supplyLines;
  final double estimatedMaterialCost;
  final double estimatedLabourCost;
  final double estimatedDirectCost;
  final double? suggestedSalePrice;
  final double recordedProductionMaterialCost;
  final int recordedOutputQuantity;
  final int recordedRunCount;

  int get missingCostCount =>
      supplyLines.where((line) => line.unitCost == null).length;

  double? get recordedMaterialCostPerItem => recordedOutputQuantity == 0
      ? null
      : recordedProductionMaterialCost / recordedOutputQuantity;

  bool get hasLabourEstimate =>
      project.estimatedLabourMinutes != null &&
      project.labourRatePerHour != null;
}

/// Builds an offline planning estimate. This does not rewrite the material cost
/// captured in a [ProductionRun], so historic reports remain trustworthy when
/// replacement prices later change.
class ProjectCostingService {
  ProjectCostingService(
      this._procurementService, this._productionRunRepository);

  final ProcurementService _procurementService;
  final ProductionRunRepository _productionRunRepository;

  Future<ProjectCostingPreview> preview(Project project) async {
    final supplyLines = await Future.wait(
      project.supplyNeeds.map(_costSupplyNeed),
    );
    final productionRuns = (await _productionRunRepository.getRuns())
        .where((run) => run.projectId == project.id)
        .toList(growable: false);

    final materialCost = supplyLines.fold<double>(
      0,
      (total, line) => total + (line.totalCost ?? 0),
    );
    final labourCost = _estimateLabourCost(project);
    final directCost = materialCost + labourCost;
    final suggestedPrice = _suggestedSalePrice(
      directCost,
      project.targetMarginPercent,
    );

    return ProjectCostingPreview(
      project: project,
      supplyLines: supplyLines,
      estimatedMaterialCost: materialCost,
      estimatedLabourCost: labourCost,
      estimatedDirectCost: directCost,
      suggestedSalePrice: suggestedPrice,
      recordedProductionMaterialCost: productionRuns.fold<double>(
        0,
        (total, run) => total + run.materialCost,
      ),
      recordedOutputQuantity: productionRuns.fold<int>(
        0,
        (total, run) => total + run.outputQuantity,
      ),
      recordedRunCount: productionRuns.length,
    );
  }

  Future<ProjectSupplyCostLine> _costSupplyNeed(SupplyNeed supplyNeed) async {
    final explicitEstimate = supplyNeed.estimatedCostEach;
    if (explicitEstimate != null) {
      return ProjectSupplyCostLine(
        supplyNeed: supplyNeed,
        unitCost: explicitEstimate,
        totalCost: explicitEstimate * supplyNeed.quantityNeeded,
        source: ProjectCostSource.plannerEstimate,
      );
    }

    final inventoryItemId = supplyNeed.inventoryItemId;
    if (inventoryItemId == null || inventoryItemId.trim().isEmpty) {
      return ProjectSupplyCostLine(
        supplyNeed: supplyNeed,
        unitCost: null,
        totalCost: null,
        source: ProjectCostSource.noCostAvailable,
      );
    }

    final purchaseHistory =
        await _procurementService.getPurchaseHistory(inventoryItemId);
    if (purchaseHistory.isEmpty) {
      return ProjectSupplyCostLine(
        supplyNeed: supplyNeed,
        unitCost: null,
        totalCost: null,
        source: ProjectCostSource.noCostAvailable,
      );
    }

    final latestPurchase = purchaseHistory.first;
    if (!_sameUnit(supplyNeed.unit, latestPurchase.unit)) {
      return ProjectSupplyCostLine(
        supplyNeed: supplyNeed,
        unitCost: null,
        totalCost: null,
        source: ProjectCostSource.unitMismatch,
        latestPurchase: latestPurchase,
      );
    }

    return ProjectSupplyCostLine(
      supplyNeed: supplyNeed,
      unitCost: latestPurchase.unitCost,
      totalCost: latestPurchase.unitCost * supplyNeed.quantityNeeded,
      source: ProjectCostSource.latestRecordedPurchase,
      latestPurchase: latestPurchase,
    );
  }

  double _estimateLabourCost(Project project) {
    final minutes = project.estimatedLabourMinutes;
    final rate = project.labourRatePerHour;
    if (minutes == null || rate == null || minutes <= 0 || rate < 0) return 0;
    return (minutes / 60) * rate;
  }

  double? _suggestedSalePrice(double directCost, double? targetMarginPercent) {
    if (targetMarginPercent == null ||
        targetMarginPercent < 0 ||
        targetMarginPercent >= 100) {
      return null;
    }
    return directCost / (1 - targetMarginPercent / 100);
  }

  bool _sameUnit(String a, String b) =>
      a.trim().toLowerCase() == b.trim().toLowerCase();
}
