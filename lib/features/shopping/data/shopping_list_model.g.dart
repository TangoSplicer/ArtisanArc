// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShoppingListAdapter extends TypeAdapter<ShoppingList> {
  @override
  final int typeId = 6;

  @override
  ShoppingList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShoppingList(
      id: fields[0] as String,
      name: fields[1] as String,
      createdAt: fields[2] as DateTime,
      items: (fields[3] as List?)?.cast<ShoppingListItem>(),
    );
  }

  @override
  void write(BinaryWriter writer, ShoppingList obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.items);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShoppingListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

class ShoppingListItemAdapter extends TypeAdapter<ShoppingListItem> {
  @override
  final int typeId = 7;

  @override
  ShoppingListItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShoppingListItem(
      id: fields[0] as String,
      itemName: fields[1] as String,
      quantity: fields[2] as String?,
      isPurchased: fields[3] as bool,
      notes: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ShoppingListItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.itemName)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.isPurchased)
      ..writeByte(4)
      ..write(obj.notes);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShoppingListItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}