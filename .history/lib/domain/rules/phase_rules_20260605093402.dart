import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import 'package:mafia_help/domain/rules/speech_rules.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
import '../../core/logger/app_logger.dart';

class PhaseRules {
  final SpeechRules _speechRules = SpeechRules();

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
      nextPhase = next ?? SubPhase.speeches;
    }
    // День
    else if (_dayOrder.contains(currentPhase)) {
      // Если speeches и есть следующий говорящий — не меняем фазу
      if (currentPhase == SubPhase.speeches) {
        final allAlive = currentState.players.where((p) => p.isAlive).map((p) => p.seatNumber).toList()..sort();
        final nextSpeaker = _speechRules.findNextSpeaker(
          currentSpeaker: currentState.currentSpeakerSeat ?? 0,
          aliveSeats: allAlive,
          speechHistory: currentState.speechHistory,
        );
        if (nextSpeaker != null) {
          return _updateSpeakerInSpeeches(currentState, nextSpeaker);
        }
      }
      
      // СПЕЦИАЛЬНАЯ ОБРАБОТКА ДЛЯ eliminationVote
      if (currentPhase == SubPhase.eliminationVote) {
        final totalAlive = currentState.players.where((p) => p.isAlive).length;
        final majority = (totalAlive ~/ 2) + 1;
        if (currentState.eliminationVotes >= majority) {
          nextPhase = SubPhase.finalWord;
        } else {
          nextPhase = SubPhase.mafiaShoot;
        }
      } else if (currentPhase == _dayOrder.last) {
        final candidates = currentState.nominatedSeats;
        final isDay0 = currentDay == 0;
        if (candidates.isEmpty) {
          nextPhase = SubPhase.mafiaShoot;
        } else if (candidates.length == 1 && isDay0) {
          nextPhase = SubPhase.mafiaShoot;
        } else if (candidates.length == 1 && !isDay0) {
          nextPhase = SubPhase.finalWord;
        } else {
          nextPhase = SubPhase.voting;
        }
      } else {
        nextPhase = _getNextInOrder(currentPhase, _dayOrder) ?? SubPhase.mafiaShoot;
      }
    }
    // Ночь 1+
    else if (_nightOrder.contains(currentPhase)) {
      final next = _getNextInOrder(currentPhase, _nightOrder);
      if (next != null) {
        nextPhase = next;
      } else {
        final nightAction = currentState.nightActions ?? [];
        final lastKill = nightAction.length >= 3 ? nightAction[nightAction.length - 3] : null;
        final isMiss = lastKill == null || lastKill == 0 || lastKill == -1;

        if (isMiss) {
          nextPhase = SubPhase.speeches;
        } else {
          nextPhase = (currentDay == 1) ? SubPhase.bestMove : SubPhase.finalWordKill;
        }
      }
    } else {
      return currentState;
    }

    if (nextPhase == null) return currentState;
    return _buildNewState(currentState, nextPhase, currentDay);
  }

  GameState _updateSpeakerInSpeeches(GameState state, int nextSpeaker) {
    return state.copyWith(
      currentSpeakerSeat: nextSpeaker,
      speechHistory: [...state.speechHistory, nextSpeaker],
    );
  }

  GameState _buildNewState(GameState currentState, SubPhase nextPhase, int currentDay) {
    final shouldIncrementDay = nextPhase == SubPhase.mafiaShoot;
    final newDay = shouldIncrementDay ? currentDay + 1 : currentDay;

    int? newSpeaker = currentState.currentSpeakerSeat;

    if (nextPhase == SubPhase.contract || nextPhase == SubPhase.donCheck) {
      final don = currentState.players.firstWhere((p) => p.role == 'don');
      newSpeaker = don.seatNumber;
    } else if (nextPhase == SubPhase.sheriffLook || nextPhase == SubPhase.sheriffCheck) {
      final sheriff = currentState.players.firstWhere((p) => p.role == 'sheriff');
      newSpeaker = sheriff.seatNumber;
    } else if (nextPhase == SubPhase.bestMove || nextPhase == SubPhase.finalWordKill) {
      final nightActions = currentState.nightActions ?? [];
      newSpeaker = nightActions.length >= 3 ? nightActions[nightActions.length - 3] : null;
    } else if (nextPhase == SubPhase.finalWord && currentState.votes.isNotEmpty) {
      newSpeaker = currentState.votes.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    } else if (nextPhase == SubPhase.speeches) {
      final allAlive = currentState.players.where((p) => p.isAlive).map((p) => p.seatNumber).toList()..sort();
      if (allAlive.isNotEmpty) {
        final queue = _speechRules.buildSpeechQueue(
          aliveSeats: allAlive,
          lastSpeakerOfPreviousDay: currentState.dayStarterSeat,
        );
        newSpeaker = queue.isNotEmpty ? queue.first : null;
      }
    }

    final shouldClear = nextPhase == SubPhase.mafiaShoot;

    return currentState.copyWith(
      currentSubPhase: nextPhase,
      currentDay: newDay,
      currentPhase: nightPhases.contains(nextPhase) ? Phase.night : Phase.day,
      currentSpeakerSeat: newSpeaker,
      dayStarterSeat: nextPhase == SubPhase.speeches ? newSpeaker : currentState.dayStarterSeat,
      speechHistory: nextPhase == SubPhase.speeches ? [newSpeaker] : currentState.speechHistory,
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