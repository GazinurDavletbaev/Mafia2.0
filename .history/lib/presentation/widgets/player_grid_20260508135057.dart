import 'package:flutter/material.dart';
import '../../data/local/models/player_model.dart';
import 'player_card.dart';

class PlayerGrid extends StatelessWidget {
  final List<PlayerModel> players;
  final int? currentSpeaker;
  final int? speechTimerSeconds;
  final VoidCallback? onTimerComplete;
  final Function(int) onTap;
  final Function(int) onLongPress;

  const PlayerGrid({
    super.key,
    required this.players,
    this.currentSpeaker,
    this.speechTimerSeconds,
    this.onTimerComplete,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    AppLogger.d('PlayerGrid: currentSpeaker=$currentSpeaker, speechTimerSeconds=$speechTimerSeconds');
    final sortedPlayers = List<PlayerModel>.from(players)
      ..sort((a, b) => a.seatNumber.compareTo(b.seatNumber));
    
    final leftColumn = sortedPlayers.where((p) => p.seatNumber <= 5).toList().reversed.toList();
    final rightColumn = sortedPlayers.where((p) => p.seatNumber >= 6).toList();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: leftColumn.asMap().entries.map((entry) {
              final player = entry.value;
              final isSpeaking = currentSpeaker == player.seatNumber;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: PlayerCard(
                    player: player,
                    isSpeaking: isSpeaking,
                    isLeftColumn: true,
                    timerSeconds: isSpeaking ? speechTimerSeconds : null,
                    onTimerComplete: onTimerComplete,
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: rightColumn.asMap().entries.map((entry) {
              final player = entry.value;
              final isSpeaking = currentSpeaker == player.seatNumber;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: PlayerCard(
                    player: player,
                    isSpeaking: isSpeaking,
                    isLeftColumn: false,
                    timerSeconds: isSpeaking ? speechTimerSeconds : null,
                    onTimerComplete: onTimerComplete,
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