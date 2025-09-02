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
    );
  }

  @override
  void write(BinaryWriter writer, SaleRecord obj) {
    writer
      ..writeByte(6)
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
      ..write(obj.buyer);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}