import 'package:mafia_help/domain/repositories/game_repository.dart';
import 'package:mafia_help/presentation/state/game_state.dart';

class PopBestMoveUsecase {
  final GameRepository _repository;

  PopBestMoveUsecase({required GameRepository repository})
      : _repository = repository;

  Future<GameState> call() async {
    final state = await _repository.getCurrentGameState();
    
    final updatedPartial = List<int>.from(state.partialBestMove);
    if (updatedPartial.isNotEmpty) {
      updatedPartial.removeLast();
    }
    
    final newState = state.copyWith(
      partialBestMove: updatedPartial,
    );
    
    await _repository.saveCurrentGameState(newState);
    return newState;
  }
}