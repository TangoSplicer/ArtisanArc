import 'package:hive/hive.dart';

part 'stall_session_model.g.dart';

@HiveType(typeId: 8)
class StallSession extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? venue;

  @HiveField(3)
  final DateTime startedAt;

  @HiveField(4, defaultValue: 0.0)
  final double cashFloat;

  @HiveField(5, defaultValue: 0.0)
  final double tableFee;

  @HiveField(6, defaultValue: 0.0)
  final double travelCost;

  @HiveField(7, defaultValue: false)
  final bool isClosed;

  @HiveField(8)
  final DateTime? closedAt;

  @HiveField(9)
  final double? countedCash;

  @HiveField(10)
  final String? closingNotes;

  StallSession({
    required this.id,
    required this.name,
    this.venue,
    required this.startedAt,
    this.cashFloat = 0.0,
    this.tableFee = 0.0,
    this.travelCost = 0.0,
    this.isClosed = false,
    this.closedAt,
    this.countedCash,
    this.closingNotes,
  });

  StallSession copyWith({
    String? id,
    String? name,
    String? venue,
    DateTime? startedAt,
    double? cashFloat,
    double? tableFee,
    double? travelCost,
    bool? isClosed,
    DateTime? closedAt,
    double? countedCash,
    String? closingNotes,
  }) {
    return StallSession(
      id: id ?? this.id,
      name: name ?? this.name,
      venue: venue ?? this.venue,
      startedAt: startedAt ?? this.startedAt,
      cashFloat: cashFloat ?? this.cashFloat,
      tableFee: tableFee ?? this.tableFee,
      travelCost: travelCost ?? this.travelCost,
      isClosed: isClosed ?? this.isClosed,
      closedAt: closedAt ?? this.closedAt,
      countedCash: countedCash ?? this.countedCash,
      closingNotes: closingNotes ?? this.closingNotes,
    );
  }
}
