import 'package:mafia_help/application/providers/game_state_provider.dart';
import 'package:mafia_help/domain/repositories/game_repository.dart';

class SetCurrentSpeakerUsecase {
  final GameRepository _repository;
  final GameStateNotifier _notifier;

  SetCurrentSpeakerUsecase({
    required GameRepository repository,
    required GameStateNotifier notifier,
  }) : _repository = repository,
       _notifier = notifier;

  Future<void> call(int? seatNumber) async {
    // 1. Сохранить в репозиторий
    await _repository.setCurrentSpeaker(seatNumber);
    
    // 2. Обновить UI состояние
    if (seatNumber != null) {
      _notifier.setSpeaking(seatNumber);
    }
  }
}