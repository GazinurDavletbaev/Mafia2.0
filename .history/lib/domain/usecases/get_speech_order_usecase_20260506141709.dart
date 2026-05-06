import 'package:mafia_help/domain/repositories/game_repository.dart';
import 'package:mafia_help/presentation/state/game_state.dart';

class GetSpeechOrderUsecase {
  final GameRepository _repository;

  GetSpeechOrderUsecase({required GameRepository repository})
      : _repository = repository;

  Future<List<int>> call() async {
    final state = await _repository.getCurrentGameState();
    
    final aliveSeats = state.players
        .where((p) => p.isAlive)
        .map((p) => p.seatNumber)
        .toList();
    
    // Начинаем с currentSpeakerSeat или первого живого
    final startIndex = state.currentSpeakerSeat != null
        ? aliveSeats.indexOf(state.currentSpeakerSeat!)
        : 0;
    
    if (startIndex == -1) return aliveSeats;
    
    final ordered = <int>[];
    for (int i = 0; i < aliveSeats.length; i++) {
      ordered.add(aliveSeats[(startIndex + i) % aliveSeats.length]);
    }
    
    return ordered;
  }
}