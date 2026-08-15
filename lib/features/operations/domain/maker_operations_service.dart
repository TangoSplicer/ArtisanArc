import 'package:artisanarc/core/constants/app_constants.dart';
import 'package:artisanarc/features/business/data/sale_model.dart';
import 'package:artisanarc/features/business/data/stall_session_model.dart';
import 'package:artisanarc/features/business/domain/business_service.dart';
import 'package:artisanarc/features/business/domain/stall_session_service.dart';
import 'package:artisanarc/features/commissions/data/commission_model.dart';
import 'package:artisanarc/features/commissions/domain/commission_service.dart';
import 'package:artisanarc/features/inventory/data/inventory_model.dart';
import 'package:artisanarc/features/inventory/domain/inventory_service.dart';
import 'package:artisanarc/features/project/data/project_model.dart';
import 'package:artisanarc/features/project/domain/project_service.dart';

class MakerOperationsSnapshot {
  const MakerOperationsSnapshot({
    required this.generatedAt,
    required this.lowMaterials,
    required this.overdueProjects,
    required this.projectsDueSoon,
    required this.overdueCommissions,
    required this.commissionsDueSoon,
    required this.openCommissionCount,
    required this.salesThisWeek,
    required this.activeStall,
  });

  final DateTime generatedAt;
  final List<InventoryItem> lowMaterials;
  final List<Project> overdueProjects;
  final List<Project> projectsDueSoon;
  final List<Commission> overdueCommissions;
  final List<Commission> commissionsDueSoon;
  final int openCommissionCount;
  final double salesThisWeek;
  final StallSession? activeStall;

  int get urgentActionCount =>
      lowMaterials.length + overdueProjects.length + overdueCommissions.length;
}

enum SeasonalWorkflow {
  allYear,
  springMarkets,
  summerFairs,
  autumnLaunch,
  winterGifting;

  String get label {
    switch (this) {
      case SeasonalWorkflow.allYear:
        return 'All-year rhythm';
      case SeasonalWorkflow.springMarkets:
        return 'Spring markets';
      case SeasonalWorkflow.summerFairs:
        return 'Summer fairs';
      case SeasonalWorkflow.autumnLaunch:
        return 'Autumn launch';
      case SeasonalWorkflow.winterGifting:
        return 'Winter gifting';
    }
  }

  String get idealWindow {
    switch (this) {
      case SeasonalWorkflow.allYear:
        return 'Use any time to keep the next make, sale and stock tasks visible.';
      case SeasonalWorkflow.springMarkets:
        return 'Plan in January–March for spring events and makers markets.';
      case SeasonalWorkflow.summerFairs:
        return 'Plan in April–June for school fairs, festivals and summer markets.';
      case SeasonalWorkflow.autumnLaunch:
        return 'Plan in July–September for launches, fairs and early gifting stock.';
      case SeasonalWorkflow.winterGifting:
        return 'Plan in August–November for gifting, craft fairs and custom orders.';
    }
  }

  List<SeasonalWorkflowStep> get steps {
    switch (this) {
      case SeasonalWorkflow.allYear:
        return const [
          SeasonalWorkflowStep('Trust the count',
              'Run a stocktake on materials and saleable makes.'),
          SeasonalWorkflowStep('Price the next make',
              'Review Cost & Price before creating new finished stock.'),
          SeasonalWorkflowStep('Protect records',
              'Create a portable backup before a major import or tidy-up.'),
        ];
      case SeasonalWorkflow.springMarkets:
        return const [
          SeasonalWorkflowStep('Eight weeks out',
              'Choose projects, confirm yarn and notion needs, and set a target stall date.'),
          SeasonalWorkflowStep('Four weeks out',
              'Complete makes, print QR labels and photograph new pieces.'),
          SeasonalWorkflowStep('Event week',
              'Start a stall session, check low materials, and pack labelled created items.'),
        ];
      case SeasonalWorkflow.summerFairs:
        return const [
          SeasonalWorkflowStep('Six weeks out',
              'Plan lightweight seasonal makes and replenish fast-moving materials.'),
          SeasonalWorkflowStep('Two weeks out',
              'Use project costs to check prices and label display stock.'),
          SeasonalWorkflowStep('Fair day',
              'Use scan-to-sell or the stall basket, then close the session with cash-up.'),
        ];
      case SeasonalWorkflow.autumnLaunch:
        return const [
          SeasonalWorkflowStep('Production window',
              'Build a short, repeatable autumn range from measured material stock.'),
          SeasonalWorkflowStep('Order window',
              'Confirm commission due dates, deposits and linked projects.'),
          SeasonalWorkflowStep('Launch check',
              'Refresh labels, restock packaging and review the operations dashboard.'),
        ];
      case SeasonalWorkflow.winterGifting:
        return const [
          SeasonalWorkflowStep('Twelve weeks out',
              'Set commission cut-off dates and reserve core materials for gift orders.'),
          SeasonalWorkflowStep('Six weeks out',
              'Prioritise open orders by due date and complete saleable gift stock.'),
          SeasonalWorkflowStep('Final fortnight',
              'Use QR labels for fast sales and confirm collection or delivery notes locally.'),
        ];
    }
  }
}

