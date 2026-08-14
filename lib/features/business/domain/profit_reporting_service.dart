import '../../inventory/data/inventory_model.dart';
import '../../inventory/data/inventory_repository.dart';
import '../../project/data/production_run_model.dart';
import '../../project/data/production_run_repository.dart';
import '../data/business_repository.dart';
import '../data/sale_model.dart';
import '../data/stall_session_repository.dart';

class ProfitSummary {
  const ProfitSummary({
    required this.revenue,
    required this.materialCostOfSales,
    required this.grossProfit,
    required this.knownCostRevenue,
    required this.itemsSold,
  });

  final double revenue;
  final double materialCostOfSales;
  final double grossProfit;
  final double knownCostRevenue;
  final int itemsSold;

  double get marginPercent => revenue == 0 ? 0 : grossProfit / revenue * 100;

  bool get hasUnknownCosts => revenue > knownCostRevenue;
}

class ItemPerformance {
  const ItemPerformance({
    required this.itemId,
    required this.itemName,
    required this.soldQuantity,
    required this.revenue,
    required this.materialCost,
    required this.remainingQuantity,
    required this.costKnown,
  });

  final String itemId;
  final String itemName;
  final int soldQuantity;
  final double revenue;
  final double materialCost;
  final int remainingQuantity;
  final bool costKnown;

  double get profit => revenue - materialCost;
}

class SessionProfitSummary {
  const SessionProfitSummary({
    required this.sessionId,
    required this.name,
    required this.revenue,
    required this.materialCost,
    required this.directCosts,
  });

  final String sessionId;
  final String name;
  final double revenue;
  final double materialCost;
  final double directCosts;

  double get profitAfterDirectCosts => revenue - materialCost - directCosts;
}

class StockMovement {
  const StockMovement({
    required this.itemId,
    required this.itemName,
    required this.quantityChange,
    required this.date,
    required this.reason,
  });

  final String itemId;
  final String itemName;
  final int quantityChange;
  final DateTime date;
  final String reason;
}

/// Produces privacy-preserving profitability and stock-movement insights solely
/// from local ArtisanArc records. No tax estimate or external price source is
/// implied: profit is revenue less the captured material-cost snapshot and any
/// directly entered event fees.
class ProfitReportingService {
  ProfitReportingService(
    this._salesRepository,
    this._inventoryRepository,
    this._productionRunRepository,
    this._sessionRepository,
  );

  final BusinessRepository _salesRepository;
  final InventoryRepository _inventoryRepository;
  final ProductionRunRepository _productionRunRepository;
  final StallSessionRepository _sessionRepository;

  Future<ProfitSummary> getSummary() async {
    final data = await _loadData();
    return _summaryForSales(data.sales, data.costPerItem);
  }

