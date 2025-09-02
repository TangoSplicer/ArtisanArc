// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InventoryItemAdapter extends TypeAdapter<InventoryItem> {
  @override
  final int typeId = 0;

  @override
  InventoryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InventoryItem(
      id: fields[0] as String,
      name: fields[1] as String,
      category: fields[2] as String,
      quantity: fields[3] as int,
      price: fields[4] as double?,
      storageLocation: fields[5] as String?,
      imagePaths: (fields[6] as List?)?.cast<String>(),
      lastUpdated: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, InventoryItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.price)
      ..writeByte(5)
      ..write(obj.storageLocation)
      ..writeByte(6)
      ..write(obj.imagePaths)
      ..writeByte(7)
      ..write(obj.lastUpdated);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}