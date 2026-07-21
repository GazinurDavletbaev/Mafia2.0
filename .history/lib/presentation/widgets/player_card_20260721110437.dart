import 'package:flutter/material.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
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

    if (!player.isAlive) {
      backgroundColor = isDark ? Colors.black54 : Colors.grey.shade300;
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
    } else if (isDon) {
      backgroundColor = Colors.teal.shade800;
    } else if (isSpeaking) {
      backgroundColor = Colors.green.shade800;
    } else {
      backgroundColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    }

    final textColor = isDark ? Colors.white : Colors.black87;
    final textColorMuted = isDark ? Colors.grey : Colors.grey.shade600;

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
          SizedBox(
            height: 56,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 28,
                    backgroundImage:
                        player.avatarUrl != null && player.avatarUrl!.isNotEmpty
                            ? NetworkImage(player.avatarUrl!)
                            : null,
                    child: player.avatarUrl == null || player.avatarUrl!.isEmpty
                        ? Image.asset(
                            'assets/mafia_logo.png',
                            width: 30,
                            height: 30,
                            fit: BoxFit.contain,
                          )
                        : null,
                  ),
                ),
                Positioned(
                  top: 0,
                  left: isLeftColumn ? 0 : null,
                  right: isLeftColumn ? null : 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withOpacity(0.7)
                          : Colors.black.withOpacity(0.3),
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
                Positioned(
                  top: 28,
                  left: isLeftColumn ? 0 : null,
                  right: isLeftColumn ? null : 0,
                  child: Visibility(
                    visible: player.fouls > 0,
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
                ),
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
              color: player.isAlive ? textColor : textColorMuted,
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
