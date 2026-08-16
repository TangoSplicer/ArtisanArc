// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EquipmentItemAdapter extends TypeAdapter<EquipmentItem> {
  @override
  final int typeId = 24;

  @override
  EquipmentItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EquipmentItem(
      id: fields[0] as String,
      name: fields[1] as String,
      category: fields[2] as String,
      brand: fields[3] as String?,
      serialNumber: fields[4] as String?,
      purchaseDate: fields[5] as DateTime,
      purchasePrice: fields[6] as double?,
      maintenanceNotes: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, EquipmentItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.brand)
      ..writeByte(4)
      ..write(obj.serialNumber)
      ..writeByte(5)
      ..write(obj.purchaseDate)
      ..writeByte(6)
      ..write(obj.purchasePrice)
      ..writeByte(7)
      ..write(obj.maintenanceNotes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquipmentItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
