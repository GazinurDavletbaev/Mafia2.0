// lib/domain/usecases/revote_usecase.dart

import 'package:mafia_help/presentation/state/game_state.dart';

class RevoteUsecase {
  RevoteUsecase();

  Future<GameState> execute(GameState currentState) async {
    // TODO: переписать через VotingRules
    return currentState;
  }
}