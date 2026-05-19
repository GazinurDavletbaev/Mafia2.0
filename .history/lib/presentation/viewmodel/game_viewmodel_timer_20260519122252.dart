import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/providers.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import '../../core/logger/app_logger.dart';
import 'game_viewmodel.dart';

class TimerActions {
  final GameViewModel _vm;
  final Ref _ref;

  TimerActions(this._vm, this._ref);

  Future<void> onTimerComplete() async {
    final subPhase = _vm.state.currentSubPhase;
    final currentSpeaker = _vm.state.currentSpeakerSeat;

    AppLogger.d('onTimerComplete: subPhase=$subPhase, currentSpeaker=$currentSpeaker');

    if (subPhase == SubPhase.speeches && currentSpeaker != null) {
      await _ref.read(gameViewModelFamily(_vm.gameId).notifier).nextSpeaker();
    } else if (subPhase == SubPhase.finalWord && currentSpeaker != null) {
      await _ref.read(gameViewModelFamily(_vm.gameId).notifier).onPhaseForward();
    } else if (subPhase == SubPhase.contract) {
      // Ничего не делаем
    } else if (subPhase == SubPhase.sheriffLook || subPhase == SubPhase.sheriffCheck || subPhase == SubPhase.donCheck) {
      await _ref.read(gameViewModelFamily(_vm.gameId).notifier).onPhaseForward();
    } else if (subPhase == SubPhase.bestMove && currentSpeaker != null) {
      await _ref.read(gameViewModelFamily(_vm.gameId).notifier).setCurrentSpeaker(currentSpeaker);
      await _ref.read(gameViewModelFamily(_vm.gameId).notifier).onPhaseForward();
    }
  }
}