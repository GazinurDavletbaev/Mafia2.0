// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayerModelAdapter extends TypeAdapter<PlayerModel> {
  @override
  final typeId = 13;

  @override
  PlayerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlayerModel(
      id: fields[0] as String,
      seatNumber: (fields[1] as num).toInt(),
      name: fields[2] as String,
      team: fields[3] as String,
      role: fields[4] as String,
      isAlive: fields[5] as bool,
      fouls: (fields[6] as num).toInt(),
      isSpeaking: fields[7] as bool,
      gameId: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PlayerModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.seatNumber)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.team)
      ..writeByte(4)
      ..write(obj.role)
      ..writeByte(5)
      ..write(obj.isAlive)
      ..writeByte(6)
      ..write(obj.fouls)
      ..writeByte(7)
      ..write(obj.isSpeaking)
      ..writeByte(8)
      ..write(obj.gameId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
