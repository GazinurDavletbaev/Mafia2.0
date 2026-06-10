import 'package:flutter/material.dart';
import 'package:mafia_help/presentation/widgets/player_grid/day_column.dart';
import 'package:mafia_help/presentation/widgets/player_grid/night_actions_column.dart';
import 'package:mafia_help/presentation/widgets/player_card.dart';
import 'package:mafia_help/presentation/widgets/player_timer_type.dart';
import '../../../data/local/models/player_model.dart';
import '../../../data/local/models/sub_phase.dart';
import '../../../domain/helpers/vote_controller.dart';

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
  final List<int> nightActions;
  final int currentDay;
  final int eliminationVotes;
  final Function(int) onSwipeUp;
  final Function(int) onSwipeDown;
  final Function(int) onSwipeLeft;
  final Function(int) onSwipeRight;

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
    required this.nightActions,
    required this.currentDay,
    required this.eliminationVotes,
    required this.onSwipeUp,
    required this.onSwipeDown,
    required this.onSwipeLeft,
    required this.onSwipeRight,
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

    final isNight = currentSubPhase == SubPhase.mafiaShoot ||
        currentSubPhase == SubPhase.donCheck ||
        currentSubPhase == SubPhase.sheriffCheck;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _buildColumn(leftColumn, true, timerSeconds)),
        isNight
            ? NightActionsColumn(
                currentSubPhase: currentSubPhase,
                currentDay: currentDay,
                nightActions: nightActions,
              )
            : DayColumn(
                currentSubPhase: currentSubPhase!,
                nominatedSeats: nominatedSeats,
                tiedSeats: tiedSeats,
                partialBestMove: partialBestMove,
                eliminationVotes: eliminationVotes,
                currentSpeaker: currentSpeaker,
                voteController: voteController,
              ),
        Expanded(child: _buildColumn(rightColumn, false, timerSeconds)),
      ],
    );
  }

  Widget _buildColumn(
      List<PlayerModel> playersList, bool isLeftColumn, int? timerSeconds) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: playersList.map((player) {
        final isSpeaking = currentSpeaker == player.seatNumber;
        final timerValue = isSpeaking ? timerSeconds : null;
        final isBlackTeam = (currentSubPhase == SubPhase.contract ||
                currentSubPhase == SubPhase.mafiaShoot) &&
            (player.role == 'don' || player.role == 'mafia');
        final isSheriff = (currentSubPhase == SubPhase.sheriffLook ||
                currentSubPhase == SubPhase.sheriffCheck) &&
            player.role == 'sheriff';
        final isDon =
            currentSubPhase == SubPhase.donCheck && player.role == 'don';
        final isCurrentCandidate = isVotingActive &&
                voteController?.currentSeat == player.seatNumber ||
            currentSubPhase == SubPhase.tieBreak &&
                currentSpeaker == player.seatNumber ||
            currentSubPhase == SubPhase.finalWordKill &&
                currentSpeaker == player.seatNumber ||
            currentSubPhase == SubPhase.finalWord &&
                currentSpeaker == player.seatNumber;
        final isSelectedForBestMove = currentSubPhase == SubPhase.bestMove &&
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
              isDon: isDon,
              onTap: () => onTap(player.seatNumber),
              onLongPress: () => onLongPress(player.seatNumber),
              onSwipeUp: () => onSwipeUp(player.seatNumber),
              onSwipeDown: () => onSwipeDown(player.seatNumber),
              onSwipeLeft: () => onSwipeLeft(player.seatNumber),
              onSwipeRight: () => onSwipeRight(player.seatNumber),
            ),
          ),
        );
      }).toList(),
    );
  }
}
