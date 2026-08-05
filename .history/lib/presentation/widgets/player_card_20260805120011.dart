import 'package:flutter/material.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mdi_plus/mdi_plus.dart';
import '../../core/logger/app_logger.dart';
import 'timer/timer_overlay.dart';

class PlayerCard extends StatelessWidget {
  final PlayerModel player;
  final bool isSpeaking;
  final bool isBlackTeam;
  final bool isSheriff;
  final bool isDon;
  final bool isLeftColumn;
  final int? timerSeconds;
  final VoidCallback? onTimerComplete;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onSwipeUp;
  final VoidCallback onSwipeDown;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final bool isCurrentCandidate;
  final bool isSelectedForBestMove;
  final bool isEliminationCandidate;

  const PlayerCard({
    super.key,
    required this.player,
    required this.isSpeaking,
    this.isBlackTeam = false,
    this.isSheriff = false,
    this.isDon = false,
    required this.isLeftColumn,
    this.timerSeconds,
    this.onTimerComplete,
    required this.onTap,
    required this.onLongPress,
    required this.onSwipeUp,
    required this.onSwipeDown,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    this.isCurrentCandidate = false,
    this.isSelectedForBestMove = false,
    this.isEliminationCandidate = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      onHorizontalDragEnd: _handleHorizontalSwipe,
      onVerticalDragEnd: _handleVerticalSwipe,
      child: _buildCard(context),
    );
  }

  void _handleHorizontalSwipe(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dx;
    if (velocity > 500) {
      onSwipeRight();
    } else if (velocity < -500) {
      onSwipeLeft();
    }
  }

  void _handleVerticalSwipe(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dy;
    if (velocity > 500) {
      onSwipeDown();
    } else if (velocity < -500) {
      onSwipeUp();
    }
  }

  Widget _buildCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color backgroundColor;

    if (isSelectedForBestMove) {
      backgroundColor = Colors.blue.withOpacity(0.5);
    } else if (!player.isAlive) {
      backgroundColor = isDark ? Colors.black54 : Colors.white;
    } else if (isBlackTeam) {
      backgroundColor = Colors.deepPurple.withOpacity(0.5);
    } else if (isSheriff) {
      backgroundColor = Colors.deepOrange.withOpacity(0.5);
    } else if (isDon) {
      backgroundColor = Colors.black.withOpacity(0.9);
    } else if (isSpeaking) {
      backgroundColor = Colors.green.withOpacity(0.5);
    } else if (isCurrentCandidate) {
      backgroundColor = Colors.blue.withOpacity(0.5);
    } else if (isEliminationCandidate) {
      backgroundColor = Colors.blue.withOpacity(0.5);
    } else {
      backgroundColor = isDark ? Colors.black : Colors.white;
    }

    final textColor = isDark ? Colors.white : Colors.black87;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final cardHeight = constraints.maxHeight;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // 🔥 ОСНОВНАЯ КАРТОЧКА
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 60,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // 🔥 АВАТАРКА С БЕЙДЖАМИ
                        Center(
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade300,
                                backgroundImage: player.avatarUrl != null &&
                                        player.avatarUrl!.isNotEmpty
                                    ? NetworkImage(player.avatarUrl!)
                                    : null,
                                child: player.avatarUrl == null ||
                                        player.avatarUrl!.isEmpty
                                    ? Icon(
                                        Icons.no_photography,
                                        size: 40,
                                        color: Colors.grey.shade400,
                                      )
                                    : null,
                              ),
                              // 🔥 БЕЙДЖ С НОМЕРОМ МЕСТА (ВВЕРХУ СЛЕВА)
                              Positioned(
                                top: -12,
                                left: -12,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // 🔥 ФОН
                                    Container(
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade500,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isDark
                                              ? Colors.black
                                              : Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${player.seatNumber}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // 🔥 ИКОНКА "МЁРТВ" ПОВЕРХ БЕЙДЖА
                                    if (!player.isAlive)
                                      Container(
                                        width: 35,
                                        height: 35,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.block,
                                          size: 35,
                                          color: Colors.black,
                                        ),
                                      ),
                                    // 🔥 ТАЙМЕР ПОВЕРХ БЕЙДЖА (ЕСЛИ ГОВОРИТ)
                                    if (isSpeaking && timerSeconds != null)
                                      TimerOverlay(
                                        seconds: timerSeconds!,
                                        onComplete: onTimerComplete,
                                        width: 35,
                                        height: 35,
                                        borderRadius: 50,
                                      ),
                                  ],
                                ),
                              ),
                              // 🔥 БЕЙДЖ С ФОЛАМИ (ВВЕРХУ СПРАВА)
                              if (player.fouls > 0)
                                Positioned(
                                  top: -4,
                                  right: -4,
                                  child: Container(
                                    width: 22,
                                    height: 22,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${player.fouls}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              // 🔥 БЕЙДЖ С ТЕХ. ФОЛАМИ (СНИЗУ СПРАВА)
                              if (player.techFouls > 0)
                                Positioned(
                                  bottom: -4,
                                  right: -4,
                                  child: Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isDark
                                            ? Colors.black
                                            : Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Mdi.alertCircleOutline, // 🔥 ИКОНКА ТЕХ. ФОЛА
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    player.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
