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
  final List<int> nightActions;

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

  // Получить значение из nightActions по индексу в текущей ночи
  int? _getNightActionValue(int index) {
    if (nightActions.isEmpty) return null;

    final startIndex = nightActions.length - 3;
    if (startIndex + index >= 0 && startIndex + index < nightActions.length) {
      return nightActions[startIndex + index]; // возвращаем как есть
    }
    return null;
  }

  // Виджет для значения мафии (с поддержкой промаха)
  Widget _buildMafiaValue(int? value, bool isActive) {
    if (value == null) return const SizedBox(height: 28);

    // Промах - если значение 0 или -1
    final isMiss = value == 0 || value == -1;

    return Column(
      children: [
        const SizedBox(height: 4),
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive ? Colors.orange.shade800 : Colors.grey.shade800,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: isMiss
                ? const Icon(Icons.broken_image, color: Colors.white, size: 16)
                : Text(
                    '$value',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // Виджет для значения дона/шерифа (без промаха)
  Widget _buildNightActionValue(int? value, bool isActive) {
    if (value == null) return const SizedBox(height: 28);

    return Column(
      children: [
        const SizedBox(height: 4),
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive ? Colors.orange.shade800 : Colors.grey.shade800,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '$value',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Вертикальная колонка для ночных действий
  Widget _buildNightActionsColumn() {
  final isMafiaActive = currentSubPhase == SubPhase.mafiaShoot;
  final isDonActive = currentSubPhase == SubPhase.donCheck;
  final isSheriffActive = currentSubPhase == SubPhase.sheriffCheck;

  final lastValue = nightActions.isNotEmpty ? nightActions.last : null;

  return Container(
    width: 30,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Стрельба мафии
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Icon(
            Icons.sports_mma,
            color: isMafiaActive ? Colors.orange.shade400 : Colors.grey.shade600,
            size: 20,
          ),
        ),
        if (isMafiaActive && lastValue != null)
          _buildMafiaValue(lastValue, true)
        else
          const SizedBox(height: 28),

        // Проверка дона
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Icon(
            Icons.emoji_people,
            color: isDonActive ? Colors.orange.shade400 : Colors.grey.shade600,
            size: 20,
          ),
        ),
        if (isDonActive && lastValue != null)
          _buildNightActionValue(lastValue, true)
        else
          const SizedBox(height: 28),

        // Проверка шерифа
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Icon(
            Icons.search,
            color: isSheriffActive ? Colors.orange.shade400 : Colors.grey.shade600,
            size: 20,
          ),
        ),
        if (isSheriffActive && lastValue != null)
          _buildNightActionValue(lastValue, true)
        else
          const SizedBox(height: 28),
      ],
    ),
  );
}

  // Колонка для кандидатов (днём)
  Widget _buildCandidatesColumn() {
    return Container(
      width: 30,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Icon(Icons.thumb_up, color: Colors.grey.shade600, size: 20),
          ),
          if (nominatedSeats.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...nominatedSeats.map((seat) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
          ],
        ],
      ),
    );
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

    final isNight =
        currentSubPhase == SubPhase.mafiaShoot ||
        currentSubPhase == SubPhase.donCheck ||
        currentSubPhase == SubPhase.sheriffCheck;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _buildColumn(leftColumn, true, timerSeconds)),
        if (isNight) _buildNightActionsColumn() else _buildCandidatesColumn(),
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
            (currentSubPhase == SubPhase.contract ||
                currentSubPhase == SubPhase.mafiaShoot) &&
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
