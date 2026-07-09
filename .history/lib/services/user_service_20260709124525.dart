// lib/services/user_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mafia_help/services/auth_service.dart';

class UserService {
  static const String baseUrl = 'http://161.104.46.234:8001';

  static Future<Map<String, dynamic>> updateProfile({
    required String nickname,
    String? firstName,
    String? lastName,
    String? country,
    String? city,
    String? region,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) {
      return {'success': false, 'error': 'Не авторизован'};
    }

    final response = await http.put(
      Uri.parse('$baseUrl/users/profile?token=$token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nickname': nickname,
        'first_name': firstName,
        'last_name': lastName,
        'country': country,
        'city': city,
        'region': region,
      }),
    );

    try {
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'user': data};
      } else {
        return {
          'success': false,
          'error': data['detail'] ?? 'Ошибка обновления',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Ошибка соединения'};
    }
  }
}