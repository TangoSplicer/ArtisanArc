// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SaleRecordAdapter extends TypeAdapter<SaleRecord> {
  @override
  final int typeId = 1;

  @override
  SaleRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SaleRecord(
      id: fields[0] as String,
      itemId: fields[1] as String,
      quantity: fields[2] as int,
      pricePerUnit: fields[3] as double,
      date: fields[4] as DateTime,
      buyer: fields[5] as String?,
      eventName: fields[6] as String?,
      eventLocation: fields[7] as String?,
      sessionId: fields[8] as String?,
      paymentMethod: fields[9] == null ? 'cash' : fields[9] as String,
      discountAmount: fields[10] == null ? 0.0 : fields[10] as double,
      isReturn: fields[11] == null ? false : fields[11] as bool,
      isVoid: fields[12] == null ? false : fields[12] as bool,
      adjustmentReason: fields[13] as String?,
      relatedSaleId: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SaleRecord obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.itemId)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.pricePerUnit)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.buyer)
      ..writeByte(6)
      ..write(obj.eventName)
      ..writeByte(7)
      ..write(obj.eventLocation)
      ..writeByte(8)
      ..write(obj.sessionId)
      ..writeByte(9)
      ..write(obj.paymentMethod)
      ..writeByte(10)
      ..write(obj.discountAmount)
      ..writeByte(11)
      ..write(obj.isReturn)
      ..writeByte(12)
      ..write(obj.isVoid)
      ..writeByte(13)
      ..write(obj.adjustmentReason)
      ..writeByte(14)
      ..write(obj.relatedSaleId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
