import 'package:hive/hive.dart';

part 'stitch_model.g.dart';

@HiveType(typeId: 23)
class StitchReference extends HiveObject {
  StitchReference({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.craftType,
    required this.difficulty,
    required this.instructions,
    this.tips,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String abbreviation;

  @HiveField(3)
  final String craftType; // e.g., 'Crochet', 'Knitting'

  @HiveField(4)
  final String difficulty; // e.g., 'Beginner', 'Intermediate'

  @HiveField(5)
  final String instructions;

  @HiveField(6)
  final String? tips;
}
