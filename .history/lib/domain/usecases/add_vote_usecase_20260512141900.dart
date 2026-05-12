import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/data/local/models/vote.dart';
import '../../core/logger/app_logger.dart';

class AddVoteUsecase {
  AddVoteUsecase();

  Future<GameState> call(
    GameState currentState, {
    required int targetSeatNumber,
    required int votesCount,
  }) async {
    AppLogger.d('AddVoteUsecase: seat=$targetSeatNumber, votes=$votesCount');
    
    final updatedVotes = List<Vote>.from(currentState.pendingVotes);
    updatedVotes.add(Vote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      gameId: currentState.game?.id ?? '',
      round: currentState.currentRound,
      targetSeatNumber: targetSeatNumber,
      votesCount: votesCount,
    ));
    
    final newState = currentState.copyWith(
      pendingVotes: updatedVotes,
    );
    
    return newState;
  }
}