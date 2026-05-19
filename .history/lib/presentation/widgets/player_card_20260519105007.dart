import 'package:flutter/material.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import '../../core/logger/app_logger.dart';
import 'timer/timer_overlay.dart';

class PlayerCard extends StatelessWidget {
  final PlayerModel player;
  final bool isSpeaking;
  final bool isBlackTeam; // для подсветки чёрных в фазе contract
  final bool isSheriff; // для подсветки шерифа в фазе sheriffLook/sheriffCheck
  final bool isLeftColumn;
  final int? timerSeconds;
  final VoidCallback? onTimerComplete;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool isCurrentCandidate;


  const PlayerCard({
    super.key,
    required this.player,
    required this.isSpeaking,
    this.isBlackTeam = false,
    this.isSheriff = false,
    required this.isLeftColumn,
    this.timerSeconds,
    this.onTimerComplete,
    required this.onTap,
    required this.onLongPress,
    re
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
    if (isBlackTeam) {
      backgroundColor = Colors.purple.shade800;
    } else if (isSheriff) {
      backgroundColor = Colors.orange.shade800;
    } else if (isSpeaking) {
      backgroundColor = Colors.green.shade800;
    } else {
      backgroundColor = Colors.grey.shade800;
    }

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
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey.shade600,
                backgroundImage: const AssetImage('assets/mafia_logo.png'),
                child: player.isAlive
                    ? null
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.close, color: Colors.red, size: 30),
                        ),
                      ),
              ),
              if (player.isAlive)
                Positioned(
                  top: 0,
                  left: isLeftColumn ? 0 : null,
                  right: isLeftColumn ? null : 0,
                  child: Container(
                    width: 20,
                    height: 20,
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
          if (player.fouls > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: isLeftColumn
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
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
                ],
              ),
            ),
        ],
      ),
    );
  }
}
