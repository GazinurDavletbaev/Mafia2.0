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

    // Добавляем в историю речей
    if (seatNumber != null) {
      final newSpeechHistory = List<int>.from(_vm.state.speechHistory)
        ..add(seatNumber);
      _vm.state = _vm.state.copyWith(
        currentSpeakerSeat: seatNumber,
        speechHistory: newSpeechHistory,
      );
    } else {
      _vm.state = _vm.state.copyWith(currentSpeakerSeat: seatNumber);
    }
  }

  // В SpeechesActions

Future<void> nextSpeaker() async {
  AppLogger.d('nextSpeaker() called, currentSpeaker=${_vm.state.currentSpeakerSeat}');

  if (_vm.state.currentSubPhase != SubPhase.speeches) {
    AppLogger.d('  not in speeches phase, exiting');
    return;
  }

  final allAlive = _vm.state.players
      .where((p) => p.isAlive)
      .map((p) => p.seatNumber)
      .toList()
    ..sort();

  if (allAlive.isEmpty) {
    AppLogger.d('  no alive players, exiting');
    return;
  }

  final startSeat = _vm.state.dayStarterSeat ?? _vm.state.currentSpeakerSeat ?? allAlive.first;
  final startIndex = allAlive.indexOf(startSeat);

  final orderedSeats = <int>[];
  for (int i = 0; i < allAlive.length; i++) {
    orderedSeats.add(allAlive[(startIndex + i) % allAlive.length]);
  }

  final currentIndex = orderedSeats.indexOf(_vm.state.currentSpeakerSeat ?? 0);

  if (currentIndex != -1 && currentIndex + 1 < orderedSeats.length) {
    final nextSeat = orderedSeats[currentIndex + 1];
    AppLogger.d('  next speaker: seat $nextSeat');
    await setCurrentSpeaker(nextSeat);
  } else {
    AppLogger.d('  circle completed → moving to voting');
    // Запоминаем последнего говорящего для следующего дня
    final lastSpeaker = _vm.state.currentSpeakerSeat;
    _vm.state = _vm.state.copyWith(
      speechHistory: [],
      dayStarterSeat: lastSpeaker,
    );
    await _ref.read(gameViewModelFamily(_vm.gameId).notifier).onPhaseForward();
    AppLogger.d('day finished, lastSpeaker = $lastSpeaker');
  }
  
}

Future<void> previousSpeaker() async {
  AppLogger.d('previousSpeaker() called, currentSpeaker=${_vm.state.currentSpeakerSeat}');

  if (_vm.state.currentSubPhase != SubPhase.speeches) {
    AppLogger.d('  not in speeches phase, exiting');
    return;
  }

  final speechHistory = _vm.state.speechHistory;
  
  if (speechHistory.length >= 2) {
    final newSpeechHistory = List<int>.from(speechHistory)..removeLast();
    final prevSeat = newSpeechHistory.last;
    AppLogger.d('  previous speaker: seat $prevSeat');
    _vm.state = _vm.state.copyWith(
      currentSpeakerSeat: prevSeat,
      speechHistory: newSpeechHistory,
    );
  } else {
    AppLogger.d('  no previous speaker, exiting speeches phase');
    await _ref.read(gameViewModelFamily(_vm.gameId).notifier).onPhaseBack();
  }
}
}
