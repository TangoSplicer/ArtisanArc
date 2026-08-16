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
      finishedItemIds: (fields[10] as List?)?.cast<String>(),
      productionNotes: (fields[11] as List?)?.cast<String>(),
      estimatedLabourMinutes: fields[12] as int?,
      labourRatePerHour: fields[13] as double?,
      targetMarginPercent: fields[14] as double?,
      actualLabourMinutes: fields[15] == null ? 0 : fields[15] as int,
      activeTimerStartedAt: fields[16] as DateTime?,
      recipeId: fields[17] as String?,
      recipeName: fields[18] as String?,
      plannedOutputQuantity: fields[19] == null ? 1 : fields[19] as int,
      finishedItemCategory: fields[20] as String?,
      collectionId: fields[21] as String?,
      createdAt: fields[7] as DateTime,
      lastUpdatedAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Project obj) {
    writer
      ..writeByte(22)
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
      ..write(obj.supplyNeeds)
      ..writeByte(10)
      ..write(obj.finishedItemIds)
      ..writeByte(11)
      ..write(obj.productionNotes)
      ..writeByte(12)
      ..write(obj.estimatedLabourMinutes)
      ..writeByte(13)
      ..write(obj.labourRatePerHour)
      ..writeByte(14)
      ..write(obj.targetMarginPercent)
      ..writeByte(15)
      ..write(obj.actualLabourMinutes)
      ..writeByte(16)
      ..write(obj.activeTimerStartedAt)
      ..writeByte(17)
      ..write(obj.recipeId)
      ..writeByte(18)
      ..write(obj.recipeName)
      ..writeByte(19)
      ..write(obj.plannedOutputQuantity)
      ..writeByte(20)
      ..write(obj.finishedItemCategory)
      ..writeByte(21)
      ..write(obj.collectionId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
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
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MilestoneAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
