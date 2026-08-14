import 'package:uuid/uuid.dart';

import '../../inventory/data/inventory_model.dart';
import '../../inventory/data/inventory_repository.dart';
import '../data/business_repository.dart';
import '../data/sale_model.dart';
import '../data/stall_session_model.dart';
import '../data/stall_session_repository.dart';

class StallSessionSummary {
  const StallSessionSummary({
    required this.session,
    required this.sales,
    required this.netRevenue,
    required this.cashRevenue,
    required this.cardRevenue,
    required this.bankTransferRevenue,
    required this.otherRevenue,
  });

  final StallSession session;
  final List<SaleRecord> sales;
  final double netRevenue;
  final double cashRevenue;
  final double cardRevenue;
  final double bankTransferRevenue;
  final double otherRevenue;

  double get expectedCash => session.cashFloat + cashRevenue;

  double get directCosts => session.tableFee + session.travelCost;

  double get netAfterDirectCosts => netRevenue - directCosts;

  double? get cashDifference =>
      session.countedCash == null ? null : session.countedCash! - expectedCash;

  int get itemsSold => sales
      .where((sale) => !sale.isReturn && !sale.isVoid)
      .fold(0, (total, sale) => total + sale.quantity);

  int get itemsReturned => sales
      .where((sale) => sale.isReturn && !sale.isVoid)
      .fold(0, (total, sale) => total + sale.quantity);
}

/// Coordinates a complete stall day entirely through the app's existing local
/// Hive repositories. It deliberately performs no payment processing or cloud
/// communication: payment method is a record-keeping field only.
class StallSessionService {
  StallSessionService(
    this._sessionRepository,
    this._salesRepository,
    this._inventoryRepository,
  );

  final StallSessionRepository _sessionRepository;
  final BusinessRepository _salesRepository;
  final InventoryRepository _inventoryRepository;
  final Uuid _uuid = const Uuid();

  Future<StallSession?> getActiveSession() =>
      _sessionRepository.getActiveSession();

  Future<StallSession> startSession({
    required String name,
    String? venue,
    double cashFloat = 0.0,
    double tableFee = 0.0,
    double travelCost = 0.0,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty)
      throw ArgumentError.value(name, 'name', 'Session name is required.');
    final active = await getActiveSession();
    if (active != null) {
      throw StateError(
          '"${active.name}" is already active. Close it before starting another session.');
    }

    final session = StallSession(
      id: _uuid.v4(),
      name: cleanName,
      venue: venue?.trim().isEmpty ?? true ? null : venue!.trim(),
      startedAt: DateTime.now(),
      cashFloat: cashFloat < 0 ? 0 : cashFloat,
      tableFee: tableFee < 0 ? 0 : tableFee,
      travelCost: travelCost < 0 ? 0 : travelCost,
    );
    await _sessionRepository.saveSession(session);
    return session;
  }

  Future<List<SaleRecord>> recordBasket({
    required StallSession session,
    required Map<InventoryItem, int> basket,
    required String paymentMethod,
    double discountAmount = 0.0,
  }) async {
    if (session.isClosed)
      throw StateError('This stall session is already closed.');
    if (basket.isEmpty)
      throw ArgumentError.value(basket, 'basket', 'Add at least one item.');
    if (!_paymentMethods.contains(paymentMethod)) {
      throw ArgumentError.value(
          paymentMethod, 'paymentMethod', 'Unsupported payment method.');
    }
    if (discountAmount < 0) {
      throw ArgumentError.value(
          discountAmount, 'discountAmount', 'Discount cannot be negative.');
    }

    final subtotal = basket.entries.fold<double>(
      0,
      (total, entry) => total + entry.key.price! * entry.value,
    );
    if (subtotal <= 0)
      throw StateError('Every basket item needs a sale price.');
    if (discountAmount > subtotal) {
      throw StateError('Discount cannot be greater than the basket subtotal.');
    }

    for (final entry in basket.entries) {
      if (!entry.key.isFinishedItem ||
          entry.value < 1 ||
          entry.value > entry.key.quantity) {
        throw StateError('Basket quantities must be available finished items.');
      }
      if (entry.key.price == null)
        throw StateError('${entry.key.name} does not have a sale price.');
    }

    final now = DateTime.now();
    final records = <SaleRecord>[];
    var allocatedDiscount = 0.0;
    final entries = basket.entries.toList();
    for (var index = 0; index < entries.length; index++) {
      final entry = entries[index];
      final isFinalLine = index == entries.length - 1;
      final lineSubtotal = entry.key.price! * entry.value;
      final lineDiscount = isFinalLine
          ? discountAmount - allocatedDiscount
          : _roundMoney(discountAmount * lineSubtotal / subtotal);
      allocatedDiscount += lineDiscount;
      final record = SaleRecord(
        id: _uuid.v4(),
        itemId: entry.key.id,
        quantity: entry.value,
        pricePerUnit: entry.key.price!,
        date: now,
        eventName: session.name,
        eventLocation: session.venue,
        sessionId: session.id,
        paymentMethod: paymentMethod,
        discountAmount: lineDiscount,
      );
      records.add(record);
    }

    for (final record in records) {
      await _salesRepository.createSale(record);
      final item = basket.keys.firstWhere((entry) => entry.id == record.itemId);
      await _inventoryRepository.updateItem(
        item.copyWith(
            quantity: item.quantity - record.quantity, lastUpdated: now),
      );
    }
    return records;
  }

