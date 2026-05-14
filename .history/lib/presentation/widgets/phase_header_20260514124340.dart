import 'package:flutter/material.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import '../../core/logger/app_logger.dart';

class PhaseHeader extends StatelessWidget {
  final Phase phase;
  final SubPhase subPhase;
  final int currentDay;

  const PhaseHeader({
    super.key,
    required this.phase,
    required this.subPhase,
    required this.currentDay,
  });

  @override
  Widget build(BuildContext context) {
    final title = _getTitle();

    AppLogger.d(
      'PhaseHeader: phase=$phase, subPhase=$subPhase, day=$currentDay, title=$title',
    );

    return Container(
      height: 60,
      color: Colors.grey.shade900,
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getTitle() {
    final subPhaseTitle = _getSubPhaseTitle();

    switch (phase) {
      case Phase.night:
        // Ночь 1 (особенная) или обычная ночь
        if (currentDay == 0) {
          return 'Ночь 1 | $subPhaseTitle';
        } else {
          return 'Ночь ${currentDay + 1} | $subPhaseTitle';
        }
      case Phase.day:
        return 'День $currentDay | $subPhaseTitle';
    }
  }

  String _getSubPhaseTitle() {
    switch (subPhase) {
      case SubPhase.roleDistribution:
        return 'Раздача ролей';
      case SubPhase.contract:
        return 'Договорка';
      case SubPhase.sheriffLook:
        return 'Шериф осматривает';
      case SubPhase.mafiaShoot:
        return 'Стрельба мафии';
      case SubPhase.donCheck:
        return 'Проверка дона';
      case SubPhase.sheriffCheck:
        return 'Проверка шерифа';
      case SubPhase.bestMove:
        return 'Лучший ход';
      case SubPhase.speeches:
        return 'Речи';
      case SubPhase.voting:
        return 'Голосование';
      case SubPhase.revote:
        return 'Переголосование';
      case SubPhase.tieBreak:
        return 'Перестрелка';
      case SubPhase.eliminationVote:
        return 'Голосование за подъём';
      case SubPhase.finalWord:
        return 'Заключительная минута';
      case SubPhase.freeSeating:
        ку
    }
  }
}
