import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/domain/repositories/game_repository.dart';
import '../../core/logger/app_logger.dart';

class ResetGameUsecase {
  final GameRepository _repository;

  ResetGameUsecase({required GameRepository repository})
      : _repository = repository;

  Future<GameState> call() async {
    AppLogger.d('ResetGameUsecase: сброс игры');
    
    final newState = GameState.initial();
    await _repository.saveCurrentGameState(newState);
    
    return newState;
  }
}