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
      itemType: fields[8] as String?,
      reorderPoint: fields[9] as int?,
      isArchived: fields[10] == null ? false : fields[10] as bool,
      measuredQuantity: fields[11] as double?,
      measurementUnit: fields[12] as String?,
      measuredReorderPoint: fields[13] as double?,
      yarnBrand: fields[14] as String?,
      yarnRange: fields[15] as String?,
      yarnColour: fields[16] as String?,
      dyeLot: fields[17] as String?,
      yarnWeight: fields[18] as String?,
      yarnFibre: fields[19] as String?,
      yarnWeightGrams: fields[20] as double?,
      yarnLengthMetres: fields[21] as double?,
      recommendedHookSize: fields[22] as String?,
      gaugeNote: fields[23] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, InventoryItem obj) {
    writer
      ..writeByte(24)
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
      ..write(obj.lastUpdated)
      ..writeByte(8)
      ..write(obj.itemType)
      ..writeByte(9)
      ..write(obj.reorderPoint)
      ..writeByte(10)
      ..write(obj.isArchived)
      ..writeByte(11)
      ..write(obj.measuredQuantity)
      ..writeByte(12)
      ..write(obj.measurementUnit)
      ..writeByte(13)
      ..write(obj.measuredReorderPoint)
      ..writeByte(14)
      ..write(obj.yarnBrand)
      ..writeByte(15)
      ..write(obj.yarnRange)
      ..writeByte(16)
      ..write(obj.yarnColour)
      ..writeByte(17)
      ..write(obj.dyeLot)
      ..writeByte(18)
      ..write(obj.yarnWeight)
      ..writeByte(19)
      ..write(obj.yarnFibre)
      ..writeByte(20)
      ..write(obj.yarnWeightGrams)
      ..writeByte(21)
      ..write(obj.yarnLengthMetres)
      ..writeByte(22)
      ..write(obj.recommendedHookSize)
      ..writeByte(23)
      ..write(obj.gaugeNote);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
