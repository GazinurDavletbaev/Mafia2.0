import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  // 🔥 БАЗОВЫЙ URL ДЛЯ API
  static const String _baseUrlWithPort = 'http://161.104.46.234:8001';
  static const String _baseUrlWithoutPort = 'http://161.104.46.234';

  static String get baseUrl {
    if (kIsWeb) {
      return _baseUrlWithoutPort; // ← ВЕБ: БЕЗ ПОРТА
    }
    return _baseUrlWithPort; // ← МОБИЛКА/ДЕСКТОП: С ПОРТОМ
  }
}
