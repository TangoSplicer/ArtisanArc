// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stall_session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StallSessionAdapter extends TypeAdapter<StallSession> {
  @override
  final int typeId = 8;

  @override
  StallSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StallSession(
      id: fields[0] as String,
      name: fields[1] as String,
      venue: fields[2] as String?,
      startedAt: fields[3] as DateTime,
      cashFloat: fields[4] == null ? 0.0 : fields[4] as double,
      tableFee: fields[5] == null ? 0.0 : fields[5] as double,
      travelCost: fields[6] == null ? 0.0 : fields[6] as double,
      isClosed: fields[7] == null ? false : fields[7] as bool,
      closedAt: fields[8] as DateTime?,
      countedCash: fields[9] as double?,
      closingNotes: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, StallSession obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.venue)
      ..writeByte(3)
      ..write(obj.startedAt)
      ..writeByte(4)
      ..write(obj.cashFloat)
      ..writeByte(5)
      ..write(obj.tableFee)
      ..writeByte(6)
      ..write(obj.travelCost)
      ..writeByte(7)
      ..write(obj.isClosed)
      ..writeByte(8)
      ..write(obj.closedAt)
      ..writeByte(9)
      ..write(obj.countedCash)
      ..writeByte(10)
      ..write(obj.closingNotes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StallSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
