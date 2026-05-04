// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClubAdapter extends TypeAdapter<Club> {
  @override
  final typeId = 0;

  @override
  Club read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Club(
      id: fields[0] as String,
      title: fields[1] as String,
      president: fields[2] as String,
      city: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Club obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.president)
      ..writeByte(3)
      ..write(obj.city);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClubAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
