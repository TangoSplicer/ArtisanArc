// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commission_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CommissionAdapter extends TypeAdapter<Commission> {
  @override
  final int typeId = 13;

  @override
  Commission read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Commission(
      id: fields[0] as String,
      customerName: fields[1] as String,
      contactNote: fields[2] as String?,
      totalAmount: fields[3] as double,
      depositAmount: fields[4] as double,
      dueDate: fields[5] as DateTime?,
      linkedProjectId: fields[6] as String?,
      linkedProjectName: fields[7] as String?,
      status: fields[8] as CommissionStatus,
      notes: fields[9] as String?,
      createdAt: fields[10] as DateTime,
      updatedAt: fields[11] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Commission obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.customerName)
      ..writeByte(2)
      ..write(obj.contactNote)
      ..writeByte(3)
      ..write(obj.totalAmount)
      ..writeByte(4)
      ..write(obj.depositAmount)
      ..writeByte(5)
      ..write(obj.dueDate)
      ..writeByte(6)
      ..write(obj.linkedProjectId)
      ..writeByte(7)
      ..write(obj.linkedProjectName)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.notes)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommissionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CommissionStatusAdapter extends TypeAdapter<CommissionStatus> {
  @override
  final int typeId = 14;

  @override
  CommissionStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CommissionStatus.enquiry;
      case 1:
        return CommissionStatus.confirmed;
      case 2:
        return CommissionStatus.inProgress;
      case 3:
        return CommissionStatus.ready;
      case 4:
        return CommissionStatus.delivered;
      case 5:
        return CommissionStatus.cancelled;
      default:
        return CommissionStatus.enquiry;
    }
  }

  @override
  void write(BinaryWriter writer, CommissionStatus obj) {
    switch (obj) {
      case CommissionStatus.enquiry:
        writer.writeByte(0);
        break;
      case CommissionStatus.confirmed:
        writer.writeByte(1);
        break;
      case CommissionStatus.inProgress:
        writer.writeByte(2);
        break;
      case CommissionStatus.ready:
        writer.writeByte(3);
        break;
      case CommissionStatus.delivered:
        writer.writeByte(4);
        break;
      case CommissionStatus.cancelled:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommissionStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
