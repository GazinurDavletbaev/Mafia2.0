import 'package:mafia_help/data/local/models/game.dart';
import 'package:mafia_help/data/local/sources/game_local_source.dart';
import 'package:mafia_help/domain/repositories/game_repository.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
import '../../presentation/state/game_state_extentions.dart';

class GameRepositoryImpl implements GameRepository {
  final GameLocalSource _localSource;

  GameRepositoryImpl({
    required GameLocalSource localSource,
  }) : _localSource = localSource;

  @override
  Future<GameState> getCurrentGameState() async {
    final state = await _localSource.loadCurrentGameState();
    return state ?? GameState.initial();
  }

  @override
  Future<void> saveCurrentGameState(GameState state) async {
    await _localSource.saveCurrentGameState(state);
  }

  @override
  Future<void> clearCurrentGameState() async {
    await _localSource.clearCurrentGameState();
  }

  @override
  Future<void> saveCompletedGame(GameState finalState) async {
    final game = finalState.toGameModel();
    final players = finalState.toPlayerModels();
    final kills = finalState.toKillModels();
    final votes = finalState.toVoteModels();
    final bestMoves = finalState.toBestMoveModels();
    final logs = finalState.toGameLogModels();
    
    await _localSource.saveCompletedGame(
      game: game,
      players: players,
      kills: kills,
      votes: votes,
      bestMoves: bestMoves,
      logs: logs,
    );
  }

  @override
  Future<List<Game>> getAllCompletedGames() async {
    return _localSource.getAllCompletedGames();
  }
}