// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'material_purchase_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MaterialPurchaseAdapter extends TypeAdapter<MaterialPurchase> {
  @override
  final int typeId = 12;

  @override
  MaterialPurchase read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MaterialPurchase(
      id: fields[0] as String,
      inventoryItemId: fields[1] as String,
      materialName: fields[2] as String,
      supplierId: fields[3] as String?,
      supplierName: fields[4] as String?,
      purchasedAt: fields[5] as DateTime,
      quantityPurchased: fields[6] as double,
      unit: fields[7] as String,
      totalPaid: fields[8] as double,
      note: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MaterialPurchase obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.inventoryItemId)
      ..writeByte(2)
      ..write(obj.materialName)
      ..writeByte(3)
      ..write(obj.supplierId)
      ..writeByte(4)
      ..write(obj.supplierName)
      ..writeByte(5)
      ..write(obj.purchasedAt)
      ..writeByte(6)
      ..write(obj.quantityPurchased)
      ..writeByte(7)
      ..write(obj.unit)
      ..writeByte(8)
      ..write(obj.totalPaid)
      ..writeByte(9)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaterialPurchaseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
