// lib/application/providers/tutorial_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _tipsKey = 'tips_enabled';

// ============================================================
// 🔥 ВКЛЮЧЕНИЕ/ВЫКЛЮЧЕНИЕ ПОДСКАЗОК (ГЛОБАЛЬНО)
// ============================================================
final tipsEnabledProvider = StateNotifierProvider<TipsNotifier, bool>((ref) {
  return TipsNotifier();
});

class TipsNotifier extends StateNotifier<bool> {
  TipsNotifier() : super(true) {
    _loadTips();
  }

  Future<void> _loadTips() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool(_tipsKey) ?? true;
      state = enabled;
    } catch (e) {
      state = true;
    }
  }

  Future<void> setTips(bool enabled) async {
    state = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_tipsKey, enabled);
    } catch (e) {
      // ignore
    }
  }

  void toggleTips() {
    setTips(!state);
  }
}

// ============================================================
// 🔥 ХРАНЕНИЕ СОСТОЯНИЯ КАЖДОЙ ПОДСКАЗКИ (ПОКАЗАНА/НЕ ПОКАЗАНА)
// ============================================================
final tutorialStorageProvider = Provider<TutorialStorage>((ref) {
  return TutorialStorage();
});

class TutorialStorage {
  static const String _prefix = 'tutorial_';

  Future<bool> isStepCompleted(
      {required String screen, required String id}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('${_prefix}${screen}_$id') ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> markStepCompleted(
      {required String screen, required String id}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('${_prefix}${screen}_$id', true);
    } catch (e) {
      // ignore
    }
  }

  Future<void> resetAllTutorials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_prefix));
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> resetScreenTutorials(String screen) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs
          .getKeys()
          .where((key) => key.startsWith('${_prefix}${screen}_'));
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> resetTutorial(String screen, String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('${_prefix}${screen}_$id');
    } catch (e) {
      // ignore
    }
  }
}

// ============================================================
// 🔥 СКРЫТЫЕ ПОДСКАЗКИ (В ПАМЯТИ) — ДЛЯ ВРЕМЕННОГО СКРЫТИЯ
// ============================================================
final dismissedTipsProvider = StateProvider<Set<String>>((ref) => const {});
