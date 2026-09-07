// lib/presentation/widgets/tutorial/tutorial_manager.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/tip_provider.dart';
import 'tutorial_overlay.dart';
import 'tutorial_storage.dart';
import 'tutorials.dart';

class TutorialManager {
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;

  // 🔥 ОЧЕРЕДЬ ПОДСКАЗОК (теперь глобальная)
  static final List<TutorialStep> _queue = [];
  static int _currentIndex = 0;
  static VoidCallback? _onAllCompleted;
  static BuildContext? _context;
  static WidgetRef? _ref;
  static Map<String, GlobalKey>? _keys;

  static bool get isShowing => _isShowing;

  static Future<void> startTutorials({
    required BuildContext context,
    required String screen,
    required WidgetRef ref,
    Map<String, GlobalKey>? keys,
    VoidCallback? onAllCompleted,
  }) async {
    final tipsEnabled = ref.read(tipsEnabledProvider);
    if (!tipsEnabled) {
      print('ℹ️ Подсказки выключены в настройках');
      onAllCompleted?.call();
      return;
    }

    if (await TutorialStorage.needsReset()) {
      await TutorialStorage.clearResetFlag();
    }

    final allSteps = Tutorials.getSteps(screen);

    final stepsWithKeys = allSteps.map((step) {
      if (keys != null && keys.containsKey(step.id)) {
        return TutorialStep(
          id: step.id,
          title: step.title,
          description: step.description,
          icon: step.icon,
          targetKey: keys[step.id],
          customPosition: step.customPosition,
          width: step.width,
          height: step.height,
          backgroundColor: step.backgroundColor,
          textColor: step.textColor,
        );
      }
      return step;
    }).toList();

    // Фильтруем уже показанные
    final filteredSteps = <TutorialStep>[];
    for (final step in stepsWithKeys) {
      final shown = await TutorialStorage.isShown(step.id);
      if (!shown) {
        filteredSteps.add(step);
      }
    }

    if (filteredSteps.isEmpty) {
      print('🎉 Все подсказки уже показаны');
      onAllCompleted?.call();
      return;
    }

    // 🔥 ДОБАВЛЯЕМ В ОЧЕРЕДЬ (а не заменяем)
    _context = context;
    _ref = ref;
    _keys = keys;
    _queue.addAll(filteredSteps);

    // Если уже показывается — просто добавляем в очередь и выходим
    if (_isShowing) {
      print(
          '📌 Подсказки уже показываются, добавляем в очередь (${filteredSteps.length} шт.)');
      return;
    }

    // Если не показывается — стартуем
    _currentIndex = 0;
    _onAllCompleted = onAllCompleted;
    _showNext();
  }

  static void _showNext() {
    print(
        '🔍 _showNext called, queue length: ${_queue.length}, index: $_currentIndex');

    if (_currentIndex >= _queue.length) {
      print('✅ Все подсказки в очереди показаны!');
      _isShowing = false;
      _queue.clear();
      _currentIndex = 0;
      _onAllCompleted?.call();
      _onAllCompleted = null;
      _context = null;
      _ref = null;
      _keys = null;
      return;
    }

    if (_isShowing && _overlayEntry != null) {
      // Если уже показывается — не создаём новую
      return;
    }

    final step = _queue[_currentIndex];
    _isShowing = true;

    _overlayEntry = OverlayEntry(
      builder: (context) => TutorialOverlay(
        step: step,
        onClose: () async {
          await TutorialStorage.markShown(step.id);
          hide();
          _currentIndex++;

          Future.delayed(const Duration(milliseconds: 300), () {
            _showNext();
          });
        },
      ),
    );

    if (_context != null) {
      Overlay.of(_context!).insert(_overlayEntry!);
    } else {
      print('⚠️ _context = null, не могу показать подсказку');
      _isShowing = false;
    }
  }

  static void hide() {
    if (_overlayEntry != null) {
      try {
        _overlayEntry!.remove();
      } catch (e) {
        print('⚠️ Ошибка при удалении OverlayEntry: $e');
      }
      _overlayEntry = null;
    }
    _isShowing = false;
  }

  static Future<void> resetAllTutorials() async {
    await TutorialStorage.resetAll();
    hide();
    _queue.clear();
    _currentIndex = 0;
    _onAllCompleted = null;
    _context = null;
    _ref = null;
    _keys = null;
  }
}
