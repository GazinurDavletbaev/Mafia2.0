import 'package:mafia_help/domain/helpers/game_end_helper.dart';
import 'package:mafia_help/domain/repositories/game_repository.dart';

class CheckGameEndUsecase {
  final GameRepository _repository;

  CheckGameEndUsecase({
    required GameRepository repository,
  }) : _repository = repository;

  Future<GameResult?> call() async {
    final players = await _repository.getAllPlayers();
    final result = GameEndHelper.check(players);
    
    if (result != null) {
      await _repository.setGameEnded(true);
      await _repository.setWinner(result);
    }
    
    return result;
  }
}