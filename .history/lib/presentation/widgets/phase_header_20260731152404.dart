import 'package:flutter/material.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import '../../core/logger/app_logger.dart';

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

class _PhaseHeaderState extends State<PhaseHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  String _title = '';

  @override
  void initState() {
    super.initState();
    _title = _getTitle();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: const Offset(0, -0.5),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant PhaseHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phase != widget.phase ||
        oldWidget.subPhase != widget.subPhase ||
        oldWidget.currentDay != widget.currentDay) {
      // 🔥 ОБНОВЛЯЕМ ЗАГОЛОВОК
      setState(() {
        _title = _getTitle();
      });

      // 🔥 ПЕРЕЗАПУСКАЕМ АНИМАЦИЮ
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getTitle() {
    final subPhaseTitle = _getSubPhaseTitle();

    if (widget.subPhase == SubPhase.speeches) {
      if (widget.currentSpeaker != null) {
        return 'День ${widget.currentDay} | речь ${widget.currentSpeaker}';
      } else {
        return 'День ${widget.currentDay} | речи';
      }
    }

    if (widget.subPhase == SubPhase.tieBreak) {
      if (widget.currentSpeaker != null) {
        return 'День ${widget.currentDay} | перестрелка ${widget.currentSpeaker}';
      } else {
        return 'День ${widget.currentDay} | перестрелка';
      }
    }

    switch (widget.phase) {
      case Phase.night:
        return 'Ночь ${widget.currentDay} | $subPhaseTitle';
      case Phase.day:
        return 'День ${widget.currentDay} | $subPhaseTitle';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isNight = widget.phase == Phase.night;

    AppLogger.d(
      'PhaseHeader: phase=${widget.phase}, subPhase=${widget.subPhase}, day=${widget.currentDay}, title=$_title',
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _opacityAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isNight
                      ? Colors.indigo.shade400.withOpacity(0.5)
                      : Colors.orange.shade300.withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  isNight
                      ? const Icon(
                          Icons.nightlight_round,
                          size: 24,
                          color: Color(0xFFFFD700),
                        )
                      : const Icon(
                          Icons.wb_sunny,
                          size: 24,
                          color: Color(0xFFFF6B00),
                        ),
                  const SizedBox(width: 12),
                  Text(
                    _title,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
