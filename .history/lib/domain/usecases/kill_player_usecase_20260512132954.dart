import 'package:mafia_help/domain/repositories/game_repository.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/data/local/models/kill.dart';
import 'package:mafia_help/domain/helpers/game_end_helper.dart';
import '../../core/logger/app_logger.dart';

class KillPlayerUsecase {
  final GameRepository _repository;
  final GameEndHelper _gameEndHelper = GameEndHelper();

  KillPlayerUsecase({required GameRepository repository})
      : _repository = repository;

  Future<GameState> call({
    required int seatNumber,
    required String phase,
    required String killType,
  }) async {
    AppLogger.d('KillPlayerUsecase: START seat=$seatNumber, phase=$phase');
    
    final state = await _repository.getCurrentGameState();
    
    final targetPlayer = state.players.firstWhere(
      (p) => p.seatNumber == seatNumber,
      orElse: () => throw Exception('Player not found'),
    );
    
    if (!targetPlayer.isAlive) {
      AppLogger.d('KillPlayerUsecase: игрок уже мёртв');
      return state;
    }
    
    final updatedPlayers = state.players.map((player) {
      if (player.seatNumber == seatNumber) {
        return player.copyWith(isAlive: false);
      }
      return player;
    }).toList();
    
    final updatedKills = List<Kill>.from(state.pendingKills);
    updatedKills.add(Kill(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      gameId: state.game?.id ?? '',
      phaseId: state.currentDay,
      playerSeatNumber: seatNumber,
      type: killType,
    ));
    
    GameState newState = state.copyWith(
      players: updatedPlayers,
      pendingKills: updatedKills,
    );
    
    if (phase == 'mafiaShoot') {
      newState = newState.copyWith(hasKillInLastNight: true);
    }
    
    final result = _gameEndHelper.checkWinner(newState);
    if (result != null) {
      newState = newState.copyWith(
        isGameEnded: true,
        winner: result == GameResult.redWin ? 'red' : 'black',
      );
      AppLogger.d('KillPlayerUsecase: игра закончена');
    }
    
    await _repository.saveCurrentGameState(newState);
    return newState;
  }
}