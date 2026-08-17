import 'package:hive/hive.dart';

part 'brand_kit_model.g.dart';

@HiveType(typeId: 29)
class BrandKit extends HiveObject {
  BrandKit({
    required id,
    required this.businessName,
    required this.makerName,
    required this.address,
    required this.email,
    required this.phone,
    this.vatNumber,
    this.isVatRegistered = false,
  }) : id = id ?? 'primary_brand';

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String businessName;

  @HiveField(2)
  final String makerName;

  @HiveField(3)
  final String address;

  @HiveField(4)
  final String email;

  @HiveField(5)
  final String phone;

  @HiveField(6)
  final String? vatNumber;

  @HiveField(7)
  final bool isVatRegistered;
}
