// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_ui_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayerUIModelAdapter extends TypeAdapter<PlayerUIModel> {
  @override
  final typeId = 12;

  @override
  PlayerUIModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlayerUIModel(
      seatNumber: (fields[0] as num).toInt(),
      name: fields[1] as String,
      avatarUrl: fields[2] as String?,
      isAlive: fields[3] as bool,
      fouls: (fields[4] as num).toInt(),
      isSpeaking: fields[5] as bool,
      role: fields[6] as String?,
      team: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PlayerUIModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.seatNumber)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.avatarUrl)
      ..writeByte(3)
      ..write(obj.isAlive)
      ..writeByte(4)
      ..write(obj.fouls)
      ..writeByte(5)
      ..write(obj.isSpeaking)
      ..writeByte(6)
      ..write(obj.role)
      ..writeByte(7)
      ..write(obj.team);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerUIModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
