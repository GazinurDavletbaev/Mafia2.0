// lib/presentation/viewmodel/game_viewmodel_speeches.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/providers.dart';
import '../../core/logger/app_logger.dart';
import '../../data/local/models/sub_phase.dart';
import 'game_viewmodel.dart';

class SpeechesActions {
  final GameViewModel _vm;
  final Ref _ref;

  SpeechesActions(this._vm, this._ref);

  Future<void> setCurrentSpeaker(int? seatNumber) async {
    AppLogger.d('setCurrentSpeaker() called, seat=$seatNumber');

    if (seatNumber != null) {
      final newSpeechHistory = List<int>.from(_vm.state.speechHistory)
        ..add(seatNumber);
      _vm.state = _vm.state.copyWith(
        currentSpeakerSeat: seatNumber,
        speechHistory: newSpeechHistory,
      );
      // Убрали сохранение
    } else {
      _vm.state = _vm.state.copyWith(currentSpeakerSeat: seatNumber);
    }
  }

  Future<void> nextSpeaker() async {
    AppLogger.d(
      'nextSpeaker() called, currentSpeaker=${_vm.state.currentSpeakerSeat}',
    );

    if (_vm.state.currentSubPhase != SubPhase.speeches && _vm.state.currentSubPhase != SubPhase.tieBreak) {
  AppLogger.d('  not in speeches or tieBreak phase, exiting');
  return;
}

    final allAlive =
        _vm.state.players
            .where((p) => p.isAlive)
            .map((p) => p.seatNumber)
            .toList()
          ..sort();

    if (allAlive.isEmpty) {
      AppLogger.d('  no alive players, exiting');
      return;
    }

    final startSeat =
        _vm.state.dayStarterSeat ??
        _vm.state.currentSpeakerSeat ??
        allAlive.first;
    final startIndex = allAlive.indexOf(startSeat);

    final orderedSeats = <int>[];
    for (int i = 0; i < allAlive.length; i++) {
      orderedSeats.add(allAlive[(startIndex + i) % allAlive.length]);
    }

    final currentIndex = orderedSeats.indexOf(
      _vm.state.currentSpeakerSeat ?? 0,
    );

    if (currentIndex != -1 && currentIndex + 1 < orderedSeats.length) {
      final nextSeat = orderedSeats[currentIndex + 1];
      AppLogger.d('  next speaker: seat $nextSeat');
      await setCurrentSpeaker(nextSeat);
    } else {
      AppLogger.d('  circle completed → moving to voting');
    }
  }
}
