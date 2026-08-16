// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pattern_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StoredPatternAdapter extends TypeAdapter<StoredPattern> {
  @override
  final int typeId = 21;

  @override
  StoredPattern read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoredPattern(
      id: fields[0] as String,
      title: fields[1] as String,
      designer: fields[2] as String?,
      localFilePath: fields[3] as String,
      linkedRecipeId: fields[4] as String?,
      linkedProjectId: fields[5] as String?,
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, StoredPattern obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.designer)
      ..writeByte(3)
      ..write(obj.localFilePath)
      ..writeByte(4)
      ..write(obj.linkedRecipeId)
      ..writeByte(5)
      ..write(obj.linkedProjectId)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoredPatternAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RowCounterAdapter extends TypeAdapter<RowCounter> {
  @override
  final int typeId = 22;

  @override
  RowCounter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RowCounter(
      id: fields[0] as String,
      title: fields[1] as String,
      count: fields[2] as int,
      targetCount: fields[3] as int?,
      linkedProjectId: fields[4] as String?,
      updatedAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, RowCounter obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.count)
      ..writeByte(3)
      ..write(obj.targetCount)
      ..writeByte(4)
      ..write(obj.linkedProjectId)
      ..writeByte(5)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RowCounterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
