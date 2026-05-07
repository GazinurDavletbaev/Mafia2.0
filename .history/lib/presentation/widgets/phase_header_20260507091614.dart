import 'package:flutter/material.dart';
import 'package:mafia_help/data/local/models/phase.dart';

class PhaseHeader extends StatelessWidget {
  final Phase phase;
  final int subPhaseIndex;

  const PhaseHeader({
    super.key,
    required this.phase,
    required this.subPhaseIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade900,
      child: Center(
        child: Text(
          _getTitle(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _getTitle() {
    switch (phase) {
      case Phase.night:
        return subPhaseIndex == 0 ? '🌙 Ночь — Договорка' : '🌙 Ночь — Шериф';
      case Phase.day:
        const titles = ['🗣️ Речи', '🗳️ Голосование', '🔄 Переголосование', '⬆️ Подъём', '⏱️ Заключительная'];
        // Защита от выхода за границы
        final safeIndex = subPhaseIndex.clamp(0, titles.length - 1);
        return titles[safeIndex];
      case Phase.voting:
        return '🗳️ Голосование за подъём';
    }
  }
}