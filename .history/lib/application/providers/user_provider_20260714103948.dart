import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/services/auth_service.dart';

final userProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final token = await AuthService.getToken();
  if (token == null) return null;
  
  final result = await AuthService.getMe(token);
  if (result['success']) {
    final user = result['user'];
    return {
      'username': user.nickname ?? 'Пользователь',
      'email': user.email ?? '',
      'avatarUrl': user.avatarUrl,
    };
  }
  return null;
});