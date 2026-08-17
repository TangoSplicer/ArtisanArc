// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brand_kit_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BrandKitAdapter extends TypeAdapter<BrandKit> {
  @override
  final int typeId = 29;

  @override
  BrandKit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BrandKit(
      id: fields[0] as dynamic,
      businessName: fields[1] as String,
      makerName: fields[2] as String,
      address: fields[3] as String,
      email: fields[4] as String,
      phone: fields[5] as String,
      vatNumber: fields[6] as String?,
      isVatRegistered: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, BrandKit obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.businessName)
      ..writeByte(2)
      ..write(obj.makerName)
      ..writeByte(3)
      ..write(obj.address)
      ..writeByte(4)
      ..write(obj.email)
      ..writeByte(5)
      ..write(obj.phone)
      ..writeByte(6)
      ..write(obj.vatNumber)
      ..writeByte(7)
      ..write(obj.isVatRegistered);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrandKitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
