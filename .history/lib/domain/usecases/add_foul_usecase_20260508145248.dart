import 'package:mafia_help/domain/repositories/game_repository.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
import '../../core/logger/app_logger.dart';

class AddFoulUsecase {
  final GameRepository _repository;

  AddFoulUsecase({required GameRepository repository})
      : _repository = repository;

  Future<GameState> call(int seatNumber) async {
    AppLogger.d('AddFoulUsecase: START seat=$seatNumber');
    
    final state = await _repository.getCurrentGameState();
    AppLogger.d('AddFoulUsecase: BEFORE - currentSpeaker=${state.currentSpeakerSeat}, currentSubPhase=${state.currentSubPhase}');
    
    final updatedPlayers = state.players.map((player) {
      if (player.seatNumber == seatNumber) {
        int newFouls = player.fouls + 1;
        bool newIsAlive = player.isAlive;
        
        AppLogger.d('AddFoulUsecase: player seat=${player.seatNumber}, fouls ${player.fouls} → $newFouls, isAlive ${player.isAlive} → $newIsAlive');
        
        if (newFouls > 4) {
          newFouls = 0;
          newIsAlive = true;
        } else if (newFouls == 4) {
          newIsAlive = false;
        }
        
        return player.copyWith(
          fouls: newFouls,
          isAlive: newIsAlive,
        );
      }
      return player;
    }).toList();
    
    final newState = state.copyWith(players: updatedPlayers);
    AppLogger.d('AddFoulUsecase: AFTER - currentSpeaker=${newState.currentSpeakerSeat}');
    
    await _repository.saveCurrentGameState(newState);
    
    return newState;
  }
}