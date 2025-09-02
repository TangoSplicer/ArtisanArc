// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProjectAdapter extends TypeAdapter<Project> {
  @override
  final int typeId = 3;

  @override
  Project read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Project(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      craftType: fields[3] as String?,
      startDate: fields[4] as DateTime?,
      endDate: fields[5] as DateTime?,
      milestones: (fields[6] as List?)?.cast<Milestone>(),
      supplyNeeds: (fields[9] as List?)?.cast<SupplyNeed>(),
      createdAt: fields[7] as DateTime,
      lastUpdatedAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Project obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.craftType)
      ..writeByte(4)
      ..write(obj.startDate)
      ..writeByte(5)
      ..write(obj.endDate)
      ..writeByte(6)
      ..write(obj.milestones)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.lastUpdatedAt)
      ..writeByte(9)
      ..write(obj.supplyNeeds);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

class MilestoneAdapter extends TypeAdapter<Milestone> {
  @override
  final int typeId = 5;

  @override
  Milestone read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Milestone(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      dueDate: fields[3] as DateTime,
      isCompleted: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Milestone obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.dueDate)
      ..writeByte(4)
      ..write(obj.isCompleted);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MilestoneAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}