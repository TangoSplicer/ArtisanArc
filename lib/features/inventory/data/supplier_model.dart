import 'package:hive/hive.dart';

part 'supplier_model.g.dart';

@HiveType(typeId: 11)
class Supplier extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? website;

  @HiveField(3)
  final String? contactNote;

  @HiveField(4)
  final String? notes;

  Supplier({
    required this.id,
    required this.name,
    this.website,
    this.contactNote,
    this.notes,
  });
}
