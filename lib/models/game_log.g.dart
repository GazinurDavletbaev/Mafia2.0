// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameLogAdapter extends TypeAdapter<GameLog> {
  @override
  final typeId = 11;

  @override
  GameLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameLog(
      id: fields[0] as String,
      gameId: fields[1] as String,
      phaseId: (fields[2] as num).toInt(),
      actionType: fields[3] as String,
      description: fields[4] as String,
      timestamp: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, GameLog obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.gameId)
      ..writeByte(2)
      ..write(obj.phaseId)
      ..writeByte(3)
      ..write(obj.actionType)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
