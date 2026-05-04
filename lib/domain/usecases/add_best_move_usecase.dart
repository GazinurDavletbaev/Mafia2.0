import 'package:mafia_help/application/providers/game_state_provider.dart';
import 'package:mafia_help/domain/repositories/game_repository.dart';

class AddBestMoveUsecase {
  final GameRepository _repository;
  final GameStateNotifier _notifier;

  AddBestMoveUsecase({
    required GameRepository repository,
    required GameStateNotifier notifier,
  }) : _repository = repository,
       _notifier = notifier;

  Future<void> call(int digit) async {
    final currentDigits = await _repository.getPartialBestMove();
    
    if (currentDigits.length >= 3) return;
    
    final newDigits = [...currentDigits, digit];
    
    await _repository.setPartialBestMove(newDigits);
    
    _notifier.updatePartialBestMoveInState(newDigits);
  }
}