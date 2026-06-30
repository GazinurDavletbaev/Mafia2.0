import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import 'package:mafia_help/domain/rules/speech_rules.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/presentation/widgets/player_timer_type.dart';
import '../../core/logger/app_logger.dart';

class PhaseRules {
  static const List<SubPhase> nightPhases = [
    SubPhase.roleDistribution,
    SubPhase.contract,
    SubPhase.sheriffLook,
    SubPhase.freeSeating,
    SubPhase.mafiaShoot,
    SubPhase.donCheck,
    SubPhase.sheriffCheck,
  ];

  Future<GameState> calculateNextState(GameState currentState) async {
    print('=== CALCULATE NEXT STATE ===');
    print('currentSubPhase = ${currentState.currentSubPhase}');
    final currentPhase = currentState.currentSubPhase;
    final currentDay = currentState.currentDay;

    SubPhase? nextPhase;

    // Ночь 0
    if (_night0Order.contains(currentPhase)) {
      final next = _getNextInOrder(currentPhase, _night0Order);
      if (next != null) {
        nextPhase = next;
      } else {
        nextPhase = SubPhase.speeches;
      }
    }
    // День
    else if (_dayOrder.contains(currentPhase)) {
      // СПЕЦИАЛЬНАЯ ОБРАБОТКА ДЛЯ eliminationVote
      if (currentPhase == SubPhase.eliminationVote) {
        final totalAlive = currentState.players.where((p) => p.isAlive).length;
        final majority = (totalAlive ~/ 2) + 1;
        print('=== PHASE RULES ELIMINATION VOTE ===');
        print('eliminationVotes = ${currentState.eliminationVotes}');
        print('majority = $majority');
        print('isBestMove before = ${currentState.isBestMove}');

        if (currentState.eliminationVotes >= majority) {
          print('Переход в finalWord, isBestMove = ${currentState.isBestMove}');
          return currentState.copyWith(
            currentSubPhase: SubPhase.finalWord,
            isBestMove: currentState.isBestMove,
          );
        } else {
          print('Переход в ночь, isBestMove = ${currentState.isBestMove}');
          return currentState.copyWith(
            currentSubPhase: SubPhase.mafiaShoot,
            currentDay: currentState.currentDay + 1,
            currentPhase: Phase.night,
            nominatedSeats: [],
            votes: {},
            isBestMove: currentState.isBestMove,
          );
        }
      } else if (currentPhase == _dayOrder.last) {
        final candidates = currentState.nominatedSeats;
        final isDay0 = currentDay == 0;
        if (candidates.isEmpty) {
          final aliveCount =
              currentState.players.where((p) => p.isAlive).length;
          nextPhase = SubPhase.mafiaShoot;
          AppLogger.d('No candidates -> mafiaShoot');

          return currentState.copyWith(
            currentSubPhase: SubPhase.mafiaShoot,
            currentDay: currentDay + 1,
            currentPhase: Phase.night,
            nominatedSeats: [],
            votes: {},
            isBestMove: aliveCount >= 9,
            isVotingDay: true,
            currentSpeakerTimer: null,
          );
        } else if (candidates.length == 1 && isDay0) {
          final aliveCount =
              currentState.players.where((p) => p.isAlive).length;
          nextPhase = SubPhase.mafiaShoot;
          AppLogger.d('Day0, 1 candidate -> mafiaShoot');

          return currentState.copyWith(
            currentSubPhase: SubPhase.mafiaShoot,
            currentDay: currentDay + 1,
            currentPhase: Phase.night,
            nominatedSeats: [],
            votes: {},
            isBestMove: aliveCount >= 9,
            isVotingDay: true,
            currentSpeakerTimer: null,
          );
        } else if (candidates.length == 1 && !isDay0) {
          nextPhase = SubPhase.finalWord;
          AppLogger.d('Day1+, 1 candidate -> finalWord');
        } else {
          // Проверяем, разрешено ли голосование в этот день
          if (!currentState.isVotingDay) {
            final aliveCount =
                currentState.players.where((p) => p.isAlive).length;
            nextPhase = SubPhase.mafiaShoot;
            AppLogger.d('Voting disabled -> mafiaShoot');

            return currentState.copyWith(
              currentSubPhase: SubPhase.mafiaShoot,
              currentDay: currentDay + 1,
              currentPhase: Phase.night,
              nominatedSeats: [],
              votes: {},
              isBestMove: aliveCount >= 9,
              isVotingDay: true,
              currentSpeakerTimer: null,
            );
          }

          nextPhase = SubPhase.voting;
          AppLogger.d('${candidates.length} candidates -> voting');
        }
      } else {
        final next = _getNextInOrder(currentPhase, _dayOrder);
        if (next != null) {
          print("jj");
          print(
            'calculateNextState: currentPhase = ${currentState.currentSubPhase}',
          );
          nextPhase = next;
        } else {
          nextPhase = SubPhase.mafiaShoot;
        }
      }
    }
    // Ночь 1+
    else if (_nightOrder.contains(currentPhase)) {
      AppLogger.d('currentPhase in _nightOrder: $currentPhase');
      final next = _getNextInOrder(currentPhase, _nightOrder);
      AppLogger.d('currentPhase in _nightOrdernext: $next');
      if (next == SubPhase.donCheck) {
        final don = currentState.players.firstWhere((p) => p.role == 'don');
        if (!don.isAlive) {
          print('hi don');

          // Дон мертв — пропускаем donCheck, идём сразу в sheriffCheck
          final nightActions = currentState.nightActions ?? [];
          print('1231 $nightActions');
          // Добавляем 0 в nightActions для пропущенной проверки
          final newNightActions = [...nightActions, 0];
          return currentState.copyWith(
            nightActions: newNightActions,
            currentSubPhase: SubPhase.donCheck,
            currentSpeakerTimer: PlayerTimerType.seconds10,
            currentSpeakerSeat: don.seatNumber,
          );
        } else {
          int index = 0;
          index = (currentState.currentDay - 1) * 3 + 0;
          print('1123 $index');
          final nightActions = currentState.nightActions ?? [];
          print(nightActions);
          if (!nightActions.isEmpty) {
            print(nightActions[index]);
          } else {
            final nightActions = [0];
            print(nightActions);
            return currentState.copyWith(
              nightActions: nightActions,
              currentSubPhase: SubPhase.donCheck,
              currentSpeakerTimer: PlayerTimerType.seconds10,
              currentSpeakerSeat: don.seatNumber,
            );
          }
        }
      }

      // Проверка шерифа
      if (next == SubPhase.sheriffCheck) {
        final sheriff =
            currentState.players.firstWhere((p) => p.role == 'sheriff');
        if (!sheriff.isAlive) {
          print('hi sherifff');
          // Шериф мертв — пропускаем sheriffCheck, идём на выход из ночи
          final nightActions = currentState.nightActions ?? [];
          // Добавляем 0 в nightActions для пропущенной проверки
          final newNightActions = [...nightActions, 0];
          return currentState.copyWith(
            nightActions: newNightActions,
            currentSubPhase: SubPhase.sheriffCheck,
            currentSpeakerTimer: PlayerTimerType.seconds10,
            currentSpeakerSeat: sheriff.seatNumber,
          );
        } else {
          int index = 0;
          index = (currentState.currentDay - 1) * 3 + 1;
          final nightActions = currentState.nightActions ?? [];
          if (nightActions.length <= index) {
            final newNightActions = [...nightActions, 0];
            print(newNightActions);
            return currentState.copyWith(
              nightActions: newNightActions,
              currentSubPhase: SubPhase.sheriffCheck,
              currentSpeakerTimer: PlayerTimerType.seconds10,
              currentSpeakerSeat: sheriff.seatNumber,
            );
          }
        }
      }
      if (next != null) {
        nextPhase = next;
      } else {
        final nightActions = currentState.nightActions ?? [];
        print('1111 $nightActions');
        final lastKill = nightActions.length >= 3
            ? nightActions[nightActions.length - 3]
            : null;
        final sheriff =
            currentState.players.firstWhere((p) => p.role == 'sheriff');
        int index = 0;
        index = (currentState.currentDay - 1) * 3 + 2;
        if (nightActions.length <= index) {
          final newNightActions = [...nightActions, 0];
          print(newNightActions);
          return currentState.copyWith(
            nightActions: newNightActions,
            currentSubPhase: SubPhase.sheriffCheck,
            currentSpeakerTimer: PlayerTimerType.seconds10,
            currentSpeakerSeat: sheriff.seatNumber,
          );
        }

        // Промах - если значение -1 или 0
        final isMiss = lastKill == null || lastKill == 0 || lastKill == -1;

        if (isMiss) {
          nextPhase = SubPhase.speeches;
        } else {
          if (currentDay == 1 && currentState.isBestMove) {
            nextPhase = SubPhase.bestMove;
          } else if (currentDay == 1) {
            nextPhase = SubPhase.finalWordKill;
          } else {
            nextPhase = SubPhase.finalWordKill;
          }
        }
      }
    } else {
      return currentState;
    }

    if (nextPhase == null) return currentState;

    // Определяем новый день
    final shouldIncrementDay = nextPhase == SubPhase.mafiaShoot;
    final newDay = shouldIncrementDay ? currentDay + 1 : currentDay;

    // Определяем currentSpeaker для фаз с таймерами
    int? newSpeaker = currentState.currentSpeakerSeat;
    PlayerTimerType? newTimer;

    if (nextPhase == SubPhase.contract || nextPhase == SubPhase.donCheck) {
      final don = currentState.players.firstWhere((p) => p.role == 'don');
      newSpeaker = don.seatNumber;
      newTimer = nextPhase == SubPhase.contract
          ? PlayerTimerType.seconds60
          : PlayerTimerType.seconds10;
    } else if (nextPhase == SubPhase.sheriffLook ||
        nextPhase == SubPhase.sheriffCheck) {
      final sheriff = currentState.players.firstWhere(
        (p) => p.role == 'sheriff',
      );
      newSpeaker = sheriff.seatNumber;
      newTimer = nextPhase == SubPhase.sheriffLook
          ? PlayerTimerType.seconds20
          : PlayerTimerType.seconds10;
    } else if (nextPhase == SubPhase.bestMove) {
      final nightActions = currentState.nightActions ?? [];
      newSpeaker = nightActions.length >= 3
          ? nightActions[nightActions.length - 3]
          : null;
      newTimer = PlayerTimerType.seconds20;
    } else if (nextPhase == SubPhase.finalWordKill) {
      final nightActions = currentState.nightActions ?? [];
      newSpeaker = nightActions.length >= 3
          ? nightActions[nightActions.length - 3]
          : null;
      newTimer = PlayerTimerType.seconds60;
    } else if (nextPhase == SubPhase.finalWord) {
      if (currentState.votes.isNotEmpty) {
        newSpeaker = currentState.votes.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;
      }
      newTimer = PlayerTimerType.seconds60;
    } else if (nextPhase == SubPhase.speeches) {
      final allAlive = currentState.players
          .where((p) => p.isAlive)
          .map((p) => p.seatNumber)
          .toList()
        ..sort();
      if (allAlive.isNotEmpty) {
        final speechRules = SpeechRules();
        final queue = speechRules.buildSpeechQueue(
          aliveSeats: allAlive,
          lastSpeakerOfPreviousDay: currentState.dayStarterSeat,
        );
        newSpeaker = queue.isNotEmpty ? queue.first : null;
      }
      newTimer = PlayerTimerType.seconds60;
      // Для речей таймер устанавливается в SpeechUsecase
    } else if (nextPhase == SubPhase.tieBreak) {
      newTimer = PlayerTimerType.seconds30;
    } else if (nextPhase == SubPhase.freeSeating) {
      final sheriff = currentState.players.firstWhere(
        (p) => p.role == 'sheriff',
      );
      newSpeaker = sheriff.seatNumber;
      newTimer = PlayerTimerType.seconds40;
    }

    // Очищаем кандидатов и голоса при переходе в ночь
    final shouldClear = nextPhase == SubPhase.mafiaShoot;
    return currentState.copyWith(
      currentSubPhase: nextPhase,
      currentDay: newDay,
      currentPhase: nightPhases.contains(nextPhase) ? Phase.night : Phase.day,
      currentSpeakerSeat: newSpeaker,
      dayStarterSeat: nextPhase == SubPhase.speeches
          ? newSpeaker
          : currentState.dayStarterSeat,
      speechHistory: nextPhase == SubPhase.speeches
          ? [newSpeaker!]
          : currentState.speechHistory,
      nominatedSeats: shouldClear ? [] : currentState.nominatedSeats,
      votes: shouldClear ? {} : currentState.votes,
      isBestMove: currentState.isBestMove,
      currentSpeakerTimer: newTimer,
    );
  }

  SubPhase? _getNextInOrder(SubPhase current, List<SubPhase> order) {
    final index = order.indexOf(current);
    if (index >= 0 && index + 1 < order.length) {
      return order[index + 1];
    }
    return null;
  }

  static const List<SubPhase> _night0Order = [
    SubPhase.roleDistribution,
    SubPhase.contract,
    SubPhase.sheriffLook,
    SubPhase.freeSeating,
  ];

  static const List<SubPhase> _nightOrder = [
    SubPhase.mafiaShoot,
    SubPhase.donCheck,
    SubPhase.sheriffCheck,
  ];

  static const List<SubPhase> _dayOrder = [
    SubPhase.bestMove,
    SubPhase.finalWordKill,
    SubPhase.speeches,
    SubPhase.voting,
    SubPhase.revote,
    SubPhase.tieBreak,
    SubPhase.eliminationVote,
    SubPhase.finalWord,
  ];
}
