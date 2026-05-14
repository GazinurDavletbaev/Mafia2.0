// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'speech_stack.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SpeechStackAdapter extends TypeAdapter<SpeechStack> {
  @override
  final typeId = 21;

  @override
  SpeechStack read(BinaryReader reader) {
    reader.readByte();
    return SpeechStack();
  }

  @override
  void write(BinaryWriter writer, SpeechStack obj) {
    writer.writeByte(0);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpeechStackAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
