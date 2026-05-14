// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phase_stack.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PhaseStackAdapter extends TypeAdapter<PhaseStack> {
  @override
  final typeId = 20;

  @override
  PhaseStack read(BinaryReader reader) {
    reader.readByte();
    return PhaseStack();
  }

  @override
  void write(BinaryWriter writer, PhaseStack obj) {
    writer.writeByte(0);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhaseStackAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
