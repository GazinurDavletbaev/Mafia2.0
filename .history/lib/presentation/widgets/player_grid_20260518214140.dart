import 'package:flutter/material.dart';
import '../../core/logger/app_logger.dart';
import '../../data/local/models/player_model.dart';
import 'player_card.dart';
import 'player_timer_type.dart';

class PlayerGrid extends StatelessWidget {
  final List<PlayerModel> players;
  final int? currentSpeaker;
  final PlayerTimerType timerType;
  final VoidCallback? onTimerComplete;
  final Function(int) onTap;
  final Function(int) onLongPress;
  final bool isBlackTeam = _vm.state.currentSubPhase == SubPhase.contract &&
    (player.role == 'don' || player.role == 'mafia');
  const PlayerGrid({
    super.key,
    required this.players,
    this.currentSpeaker,
    required this.timerType,
    this.onTimerComplete,
    required this.onTap,
    required this.onLongPress,
  });

  int? _secondsFromType() {
    switch (timerType) {
      case PlayerTimerType.seconds60: return 60;
      case PlayerTimerType.seconds30: return 30;
      case PlayerTimerType.seconds20: return 20;
      case PlayerTimerType.seconds10: return 10;
      case PlayerTimerType.none: return null;
    }
  }

  @override
  Widget build(BuildContext context) {
   // AppLogger.d('PlayerGrid.build() → currentSpeaker=$currentSpeaker, timerType=$timerType');
    
    final sortedPlayers = List<PlayerModel>.from(players)
      ..sort((a, b) => a.seatNumber.compareTo(b.seatNumber));
    
    final leftColumn = sortedPlayers.where((p) => p.seatNumber <= 5).toList().reversed.toList();
    final rightColumn = sortedPlayers.where((p) => p.seatNumber >= 6).toList();
    
    final timerSeconds = _secondsFromType();
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: leftColumn.asMap().entries.map((entry) {
              final player = entry.value;
              final isSpeaking = currentSpeaker == player.seatNumber;
              final timerValue = isSpeaking ? timerSeconds : null;
              
       //       AppLogger.d('PlayerGrid left: seat=${player.seatNumber}, isSpeaking=$isSpeaking, timerSeconds=$timerValue');
              
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: PlayerCard(
                    player: player,
                    isSpeaking: isSpeaking,
                    isLeftColumn: true,
                    timerSeconds: timerValue,
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
              final timerValue = isSpeaking ? timerSeconds : null;
              
     //         AppLogger.d('PlayerGrid right: seat=${player.seatNumber}, isSpeaking=$isSpeaking, timerSeconds=$timerValue');
              
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: PlayerCard(
                    player: player,
                    isSpeaking: isSpeaking,
                    isLeftColumn: false,
                    timerSeconds: timerValue,
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