  Future<SaleRecord> returnSale({
    required SaleRecord originalSale,
    required int quantity,
    String? reason,
  }) async {
    if (originalSale.isVoid || originalSale.isReturn) {
      throw StateError('Only an active original sale can be returned.');
    }
    if (quantity < 1 || quantity > originalSale.quantity) {
      throw ArgumentError.value(quantity, 'quantity',
          'Return quantity must be within the original sale.');
    }

    final allSales = await _salesRepository.getSales();
    final previouslyReturned = allSales
        .where((sale) =>
            sale.relatedSaleId == originalSale.id &&
            sale.isReturn &&
            !sale.isVoid)
        .fold(0, (total, sale) => total + sale.quantity);
    if (previouslyReturned + quantity > originalSale.quantity) {
      throw StateError('This sale has already been returned in full.');
    }

    final item = await _inventoryRepository.getItemById(originalSale.itemId);
    if (item == null)
      throw StateError('The related finished item is no longer in Inventory.');
    final now = DateTime.now();
    final proportionalDiscount = _roundMoney(
      originalSale.discountAmount * quantity / originalSale.quantity,
    );
    final returnRecord = SaleRecord(
      id: _uuid.v4(),
      itemId: originalSale.itemId,
      quantity: quantity,
      pricePerUnit: originalSale.pricePerUnit,
      date: now,
      eventName: originalSale.eventName,
      eventLocation: originalSale.eventLocation,
      sessionId: originalSale.sessionId,
      paymentMethod: originalSale.paymentMethod,
      discountAmount: proportionalDiscount,
      isReturn: true,
      adjustmentReason: reason?.trim().isEmpty ?? true ? null : reason!.trim(),
      relatedSaleId: originalSale.id,
    );
    await _salesRepository.createSale(returnRecord);
    await _inventoryRepository.updateItem(
      item.copyWith(quantity: item.quantity + quantity, lastUpdated: now),
    );
    return returnRecord;
  }

  Future<SaleRecord> voidSale({
    required SaleRecord sale,
    required String reason,
  }) async {
    if (sale.isVoid || sale.isReturn) {
      throw StateError('Only an active original sale can be voided.');
    }
    final cleanReason = reason.trim();
    if (cleanReason.isEmpty)
      throw ArgumentError.value(reason, 'reason', 'A void reason is required.');

    final item = await _inventoryRepository.getItemById(sale.itemId);
    if (item == null)
      throw StateError('The related finished item is no longer in Inventory.');
    final allSales = await _salesRepository.getSales();
    final returnedQuantity = allSales
        .where((record) =>
            record.relatedSaleId == sale.id &&
            record.isReturn &&
            !record.isVoid)
        .fold(0, (total, record) => total + record.quantity);
    if (returnedQuantity > 0) {
      throw StateError(
          'Record a return rather than voiding a sale that already has a return.');
    }

    final now = DateTime.now();
    final voided = sale.copyWith(
      isVoid: true,
      adjustmentReason: cleanReason,
      date: now,
    );
    await _salesRepository.updateSale(voided);
    await _inventoryRepository.updateItem(
      item.copyWith(quantity: item.quantity + sale.quantity, lastUpdated: now),
    );
    return voided;
  }

  Future<StallSession> closeSession({
    required StallSession session,
    required double countedCash,
    String? notes,
  }) async {
    if (session.isClosed) return session;
    if (countedCash < 0) {
      throw ArgumentError.value(
          countedCash, 'countedCash', 'Counted cash cannot be negative.');
    }
    final closed = session.copyWith(
      isClosed: true,
      closedAt: DateTime.now(),
      countedCash: countedCash,
      closingNotes: notes?.trim().isEmpty ?? true ? null : notes!.trim(),
    );
    await _sessionRepository.saveSession(closed);
    return closed;
  }

  Future<StallSessionSummary> getSummary(StallSession session) async {
    final sales = (await _salesRepository.getSales())
        .where((sale) => sale.sessionId == session.id)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final totals = <String, double>{
      'cash': 0,
      'card': 0,
      'bank transfer': 0,
      'other': 0,
    };
    for (final sale in sales) {
      final key = _paymentMethods.contains(sale.paymentMethod)
          ? sale.paymentMethod
          : 'other';
      totals[key] = (totals[key] ?? 0) + sale.total;
    }
    return StallSessionSummary(
      session: session,
      sales: sales,
      netRevenue: sales.fold(0, (total, sale) => total + sale.total),
      cashRevenue: totals['cash'] ?? 0,
      cardRevenue: totals['card'] ?? 0,
      bankTransferRevenue: totals['bank transfer'] ?? 0,
      otherRevenue: totals['other'] ?? 0,
    );
  }

  static const _paymentMethods = ['cash', 'card', 'bank transfer', 'other'];

  double _roundMoney(double value) => (value * 100).roundToDouble() / 100;
}
