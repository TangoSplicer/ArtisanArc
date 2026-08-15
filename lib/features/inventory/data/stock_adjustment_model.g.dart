// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_adjustment_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StockAdjustmentAdapter extends TypeAdapter<StockAdjustment> {
  @override
  final int typeId = 10;

  @override
  StockAdjustment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StockAdjustment(
      id: fields[0] as String,
      itemId: fields[1] as String,
      itemName: fields[2] as String,
      previousQuantity: fields[3] as int,
      countedQuantity: fields[4] as int,
      quantityChange: fields[5] as int,
      recordedAt: fields[6] as DateTime,
      reason: fields[7] as String,
      note: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, StockAdjustment obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.itemId)
      ..writeByte(2)
      ..write(obj.itemName)
      ..writeByte(3)
      ..write(obj.previousQuantity)
      ..writeByte(4)
      ..write(obj.countedQuantity)
      ..writeByte(5)
      ..write(obj.quantityChange)
      ..writeByte(6)
      ..write(obj.recordedAt)
      ..writeByte(7)
      ..write(obj.reason)
      ..writeByte(8)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockAdjustmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
