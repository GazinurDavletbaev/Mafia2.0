import 'package:mafia_help/domain/repositories/game_repository.dart';
import 'package:mafia_help/domain/helpers/game_end_helper.dart';

class CheckGameEndUsecase {
  final GameRepository _repository;

  CheckGameEndUsecase({required GameRepository repository})
      : _repository = repository;

  Future<GameResult?> call() async {
    final state = await _repository.getCurrentGameState();
    final helper = GameEndHelper();
    return helper.checkWinner(state);
  }
}