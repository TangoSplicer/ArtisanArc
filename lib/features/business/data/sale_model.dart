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

  SaleRecord({
    required this.id,
    required this.itemId,
    required this.quantity,
    required this.pricePerUnit,
    required this.date,
    this.buyer,
  });

  double get total => quantity * pricePerUnit;

  String get formattedDate =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}