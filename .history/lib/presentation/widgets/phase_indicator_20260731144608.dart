import 'package:flutter/material.dart';
import 'package:mafia_help/data/local/models/phase.dart';

class PhaseIndicator extends StatelessWidget {
  final Phase phase;
  final int currentDay;

  const PhaseIndicator({
    super.key,
    required this.phase,
    required this.currentDay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bool isNight = phase == Phase.night;

    final Color backgroundColor = isNight
        ? (isDark ? Colors.grey.shade900 : Colors.grey.shade800)
        : (isDark ? Colors.grey.shade200 : Colors.grey.shade200);

    final String dayNumber = '$currentDay';

    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isNight
              ? Colors.indigo.shade400.withOpacity(0.5)
              : Colors.orange.shade300.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 🔥 ИКОНКА
          isNight
              ? const Icon(
                  Icons.nightlight_round,
                  size: 40,
                  color: Colors., // Золотой
                )
              : const Icon(
                  Icons.wb_sunny,
                  size: 40,
                  color: Color(0xFFFF6B00), // Оранжевый
                ),
          Positioned(
            bottom: 2,
            right: 4,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color:
                    isNight ? Colors.indigo.shade700 : Colors.orange.shade700,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.black : Colors.white,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  dayNumber,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
