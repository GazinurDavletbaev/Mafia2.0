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
      case PlayerTimerType.seconds40:
        return 40;
      case PlayerTimerType.seconds30:
        return 30;
      case PlayerTimerType.seconds20:
        return 20;
      case PlayerTimerType.seconds10:
        return 10;
      case PlayerTimerType.seconds5:
        return 5;
      case PlayerTimerType.none:
        return null;
    }
  }

  int? _getNightActionValue(int index) {
    if (nightActions.isEmpty) return null;
    final startIndex = nightActions.length - 3;
    if (startIndex + index >= 0 && startIndex + index < nightActions.length) {
      return nightActions[startIndex + index];
    }
    return null;
  }

  Widget _buildMafiaValue(int? value, bool isActive, BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    if (value == null) return const SizedBox(height: 28);

    final isMiss = value == 0 || value == -1;

    return Column(
      children: [
        const SizedBox(height: 4),
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive
                ? Colors.orange.shade800
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: isMiss
                ? Icon(
                    Icons.broken_image,
                    color: isDark ? Colors.white : Colors.black87,
                    size: 16,
                  )
                : Text(
                    '$value',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildNightActionValue(
      int? value, bool isActive, BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    if (value == null) return const SizedBox(height: 28);

    return Column(
      children: [
        const SizedBox(height: 4),
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive
                ? Colors.orange.shade800
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '$value',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNightActionsColumn(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMafiaActive = currentSubPhase == SubPhase.mafiaShoot;
    final isDonActive = currentSubPhase == SubPhase.donCheck;
    final isSheriffActive = currentSubPhase == SubPhase.sheriffCheck;

    final startIndex = currentDay == 0 ? 0 : (currentDay - 1) * 3;

    int? mafiaValue;
    int? donValue;
    int? sheriffValue;

    if (nightActions.length > startIndex + 0)
      mafiaValue = nightActions[startIndex + 0];
    if (nightActions.length > startIndex + 1)
      donValue = nightActions[startIndex + 1];
    if (nightActions.length > startIndex + 2)
      sheriffValue = nightActions[startIndex + 2];

    return Container(
      width: 30,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Icon(
              Icons.sports_mma,
              color: isMafiaActive
                  ? Colors.orange.shade400
                  : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
              size: 20,
            ),
          ),
          if (mafiaValue != null)
            _buildMafiaValue(mafiaValue, isMafiaActive, context)
          else
            const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Icon(
              Icons.emoji_people,
              color: isDonActive
                  ? Colors.orange.shade400
                  : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
              size: 20,
            ),
          ),
          if (donValue != null)
            _buildNightActionValue(donValue, isDonActive, context)
          else
            const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Icon(
              Icons.search,
              color: isSheriffActive
                  ? Colors.orange.shade400
                  : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
              size: 20,
            ),
          ),
          if (sheriffValue != null)
            _buildNightActionValue(sheriffValue, isSheriffActive, context)
          else
            const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _buildDayColumn(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    IconData icon;
    String tooltip;

    switch (currentSubPhase) {
      case SubPhase.roleDistribution:
        icon = Icons.assignment;
        tooltip = 'Раздача ролей';
        break;
      case SubPhase.contract:
        icon = Icons.handshake;
        tooltip = 'Договорка';
        break;
      case SubPhase.sheriffLook:
        icon = Icons.visibility;
        tooltip = 'Шериф осматривает город';
        break;
      case SubPhase.freeSeating:
        icon = Icons.chair;
        tooltip = 'Свободная посадка';
        break;
      case SubPhase.speeches:
        icon = Icons.mic;
        tooltip = 'Речи';
        break;
      case SubPhase.voting:
        icon = Icons.how_to_vote;
        tooltip = 'Голосование';
        break;
      case SubPhase.revote:
        icon = Icons.how_to_vote;
        tooltip = 'Переголосование';
        break;
      case SubPhase.tieBreak:
        icon = Icons.gavel;
        tooltip = 'Перестрелка';
        break;
      case SubPhase.eliminationVote:
        icon = Icons.warning;
        tooltip = 'Голосование за подъём';
        break;
      case SubPhase.finalWord:
        icon = Icons.hourglass_empty;
        tooltip = 'Заключительная минута';
        break;
      case SubPhase.finalWordKill:
        icon = Icons.speaker;
        tooltip = 'Заключительная минута убитого';
        break;
      case SubPhase.bestMove:
        icon = Icons.emoji_events;
        tooltip = 'Лучший ход';
        break;
      default:
        icon = Icons.thumb_up;
        tooltip = 'Кандидаты';
    }

    final iconColor = isDark ? Colors.grey.shade600 : Colors.grey.shade500;

    if (currentSubPhase == SubPhase.bestMove) {
      return Container(
        width: 30,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Tooltip(
                message: tooltip,
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ),
            if (partialBestMove.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...partialBestMove.map((seat) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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

    if (currentSubPhase == SubPhase.eliminationVote) {
      return Container(
        width: 30,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Tooltip(
                message: tooltip,
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ),
            if (tiedSeats.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...tiedSeats.map((seat) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
            if (eliminationVotes > 0)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade800,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$eliminationVotes',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      );
    }

    if (currentSubPhase == SubPhase.tieBreak ||
        currentSubPhase == SubPhase.finalWord ||
        currentSubPhase == SubPhase.finalWordKill) {
      final speakers = currentSubPhase == SubPhase.finalWordKill
          ? [currentSpeaker].whereType<int>().toList()
          : (tiedSeats.isNotEmpty
              ? tiedSeats
              : [currentSpeaker].whereType<int>().toList());

      return Container(
        width: 30,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Tooltip(
                message: tooltip,
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ),
            if (speakers.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...speakers.map((seat) {
                final isCurrent = currentSpeaker == seat;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? Colors.green.shade800
                        : Colors.orange.shade800,
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

    if (currentSubPhase == SubPhase.voting ||
        currentSubPhase == SubPhase.revote) {
      final candidates =
          currentSubPhase == SubPhase.revote && tiedSeats.isNotEmpty
              ? tiedSeats
              : nominatedSeats;

      final results = voteController?.results ?? {};
      final maxVotes = results.isNotEmpty
          ? results.values.reduce((a, b) => a > b ? a : b)
          : 0;

      return Container(
        width: 30,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Tooltip(
                message: tooltip,
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ),
            if (candidates.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...candidates.map((seat) {
                final isCurrent = voteController?.currentSeat == seat;
                final voteCount = results[seat];
                final isLeader =
                    !isVotingActive && voteCount == maxVotes && maxVotes > 0;

                Color backgroundColor;
                if (isLeader) {
                  backgroundColor = Colors.blue.shade700;
                } else if (isCurrent && isVotingActive) {
                  backgroundColor = Colors.green.shade800;
                } else {
                  backgroundColor = Colors.orange.shade800;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$seat',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (voteCount != null)
                        Text(
                          '$voteCount',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      );
    }

    return Container(
      width: 30,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Tooltip(
              message: tooltip,
              child: Icon(icon, color: iconColor, size: 20),
            ),
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

    final isNight = currentSubPhase == SubPhase.mafiaShoot ||
        currentSubPhase == SubPhase.donCheck ||
        currentSubPhase == SubPhase.sheriffCheck;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _buildColumn(leftColumn, true, timerSeconds, context)),
        Expanded(
            child: _buildColumn(rightColumn, false, timerSeconds, context)),
        // 🔥 КОЛОНКА С ИНФОЙ + КАЛЬКУЛЯТОР
        Column(
          children: [
            Expanded(
              child: isNight
                  ? _buildNightActionsColumn(context)
                  : _buildDayColumn(context),
            ),
            _buildCalculatorColumn(context), // 🔥 КАЛЬКУЛЯТОР ВНИЗУ
          ],
        ),
      ],
    );
  }

  Widget _buildCalculatorColumn(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: ,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔥 РЯД 1: 10, 9
          Row(
            children: [
              _buildCalcKey('10', 10, context),
              _buildCalcKey('9', 9, context),
            ],
          ),
          // 🔥 РЯД 2: 8, 7
          Row(
            children: [
              _buildCalcKey('8', 8, context),
              _buildCalcKey('7', 7, context),
            ],
          ),
          // 🔥 РЯД 3: 6, 5
          Row(
            children: [
              _buildCalcKey('6', 6, context),
              _buildCalcKey('5', 5, context),
            ],
          ),
          // 🔥 РЯД 4: 4, 3
          Row(
            children: [
              _buildCalcKey('4', 4, context),
              _buildCalcKey('3', 3, context),
            ],
          ),
          // 🔥 РЯД 5: 2, 1
          Row(
            children: [
              _buildCalcKey('2', 2, context),
              _buildCalcKey('1', 1, context),
            ],
          ),
          // 🔥 РЯД 6: 0, Промах
          Row(
            children: [
              _buildCalcKey('0', 0, context),
              _buildCalcKey('🎯', -1, context),
            ],
          ),
          const SizedBox(height: 4),
          // 🔥 НАВИГАЦИЯ: Назад, Вперёд
          Row(
            children: [
              _buildNavKey('◀', () => true, context),
              _buildNavKey('▶', () => false, context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalcKey(String text, int value, BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(2),
        height: 32,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onCalcTap(value),
            onLongPress: () => _onCalcLongPress(value),
            borderRadius: BorderRadius.circular(8),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: text.length > 2 ? 11 : 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onCalcTap(int value) {
    // Здесь логика из FloatingCalculator
    // Временно просто вызываем onTap
    onTap(value);
  }

  void _onCalcLongPress(int value) {
    onLongPress(value);
  }

  Widget _buildNavKey(String text, VoidCallback onTap, BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(2),
        height: 32,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColumn(
    List<PlayerModel> playersList,
    bool isLeftColumn,
    int? timerSeconds,
    BuildContext context,
  ) {
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
