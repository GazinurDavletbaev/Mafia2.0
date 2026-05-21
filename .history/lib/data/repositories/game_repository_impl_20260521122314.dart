import 'package:mafia_help/data/local/models/game.dart';
import 'package:mafia_help/data/local/sources/game_local_source.dart';
import 'package:mafia_help/domain/repositories/game_repository.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
import '../../core/logger/app_logger.dart';
import '../../presentation/state/game_state_extentions.dart';

class GameRepositoryImpl implements GameRepository {
  final GameLocalSource _localSource;

  GameRepositoryImpl({required GameLocalSource localSource})
    : _localSource = localSource;

  @override
  Future<GameState> getCurrentGameState() async {
    final state = await _localSource.loadCurrentGameState();
    AppLogger.d(
      'REPOSITORY getCurrentGameState: currentSpeaker=${state?.currentSpeakerSeat}',
    );
    return state ?? GameState.initial();
  }

  @override
  Future<void> saveCurrentGameState(GameState state) async {
    AppLogger.d('REPOSITORY SAVE: currentSpeaker=${state.currentSpeakerSeat}');
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


    await _localSource.saveCompletedGame(
      game: game,
      players: players,
    );
  }

  @override
  Future<List<Game>> getAllCompletedGames() async {
    return _localSource.getAllCompletedGames();
  }
}
