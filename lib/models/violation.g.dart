// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'violation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ViolationAdapter extends TypeAdapter<Violation> {
  @override
  final typeId = 8;

  @override
  Violation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Violation(
      id: fields[0] as String,
      gameId: fields[1] as String,
      playerSeatNumber: (fields[2] as num).toInt(),
      ruleId: (fields[3] as num).toInt(),
      phaseId: (fields[4] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, Violation obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.gameId)
      ..writeByte(2)
      ..write(obj.playerSeatNumber)
      ..writeByte(3)
      ..write(obj.ruleId)
      ..writeByte(4)
      ..write(obj.phaseId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ViolationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
