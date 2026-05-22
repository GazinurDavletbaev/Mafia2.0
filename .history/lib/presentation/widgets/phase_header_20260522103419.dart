import 'package:flutter/material.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import '../../core/logger/app_logger.dart';

class PhaseHeader extends StatelessWidget {
  final Phase phase;
  final SubPhase subPhase;
  final int currentDay;
  final int? currentSpeaker;

  const PhaseHeader({
    super.key,
    required this.phase,
    required this.subPhase,
    required this.currentDay,
    required this.currentSpeaker,
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

    // Для речей
    if (subPhase == SubPhase.speeches) {
      if (currentSpeaker != null) {
        return 'День $currentDay | речь $currentSpeaker';
      } else {
        return 'День $currentDay | речи';
      }
    }

    // Для перестрелки
    if (subPhase == SubPhase.tieBreak) {
      if (currentSpeaker != null) {
        return 'День $currentDay | перестрелка $currentSpeaker';
      } else {
        return 'День $currentDay | перестрелка';
      }
    }

    // Для всех остальных фаз
    switch (phase) {
      case Phase.night:
        return 'Ночь $currentDay | $subPhaseTitle';
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
      case subPhase.finalWordKill:
        return 'Заключительная минута убитого'
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
        return 'Свободная посадка';
    }
  }
}
