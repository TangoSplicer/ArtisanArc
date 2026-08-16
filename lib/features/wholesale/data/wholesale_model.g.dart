// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wholesale_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WholesalePartnerAdapter extends TypeAdapter<WholesalePartner> {
  @override
  final int typeId = 18;

  @override
  WholesalePartner read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WholesalePartner(
      id: fields[0] as String,
      name: fields[1] as String,
      contactName: fields[2] as String,
      email: fields[3] as String,
      phone: fields[4] as String,
      address: fields[5] as String,
      partnerType: fields[6] as String,
      commissionRatePercent: fields[7] as double,
      createdAt: fields[8] as DateTime,
      updatedAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WholesalePartner obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.contactName)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.phone)
      ..writeByte(5)
      ..write(obj.address)
      ..writeByte(6)
      ..write(obj.partnerType)
      ..writeByte(7)
      ..write(obj.commissionRatePercent)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WholesalePartnerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WholesaleBatchAdapter extends TypeAdapter<WholesaleBatch> {
  @override
  final int typeId = 19;

  @override
  WholesaleBatch read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WholesaleBatch(
      id: fields[0] as String,
      partnerId: fields[1] as String,
      partnerName: fields[2] as String,
      referenceNumber: fields[3] as String,
      status: fields[4] as String,
      items: (fields[5] as List).cast<WholesaleBatchItem>(),
      sentDate: fields[6] as DateTime,
      dueDate: fields[7] as DateTime,
      settledDate: fields[8] as DateTime?,
      notes: fields[9] as String,
      createdAt: fields[10] as DateTime,
      updatedAt: fields[11] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WholesaleBatch obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.partnerId)
      ..writeByte(2)
      ..write(obj.partnerName)
      ..writeByte(3)
      ..write(obj.referenceNumber)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.items)
      ..writeByte(6)
      ..write(obj.sentDate)
      ..writeByte(7)
      ..write(obj.dueDate)
      ..writeByte(8)
      ..write(obj.settledDate)
      ..writeByte(9)
      ..write(obj.notes)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WholesaleBatchAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WholesaleBatchItemAdapter extends TypeAdapter<WholesaleBatchItem> {
  @override
  final int typeId = 20;

  @override
  WholesaleBatchItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WholesaleBatchItem(
      id: fields[0] as String,
      inventoryItemId: fields[1] as String,
      itemName: fields[2] as String,
      quantitySent: fields[3] as int,
      quantitySold: fields[4] as int,
      quantityReturned: fields[5] as int,
      agreedUnitPrice: fields[6] as double,
    );
  }

  @override
  void write(BinaryWriter writer, WholesaleBatchItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.inventoryItemId)
      ..writeByte(2)
      ..write(obj.itemName)
      ..writeByte(3)
      ..write(obj.quantitySent)
      ..writeByte(4)
      ..write(obj.quantitySold)
      ..writeByte(5)
      ..write(obj.quantityReturned)
      ..writeByte(6)
      ..write(obj.agreedUnitPrice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WholesaleBatchItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
