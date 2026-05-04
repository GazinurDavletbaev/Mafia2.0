import 'package:mafia_help/application/providers/game_state_provider.dart';
import 'package:mafia_help/domain/repositories/game_repository.dart';

class PopBestMoveUsecase {
  final GameRepository _repository;
  final GameStateNotifier _notifier;

  PopBestMoveUsecase({
    required GameRepository repository,
    required GameStateNotifier notifier,
  }) : _repository = repository,
       _notifier = notifier;

  Future<void> call() async {
    final currentDigits = await _repository.getPartialBestMove();
    
    if (currentDigits.isEmpty) return;
    
    final newDigits = List<int>.from(currentDigits);
    newDigits.removeLast();
    
    await _repository.setPartialBestMove(newDigits);
    
    _notifier.updatePartialBestMoveInState(newDigits);
  }
}