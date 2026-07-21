// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mafia_help/data/local/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://161.104.46.234:8001';

  static Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
    required String phone, // ← теперь required, не nullable
  }) async {
    final body = <String, dynamic>{
      'username': username,
      'password': password,
    };

    if (email.isNotEmpty) body['email'] = email;
    if (phone.isNotEmpty) body['phone'] = phone;

    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> sendPhoneCode(
      {required String phone}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/phone/send-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );

    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> verifyPhone({
    required String phone,
    required String code,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/phone/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
        'code': code,
      }),
    );

    return _handleResponse(response);
  }

// lib/services/auth_service.dart

  static Future<Map<String, dynamic>> forgotPassword(
      {required String email}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token,
        'new_password': newPassword,
      }),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> verifyResetCode({
    required String email,
    required String code,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify-reset-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'code': code,
      }),
    );

    try {
      final data = jsonDecode(response.body);
      print('📦 Ответ verify-reset-code: $data'); // ✅ Отладка

      if (response.statusCode == 200) {
        return {
          'success': true,
          'reset_token': data['reset_token'], // ✅ КЛЮЧ: reset_token
        };
      } else {
        return {
          'success': false,
          'error': data['detail'] ?? 'Неверный код',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Ошибка соединения с сервером',
      };
    }
  }

  static Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final token = await getToken();
    if (token == null) {
      return {'success': false, 'error': 'Не авторизован'};
    }

    final response = await http.post(
      Uri.parse('$baseUrl/auth/change-password?token=$token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'old_password': oldPassword,
        'new_password': newPassword,
      }),
    );
    return _handleResponse(response);
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      // ✅ ОБРАБОТКА 401
      if (response.statusCode == 401) {
        logout();
        return {
          'success': false,
          'error': 'Сессия истекла. Войдите заново.',
          'code': 401,
        };
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'token': data['access_token'],
          'user': data['user'] != null ? User.fromJson(data['user']) : null,
        };
      } else {
        final errorMessage =
            data['detail'] ?? data['message'] ?? 'Ошибка сервера';
        return {
          'success': false,
          'error': errorMessage,
          'code': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Ошибка соединения с сервером',
        'code': 500,
      };
    }
  }

  static Future<Map<String, dynamic>> sendVerificationEmail(
      {required String email}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/send-verification'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getMe(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/profile?token=$token'), // ✅ НОВЫЙ ЭНДПОИНТ
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('📦 getMe response: $data'); // ✅ Отладка
      return {
        'success': true,
        'user': User.fromJson(data),
      };
    } else {
      return {
        'success': false,
        'error': 'Не удалось получить профиль',
      };
    }
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}
