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
    final sortedPlayers = List<PlayerModel>.from(players)
      ..sort((a, b) => a.seatNumber.compareTo(b.seatNumber));

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 0.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: sortedPlayers.length,
      itemBuilder: (context, index) {
        final player = sortedPlayers[index];
        return PlayerCard(
          player: player,
          isSpeaking: currentSpeaker == player.seatNumber,
          onTap: () => onTap(player.seatNumber),
          onLongPress: () => onLongPress(player.seatNumber),
        );
      },
    );
  }
}