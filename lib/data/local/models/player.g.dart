// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayerAdapter extends TypeAdapter<Player> {
  @override
  final typeId = 3;

  @override
  Player read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Player(
      id: fields[0] as String,
      gameId: fields[1] as String,
      userId: fields[2] as String?,
      customName: fields[3] as String?,
      seatNumber: (fields[4] as num).toInt(),
      roleId: (fields[5] as num).toInt(),
      score: (fields[6] as num).toInt(),
      isAlive: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Player obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.gameId)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.customName)
      ..writeByte(4)
      ..write(obj.seatNumber)
      ..writeByte(5)
      ..write(obj.roleId)
      ..writeByte(6)
      ..write(obj.score)
      ..writeByte(7)
      ..write(obj.isAlive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
