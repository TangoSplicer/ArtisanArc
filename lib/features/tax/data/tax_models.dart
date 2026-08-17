import 'package:hive/hive.dart';

part 'tax_models.g.dart';

@HiveType(typeId: 27)
class BusinessExpense extends HiveObject {
  BusinessExpense({
    required this.id,
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
    this.isAllowable = true,
    this.receiptPath,
    this.supplierName,
    this.notes,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String category; // e.g., 'Materials', 'Office', 'Travel', 'Marketing'

  @HiveField(2)
  final String description;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final bool isAllowable;

  @HiveField(6)
  final String? receiptPath;

  @HiveField(7)
  final String? supplierName;

  @HiveField(8)
  final String? notes;
}

@HiveType(typeId: 28)
class TaxYearConfig extends HiveObject {
  TaxYearConfig({
    required this.id,
    required this.yearLabel, // e.g., '2026/27'
    required this.startDate,
    required this.endDate,
    required this.personalAllowance,
    required this.basicRateThreshold,
    required this.basicRatePercent,
    required this.higherRatePercent,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String yearLabel;

  @HiveField(2)
  final DateTime startDate;

  @HiveField(3)
  final DateTime endDate;

  @HiveField(4)
  final double personalAllowance;

  @HiveField(5)
  final double basicRateThreshold;

  @HiveField(6)
  final double basicRatePercent;

  @HiveField(7)
  final double higherRatePercent;
}
