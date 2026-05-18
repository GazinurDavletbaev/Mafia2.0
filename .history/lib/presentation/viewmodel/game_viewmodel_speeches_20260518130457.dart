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

    
    final newHistory = List<int>.from(_vm.state.speechHistory);
    final currentSpeaker = newHistory.removeAt(0); // берём первого и удаляем

    _vm.state = _vm.state.copyWith(
      currentSpeakerSeat: currentSpeaker,
      speechHistory: newHistory,
    );
    AppLogger.d('  next speaker: seat $currentSpeaker');




    if (currentIndex != -1 && currentIndex + 1 < orderedSeats.length) {
      final nextSeat = orderedSeats[currentIndex + 1];
      AppLogger.d('  next speaker: seat $nextSeat');
      await setCurrentSpeaker(nextSeat);
    } else {
      AppLogger.d('  circle completed → moving to voting');
    }
  }
}
