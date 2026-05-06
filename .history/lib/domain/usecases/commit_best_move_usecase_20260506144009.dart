import 'package:mafia_help/domain/repositories/game_repository.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/data/local/models/best_move.dart';

class CommitBestMoveUsecase {
  final GameRepository _repository;

  CommitBestMoveUsecase({required GameRepository repository})
      : _repository = repository;

  Future<GameState> call() async {
    final state = await _repository.getCurrentGameState();
    
    // 1. Проверка: должно быть ровно 3 цифры в partialBestMove
    if (state.partialBestMove.length != 3) {
      return state; // ничего не меняем
    }
    
    // 2. Создаём BestMove из partialBestMove
    final newBestMove = BestMove(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      gameId: state.game?.id ?? '',
      killedSeatNumber: state.partialBestMove[0], // или другой порядок?
      suspectSeat1: state.partialBestMove[1],
      suspectSeat2: state.partialBestMove[2],
      suspectSeat3: 0, // если только 2 подозреваемых, или добавить поле
    );
    
    // 3. Добавляем в список pendingBestMoves
    final updatedBestMoves = List<BestMove>.from(state.pendingBestMoves);
    updatedBestMoves.add(newBestMove);
    
    // 4. Очищаем partialBestMove
    final newState = state.copyWith(
      pendingBestMoves: updatedBestMoves,
      partialBestMove: [],
    );
    
    await _repository.saveCurrentGameState(newState);
    return newState;
  }
}