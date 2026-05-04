import 'package:mafia_help/domain/helpers/speech_order_helper.dart';
import 'package:mafia_help/domain/repositories/game_repository.dart';

class GetSpeechOrderUsecase {
  final GameRepository _repository;

  GetSpeechOrderUsecase({
    required GameRepository repository,
  }) : _repository = repository;

  Future<List<int>> call() async {
    // 1. Получить живых игроков
    final alivePlayers = await _repository.getAlivePlayers();
    final aliveSeats = alivePlayers.map((p) => p.seatNumber).toList()..sort();
    
    // 2. Получить текущего говорящего (если есть)
    final currentSpeaker = await _repository.getCurrentSpeaker();
    
    // 3. Вернуть порядок речей
    return SpeechOrderHelper.getOrder(aliveSeats, currentSpeaker);
  }
}