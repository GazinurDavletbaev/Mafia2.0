// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phase.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PhaseAdapter extends TypeAdapter<Phase> {
  @override
  final typeId = 5;

  @override
  Phase read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Phase(id: (fields[0] as num).toInt(), name: fields[1] as String);
  }

  @override
  void write(BinaryWriter writer, Phase obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhaseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
