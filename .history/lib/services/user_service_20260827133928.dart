// lib/services/user_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mafia_help/services/auth_service.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mafia_help/core/config/app_config.dart'; // ← ДОБАВИТЬ

class UserService {
  static String get baseUrl => AppConfig.baseUrl; // ← ИСПОЛЬЗОВАТЬ

  // ============================================================
  // КОЛИЧЕСТВО ПОЛЬЗОВАТЕЛЕЙ
  // ============================================================

  static Future<Map<String, dynamic>> getUserCount() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/count'),
        headers: {'Content-Type': 'application/json'},
      );

      print('📦 getUserCount status: ${response.statusCode}');
      print('📦 getUserCount body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'count': data['count'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'error': 'Ошибка загрузки количества пользователей',
        };
      }
    } catch (e) {
      print('❌ getUserCount error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // ============================================================
  // АВАТАРКА
  // ============================================================

  static Future<Map<String, dynamic>> uploadAvatar(File image) async {
    final token = await AuthService.getToken();
    if (token == null) {
      return {'success': false, 'error': 'Не авторизован'};
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/user/upload-avatar?token=$token'),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        image.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    var response = await request.send();
    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    var json = jsonDecode(responseString);

    if (response.statusCode == 200) {
      return {
        'success': true,
        'avatar_url': json['avatar_url'],
      };
    } else {
      return {
        'success': false,
        'error': json['detail'] ?? 'Ошибка загрузки',
      };
    }
  }

  // ============================================================
  // ПРОФИЛЬ
  // ============================================================

  static Future<Map<String, dynamic>> updateProfile({
    required String nickname,
    String? firstName,
    String? lastName,
    String? country,
    String? city,
    String? region,
    String? avatarUrl,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) {
      return {'success': false, 'error': 'Не авторизован'};
    }

    final response = await http.put(
      Uri.parse('$baseUrl/user/profile?token=$token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nickname': nickname,
        'first_name': firstName,
        'last_name': lastName,
        'country': country,
        'city': city,
        'region': region,
        'avatar_url': avatarUrl,
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
