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
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(12),
          border: isSpeaking
              ? Border.all(color: Colors.amber, width: 3)
              : null,
        ),
        child: Stack(
          children: [
            // Основное содержимое
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Аватар или заглушка
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade800,
                  child: Text(
                    '${player.seatNumber}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                // Имя
                Text(
                  player.customName ?? 'Игрок ${player.seatNumber}',
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // Фолы
                if (player.fouls > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${player.fouls}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
              ],
            ),
            // Крестик если мёртв
            if (!player.isAlive)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.close, color: Colors.white, size: 40),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (!player.isAlive) return Colors.grey.shade900;
    if (player.team == 'red') return Colors.red.shade900.withOpacity(0.3);
    if (player.team == 'black') return Colors.grey.shade800;
    return Colors.grey.shade800;
  }
}