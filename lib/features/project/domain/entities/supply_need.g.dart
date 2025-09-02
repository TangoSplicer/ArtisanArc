// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supply_need.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SupplyNeedAdapter extends TypeAdapter<SupplyNeed> {
  @override
  final int typeId = 4;

  @override
  SupplyNeed read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SupplyNeed(
      id: fields[0] as String,
      itemName: fields[1] as String,
      quantityNeeded: fields[2] as double,
      unit: fields[3] as String,
      isSourced: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SupplyNeed obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.itemName)
      ..writeByte(2)
      ..write(obj.quantityNeeded)
      ..writeByte(3)
      ..write(obj.unit)
      ..writeByte(4)
      ..write(obj.isSourced);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupplyNeedAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}