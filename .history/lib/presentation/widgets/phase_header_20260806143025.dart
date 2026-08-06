import 'package:flutter/material.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';

class PhaseHeader extends StatefulWidget {
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
  State<PhaseHeader> createState() => _PhaseHeaderState();
}

class _PhaseHeaderState extends State<PhaseHeader> {
  String _title = '';

  @override
  void initState() {
    super.initState();
    _title = _getTitle();
  }

  @override
  void didUpdateWidget(covariant PhaseHeader oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.phase != widget.phase ||
        oldWidget.subPhase != widget.subPhase ||
        oldWidget.currentDay != widget.currentDay ||
        oldWidget.currentSpeaker != widget.currentSpeaker) {
      setState(() {
        _title = _getTitle();
      });

      // 🔥 ПОКАЗЫВАЕМ SNACKBAR
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSnackBar(_title);
      });
    }
  }

  void _showSnackBar(String title) {
    final isNight = widget.phase == Phase.night;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 280,
        left: 0,
        right: 0,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 140, // 🔥 МАКСИМАЛЬНАЯ ШИРИНА 220
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.deepPurple.withOpacity(0.5)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isNight
                      ? Colors.indigo.shade400.withOpacity(0.5)
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min, // 🔥 ТОЛЬКО ПО КОНТЕНТУ
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      softWrap: true, // 🔥 ПЕРЕНОС
                      maxLines: 3, // 🔥 МАКСИМУМ 3 СТРОКИ
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  String _getTitle() {
    final subPhaseTitle = _getSubPhaseTitle();

    if (widget.subPhase == SubPhase.speeches) {
      if (widget.currentSpeaker != null) {
        return 'Речь ${widget.currentSpeaker}';
      } else {
        return 'Речи';
      }
    }

    if (widget.subPhase == SubPhase.tieBreak) {
      if (widget.currentSpeaker != null) {
        return 'Перестрелка ${widget.currentSpeaker}';
      } else {
        return 'Перестрелка';
      }
    }

    switch (widget.phase) {
      case Phase.night:
        return subPhaseTitle;
      case Phase.day:
        return subPhaseTitle;
    }
  }

  String _getSubPhaseTitle() {
    switch (widget.subPhase) {
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
      case SubPhase.finalWordKill:
        return 'Заключительная минута убитого';
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

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // 🔥 НИЧЕГО НЕ РИСУЕМ
  }
}
