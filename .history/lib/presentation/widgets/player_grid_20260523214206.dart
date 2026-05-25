import 'package:flutter/material.dart';
import '../../core/logger/app_logger.dart';
import '../../data/local/models/player_model.dart';
import '../../data/local/models/sub_phase.dart';
import '../../domain/helpers/vote_controller.dart';
import '../state/game_state.dart';
import 'player_card.dart';
import 'player_timer_type.dart';

class PlayerGrid extends StatelessWidget {
  final List<PlayerModel> players;
  final int? currentSpeaker;
  final PlayerTimerType timerType;
  final SubPhase? currentSubPhase;
  final Function(int) onTap;
  final Function(int) onLongPress;
  final bool isVotingActive;
  final VoteController? voteController;
  final List<int> partialBestMove; // ← добавить
  final List<int> tiedSeats;

  const PlayerGrid({
    super.key,
    required this.players,
    this.currentSpeaker,
    required this.timerType,
    this.currentSubPhase,
    required this.onTap,
    required this.onLongPress,
    required this.isVotingActive,
    this.voteController,
    required this.partialBestMove, // ← добавить
    required this.tiedSeats,
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
              final isBlackTeam =
                  currentSubPhase == SubPhase.contract &&
                  (player.role == 'don' || player.role == 'mafia');
              final isSheriff =
                  (currentSubPhase == SubPhase.sheriffLook ||
                      currentSubPhase == SubPhase.sheriffCheck) &&
                  player.role == 'sheriff';
              final isCurrentCandidate =
                  isVotingActive &&
                  voteController?.currentSeat == player.seatNumber;

              // ← добавить подсветку для bestMove
              final isSelectedForBestMove =
                  currentSubPhase == SubPhase.bestMove &&
                  partialBestMove.contains(player.seatNumber);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: PlayerCard(
                    player: player,
                    isSpeaking: isSpeaking,
                    isBlackTeam: isBlackTeam,
                    isSheriff: isSheriff,
                    isCurrentCandidate: isCurrentCandidate,
                    isSelectedForBestMove: isSelectedForBestMove, // ← добавить
                    isLeftColumn: true,
                    timerSeconds: timerValue,
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
              final isBlackTeam =
                  currentSubPhase == SubPhase.contract &&
                  (player.role == 'don' || player.role == 'mafia');
              final isSheriff =
                  (currentSubPhase == SubPhase.sheriffLook ||
                      currentSubPhase == SubPhase.sheriffCheck) &&
                  player.role == 'sheriff';
              final isCurrentCandidate =
                  isVotingActive &&
                      voteController?.currentSeat == player.seatNumber ||
                  currentSubPhase == SubPhase.tieBreak &&
                      currentSpeaker == player.seatNumber ||
                  currentSubPhase == SubPhase.finalWordKill &&
                      currentSpeaker == player.seatNumber;

              // ← добавить подсветку для bestMove
              final isSelectedForBestMove =
                  currentSubPhase == SubPhase.bestMove &&
                  partialBestMove.contains(player.seatNumber);
              final isEliminationCandidate =
                  currentSubPhase == SubPhase.eliminationVote &&
                  tiedSeats.contains(player.seatNumber);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: PlayerCard(
                    player: player,
                    isSpeaking: isSpeaking,
                    isBlackTeam: isBlackTeam,
                    isSheriff: isSheriff,
isCurrentCandidate: isCurrentCandidate || isEliminationCandidate,                    isSelectedForBestMove: isSelectedForBestMove, // ← добавить
                    isLeftColumn: false,
                    timerSeconds: timerValue,
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
