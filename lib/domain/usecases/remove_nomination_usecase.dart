import 'package:mafia_help/application/providers/game_state_provider.dart';
import 'package:mafia_help/domain/repositories/game_repository.dart';

class RemoveNominationUsecase {
  final GameRepository _repository;
  final GameStateNotifier _notifier;

  RemoveNominationUsecase({
    required GameRepository repository,
    required GameStateNotifier notifier,
  }) : _repository = repository,
       _notifier = notifier;

  Future<void> call(int seatNumber) async {
    final currentNominations = await _repository.getCurrentNominations();
    
    if (!currentNominations.contains(seatNumber)) return;
    
    final newNominations = currentNominations.where((s) => s != seatNumber).toList();
    
    await _repository.setNominations(newNominations);
    _notifier.updateNominationsInState(newNominations);
  }
}