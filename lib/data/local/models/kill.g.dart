// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kill.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KillAdapter extends TypeAdapter<Kill> {
  @override
  final typeId = 6;

  @override
  Kill read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Kill(
      id: fields[0] as String,
      gameId: fields[1] as String,
      phaseId: (fields[2] as num).toInt(),
      playerSeatNumber: (fields[3] as num).toInt(),
      type: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Kill obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.gameId)
      ..writeByte(2)
      ..write(obj.phaseId)
      ..writeByte(3)
      ..write(obj.playerSeatNumber)
      ..writeByte(4)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KillAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
