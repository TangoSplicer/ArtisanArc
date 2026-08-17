// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BusinessExpenseAdapter extends TypeAdapter<BusinessExpense> {
  @override
  final int typeId = 27;

  @override
  BusinessExpense read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BusinessExpense(
      id: fields[0] as String,
      category: fields[1] as String,
      description: fields[2] as String,
      amount: fields[3] as double,
      date: fields[4] as DateTime,
      isAllowable: fields[5] as bool,
      receiptPath: fields[6] as String?,
      supplierName: fields[7] as String?,
      notes: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BusinessExpense obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.isAllowable)
      ..writeByte(6)
      ..write(obj.receiptPath)
      ..writeByte(7)
      ..write(obj.supplierName)
      ..writeByte(8)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BusinessExpenseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaxYearConfigAdapter extends TypeAdapter<TaxYearConfig> {
  @override
  final int typeId = 28;

  @override
  TaxYearConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaxYearConfig(
      id: fields[0] as String,
      yearLabel: fields[1] as String,
      startDate: fields[2] as DateTime,
      endDate: fields[3] as DateTime,
      personalAllowance: fields[4] as double,
      basicRateThreshold: fields[5] as double,
      basicRatePercent: fields[6] as double,
      higherRatePercent: fields[7] as double,
    );
  }

  @override
  void write(BinaryWriter writer, TaxYearConfig obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.yearLabel)
      ..writeByte(2)
      ..write(obj.startDate)
      ..writeByte(3)
      ..write(obj.endDate)
      ..writeByte(4)
      ..write(obj.personalAllowance)
      ..writeByte(5)
      ..write(obj.basicRateThreshold)
      ..writeByte(6)
      ..write(obj.basicRatePercent)
      ..writeByte(7)
      ..write(obj.higherRatePercent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaxYearConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