  Future<List<ItemPerformance>> getItemPerformance() async {
    final data = await _loadData();
    final byItem = <String, _MutableItemPerformance>{};
    for (final sale in data.sales) {
      if (sale.isVoid) continue;
      final item = data.itemsById[sale.itemId];
      final entry = byItem.putIfAbsent(
        sale.itemId,
        () => _MutableItemPerformance(
          id: sale.itemId,
          name: item?.name ?? 'Removed inventory item',
          remainingQuantity: item?.quantity ?? 0,
          costPerItem: data.costPerItem[sale.itemId],
        ),
      );
      final direction = sale.isReturn ? -1 : 1;
      entry.soldQuantity += direction * sale.quantity;
      entry.revenue += sale.total;
      if (entry.costPerItem != null) {
        entry.materialCost += direction * sale.quantity * entry.costPerItem!;
      }
    }
    return byItem.values
        .map((entry) => entry.toImmutable())
        .where(
            (entry) => entry.soldQuantity != 0 || entry.remainingQuantity > 0)
        .toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));
  }

  Future<List<SessionProfitSummary>> getSessionProfitability() async {
    final data = await _loadData();
    final sessions = await _sessionRepository.getSessions();
    final result = <SessionProfitSummary>[];
    for (final session in sessions) {
      final sales =
          data.sales.where((sale) => sale.sessionId == session.id).toList();
      final summary = _summaryForSales(sales, data.costPerItem);
      result.add(SessionProfitSummary(
        sessionId: session.id,
        name: session.name,
        revenue: summary.revenue,
        materialCost: summary.materialCostOfSales,
        directCosts: session.tableFee + session.travelCost,
      ));
    }
    result.sort(
        (a, b) => b.profitAfterDirectCosts.compareTo(a.profitAfterDirectCosts));
    return result;
  }

  Future<List<StockMovement>> getFinishedItemMovements() async {
    final data = await _loadData();
    final movements = <StockMovement>[];
    for (final run in data.productionRuns) {
      movements.add(StockMovement(
        itemId: run.finishedItemId,
        itemName: run.finishedItemName,
        quantityChange: run.outputQuantity,
        date: run.completedAt,
        reason: 'Completed make',
      ));
    }
    for (final sale in data.sales) {
      if (sale.isVoid) {
        movements.add(StockMovement(
          itemId: sale.itemId,
          itemName:
              data.itemsById[sale.itemId]?.name ?? 'Removed inventory item',
          quantityChange: sale.quantity,
          date: sale.date,
          reason: 'Voided sale restored stock',
        ));
      } else if (sale.isReturn) {
        movements.add(StockMovement(
          itemId: sale.itemId,
          itemName:
              data.itemsById[sale.itemId]?.name ?? 'Removed inventory item',
          quantityChange: sale.quantity,
          date: sale.date,
          reason: 'Return restored stock',
        ));
      } else {
        movements.add(StockMovement(
          itemId: sale.itemId,
          itemName:
              data.itemsById[sale.itemId]?.name ?? 'Removed inventory item',
          quantityChange: -sale.quantity,
          date: sale.date,
          reason: 'Sale',
        ));
      }
    }
    movements.sort((a, b) => b.date.compareTo(a.date));
    return movements;
  }

  Future<_ReportingData> _loadData() async {
    final sales = await _salesRepository.getSales();
    final items = await _inventoryRepository.getAllItems();
    final runs = await _productionRunRepository.getRuns();
    final producedUnits = <String, int>{};
    final producedCost = <String, double>{};
    for (final run in runs) {
      producedUnits[run.finishedItemId] =
          (producedUnits[run.finishedItemId] ?? 0) + run.outputQuantity;
      producedCost[run.finishedItemId] =
          (producedCost[run.finishedItemId] ?? 0) + run.materialCost;
    }
    final costPerItem = <String, double>{
      for (final entry in producedUnits.entries)
        if (entry.value > 0)
          entry.key: (producedCost[entry.key] ?? 0) / entry.value,
    };
    return _ReportingData(
      sales: sales,
      productionRuns: runs,
      itemsById: {for (final item in items) item.id: item},
      costPerItem: costPerItem,
    );
  }

  ProfitSummary _summaryForSales(
    Iterable<SaleRecord> sales,
    Map<String, double> costPerItem,
  ) {
    var revenue = 0.0;
    var materialCost = 0.0;
    var knownCostRevenue = 0.0;
    var itemsSold = 0;
    for (final sale in sales) {
      if (sale.isVoid) continue;
      final unitCost = costPerItem[sale.itemId];
      final direction = sale.isReturn ? -1 : 1;
      revenue += sale.total;
      itemsSold += direction * sale.quantity;
      if (unitCost != null) {
        materialCost += direction * sale.quantity * unitCost;
        knownCostRevenue += sale.total;
      }
    }
    return ProfitSummary(
      revenue: revenue,
      materialCostOfSales: materialCost,
      grossProfit: revenue - materialCost,
      knownCostRevenue: knownCostRevenue,
      itemsSold: itemsSold,
    );
  }
}

class _ReportingData {
  const _ReportingData({
    required this.sales,
    required this.productionRuns,
    required this.itemsById,
    required this.costPerItem,
  });

  final List<SaleRecord> sales;
  final List<ProductionRun> productionRuns;
  final Map<String, InventoryItem> itemsById;
  final Map<String, double> costPerItem;
}

class _MutableItemPerformance {
  _MutableItemPerformance({
    required this.id,
    required this.name,
    required this.remainingQuantity,
    required this.costPerItem,
  });

  final String id;
  final String name;
  final int remainingQuantity;
  final double? costPerItem;
  int soldQuantity = 0;
  double revenue = 0;
  double materialCost = 0;

  ItemPerformance toImmutable() => ItemPerformance(
        itemId: id,
        itemName: name,
        soldQuantity: soldQuantity,
        revenue: revenue,
        materialCost: materialCost,
        remainingQuantity: remainingQuantity,
        costKnown: costPerItem != null,
      );
}
