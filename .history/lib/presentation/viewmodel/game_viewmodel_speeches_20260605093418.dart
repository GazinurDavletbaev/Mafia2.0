import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/providers.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import '../../core/logger/app_logger.dart';
import '../../domain/helpers/vote_controller.dart';
import '../../domain/rules/speech_rules.dart';
import 'game_viewmodel.dart';

class SpeechesActions {
  final GameViewModel _vm;
  final Ref _ref;
  final SpeechRules _speechRules = SpeechRules();

  SpeechesActions(this._vm, this._ref);

  Future<void> setCurrentSpeaker(int? seatNumber) async {
    if (seatNumber != null) {
      _vm.state = _vm.state.copyWith(currentSpeakerSeat: seatNumber);
    }
  }

  Future<void> nextSpeakerForTieBreak() async {
    final tiedSeats = _vm.state.tiedSeats;
    final currentIndex = _vm.state.currentTieIndex;

    if (currentIndex + 1 < tiedSeats.length) {
      _vm.state = _vm.state.copyWith(
        currentTieIndex: currentIndex + 1,
        currentSpeakerSeat: tiedSeats[currentIndex + 1],
      );
    } else {
      _vm.state = _vm.state.copyWith(
        currentSubPhase: SubPhase.revote,
        currentSpeakerSeat: null,
        nominatedSeats: tiedSeats,
        currentTieIndex: 0,
        voteController: VoteController(tiedSeats),
        isVotingActive: true,
      );
    }
  }

  Future<void> nextSpeaker() async {
    final allAlive = _vm.state.players
        .where((p) => p.isAlive)
        .map((p) => p.seatNumber)
        .toList()
      ..sort();

    final nextSpeaker = _speechRules.findNextSpeaker(
      currentSpeaker: _vm.state.currentSpeakerSeat ?? 0,
      aliveSeats: allAlive,
      speechHistory: _vm.state.speechHistory,
    );

    if (nextSpeaker != null) {
      _vm.state = _vm.state.copyWith(
        currentSpeakerSeat: nextSpeaker,
        speechHistory: [..._vm.state.speechHistory, nextSpeaker],
      );
    }
    // Если nextSpeaker == null — день закончен, переход обрабатывается в PhaseRules
  }
}