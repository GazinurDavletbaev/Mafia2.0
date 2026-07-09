import 'package:hive_ce/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 1)
class User {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nickname;

  @HiveField(2)
  final String clubId;

  @HiveField(3)
  final String city;

  @HiveField(4)
  final String avatarUrl;

  // ✅ Дополнительные поля для авторизации
  @HiveField(5)
  final String? email;

  @HiveField(6)
  final String? phone;

  @HiveField(7)
  final bool phoneVerified;

  @HiveField(8)
  final bool isEmailVerified;

  @HiveField(9)
  final DateTime? createdAt;

  // ✅ НОВЫЕ ПОЛЯ ДЛЯ ПРОФИЛЯ
  @HiveField(10)
  final String? firstName;

  @HiveField(11)
  final String? lastName;

  @HiveField(12)
  final String? country;

  @HiveField(13)
  final String? region;

  const User({
    required this.id,
    required this.nickname,
    required this.clubId,
    required this.city,
    required this.avatarUrl,
    this.email,
    this.phone,
    this.phoneVerified = false,
    this.isEmailVerified = false,
    this.createdAt,
    this.firstName,
    this.lastName,
    this.country,
    this.region,
  });

  // ✅ Фабрика для создания из JSON с сервера
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      nickname: json['username'] ?? '',
      clubId: json['club_id']?.toString() ?? '',
      city: json['city'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      email: json['email'],
      phone: json['phone'],
      phoneVerified: json['phone_verified'] ?? false,
      isEmailVerified: json['is_email_verified'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      firstName: json['first_name'],    // ✅ ДОБАВИТЬ
      lastName: json['last_name'],      // ✅ ДОБАВИТЬ
      country: json['country'],         // ✅ ДОБАВИТЬ
      region: json['region'],           // ✅ ДОБАВИТЬ
    );
  }

  // ✅ Преобразование в JSON для отправки на сервер
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': nickname,
      'club_id': clubId,
      'city': city,
      'avatar_url': avatarUrl,
      'email': email,
      'phone': phone,
      'phone_verified': phoneVerified,
      'is_email_verified': isEmailVerified,
      'created_at': createdAt?.toIso8601String(),
      'first_name': firstName,   // ✅ ДОБАВИТЬ
      'last_name': lastName,     // ✅ ДОБАВИТЬ
      'country': country,        // ✅ ДОБАВИТЬ
      'region': region,          // ✅ ДОБАВИТЬ
    };
  }
}