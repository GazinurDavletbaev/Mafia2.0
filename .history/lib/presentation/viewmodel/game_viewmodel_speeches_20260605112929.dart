import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/domain/usecases/speech_usecase.dart';
import 'game_viewmodel.dart';

class SpeechesActions {
  final GameViewModel _vm;
  final Ref _ref;
  final SpeechUsecase _usecase = SpeechUsecase();

  SpeechesActions(this._vm, this._ref);

  Future<void> setCurrentSpeaker(int? seatNumber) async {
    if (seatNumber != null) {
      _vm.state = _vm.state.copyWith(currentSpeakerSeat: seatNumber);
    }
  }

  Future<void> nextSpeakerForTieBreak() async {
    final (newState, _) = _usecase.processNextTieBreak(_vm.state);
    _vm.state = newState;
  }

  Future<void> nextSpeaker() async {
    final (newState, _) = _usecase.processNextSpeaker(_vm.state);
    _vm.state = newState;
  }
}