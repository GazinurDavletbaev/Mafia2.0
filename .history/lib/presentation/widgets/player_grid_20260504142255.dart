import 'package:flutter/material.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mafia_help/presentation/widgets/player_card.dart';

class PlayerGrid extends StatelessWidget {
  final List<PlayerModel> players;
  final int? currentSpeaker;
  final void Function(int seat) onTap;
  final void Function(int seat) onLongPress;

  const PlayerGrid({
    super.key,
    required this.players,
    this.currentSpeaker,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    // Получаем игроков по местам
    final seat1 = _getPlayerBySeat(1);
    final seat2 = _getPlayerBySeat(2);
    final seat3 = _getPlayerBySeat(3);
    final seat4 = _getPlayerBySeat(4);
    final seat5 = _getPlayerBySeat(5);
    final seat6 = _getPlayerBySeat(6);
    final seat7 = _getPlayerBySeat(7);
    final seat8 = _getPlayerBySeat(8);
    final seat9 = _getPlayerBySeat(9);
    final seat10 = _getPlayerBySeat(10);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Левая сторона: места 5, 4, 3, 2, 1 (сверху вниз)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCard(seat5, 5),
                _buildCard(seat4, 4),
                _buildCard(seat3, 3),
                _buildCard(seat2, 2),
                _buildCard(seat1, 1),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Правая сторона: места 6, 7, 8, 9, 10 (сверху вниз)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCard(seat6, 6),
                _buildCard(seat7, 7),
                _buildCard(seat8, 8),
                _buildCard(seat9, 9),
                _buildCard(seat10, 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PlayerModel? _getPlayerBySeat(int seatNumber) {
    try {
      return players.firstWhere((p) => p.seatNumber == seatNumber);
    } catch (_) {
      return null;
    }
  }

  Widget _buildCard(PlayerModel? player, int seatNumber) {
    if (player == null) {
      return Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            '$seatNumber',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return PlayerCard(
      player: player,
      isSpeaking: currentSpeaker == player.seatNumber,
      onTap: () => onTap(player.seatNumber),
      onLongPress: () => onLongPress(player.seatNumber),
    );
  }
}