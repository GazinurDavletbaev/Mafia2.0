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
        : (isDark ? Colors.grey.shade200 : Colors.white);

    final String icon = isNight ? '🌙' : '🌞';

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 28),
          ),
          Positioned(
            bottom: 27,
            right: 27,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isNight ? Colors.blue : Colors.orange.shade700,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.black : Colors.white,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  '$currentDay',
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
