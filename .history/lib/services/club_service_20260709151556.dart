// lib/services/club_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mafia_help/services/auth_service.dart';

class ClubService {
  static const String baseUrl = 'http://161.104.46.234:8001';

  // ============================================================
  // БАЗОВЫЕ МЕТОДЫ
  // ============================================================

  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (data is List) {
          return {
            'success': true,
            'clubs': data.cast<Map<String, dynamic>>(),
          };
        }
        return {'success': true, ...data};
      } else {
        return {
          'success': false,
          'error': data['detail'] ?? data['message'] ?? 'Ошибка сервера',
          'code': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Ошибка соединения с сервером: $e',
        'code': 500,
      };
    }
  }

  // ============================================================
  // КЛУБЫ
  // ============================================================

  static Future<Map<String, dynamic>> getAllClubs() async {
    final token = await AuthService.getToken();
    if (token == null) {
      return {'success': false, 'error': 'Не авторизован'};
    }

    final response = await http.get(
      Uri.parse('$baseUrl/clubs/clubs?token=$token'),
      headers: {'Content-Type': 'application/json'},
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getMyClubs() async {
    final token = await AuthService.getToken();
    if (token == null) {
      return {'success': false, 'error': 'Не авторизован'};
    }

    final response = await http.get(
      Uri.parse('$baseUrl/clubs/my-clubs?token=$token'),
      headers: {'Content-Type': 'application/json'},
    );

    try {
      final data = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (data is List) {
          return {
            'success': true,
            'clubs': data.cast<Map<String, dynamic>>(),
          };
        }
        return {'success': true, 'clubs': data};
      } else {
        return {
          'success': false,
          'error': data['detail'] ?? data['message'] ?? 'Ошибка сервера',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Ошибка соединения: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getCurrentClub() async {
    final result = await getMyClubs();
    if (result['success'] &&
        result['clubs'] != null &&
        result['clubs'].isNotEmpty) {
      return {
        'success': true,
        'club': result['clubs'][0],
      };
    }
    return {'success': true, 'club': null};
  }

  static Future<Map<String, dynamic>> getClub(int clubId) async {
    final token = await AuthService.getToken();
    if (token == null) {
      return {'success': false, 'error': 'Не авторизован'};
    }

    final response = await http.get(
      Uri.parse('$baseUrl/clubs/clubs/$clubId?token=$token'),
      headers: {'Content-Type': 'application/json'},
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> createClub({
    required String title,
    String? city,
    String? description,
    String? country,
    String? region,
    String? vk,
    String? telegram,
    String? twitch,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) {
      return {'success': false, 'error': 'Не авторизован'};
    }

    final response = await http.post(
      Uri.parse('$baseUrl/clubs/clubs?token=$token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'city': city,
        'description': description,
        'country': country,
        'region': region,
        'vk': vk,
        'telegram': telegram,
        'twitch': twitch,
      }),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> joinClub(int clubId) async {
    final token = await AuthService.getToken();
    if (token == null) {
      return {'success': false, 'error': 'Не авторизован'};
    }

    final response = await http.post(
      Uri.parse('$baseUrl/clubs/clubs/$clubId/join?token=$token'),
      headers: {'Content-Type': 'application/json'},
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> leaveClub(int clubId) async {
    final token = await AuthService.getToken();
    if (token == null) {
      return {'success': false, 'error': 'Не авторизован'};
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/clubs/$clubId/leave?token=$token'), // ✅ Токен в URL
      headers: {
        'Content-Type': 'application/json',
      },
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> dissolveClub(int clubId) async {
    final token = await AuthService.getToken();
    if (token == null) {
      return {'success': false, 'error': 'Не авторизован'};
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/clubs/$clubId/leave?token=$token'), // ✅ уже есть
      headers: {'Content-Type': 'application/json'},
    );
    return _handleResponse(response);
  }

  // ============================================================
  // ЗАЯВКИ
  // ============================================================

  static Future<Map<String, dynamic>> getClubRequests(int clubId) async {
    final token = await AuthService.getToken();
    if (token == null) {
      return {'success': false, 'error': 'Не авторизован'};
    }

    final response = await http.get(
      Uri.parse('$baseUrl/clubs/clubs/$clubId/requests?token=$token'),
      headers: {'Content-Type': 'application/json'},
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> approveRequest(int requestId) async {
    final token = await AuthService.getToken();
    if (token == null) {
      return {'success': false, 'error': 'Не авторизован'};
    }

    final response = await http.post(
      Uri.parse(
          '$baseUrl/clubs/clubs/requests/$requestId/approve?token=$token'),
      headers: {'Content-Type': 'application/json'},
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> rejectRequest(int requestId) async {
    final token = await AuthService.getToken();
    if (token == null) {
      return {'success': false, 'error': 'Не авторизован'};
    }

    final response = await http.post(
      Uri.parse('$baseUrl/clubs/clubs/requests/$requestId/reject?token=$token'),
      headers: {'Content-Type': 'application/json'},
    );
    return _handleResponse(response);
  }

  // ============================================================
  // УЧАСТНИКИ
  // ============================================================

  static Future<Map<String, dynamic>> getClubMembers(int clubId) async {
    final token = await AuthService.getToken();
    if (token == null) {
      return {'success': false, 'error': 'Не авторизован'};
    }

    final response = await http.get(
      Uri.parse('$baseUrl/clubs/clubs/$clubId/members?token=$token'),
      headers: {'Content-Type': 'application/json'},
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> removeMember(
      int clubId, int userId) async {
    final token = await AuthService.getToken();
    if (token == null) {
      return {'success': false, 'error': 'Не авторизован'};
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/clubs/clubs/$clubId/members/$userId?token=$token'),
      headers: {'Content-Type': 'application/json'},
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> promoteToJudge(
      int clubId, int userId) async {
    final token = await AuthService.getToken();
    if (token == null) {
      return {'success': false, 'error': 'Не авторизован'};
    }

    final response = await http.post(
      Uri.parse('$baseUrl/clubs/clubs/$clubId/promote/$userId?token=$token'),
      headers: {'Content-Type': 'application/json'},
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> demoteFromJudge(
      int clubId, int userId) async {
    final token = await AuthService.getToken();
    if (token == null) {
      return {'success': false, 'error': 'Не авторизован'};
    }

    final response = await http.post(
      Uri.parse('$baseUrl/clubs/clubs/$clubId/demote/$userId?token=$token'),
      headers: {'Content-Type': 'application/json'},
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getPendingRequestsCount() async {
    final token = await AuthService.getToken();
    if (token == null) {
      return {'success': false, 'error': 'Не авторизован'};
    }

    final response = await http.get(
      Uri.parse('$baseUrl/clubs/requests/pending-count?token=$token'),
      headers: {'Content-Type': 'application/json'},
    );
    return _handleResponse(response);
  }

  // ========== РЕЙТИНГ КЛУБА ==========
  static Future<Map<String, dynamic>> getClubRating({
    required int clubId,
    required int month,
    required int year,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) {
      return {'success': false, 'error': 'Не авторизован'};
    }

    final response = await http.get(
      Uri.parse(
          '$baseUrl/clubs/clubs/$clubId/rating?token=$token&month=$month&year=$year'),
      headers: {'Content-Type': 'application/json'},
    );
    return _handleResponse(response);
  }

  // ============================================================
  // АДМИН
  // ============================================================

  static Future<Map<String, dynamic>> verifyClub(int clubId) async {
    final token = await AuthService.getToken();
    if (token == null) {
      return {'success': false, 'error': 'Не авторизован'};
    }

    final response = await http.post(
      Uri.parse('$baseUrl/clubs/clubs/$clubId/verify?token=$token'),
      headers: {'Content-Type': 'application/json'},
    );
    return _handleResponse(response);
  }
  
}
