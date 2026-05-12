import 'package:flutter/material.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import '../../core/logger/app_logger.dart';
import 'timer/timer_overlay.dart';

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
    final timerSeconds = _getTimerSeconds();
    
    AppLogger.d('PhaseHeader: phase=$phase, subPhase=$subPhase, day=$currentDay, title=$title');
    
    if (timerSeconds != null) {
      return TimerOverlay(
        seconds: timerSeconds,
        child: _buildHeader(title),
      );
    }
    
    return _buildHeader(title);
  }

  Widget _buildHeader(String title) {
    return Container(
      height: 70,
      color: Colors.grey.shade900,
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
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
        return 'Ночь | $subPhaseTitle';
      case Phase.day:
        return 'День $currentDay | $subPhaseTitle';
    }
  }

  String _getSubPhaseTitle() {
    switch (subPhase) {
      case SubPhase.roleDistribution: return 'Раздача ролей';
      case SubPhase.contract: return 'Договорка';
      case SubPhase.sheriffLook: return 'Шериф осматривает';
      case SubPhase.mafiaShoot: return 'Стрельба мафии';
      case SubPhase.donCheck: return 'Проверка дона';
      case SubPhase.sheriffCheck: return 'Проверка шерифа';
      case SubPhase.bestMove: return 'Лучший ход';
      case SubPhase.speeches: return 'Речи';
      case SubPhase.voting: return 'Голосование';
      case SubPhase.revote: return 'Переголосование';
      case SubPhase.tieBreak: return 'Перестрелка';
      case SubPhase.eliminationVote: return 'Голосование за подъём';
      case SubPhase.finalWord: return 'Заключительная минута';
    }
  }

  int? _getTimerSeconds() {
    switch (subPhase) {
      case SubPhase.contract: return 60;
      case SubPhase.sheriffLook: return 20;
      case SubPhase.speeches: return 60;
      case SubPhase.revote: return 30;
      case SubPhase.finalWord: return 60;
      case SubPhase.tieBreak: return 30;
      default: return null;
    }
  }
}