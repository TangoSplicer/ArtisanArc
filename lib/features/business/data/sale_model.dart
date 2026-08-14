import 'package:hive/hive.dart';

part 'sale_model.g.dart';

@HiveType(typeId: 1)
class SaleRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String itemId;

  @HiveField(2)
  final int quantity;

  @HiveField(3)
  final double pricePerUnit;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final String? buyer;

  /// Optional event/session label, for example "Saturday Makers Market".
  @HiveField(6)
  final String? eventName;

  /// Optional table, stall, or venue detail associated with the event.
  @HiveField(7)
  final String? eventLocation;

  /// The optional persistent stall session containing this sale.
  @HiveField(8)
  final String? sessionId;

  @HiveField(9, defaultValue: 'cash')
  final String paymentMethod;

  /// The discount applied to this individual sale line, rather than a global
  /// basket value, so session and export totals remain accurate offline.
  @HiveField(10, defaultValue: 0.0)
  final double discountAmount;

  /// A return creates a separate negative-revenue record and restores the
  /// finished-item tally without deleting the original sale audit trail.
  @HiveField(11, defaultValue: false)
  final bool isReturn;

  /// A void leaves the sale history intact but removes its revenue and restores
  /// its finished-item tally after an explicit confirmation.
  @HiveField(12, defaultValue: false)
  final bool isVoid;

  @HiveField(13)
  final String? adjustmentReason;

  @HiveField(14)
  final String? relatedSaleId;

  SaleRecord({
    required this.id,
    required this.itemId,
    required this.quantity,
    required this.pricePerUnit,
    required this.date,
    this.buyer,
    this.eventName,
    this.eventLocation,
    this.sessionId,
    this.paymentMethod = 'cash',
    this.discountAmount = 0.0,
    this.isReturn = false,
    this.isVoid = false,
    this.adjustmentReason,
    this.relatedSaleId,
  });

  double get subtotal => quantity * pricePerUnit;

  double get total {
    if (isVoid) return 0.0;
    final net = subtotal - discountAmount;
    return isReturn ? -net : net;
  }

  SaleRecord copyWith({
    String? id,
    String? itemId,
    int? quantity,
    double? pricePerUnit,
    DateTime? date,
    String? buyer,
    String? eventName,
    String? eventLocation,
    String? sessionId,
    String? paymentMethod,
    double? discountAmount,
    bool? isReturn,
    bool? isVoid,
    String? adjustmentReason,
    String? relatedSaleId,
  }) {
    return SaleRecord(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      quantity: quantity ?? this.quantity,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      date: date ?? this.date,
      buyer: buyer ?? this.buyer,
      eventName: eventName ?? this.eventName,
      eventLocation: eventLocation ?? this.eventLocation,
      sessionId: sessionId ?? this.sessionId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      discountAmount: discountAmount ?? this.discountAmount,
      isReturn: isReturn ?? this.isReturn,
      isVoid: isVoid ?? this.isVoid,
      adjustmentReason: adjustmentReason ?? this.adjustmentReason,
      relatedSaleId: relatedSaleId ?? this.relatedSaleId,
    );
  }

  String get formattedDate =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
