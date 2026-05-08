import 'package:flutter/material.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import 'timer/timer_overlay.dart';

class PhaseHeader extends StatelessWidget {
  final Phase phase;
  final SubPhase subPhase;

  const PhaseHeader({
    super.key,
    required this.phase,
    required this.subPhase,
  });

  @override
  Widget build(BuildContext context) {
    final title = _getTitle();
    final timerSeconds = _getTimerSeconds();
    
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
    switch (subPhase) {
      case SubPhase.roleDistribution: return 'РАЗДАЧА РОЛЕЙ';
      case SubPhase.contract: return 'ДОГОВОРКА';
      case SubPhase.sheriffLook: return 'ШЕРИФ ОСМАТРИВАЕТ';
      case SubPhase.mafiaShoot: return 'СТРЕЛЬБА МАФИИ';
      case SubPhase.donCheck: return 'ПРОВЕРКА ДОНА';
      case SubPhase.sheriffCheck: return 'ПРОВЕРКА ШЕРИФА';
      case SubPhase.bestMove: return 'ЛУЧШИЙ ХОД';
      case SubPhase.speeches: return 'РЕЧИ';
      case SubPhase.voting: return 'ГОЛОСОВАНИЕ';
      case SubPhase.revote: return 'ПЕРЕГОЛОСОВАНИЕ';
      case SubPhase.eliminationVote: return 'ГОЛОСОВАНИЕ ЗА ПОДЪЁМ';
      case SubPhase.finalWord: return 'ЗАКЛЮЧИТЕЛЬНАЯ МИНУТА';
      case SubPhase.tieBreak: return 'ПЕРЕСТРЕЛКА'; // ✅ добавлено
    }
  }

  int? _getTimerSeconds() {
    switch (subPhase) {
      case SubPhase.contract: return 60;
      case SubPhase.sheriffLook: return 20;
      case SubPhase.speeches: return 60;
      case SubPhase.revote: return 30;
      case SubPhase.finalWord: return 60;
      case SubPhase.tieBreak: return 30; // ✅ добавлено (30 сек на кандидата)
      default: return null;
    }
  }
}