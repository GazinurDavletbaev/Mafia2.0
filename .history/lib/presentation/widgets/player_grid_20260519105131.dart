import 'package:flutter/material.dart';
import '../../core/logger/app_logger.dart';
import '../../data/local/models/player_model.dart';
import '../../data/local/models/sub_phase.dart';
import 'player_card.dart';
import 'player_timer_type.dart';

class PlayerGrid extends StatelessWidget {
  final List<PlayerModel> players;
  final int? currentSpeaker;
  final PlayerTimerType timerType;
  final SubPhase? currentSubPhase; // добавляем текущую фазу
  final VoidCallback? onTimerComplete;
  final Function(int) onTap;
  final Function(int) onLongPress;

  const PlayerGrid({
    super.key,
    required this.players,
    this.currentSpeaker,
    required this.timerType,
    this.currentSubPhase,
    this.onTimerComplete,
    required this.onTap,
    required this.onLongPress,
  });

  int? _secondsFromType() {
    switch (timerType) {
      case PlayerTimerType.seconds60:
        return 60;
      case PlayerTimerType.seconds30:
        return 30;
      case PlayerTimerType.seconds20:
        return 20;
      case PlayerTimerType.seconds10:
        return 10;
      case PlayerTimerType.none:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedPlayers = List<PlayerModel>.from(players)
      ..sort((a, b) => a.seatNumber.compareTo(b.seatNumber));

    final leftColumn = sortedPlayers
        .where((p) => p.seatNumber <= 5)
        .toList()
        .reversed
        .toList();
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

              // Для фазы contract подсвечиваем чёрных
              final isBlackTeam =
                  currentSubPhase == SubPhase.contract &&
                  (player.role == 'don' || player.role == 'mafia');
              final isSheriff =
                  (currentSubPhase == SubPhase.sheriffLook ||
                      currentSubPhase == SubPhase.sheriffCheck) &&
                  player.role == 'sheriff';
              
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: PlayerCard(
                    player: player,
                    isSpeaking: isSpeaking,
                    isBlackTeam: isBlackTeam,
                    isLeftColumn: true,
                    timerSeconds: timerValue,
                    onTimerComplete: onTimerComplete,
                    isCurrentCandidate: isCurrentCandidate,
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

              // Для фазы contract подсвечиваем чёрных
              final isBlackTeam =
                  currentSubPhase == SubPhase.contract &&
                  (player.role == 'don' || player.role == 'mafia');

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: PlayerCard(
                    player: player,
                    isSpeaking: isSpeaking,
                    isBlackTeam: isBlackTeam,
                    isLeftColumn: false,
                    timerSeconds: timerValue,
                    onTimerComplete: onTimerComplete,
                                        isCurrentCandidate: isCurrentCandidate,

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
