import 'package:mafia_help/domain/repositories/game_repository.dart';
import 'package:mafia_help/presentation/state/game_state.dart';

import '../../presentation/state/game_state_copy.dart';

class SetCurrentSpeakerUsecase {
  final GameRepository _repository;

  SetCurrentSpeakerUsecase({required GameRepository repository})
      : _repository = repository;

  Future<GameState> call(int? seatNumber) async {
    final state = await _repository.getCurrentGameState();
    
    final newState = state.copyWith(currentSpeakerSeat: seatNumber);
    await _repository.saveCurrentGameState(newState);
    
    return newState;
  }
}