import 'package:flutter/material.dart';
import '../../data/local/models/player_model.dart';
import 'player_card.dart';

class PlayerGrid extends StatelessWidget {
  final List<PlayerModel> players;
  final int? currentSpeaker;
  final Function(int) onTap;
  final Function(int) onLongPress;

  const PlayerGrid({
    super.key,
    required this.players,
    this.currentSpeaker,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final sortedPlayers = List<PlayerModel>.from(players)
      ..sort((a, b) => a.seatNumber.compareTo(b.seatNumber));
    
    // Левая колонка: места 5,4,3,2,1 (сверху вниз)
    final leftColumn = sortedPlayers.where((p) => p.seatNumber <= 5).toList().reversed.toList();
    
    // Правая колонка: места 6,7,8,9,10 (сверху вниз)
    final rightColumn = sortedPlayers.where((p) => p.seatNumber >= 6).toList();
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch, // растягиваем по высоте
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // растягиваем по ширине
            children: leftColumn.asMap().entries.map((entry) {
              final player = entry.value;
              return Expanded( // каждая карточка занимает равное место
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: PlayerCard(
                    player: player,
                    isSpeaking: currentSpeaker == player.seatNumber,
                    isLeftColumn: true,
                    onTap: () => onTap(player.seatNumber),
                    onLongPress: () => onLongPress(player.seatNumber),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // растягиваем по ширине
            children: rightColumn.asMap().entries.map((entry) {
              final player = entry.value;
              return Expanded( // каждая карточка занимает равное место
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: PlayerCard(
                    player: player,
                    isSpeaking: currentSpeaker == player.seatNumber,
                    isLeftColumn: false,
                    onTap: () => onTap(player.seatNumber),
                    onLongPress: () => onLongPress(player.seatNumber),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}