class SeasonalWorkflowStep {
  const SeasonalWorkflowStep(this.title, this.detail);

  final String title;
  final String detail;
}

/// Summarises actionable maker work from local data only. It is a read-only
/// dashboard service: source records remain in their existing features.
class MakerOperationsService {
  MakerOperationsService(
    this._inventoryService,
    this._projectService,
    this._commissionService,
    this._businessService,
    this._stallSessionService,
  );

  final InventoryService _inventoryService;
  final ProjectService _projectService;
  final CommissionService _commissionService;
  final BusinessService _businessService;
  final StallSessionService _stallSessionService;

  Future<MakerOperationsSnapshot> getSnapshot({
    DateTime? now,
    int dueSoonDays = 14,
  }) async {
    final current = now ?? DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    final dueSoonCutoff = today.add(Duration(days: dueSoonDays));
    final weekStart = today.subtract(const Duration(days: 6));

    final results = await Future.wait<dynamic>([
      _inventoryService.fetchItems(),
      _projectService.fetchProjects(),
      _commissionService.getCommissions(),
      _businessService.fetchSales(),
      _stallSessionService.getActiveSession(),
    ]);
    final inventory = results[0] as List<InventoryItem>;
    final projects = results[1] as List<Project>;
    final commissions = results[2] as List<Commission>;
    final sales = results[3] as List<SaleRecord>;
    final activeStall = results[4] as StallSession?;

    final lowMaterials = inventory
        .where(
          (item) =>
              item.isMaterialStock &&
              !item.isArchived &&
              item.availableStockQuantity <=
                  (item.activeReorderPoint ??
                      AppConstants.lowStockThreshold.toDouble()),
        )
        .toList()
      ..sort((a, b) =>
          a.availableStockQuantity.compareTo(b.availableStockQuantity));

    final incompleteProjects = projects.where(_isProjectIncomplete).toList();
    final overdueProjects = incompleteProjects
        .where((project) =>
            project.endDate != null && project.endDate!.isBefore(today))
        .toList()
      ..sort((a, b) => a.endDate!.compareTo(b.endDate!));
    final projectsDueSoon = incompleteProjects
        .where((project) =>
            project.endDate != null &&
            !project.endDate!.isBefore(today) &&
            !project.endDate!.isAfter(dueSoonCutoff))
        .toList()
      ..sort((a, b) => a.endDate!.compareTo(b.endDate!));

    final openCommissions =
        commissions.where((commission) => commission.isOpen).toList();
    final overdueCommissions = openCommissions
        .where((commission) =>
            commission.dueDate != null && commission.dueDate!.isBefore(today))
        .toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    final commissionsDueSoon = openCommissions
        .where((commission) =>
            commission.dueDate != null &&
            !commission.dueDate!.isBefore(today) &&
            !commission.dueDate!.isAfter(dueSoonCutoff))
        .toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

    final salesThisWeek = sales
        .where((sale) => !sale.date.isBefore(weekStart))
        .fold<double>(0, (total, sale) => total + sale.total);

    return MakerOperationsSnapshot(
      generatedAt: current,
      lowMaterials: List.unmodifiable(lowMaterials),
      overdueProjects: List.unmodifiable(overdueProjects),
      projectsDueSoon: List.unmodifiable(projectsDueSoon),
      overdueCommissions: List.unmodifiable(overdueCommissions),
      commissionsDueSoon: List.unmodifiable(commissionsDueSoon),
      openCommissionCount: openCommissions.length,
      salesThisWeek: salesThisWeek,
      activeStall: activeStall,
    );
  }

  bool _isProjectIncomplete(Project project) =>
      project.milestones.isEmpty ||
      project.milestones.any((milestone) => !milestone.isCompleted);
}
