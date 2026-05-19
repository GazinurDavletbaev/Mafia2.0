import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/providers.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import '../../application/providers/rules_providers.dart';
import '../../core/logger/app_logger.dart';
import '../../data/local/models/sub_phase.dart';
import '../../domain/rules/speech_rules.dart';
import '../state/game_state.dart';
import 'game_viewmodel.dart';

class PhaseActions {
  final GameViewModel _vm;
  final Ref _ref;

  PhaseActions(this._vm, this._ref);

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

    final phaseHistory = currentState.phaseHistory;
    final isNight0Completed = currentState.currentDay > 0;

    SubPhase? nextPhase;
    List<SubPhase> newPhaseHistory;

    if (phaseHistory.isEmpty) {
      nextPhase = isNight0Completed
          ? SubPhase.speeches
          : SubPhase.roleDistribution;
      newPhaseHistory = [nextPhase];
    } else {
      final currentPhase = phaseHistory.last;

      if (_night0Order.contains(currentPhase)) {
        final next = _getNextInOrder(currentPhase, _night0Order);
        if (next != null) {
          nextPhase = next;
          newPhaseHistory = List.from(phaseHistory)..add(nextPhase);
        } else {
          nextPhase = SubPhase.speeches;
          newPhaseHistory = List.from(phaseHistory)..add(nextPhase);
        }
      } else if (_dayOrder.contains(currentPhase)) {
        // Если текущая фаза - последняя в дне, проверяем кандидатов
        if (currentPhase == _dayOrder.last) {
          final candidates = currentState.nominatedSeats;
          final isDay0 = currentState.currentDay == 0;

          if (candidates.isEmpty) {
            nextPhase = SubPhase.mafiaShoot;
          } else if (candidates.length == 1 && isDay0) {
            nextPhase = SubPhase.mafiaShoot;
          } else if (candidates.length == 1 && !isDay0) {
            nextPhase = SubPhase.finalWord;
          } else {
            nextPhase = SubPhase.voting;
          }
          newPhaseHistory = List.from(phaseHistory)..add(nextPhase);
        } else {
          final next = _getNextInOrder(currentPhase, _dayOrder);
          if (next != null) {
            nextPhase = next;
            newPhaseHistory = List.from(phaseHistory)..add(nextPhase);
          } else {
            nextPhase = SubPhase.mafiaShoot;
            newPhaseHistory = List.from(phaseHistory)..add(nextPhase);
          }
        }
      } else if (_nightOrder.contains(currentPhase)) {
        final next = _getNextInOrder(currentPhase, _nightOrder);
        if (next != null) {
          nextPhase = next;
          newPhaseHistory = List.from(phaseHistory)..add(nextPhase);
        } else {
          nextPhase = SubPhase.speeches;
          newPhaseHistory = List.from(phaseHistory)..add(nextPhase);
        }
      } else {
        return currentState;
      }
    }

    if (nextPhase == null) return currentState;

    // Ночь 0 фазы с таймерами
    if (nextPhase == SubPhase.contract) {
      final don = currentState.players.firstWhere((p) => p.role == 'don');
      return currentState.copyWith(
        phaseHistory: newPhaseHistory,
        currentSubPhase: nextPhase,
        currentDay: newPhaseHistory
            .where((p) => p == SubPhase.mafiaShoot)
            .length,
        currentPhase: Phase.night,
        currentSpeakerSeat: don.seatNumber,
      );
    }

    if (nextPhase == SubPhase.sheriffLook) {
      final sheriff = currentState.players.firstWhere(
        (p) => p.role == 'sheriff',
      );
      return currentState.copyWith(
        phaseHistory: newPhaseHistory,
        currentSubPhase: nextPhase,
        currentDay: newPhaseHistory
            .where((p) => p == SubPhase.mafiaShoot)
            .length,
        currentPhase: Phase.night,
        currentSpeakerSeat: sheriff.seatNumber,
      );
    }

    if (nextPhase == SubPhase.sheriffCheck) {
      final sheriff = currentState.players.firstWhere(
        (p) => p.role == 'sheriff',
      );
      return currentState.copyWith(
        phaseHistory: newPhaseHistory,
        currentSubPhase: nextPhase,
        currentDay: newPhaseHistory
            .where((p) => p == SubPhase.mafiaShoot)
            .length,
        currentPhase: Phase.night,
        currentSpeakerSeat: sheriff.seatNumber,
      );
    }

    if (nextPhase == SubPhase.donCheck) {
      final don = currentState.players.firstWhere((p) => p.role == 'don');
      return currentState.copyWith(
        phaseHistory: newPhaseHistory,
        currentSubPhase: nextPhase,
        currentDay: newPhaseHistory
            .where((p) => p == SubPhase.mafiaShoot)
            .length,
        currentPhase: Phase.night,
        currentSpeakerSeat: don.seatNumber,
      );
    }

    // Речи
    if (nextPhase == SubPhase.speeches) {
      final allAlive =
          currentState.players
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

        final firstSpeaker = queue.isNotEmpty ? queue.first : null;

        return currentState.copyWith(
          phaseHistory: newPhaseHistory,
          currentSubPhase: nextPhase,
          currentDay: newPhaseHistory
              .where((p) => p == SubPhase.mafiaShoot)
              .length,
          currentPhase: Phase.day,
          currentSpeakerSeat: firstSpeaker,
          dayStarterSeat: firstSpeaker,
          speechHistory: [?firstSpeaker],
        );
      }
    }

    // FinalWord - устанавливаем победителя голосования
    if (nextPhase == SubPhase.finalWord) {
      final winner = currentState.votes.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      return currentState.copyWith(
        phaseHistory: newPhaseHistory,
        currentSubPhase: nextPhase,
        currentDay: newPhaseHistory
            .where((p) => p == SubPhase.mafiaShoot)
            .length,
        currentPhase: Phase.day,
        currentSpeakerSeat: winner,
      );
    }

if (currentState.currentSubPhase == SubPhase.finalWord) {
  nextPhase = SubPhase.mafiaShoot;
  newPhaseHistory = List.from(phaseHistory)..add(nextPhase);
  return currentState.copyWith(
    phaseHistory: newPhaseHistory,
    currentSubPhase: nextPhase,
    currentDay: currentState.currentDay + 1,
    currentPhase: Phase.night,
    currentSpeakerSeat: null,
  );

    // Обычный переход
    final shouldIncrement =
        currentState.currentSubPhase == SubPhase.finalWord &&
        nextPhase == SubPhase.mafiaShoot;
    final newDay = shouldIncrement
        ? currentState.currentDay + 1
        : newPhaseHistory.where((p) => p == SubPhase.mafiaShoot).length;

    return currentState.copyWith(
      phaseHistory: newPhaseHistory,
      currentSubPhase: nextPhase,
      currentDay: newDay,
      currentPhase: nightPhases.contains(nextPhase) ? Phase.night : Phase.day,
      currentSpeakerSeat: currentState.speechHistory.isNotEmpty
          ? currentState.speechHistory.last
          : null,
    );
  }

  String currentPhaseString() {
    switch (_vm.state.currentPhase) {
      case Phase.night:
        return 'night';
      case Phase.day:
        return 'day';
    }
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
    SubPhase.speeches,
    SubPhase.voting,
    SubPhase.revote,
    SubPhase.tieBreak,
    SubPhase.eliminationVote,
    SubPhase.finalWord,
  ];
}
