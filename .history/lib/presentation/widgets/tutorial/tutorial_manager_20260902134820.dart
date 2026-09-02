// lib/presentation/widgets/tutorial/tutorial_manager.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/tip_provider.dart';
import 'tutorial_overlay.dart';
import 'tutorial_storage.dart';
import 'tutorials/base_tutorial.dart';

class TutorialManager {
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;
  static List<TutorialStep> _currentQueue = [];
  static int _currentIndex = 0;
  static VoidCallback? _onAllCompleted;

  static bool get isShowing => _isShowing;

  static Future<void> startTutorials({
    required BuildContext context,
    required TutorialGroup tutorialGroup,
    required WidgetRef ref,
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

    final filteredSteps = <TutorialStep>[];
    for (final step in tutorialGroup.steps) {
      final shown = await TutorialStorage.isShown(step.id);
      if (!shown) {
        final shouldShow = await tutorialGroup.shouldShow(step.id);
        if (shouldShow) {
          filteredSteps.add(step);
        }
      }
    }

    if (filteredSteps.isEmpty) {
      onAllCompleted?.call();
      return;
    }

    _currentQueue = filteredSteps;
    _currentIndex = 0;
    _onAllCompleted = onAllCompleted;

    _showNext(context);
  }

  static void _showNext(BuildContext context) {
    if (_currentIndex >= _currentQueue.length) {
      _isShowing = false;
      _onAllCompleted?.call();
      return;
    }

    if (_isShowing) {
      hide();
    }

    final step = _currentQueue[_currentIndex];
    _isShowing = true;

    _overlayEntry = OverlayEntry(
      builder: (context) => TutorialOverlay(
        step: step,
        onClose: () async {
          await TutorialStorage.markShown(step.id);
          hide();
          _currentIndex++;
          Future.delayed(const Duration(milliseconds: 300), () {
            if (_currentIndex < _currentQueue.length) {
              _showNext(context);
            } else {
              _isShowing = false;
              _onAllCompleted?.call();
            }
          });
        },
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  static void hide() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    _isShowing = false;
  }

  static Future<void> resetAllTutorials() async {
    await TutorialStorage.resetAll();
    hide();
    _currentQueue = [];
    _currentIndex = 0;
  }
}
