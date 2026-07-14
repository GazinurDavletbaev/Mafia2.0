import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/services/auth_service.dart';

final userProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final token = await AuthService.getToken();
  if (token == null) return null;
  
  final result = await AuthService.getMe(token);
  if (result['success']) {
    final user = result['user'];
    return {
      'id': user.id,
      'username': user.nickname ?? 'Пользователь',
      'email': user.email ?? '',
      'avatarUrl': user.avatarUrl,
      'firstName': user.firstName,
      'lastName': user.lastName,
      'country': user.country,
      'city': user.city,
      'region': user.region,
      'phone': user.phone,
      'phoneVerified': user.phoneVerified,
      'isEmailVerified': user.isEmailVerified,
      'createdAt': user.createdAt,
    };
  }
  return null;
});