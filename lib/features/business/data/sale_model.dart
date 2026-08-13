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

  SaleRecord({
    required this.id,
    required this.itemId,
    required this.quantity,
    required this.pricePerUnit,
    required this.date,
    this.buyer,
    this.eventName,
    this.eventLocation,
  });

  double get total => quantity * pricePerUnit;

  String get formattedDate =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}