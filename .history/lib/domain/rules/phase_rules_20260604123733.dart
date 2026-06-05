import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import 'package:mafia_help/domain/rules/speech_rules.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
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
    AppLogger.d('calculateNextState called');

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
        
        if (currentState.eliminationVotes >= majority) {
          nextPhase = SubPhase.finalWord;
        } else {
          nextPhase = SubPhase.mafiaShoot;
        }
      }
      else if (currentPhase == _dayOrder.last) {
        final candidates = currentState.nominatedSeats;
        final isDay0 = currentDay == 0;
        print("hi1");
        if (candidates.isEmpty) {
          nextPhase = SubPhase.mafiaShoot;
          AppLogger.d('No candidates -> mafiaShoot');
        } else if (candidates.length == 1 && isDay0) {
          nextPhase = SubPhase.mafiaShoot;
          AppLogger.d('Day0, 1 candidate -> mafiaShoot');
        } else if (candidates.length == 1 && !isDay0) {
          nextPhase = SubPhase.finalWord;
          AppLogger.d('Day1+, 1 candidate -> finalWord');
        } else {
          nextPhase = SubPhase.voting;
          AppLogger.d('${candidates.length} candidates -> voting');
        }
      } else {
        final next = _getNextInOrder(currentPhase, _dayOrder);
        if (next != null) {
          print("jj");
          print('calculateNextState: currentPhase = ${currentState.currentSubPhase}');
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
      AppLogger.d('next = $next');

      if (next != null) {
        nextPhase = next;
      } else {
        final nightAction = currentState.nightActions ?? [];
        final lastKill = nightAction.length >= 3
            ? nightAction[nightAction.length - 3]
            : null;

        // Промах - если значение -1 или 0
        final isMiss = lastKill == null || lastKill == 0 || lastKill == -1;

        if (isMiss) {
          nextPhase = SubPhase.speeches;
        } else {
          if (currentDay == 1) {
            print("besss");
            nextPhase = SubPhase.bestMove;
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
    
    if (nextPhase == SubPhase.contract || nextPhase == SubPhase.donCheck) {
      final don = currentState.players.firstWhere((p) => p.role == 'don');
      newSpeaker = don.seatNumber;
    } else if (nextPhase == SubPhase.sheriffLook || nextPhase == SubPhase.sheriffCheck) {
      final sheriff = currentState.players.firstWhere((p) => p.role == 'sheriff');
      newSpeaker = sheriff.seatNumber;
    } else if (nextPhase == SubPhase.bestMove) {
      final nightActions = currentState.nightActions ?? [];
      newSpeaker = nightActions.length >= 3 ? nightActions[nightActions.length - 3] : null;
    } else if (nextPhase == SubPhase.finalWordKill) {
      final nightActions = currentState.nightActions ?? [];
      newSpeaker = nightActions.length >= 3 ? nightActions[nightActions.length - 3] : null;
    } else if (nextPhase == SubPhase.finalWord) {
      if (currentState.votes.isNotEmpty) {
        newSpeaker = currentState.votes.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      }
    } else if (nextPhase == SubPhase.speeches) {
      final allAlive = currentState.players.where((p) => p.isAlive).map((p) => p.seatNumber).toList()..sort();
      if (allAlive.isNotEmpty) {
        final speechRules = SpeechRules();
        final queue = speechRules.buildSpeechQueue(
          aliveSeats: allAlive,
          lastSpeakerOfPreviousDay: currentState.dayStarterSeat,
        );
        newSpeaker = queue.isNotEmpty ? queue.first : null;
      }
    }

    // Очищаем кандидатов и голоса при переходе в ночь
    final shouldClear = nextPhase == SubPhase.mafiaShoot;

    return currentState.copyWith(
      currentSubPhase: nextPhase,
      currentDay: newDay,
      currentPhase: nightPhases.contains(nextPhase) ? Phase.night : Phase.day,
      currentSpeakerSeat: newSpeaker,
      dayStarterSeat: nextPhase == SubPhase.speeches ? newSpeaker : currentState.dayStarterSeat,
      speechHistory: nextPhase == SubPhase.speeches ? [?newSpeaker] : currentState.speechHistory,
      nominatedSeats: shouldClear ? [] : currentState.nominatedSeats,
      votes: shouldClear ? {} : currentState.votes,
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