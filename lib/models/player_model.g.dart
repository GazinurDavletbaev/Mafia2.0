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
      seatNumber: (fields[0] as num).toInt(),
      name: fields[1] as String,
      team: fields[2] as String,
      role: fields[3] as String,
      isAlive: fields[4] as bool,
      fouls: (fields[5] as num).toInt(),
      isSpeaking: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PlayerModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.seatNumber)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.team)
      ..writeByte(3)
      ..write(obj.role)
      ..writeByte(4)
      ..write(obj.isAlive)
      ..writeByte(5)
      ..write(obj.fouls)
      ..writeByte(6)
      ..write(obj.isSpeaking);
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
