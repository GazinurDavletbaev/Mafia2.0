import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/notification_provider.dart';
import 'package:mafia_help/application/providers/timer_provider.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mdi_plus/mdi_plus.dart';

class AppBottomNav extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Phase? phase;
  final int? currentDay;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.phase,
    this.currentDay,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final navBarTimer = ref.watch(navBarTimerProvider);

    final pendingRequestsAsync = ref.watch(pendingRequestsProvider);
    final pendingCount = pendingRequestsAsync.when(
      data: (count) => count,
      loading: () => 0,
      error: (_, __) => 0,
    );
    print('🔍 AppBottomNav: navBarTimer = $navBarTimer');

    final hasTimer = navBarTimer != null && navBarTimer > 0;
    print('🔍 hasTimer = $hasTimer'); // 🔥 ЛОГ

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 🔥 НАВИГАЦИЯ
        Container(
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 70, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(context, Mdi.home, 'Клуб', 0,
                  badgeCount: pendingCount),
              _buildNavItem(context, Mdi.accountGroupOutline, 'Рассадка', 1),
              _buildNavItem(context, Mdi.brain, 'Игра', 2),
              _buildNavItem(context, Mdi.listBox, 'Протокол', 3),
            ],
          ),
        ),
        // 🔥 ЛИНИЯ ТАЙМЕРА ВОКРУГ НАВБАРА
        if (hasTimer)
          Positioned(
            top: 2,
            left: 68,
            right: 68,
            bottom: 2,
            child: CustomPaint(
              painter: TimerBorderPainter(
                progress: navBarTimer! / 60, // 60 секунд максимум
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index, {
    int badgeCount = 0,
  }) {
    final theme = Theme.of(context);
    final isSelected = currentIndex == index;
    final Color itemColor = isSelected
        ? theme.primaryColor
        : theme.bottomNavigationBarTheme.unselectedItemColor ??
            Colors.grey.shade400;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Icon(icon, size: 22, color: itemColor),
                if (badgeCount > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: theme.colorScheme.surface,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: itemColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🔥 ПАИНТЕР ДЛЯ ЛИНИИ ТАЙМЕРА
class TimerBorderPainter extends CustomPainter {
  final double progress;

  TimerBorderPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(50),
    );

    final path = Path()..addRRect(rect);
    canvas.save();
    final clipRect = Rect.fromLTWH(0, 0, size.width * progress, size.height);
    canvas.clipRect(clipRect);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is TimerBorderPainter) {
      return oldDelegate.progress != progress;
    }
    return true;
  }
}
