import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  // 🔥 БАЗОВЫЙ URL ДЛЯ API
  static const String _baseUrlWithPort = 'https://mafiahelp.ru:8001';
  static const String _baseUrlWithoutPort = 'https://mafiahelp.ru';

  static String get baseUrl {
    if (kIsWeb) {
      return _baseUrlWithoutPort; // ← ВЕБ: БЕЗ ПОРТА
    }
    return _baseUrlWithPort; // ← МОБИЛКА/ДЕСКТОП: С ПОРТОМ
  }
}
