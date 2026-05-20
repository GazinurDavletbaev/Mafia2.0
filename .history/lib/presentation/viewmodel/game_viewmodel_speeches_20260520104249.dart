// lib/presentation/viewmodel/game_viewmodel_speeches.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/providers.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import '../../core/logger/app_logger.dart';
import '../../data/local/models/sub_phase.dart';
import '../../domain/rules/speech_rules.dart';
import 'game_viewmodel.dart';

class SpeechesActions {
  final GameViewModel _vm;
  final Ref _ref;

  SpeechesActions(this._vm, this._ref);
  Future<void> setCurrentSpeaker(int? seatNumber) async {
    if (seatNumber != null) {
      _vm.state = _vm.state.copyWith(currentSpeakerSeat: seatNumber);
    }
  }

  Future<void> nextSpeaker() async {
    final allAlive =
        _vm.state.players
            .where((p) => p.isAlive)
            .map((p) => p.seatNumber)
            .toList()
          ..sort();

    final speechRules = SpeechRules();
    final nextSpeaker = speechRules.findNextSpeaker(
      currentSpeaker: _vm.state.currentSpeakerSeat ?? 0,
      aliveSeats: allAlive,
      speechHistory: _vm.state.speechHistory,
    );
    final k = _vm.state.speechHistory;
    AppLogger.d('speechystory: $k');

    if (nextSpeaker != null) {
      final newHistory = List<int>.from(_vm.state.speechHistory)
        ..add(nextSpeaker);
      _vm.state = _vm.state.copyWith(
        currentSpeakerSeat: nextSpeaker,
        speechHistory: newHistory,
      );
    } else {
      // День закончен

      if (_vm.state.nominatedSeats.length > 1) {
        _vm.state = _vm.state.copyWith(
          currentSubPhase: SubPhase.voting,
          currentSpeakerSeat: null,
        );
      } else {
        _vm.state = _vm.state.copyWith(
          currentPhase: Phase.night,
          currentSubPhase: SubPhase.mafiaShoot,
          currentSpeakerSeat: null,
          nominatedSeats: 
        );
      }
    }
  }
}
