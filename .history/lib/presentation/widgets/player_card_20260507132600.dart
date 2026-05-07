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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Аватарка с номером места
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
                            child: Icon(
                              Icons.close,
                              color: Colors.red,
                              size: 30,
                            ),
                          ),
                        ),
                ),
                // Номер места поверх аватарки
                if (player.isAlive)
                  Text(
                    '${player.seatNumber}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Имя игрока под аватаркой
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
            // Индикатор фолов (маленький, под именем)
            if (player.fouls > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
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
              ),
          ],
        ),
      ),
    );
  }
}