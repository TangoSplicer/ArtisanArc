// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'production_run_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductionRunAdapter extends TypeAdapter<ProductionRun> {
  @override
  final int typeId = 9;

  @override
  ProductionRun read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductionRun(
      id: fields[0] as String,
      projectId: fields[1] as String,
      finishedItemId: fields[2] as String,
      finishedItemName: fields[3] as String,
      outputQuantity: fields[4] as int,
      materialCost: fields[5] as double,
      completedAt: fields[6] as DateTime,
      notes: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ProductionRun obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.projectId)
      ..writeByte(2)
      ..write(obj.finishedItemId)
      ..writeByte(3)
      ..write(obj.finishedItemName)
      ..writeByte(4)
      ..write(obj.outputQuantity)
      ..writeByte(5)
      ..write(obj.materialCost)
      ..writeByte(6)
      ..write(obj.completedAt)
      ..writeByte(7)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductionRunAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
