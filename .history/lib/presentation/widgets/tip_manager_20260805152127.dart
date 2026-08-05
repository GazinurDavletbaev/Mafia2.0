import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tip_widget.dart';

class TipManager {
  static void showTip({
    required BuildContext context,
    required WidgetRef ref,
    required String tipId,
    required String message,
    IconData? icon,
  }) {
    final enabled = ref.read(tipsEnabledProvider);
    final dismissed = ref.read(dismissedTipsProvider);

    // Если подсказки выключены или уже скрыта — не показываем
    if (!enabled || dismissed.contains(tipId)) return;

    // Показываем подсказку
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 60,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: TipWidget(
            message: message,
            icon: icon,
            onTap: () {
              // Добавляем в список скрытых
              final current = ref.read(dismissedTipsProvider);
              final updated = {...current, tipId};
              ref.read(dismissedTipsProvider.notifier).state = updated;
              overlayEntry.remove();
            },
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
  }
}