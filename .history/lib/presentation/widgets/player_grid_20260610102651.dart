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
      return nightActions[startIndex + index];
    }
    return null;
  }

  // ========== НОЧНЫЕ ДЕЙСТВИЯ (ВСЕ ТРИ СРАЗУ) ==========

  Widget _buildAllNightActionsColumn() {
    final isMafiaActive = currentSubPhase == SubPhase.mafiaShoot;
    final isDonActive = currentSubPhase == SubPhase.donCheck;
    final isSheriffActive = currentSubPhase == SubPhase.sheriffCheck;

    final mafiaValue = _getNightActionValue(0);
    final donValue = _getNightActionValue(1);
    final sheriffValue = _getNightActionValue(2);

    final isMiss = mafiaValue == 0 || mafiaValue == -1;

    return Container(
      width: 30,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Стрельба мафии
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Tooltip(
              message: 'Стрельба мафии',
              child: Icon(
                Icons.sports_mma,
                color: isMafiaActive
                    ? Colors.orange.shade400
                    : Colors.grey.shade600,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 4),
          if (mafiaValue != null)
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isMafiaActive
                    ? Colors.orange.shade800
                    : Colors.grey.shade800,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: isMiss
                    ? const Icon(Icons.broken_image,
                        color: Colors.white, size: 16)
                    : Text(
                        '$mafiaValue',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            )
          else
            const SizedBox(height: 28),

          // Проверка дона
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Tooltip(
              message: 'Проверка дона',
              child: Icon(
                Icons.emoji_people,
                color:
                    isDonActive ? Colors.orange.shade400 : Colors.grey.shade600,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 4),
          if (donValue != null)
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color:
                    isDonActive ? Colors.orange.shade800 : Colors.grey.shade800,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$donValue',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else
            const SizedBox(height: 28),

          // Проверка шерифа
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Tooltip(
              message: 'Проверка шерифа',
              child: Icon(
                Icons.search,
                color: isSheriffActive
                    ? Colors.orange.shade400
                    : Colors.grey.shade600,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 4),
          if (sheriffValue != null)
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSheriffActive
                    ? Colors.orange.shade800
                    : Colors.grey.shade800,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$sheriffValue',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else
            const SizedBox(height: 28),
        ],
      ),
    );
  }

  // ========== ЦЕНТРАЛЬНАЯ КОЛОНКА В ЗАВИСИМОСТИ ОТ ФАЗЫ ==========

  Widget _buildCenterColumn() {
    if (currentSubPhase == null) return const SizedBox(width: 30);

    // ========== НОЧНЫЕ ФАЗЫ С ДЕЙСТВИЯМИ - ПОКАЗЫВАЕМ ВСЕ ТРИ ==========
    if (currentSubPhase == SubPhase.mafiaShoot ||
        currentSubPhase == SubPhase.donCheck ||
        currentSubPhase == SubPhase.sheriffCheck) {
      return _buildAllNightActionsColumn();
    }

    switch (currentSubPhase) {
      // ========== ОСТАЛЬНЫЕ НОЧНЫЕ ФАЗЫ ==========
      case SubPhase.roleDistribution:
        return _buildIconColumn(
            icon: Icons.assignment, tooltip: 'Раздача ролей');
      case SubPhase.contract:
        return _buildIconColumn(icon: Icons.handshake, tooltip: 'Договорка');
      case SubPhase.sheriffLook:
        return _buildIconColumn(
            icon: Icons.visibility, tooltip: 'Шериф осматривает город');
      case SubPhase.freeSeating:
        return _buildIconColumn(
            icon: Icons.chair, tooltip: 'Свободная посадка');

      // ========== ДНЕВНЫЕ ФАЗЫ ==========
      case SubPhase.speeches:
        if (nominatedSeats.isNotEmpty) {
          return _buildCandidatesListColumn(
            icon: Icons.mic,
            tooltip: 'Выставленные кандидаты',
            candidates: nominatedSeats,
            currentCandidate: null,
            votes: null,
          );
        }
        return _buildIconColumn(icon: Icons.mic, tooltip: 'Речи');

      case SubPhase.voting:
        return _buildCandidatesListColumn(
          icon: Icons.how_to_vote,
          tooltip: 'Голосование',
          candidates: nominatedSeats,
          currentCandidate: voteController?.currentSeat,
          votes: voteController?.results,
        );

      case SubPhase.revote:
        final candidates = tiedSeats.isNotEmpty ? tiedSeats : nominatedSeats;
        return _buildCandidatesListColumn(
          icon: Icons.how_to_vote,
          tooltip: 'Переголосование',
          candidates: candidates,
          currentCandidate: voteController?.currentSeat,
          votes: voteController?.results,
        );

      case SubPhase.tieBreak:
        return _buildSpeakersListColumn(
          icon: Icons.gavel,
          tooltip: 'Перестрелка',
          speakers: tiedSeats,
          currentSpeaker: currentSpeaker,
        );

      case SubPhase.eliminationVote:
        return _buildEliminationColumn(
          icon: Icons.warning,
          tooltip: 'Голосование за подъём',
          candidates: tiedSeats,
          votes: eliminationVotes,
        );

      case SubPhase.finalWord:
        final speakers = tiedSeats.isNotEmpty
            ? tiedSeats
            : [currentSpeaker].whereType<int>().toList();
        return _buildSpeakersListColumn(
          icon: Icons.hourglass_empty,
          tooltip: 'Заключительная минута',
          speakers: speakers,
          currentSpeaker: currentSpeaker,
        );

      case SubPhase.finalWordKill:
        return _buildSpeakersListColumn(
          icon: Icons.speaker,
          tooltip: 'Заключительная минута убитого',
          speakers: [currentSpeaker].whereType<int>().toList(),
          currentSpeaker: currentSpeaker,
        );

      case SubPhase.bestMove:
        return _buildValueListColumn(
          icon: Icons.emoji_events,
          tooltip: 'Лучший ход',
          values: partialBestMove,
          maxValues: 3,
        );

      default:
        return const SizedBox(width: 30);
    }
  }

  // ========== БАЗОВЫЕ ВИДЖЕТЫ ДЛЯ ЦЕНТРАЛЬНОЙ КОЛОНКИ ==========

  Widget _buildIconColumn({
    required IconData icon,
    required String tooltip,
  }) {
    return Container(
      width: 30,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Tooltip(
              message: tooltip,
              child: Icon(icon, color: Colors.grey.shade600, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueListColumn({
    required IconData icon,
    required String tooltip,
    required List<int> values,
    int maxValues = 3,
  }) {
    return Container(
      width: 30,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Tooltip(
              message: tooltip,
              child: Icon(icon, color: Colors.grey.shade600, size: 20),
            ),
          ),
          if (values.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...values.map((value) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.shade800,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$value',
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

  Widget _buildCandidatesListColumn({
    required IconData icon,
    required String tooltip,
    required List<int> candidates,
    int? currentCandidate,
    Map<int, int>? votes,
  }) {
    return Container(
      width: 30,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Tooltip(
              message: tooltip,
              child: Icon(icon, color: Colors.grey.shade600, size: 20),
            ),
          ),
          if (candidates.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...candidates.map((seat) {
              final isCurrent = currentCandidate == seat;
              final voteCount = votes?[seat];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? Colors.green.shade800
                      : Colors.orange.shade800,
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

  Widget _buildSpeakersListColumn({
    required IconData icon,
    required String tooltip,
    required List<int> speakers,
    int? currentSpeaker,
  }) {
    return Container(
      width: 30,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Tooltip(
              message: tooltip,
              child: Icon(icon, color: Colors.grey.shade600, size: 20),
            ),
          ),
          if (speakers.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...speakers.map((seat) {
              final isCurrent = currentSpeaker == seat;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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

  Widget _buildEliminationColumn({
    required IconData icon,
    required String tooltip,
    required List<int> candidates,
    int? votes,
  }) {
    return Container(
      width: 30,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Tooltip(
              message: tooltip,
              child: Icon(icon, color: Colors.grey.shade600, size: 20),
            ),
          ),
          if (candidates.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...candidates.map((seat) {
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
          if (votes != null && votes > 0)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.shade800,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$votes',
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

  // ========== ОСНОВНОЙ BUILD ==========

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
        _buildCenterColumn(),
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
