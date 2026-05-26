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
  final List<int> partialBestMove;
  final List<int> tiedSeats;
  final List<int> nominatedSeats;

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
    required this.partialBestMove,
    required this.tiedSeats,
    required this.nominatedSeats,
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
        Expanded(child: _buildColumn(leftColumn, true, timerSeconds)),

        // Фиксированная колонка для кандидатов (всегда 40px)
        // Фиксированная колонка для кандидатов (всегда 40px)
        Container(
          width: 40,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // ← вверх, а не центр
            children: nominatedSeats.isEmpty
                ? [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 20,
                      ), // небольшой отступ сверху
                      child: Icon(
                        Icons.thumb_up,
                        color: Colors.grey.shade600,
                        size: 32,
                      ),
                    ),
                  ]
                : nominatedSeats.map((seat) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade800,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$seat',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }).toList(),
          ),
        ),

        Expanded(child: _buildColumn(rightColumn, false, timerSeconds)),
      ],
    );
  }

  Widget _buildColumn(
    List<PlayerModel> playersList,
    bool isLeftColumn,
    int? timerSeconds,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: playersList.map((player) {
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
              isCurrentCandidate: isCurrentCandidate,
              isSelectedForBestMove: isSelectedForBestMove,
              isEliminationCandidate: isEliminationCandidate,
              isLeftColumn: isLeftColumn,
              timerSeconds: timerValue,
              onTap: () => onTap(player.seatNumber),
              onLongPress: () => onLongPress(player.seatNumber),
            ),
          ),
        );
      }).toList(),
    );
  }
}
