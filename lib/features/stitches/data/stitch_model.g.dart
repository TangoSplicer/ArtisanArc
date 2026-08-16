// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stitch_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StitchReferenceAdapter extends TypeAdapter<StitchReference> {
  @override
  final int typeId = 23;

  @override
  StitchReference read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StitchReference(
      id: fields[0] as String,
      name: fields[1] as String,
      abbreviation: fields[2] as String,
      craftType: fields[3] as String,
      difficulty: fields[4] as String,
      instructions: fields[5] as String,
      tips: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, StitchReference obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.abbreviation)
      ..writeByte(3)
      ..write(obj.craftType)
      ..writeByte(4)
      ..write(obj.difficulty)
      ..writeByte(5)
      ..write(obj.instructions)
      ..writeByte(6)
      ..write(obj.tips);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StitchReferenceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
