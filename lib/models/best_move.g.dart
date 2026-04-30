// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'best_move.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BestMoveAdapter extends TypeAdapter<BestMove> {
  @override
  final typeId = 10;

  @override
  BestMove read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BestMove(
      id: fields[0] as String,
      gameId: fields[1] as String,
      killedSeatNumber: (fields[2] as num).toInt(),
      suspectSeat1: (fields[3] as num).toInt(),
      suspectSeat2: (fields[4] as num).toInt(),
      suspectSeat3: (fields[5] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, BestMove obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.gameId)
      ..writeByte(2)
      ..write(obj.killedSeatNumber)
      ..writeByte(3)
      ..write(obj.suspectSeat1)
      ..writeByte(4)
      ..write(obj.suspectSeat2)
      ..writeByte(5)
      ..write(obj.suspectSeat3);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BestMoveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
