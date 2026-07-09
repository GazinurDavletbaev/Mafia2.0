// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final typeId = 1;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as String,
      nickname: fields[1] as String,
      clubId: fields[2] as String,
      city: fields[3] as String,
      avatarUrl: fields[4] as String,
      email: fields[5] as String?,
      phone: fields[6] as String?,
      phoneVerified: fields[7] == null ? false : fields[7] as bool,
      isEmailVerified: fields[8] == null ? false : fields[8] as bool,
      createdAt: fields[9] as DateTime?,
      firstName: fields[10] as String?,
      lastName: fields[11] as String?,
      country: fields[12] as String?,
      region: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nickname)
      ..writeByte(2)
      ..write(obj.clubId)
      ..writeByte(3)
      ..write(obj.city)
      ..writeByte(4)
      ..write(obj.avatarUrl)
      ..writeByte(5)
      ..write(obj.email)
      ..writeByte(6)
      ..write(obj.phone)
      ..writeByte(7)
      ..write(obj.phoneVerified)
      ..writeByte(8)
      ..write(obj.isEmailVerified)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.firstName)
      ..writeByte(11)
      ..write(obj.lastName)
      ..writeByte(12)
      ..write(obj.country)
      ..writeByte(13)
      ..write(obj.region);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
