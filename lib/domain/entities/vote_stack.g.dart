// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote_stack.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VoteStackAdapter extends TypeAdapter<VoteStack> {
  @override
  final typeId = 22;

  @override
  VoteStack read(BinaryReader reader) {
    reader.readByte();
    return VoteStack();
  }

  @override
  void write(BinaryWriter writer, VoteStack obj) {
    writer.writeByte(0);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoteStackAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
