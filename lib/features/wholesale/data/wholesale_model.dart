import 'package:hive/hive.dart';

part 'wholesale_model.g.dart';

@HiveType(typeId: 18)
class WholesalePartner extends HiveObject {
  WholesalePartner({
    required this.id,
    required this.name,
    required this.contactName,
    required this.email,
    required this.phone,
    required this.address,
    required this.partnerType, // 'wholesale' or 'consignment'
    required this.commissionRatePercent, // e.g., 30.0 for 30% consignment fee
    required this.createdAt,
    required this.updatedAt,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String contactName;

  @HiveField(3)
  final String email;

  @HiveField(4)
  final String phone;

  @HiveField(5)
  final String address;

  @HiveField(6)
  final String partnerType;

  @HiveField(7)
  final double commissionRatePercent;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime updatedAt;
}

@HiveType(typeId: 19)
class WholesaleBatch extends HiveObject {
  WholesaleBatch({
    required this.id,
    required this.partnerId,
    required this.partnerName,
    required this.referenceNumber,
    required this.status, // 'sent', 'settled', 'returned'
    required this.items,
    required this.sentDate,
    required this.dueDate,
    this.settledDate,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String partnerId;

  @HiveField(2)
  final String partnerName;

  @HiveField(3)
  final String referenceNumber;

  @HiveField(4)
  final String status;

  @HiveField(5)
  final List<WholesaleBatchItem> items;

  @HiveField(6)
  final DateTime sentDate;

  @HiveField(7)
  final DateTime dueDate;

  @HiveField(8)
  final DateTime? settledDate;

  @HiveField(9)
  final String notes;

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final DateTime updatedAt;

  double get totalWholesaleValue => items.fold(
        0.0,
        (sum, item) => sum + (item.agreedUnitPrice * item.quantitySent),
      );

  double get totalSoldValue => items.fold(
        0.0,
        (sum, item) => sum + (item.agreedUnitPrice * item.quantitySold),
      );
}

@HiveType(typeId: 20)
class WholesaleBatchItem extends HiveObject {
  WholesaleBatchItem({
    required this.id,
    required this.inventoryItemId,
    required this.itemName,
    required this.quantitySent,
    required this.quantitySold,
    required this.quantityReturned,
    required this.agreedUnitPrice,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String inventoryItemId;

  @HiveField(2)
  final String itemName;

  @HiveField(3)
  final int quantitySent;

  @HiveField(4)
  final int quantitySold;

  @HiveField(5)
  final int quantityReturned;

  @HiveField(6)
  final double agreedUnitPrice;
}
