import 'package:http/http.dart' as http;

class AuthError {
  final String message;
  final String? field; // например, 'email', 'password', 'username'

  AuthError({required this.message, this.field});

  // Превращаем json-ответ сервера в понятную ошибку
  factory AuthError.fromResponse(http.Response response, {String? field}) {
    try {
      final Map<String, dynamic> json = jsonDecode(response.body);
      // Если сервер отдаёт поле 'detail'
      if (json.containsKey('detail')) {
        return AuthError(message: json['detail'], field: field);
      }
      // Если сервер отдаёт конкретное поле ошибки
      if (json.containsKey('message')) {
        return AuthError(message: json['message'], field: field);
      }
      return AuthError(message: 'Неизвестная ошибка', field: field);
    } catch (e) {
      return AuthError(message: 'Ошибка соединения с сервером', field: field);
    }
  }
}