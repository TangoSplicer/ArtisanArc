// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'make_recipe_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MakeRecipeAdapter extends TypeAdapter<MakeRecipe> {
  @override
  final int typeId = 14;

  @override
  MakeRecipe read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MakeRecipe(
      id: fields[0] as String,
      name: fields[1] as String,
      productCategory: fields[2] as String,
      craftFocus: fields[3] as String,
      patternReference: fields[4] as String?,
      patternSource: fields[5] as String?,
      hookSize: fields[6] as String?,
      gaugeNote: fields[7] as String?,
      defaultOutputQuantity: fields[8] == null ? 1 : fields[8] as int,
      estimatedMakeMinutes: fields[9] as int?,
      targetMarginPercent: fields[10] as double?,
      supplyNeeds: (fields[11] as List?)?.cast<SupplyNeed>(),
      variants: (fields[12] as List?)?.cast<RecipeVariant>(),
      createdAt: fields[13] as DateTime,
      updatedAt: fields[14] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MakeRecipe obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.productCategory)
      ..writeByte(3)
      ..write(obj.craftFocus)
      ..writeByte(4)
      ..write(obj.patternReference)
      ..writeByte(5)
      ..write(obj.patternSource)
      ..writeByte(6)
      ..write(obj.hookSize)
      ..writeByte(7)
      ..write(obj.gaugeNote)
      ..writeByte(8)
      ..write(obj.defaultOutputQuantity)
      ..writeByte(9)
      ..write(obj.estimatedMakeMinutes)
      ..writeByte(10)
      ..write(obj.targetMarginPercent)
      ..writeByte(11)
      ..write(obj.supplyNeeds)
      ..writeByte(12)
      ..write(obj.variants)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MakeRecipeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecipeVariantAdapter extends TypeAdapter<RecipeVariant> {
  @override
  final int typeId = 15;

  @override
  RecipeVariant read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecipeVariant(
      id: fields[0] as String,
      name: fields[1] as String,
      detail: fields[2] as String?,
      outputQuantity: fields[3] == null ? 1 : fields[3] as int,
      estimatedMakeMinutes: fields[4] as int?,
      supplyNeeds: (fields[5] as List?)?.cast<SupplyNeed>(),
    );
  }

  @override
  void write(BinaryWriter writer, RecipeVariant obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.detail)
      ..writeByte(3)
      ..write(obj.outputQuantity)
      ..writeByte(4)
      ..write(obj.estimatedMakeMinutes)
      ..writeByte(5)
      ..write(obj.supplyNeeds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeVariantAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
