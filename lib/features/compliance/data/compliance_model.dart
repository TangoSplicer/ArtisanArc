import 'package:hive/hive.dart';

part 'compliance_model.g.dart';

@HiveType(typeId: 2)
class ComplianceEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String certification;

  @HiveField(2)
  final String applicableCraft;

  @HiveField(3)
  final DateTime dateCertified;

  @HiveField(4)
  final String? notes;

  ComplianceEntry({
    required this.id,
    required this.certification,
    required this.applicableCraft,
    required this.dateCertified,
    this.notes,
  });
}