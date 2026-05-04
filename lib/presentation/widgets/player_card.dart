import 'package:flutter/material.dart';
import 'package:mafia_help/data/local/models/player_model.dart';

class PlayerCard extends StatelessWidget {
  final PlayerModel player;
  final bool isSpeaking;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const PlayerCard({
    super.key,
    required this.player,
    required this.isSpeaking,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: isSpeaking ? Colors.green.shade800 : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Аватарка с номером места
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey.shade600,
                  child: Text(
                    '${player.seatNumber}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Индикатор "мёртв"
                if (!player.isAlive)
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 30,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Имя игрока
            Expanded(
              child: Text(
                player.name,
                style: TextStyle(
                  fontSize: 14,
                  color: player.isAlive ? Colors.white : Colors.grey,
                  decoration: player.isAlive ? null : TextDecoration.lineThrough,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            // Индикатор фолов
            if (player.fouls > 0)
              Container(
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
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}