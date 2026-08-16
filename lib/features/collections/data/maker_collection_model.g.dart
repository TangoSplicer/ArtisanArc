// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maker_collection_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MakerCollectionAdapter extends TypeAdapter<MakerCollection> {
  @override
  final int typeId = 16;

  @override
  MakerCollection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MakerCollection(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      season: fields[3] as String?,
      targetDate: fields[4] as DateTime?,
      weeklyCapacityMinutes: fields[5] == null ? 180 : fields[5] as int,
      recipeTargets: (fields[6] as List?)?.cast<CollectionRecipeTarget>(),
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MakerCollection obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.season)
      ..writeByte(4)
      ..write(obj.targetDate)
      ..writeByte(5)
      ..write(obj.weeklyCapacityMinutes)
      ..writeByte(6)
      ..write(obj.recipeTargets)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MakerCollectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CollectionRecipeTargetAdapter
    extends TypeAdapter<CollectionRecipeTarget> {
  @override
  final int typeId = 17;

  @override
  CollectionRecipeTarget read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CollectionRecipeTarget(
      id: fields[0] as String,
      recipeId: fields[1] as String,
      targetQuantity: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CollectionRecipeTarget obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.recipeId)
      ..writeByte(2)
      ..write(obj.targetQuantity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectionRecipeTargetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
