// lib/services/club_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mafia_help/services/auth_service.dart';
import 'package:http_parser/http_parser.dart'; // ✅ ДОБАВИТЬ

class ClubService {
  static const String baseUrl = 'http://161.104.46.234:8001';

  // ============================================================
  // БАЗОВЫЕ МЕТОДЫ
  // ============================================================

  static Future<Map<String, dynamic>> updateClub({
    required int clubId,
    String? title,
    String? description,
    String? city,
    String? country,
    String? region,
    String? logoUrl,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) {
      return {'success': false, 'error': 'Не авторизован'};
    }

    final response = await http.put(
      Uri.parse('$baseUrl/clubs/$clubId?token=$token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'description': description,
        'city': city,
        'country': country,
        'region': region,
        'logo_url': logoUrl,
      }),
    );

    try {
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'club': data};
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
      Uri.parse('$baseUrl/clubs?token=$token'),
      headers: {'Content-Type': 'application/json'},
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getMyClub() async {
    final token = await AuthService.getToken();
    if (token == null) {
      return {'success': false, 'error': 'Не авторизован'};
    }

    final response = await http.get(
      Uri.parse('$baseUrl/clubs/my-club?token=$token'),
      headers: {'Content-Type': 'application/json'},
    );

    print('📦 getMyClub status: ${response.statusCode}');
    print('📦 getMyClub body: ${response.body}');

    try {
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // ✅ Сервер возвращает клуб напрямую
        return {
          'success': true,
          'club': data, // ✅ НЕ data['club']
        };
      } else {
        return {
          'success': false,
          'error': data['detail'] ?? 'Ошибка',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Ошибка соединения'};
    }
  }

  static Future<Map<String, dynamic>> getCurrentClub() async {
    final result = await getMyClub();
    if (result['success'] && result['club'] != null) {
      return {
        'success': true,
        'club': result['club'],
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
      Uri.parse('$baseUrl/clubs/$clubId?token=$token'),
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
      Uri.parse('$baseUrl/clubs?token=$token'),
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

    try {
      final data = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'id': data['id'], // ✅ ЕСТЬ
          'club': data, // ✅ ВЕСЬ КЛУБ
        };
      } else {
        return {
          'success': false,
          'error': data['detail'] ?? 'Ошибка создания',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Ошибка соединения'};
    }
  }

  static Future<Map<String, dynamic>> joinClub(int clubId) async {
    final token = await AuthService.getToken();
    if (token == null) {
      return {'success': false, 'error': 'Не авторизован'};
    }

    final response = await http.post(
      Uri.parse('$baseUrl/clubs/$clubId/join?token=$token'),
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
      Uri.parse('$baseUrl/clubs/$clubId/requests?token=$token'),
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
      Uri.parse('$baseUrl/clubs/requests/$requestId/approve?token=$token'),
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
      Uri.parse('$baseUrl/clubs/requests/$requestId/reject?token=$token'),
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
      Uri.parse('$baseUrl/clubs/$clubId/members?token=$token'),
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
      Uri.parse('$baseUrl/clubs/$clubId/members/$userId?token=$token'),
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
      Uri.parse('$baseUrl/clubs/$clubId/promote/$userId?token=$token'),
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
      Uri.parse('$baseUrl/clubs/$clubId/demote/$userId?token=$token'),
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
          '$baseUrl/clubs/$clubId/rating?token=$token&month=$month&year=$year'),
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
      Uri.parse('$baseUrl/clubs/$clubId/verify?token=$token'),
      headers: {'Content-Type': 'application/json'},
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> uploadClubLogo({
    required int clubId,
    required File image,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) {
      return {'success': false, 'error': 'Не авторизован'};
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(
          '$baseUrl/clubs/$clubId/upload-logo?token=$token'), // ✅ ДВАЖДЫ /clubs
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

    print('📦 uploadClubLogo response: $json');

    if (response.statusCode == 200) {
      return {
        'success': true,
        'logo_url': json['logo_url'],
      };
    } else {
      return {
        'success': false,
        'error': json['detail'] ?? 'Ошибка загрузки',
      };
    }
  }
}
