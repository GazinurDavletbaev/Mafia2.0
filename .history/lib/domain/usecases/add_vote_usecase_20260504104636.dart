import 'package:mafia_help/application/providers/game_state_provider.dart';
import 'package:mafia_help/domain/repositories/game_repository.dart';

class AddVoteUsecase {
  final GameRepository _repository;
  final GameStateNotifier _notifier;

  AddVoteUsecase({
    required GameRepository repository,
    required GameStateNotifier notifier,
  }) : _repository = repository,
       _notifier = notifier;

  Future<void> call({
    required int round,
    required int targetSeat,
    required int voteCount,
  }) async {
    // 1. Сохранить в репозиторий (перезаписывает, если уже есть голоса за этого игрока в этом раунде)
    await _repository.addVote(
      round: round,
      targetSeat: targetSeat,
      voteCount: voteCount,
    );
    
    // 2. Обновить UI состояние (мердж с существующими голосами)
    final currentVotes = _notifier.state.votes;
    final newVotes = Map<int, int>.from(currentVotes);
    newVotes[targetSeat] = voteCount;
    _notifier.updateVotesInState(newVotes);
  }
}