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

    // 🔥 ЦВЕТА ДЛЯ ДНЯ И НОЧИ
    final Color backgroundColor = isNight
        ? (isDark ? Colors.grey.shade900 : Colors.grey.shade800)
        : (isDark ? Colors.grey.shade200 : Colors.grey.shade200);

    final Color iconColor =
        isNight ? Colors.yellow.shade300 : Colors.orange.shade700;

    final String icon = isNight ? '🌙' : '☀️';
    final String dayNumber = '$currentDay';

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: isNight
              ? Colors.indigo.shade400.withOpacity(0.5)
              : Colors.blue.shade300.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            icon,
            style: TextStyle(fontSize: 30),
          ),
          Positioned(
            bottom: ,
            right: 0,
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
