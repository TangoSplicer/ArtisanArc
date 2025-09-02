// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compliance_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ComplianceEntryAdapter extends TypeAdapter<ComplianceEntry> {
  @override
  final int typeId = 2;

  @override
  ComplianceEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ComplianceEntry(
      id: fields[0] as String,
      certification: fields[1] as String,
      applicableCraft: fields[2] as String,
      dateCertified: fields[3] as DateTime,
      notes: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ComplianceEntry obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.certification)
      ..writeByte(2)
      ..write(obj.applicableCraft)
      ..writeByte(3)
      ..write(obj.dateCertified)
      ..writeByte(4)
      ..write(obj.notes);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComplianceEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}