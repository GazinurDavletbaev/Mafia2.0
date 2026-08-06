import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _tipsKey = 'tips_enabled';

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

// 🔥 СКРЫТЫЕ ПОДСКАЗКИ (В ПАМЯТИ)
final dismissedTipsProvider = StateProvider<Set<String>>((ref) => const {});