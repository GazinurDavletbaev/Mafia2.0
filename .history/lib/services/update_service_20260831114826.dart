import 'package:flutter/material.dart';
import 'package:flutter_rustore_update/flutter_rustore_update.dart';

class UpdateService {
  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      final info = await RustoreUpdateClient.info();

      print('📦 RuStore update availability: ${info.updateAvailability}');

      if (info.updateAvailability == UpdateAvailability.available) {
        _showUpdateDialog(context);
      } else {
        print('✅ Обновление не требуется');
      }
    } catch (e) {
      print('❌ RuStore check failed: $e');
    }
  }

  static void _showUpdateDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        title: Text(
          'Доступно обновление!',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        content: Text(
          'Новая версия доступна в RuStore.',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Позже',
              style: TextStyle(
                color: isDark ? Colors.grey : Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _startUpdate(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Обновить'),
          ),
        ],
      ),
    );
  }

  static Future<void> _startUpdate(BuildContext context) async {
    try {
      final result = await RustoreUpdateClient.immediate();

      // Просто выводим результат
      print('📦 Update result: $result');

      if (result is int) {
        if (result == 0) {
          print('✅ RuStore обновление запущено');
        } else {
          print('❌ Обновление отменено: $result');
        }
      }
    } catch (e) {
      print('❌ Start update error: $e');
    }
  }
}
