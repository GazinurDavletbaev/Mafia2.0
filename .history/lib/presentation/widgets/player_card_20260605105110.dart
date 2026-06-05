import 'package:flutter/material.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../core/logger/app_logger.dart';
import 'timer/timer_overlay.dart';

class PlayerCard extends StatelessWidget {
  final PlayerModel player;
  final bool isSpeaking;
  final bool isBlackTeam;
  final bool isSheriff;
  final bool isLeftColumn;
  final int? timerSeconds;
  final int? maxTimerSeconds; // ← добавить: максимальное время для этой фазы
  final VoidCallback? onTimerComplete;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool isCurrentCandidate;
  final bool isSelectedForBestMove;
  final bool isEliminationCandidate;

  const PlayerCard({
    super.key,
    required this.player,
    required this.isSpeaking,
    this.isBlackTeam = false,
    this.isSheriff = false,
    required this.isLeftColumn,
    this.timerSeconds,
    this.maxTimerSeconds,
    this.onTimerComplete,
    required this.onTap,
    required this.onLongPress,
    this.isCurrentCandidate = false,
    this.isSelectedForBestMove = false,
    this.isEliminationCandidate = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: _buildCard(),
    );
  }

  Widget _buildCard() {
    // Определяем цвет фона
    Color backgroundColor;
    
    if (!player.isAlive) {
      backgroundColor = Colors.black54;
    } else if (isSelectedForBestMove) {
      backgroundColor = Colors.blue.shade800;
    } else if (isCurrentCandidate) {
      backgroundColor = Colors.blue.shade800;
    } else if (isEliminationCandidate) {
      backgroundColor = Colors.blue.shade800;
    } else if (isBlackTeam) {
      backgroundColor = Colors.purple.shade800;
    } else if (isSheriff) {
      backgroundColor = Colors.orange.shade800;
    } else {
      backgroundColor = Colors.grey.shade800;
    }

    // Рассчитываем процент для прогресс-бара
    double percent = 1.0;
    if (isSpeaking && timerSeconds != null && maxTimerSeconds != null && maxTimerSeconds! > 0) {
      percent = (timerSeconds! / maxTimerSeconds!).clamp(0.0, 1.0);
    }

    // Если игрок говорит — оборачиваем в круговой прогресс
    if (isSpeaking && timerSeconds != null && maxTimerSeconds != null) {
      return CircularPercentIndicator(
        radius: 70.0,
        lineWidth: 4.0,
        percent: percent,
        center: _buildCardContent(backgroundColor),
        progressColor: Colors.orange.shade400,
        backgroundColor: Colors.grey.shade700,
        circularStrokeCap: CircularStrokeCap.round,
        animation: true,
        animationDuration: 1000,
      );
    }

    return _buildCardContent(backgroundColor);
  }

  Widget _buildCardContent(Color backgroundColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Контейнер для аватарки и меток (номер, фолы)
          SizedBox(
            height: 56,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Аватарка по центру
                Center(
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.grey.shade600,
                    backgroundImage: const AssetImage('assets/mafia_logo.png'),
                  ),
                ),
                // Номер места на фоне
                Positioned(
                  top: 0,
                  left: isLeftColumn ? 0 : null,
                  right: isLeftColumn ? null : 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${player.seatNumber}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                // Фолы под номером (на фоне)
                if (player.fouls > 0)
                  Positioned(
                    top: 28,
                    left: isLeftColumn ? 0 : null,
                    right: isLeftColumn ? null : 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${player.fouls}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                // Таймер поверх аватарки
                if (isSpeaking && timerSeconds != null)
                  Positioned.fill(
                    child: TimerOverlay(
                      seconds: timerSeconds!,
                      onComplete: onTimerComplete,
                      radius: 28,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            player.name,
            style: TextStyle(
              fontSize: 12,
              color: player.isAlive ? Colors.white : Colors.grey,
              decoration: player.isAlive ? null : TextDecoration.lineThrough,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}