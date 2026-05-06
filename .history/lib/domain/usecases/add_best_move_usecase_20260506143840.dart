import 'package:mafia_help/domain/repositories/game_repository.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/data/local/models/best_move.dart';

import '../../presentation/state/game_state_copy.dart';

class AddBestMoveUsecase {
  final GameRepository _repository;

  AddBestMoveUsecase({required GameRepository repository})
      : _repository = repository;

  Future<GameState> call({
    required int killedSeatNumber,
    required int suspectSeat1,
    required int suspectSeat2,
    required int suspectSeat3,
  }) async {
    final state = await _repository.getCurrentGameState();
    
    final updatedBestMoves = List<BestMove>.from(state.pendingBestMoves);
    updatedBestMoves.add(BestMove(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      gameId: state.game?.id ?? '',
      killedSeatNumber: killedSeatNumber,
      suspectSeat1: suspectSeat1,
      suspectSeat2: suspectSeat2,
      suspectSeat3: suspectSeat3,
    ));
    
    final newState = state.copyWith(
      pendingBestMoves: updatedBestMoves,
    );
    
    await _repository.saveCurrentGameState(newState);
    return newState;
  }
}