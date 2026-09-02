// lib/presentation/widgets/tutorial/tutorial_storage.dart
import 'package:shared_preferences/shared_preferences.dart';

class TutorialStorage {
  static const String _prefix = 'tutorial_';
  static const String _resetKey = 'tutorial_reset_required';

  static Future<bool> isShown(String tutorialId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_prefix$tutorialId') ?? false;
  }

  static Future<void> markShown(String tutorialId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix$tutorialId', true);
  }

  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_prefix)) {
        await prefs.remove(key);
      }
    }
    await prefs.setBool(_resetKey, true);
  }

  static Future<bool> needsReset() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_resetKey) ?? false;
  }

  static Future<void> clearResetFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_resetKey);
  }
}
