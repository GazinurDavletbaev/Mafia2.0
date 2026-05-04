import 'package:mafia_help/application/providers/game_state_provider.dart';
import 'package:mafia_help/data/local/models/best_move.dart';
import 'package:mafia_help/data/local/models/game.dart';
import 'package:mafia_help/data/local/models/kill.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mafia_help/data/local/models/vote.dart';
import 'package:mafia_help/data/local/sources/game_local_source.dart';
import 'package:mafia_help/domain/helpers/game_end_helper.dart';
import 'package:mafia_help/domain/repositories/game_repository.dart';
import 'package:mafia_help/presentation/state/game_state.dart';

class GameRepositoryImpl implements GameRepository {
  final GameLocalSource _localSource;
  final GameStateNotifier _notifier;

  GameRepositoryImpl({
    required GameLocalSource localSource,
    required GameStateNotifier notifier,
  }) : _localSource = localSource,
       _notifier = notifier;

  @override
  Future<GameState?> loadCurrentGameState() async {
    return _localSource.loadCurrentGameState();
  }

  @override
  Future<void> saveCurrentGameState() async {
    await _localSource.saveCurrentGameState(_notifier.state);
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

  @override
  Future<PlayerModel?> getPlayerBySeat(int seatNumber) async {
    return _notifier.state.getPlayerBySeat(seatNumber);
  }

  @override
  Future<List<PlayerModel>> getAllPlayers() async {
    return _notifier.state.players;
  }

  @override
  Future<List<PlayerModel>> getAlivePlayers() async {
    return _notifier.state.players.where((p) => p.isAlive).toList();
  }

  @override
  Future<void> updatePlayerFouls(int seatNumber, int fouls) async {
    _notifier.updateFoulsInState(seatNumber, fouls);
  }

  @override
  Future<void> setPlayerAlive(int seatNumber, bool isAlive) async {
    _notifier.updateAliveInState(seatNumber, isAlive);
  }

  @override
  Future<void> updatePlayer(PlayerModel player) async {
    _notifier.updatePlayerInState(player);
  }

  @override
  Future<List<int>> getCurrentNominations() async {
    return _notifier.state.nominatedSeats;
  }

  @override
  Future<void> setNominations(List<int> seats) async {
    _notifier.updateNominationsInState(seats);
  }

  @override
  Future<Map<int, int>> getCurrentVotes() async {
    return _notifier.state.votes;
  }

  @override
  Future<void> addVote({
    required int round,
    required int targetSeat,
    required int voteCount,
  }) async {
    final currentVotes = Map<int, int>.from(_notifier.state.votes);
    currentVotes[targetSeat] = voteCount;
    _notifier.updateVotesInState(currentVotes);
  }

  @override
  Future<void> clearVotes() async {
    _notifier.updateVotesInState({});
  }

  @override
  Future<List<int>> getPartialBestMove() async {
    return _notifier.state.partialBestMove;
  }

  @override
  Future<void> setPartialBestMove(List<int> digits) async {
    _notifier.updatePartialBestMoveInState(digits);
  }

  @override
  Future<void> clearPartialBestMove() async {
    _notifier.updatePartialBestMoveInState([]);
  }

  @override
  Future<Phase> getCurrentPhase() async {
    return _notifier.state.currentPhase;
  }

  @override
  Future<void> setCurrentPhase(Phase phase) async {
    _notifier.setPhase(phase);
  }

  @override
  Future<int> getCurrentSubPhaseIndex() async {
    return _notifier.state.currentSubPhaseIndex;
  }

  @override
  Future<void> setCurrentSubPhaseIndex(int index) async {
    _notifier.setSubPhaseIndex(index);
  }

  @override
  Future<int> getCurrentDay() async {
    return _notifier.state.currentDay;
  }

  @override
  Future<void> setCurrentDay(int day) async {
    _notifier.setDay(day);
  }

  @override
  Future<int?> getCurrentSpeaker() async {
    return _notifier.state.currentSpeakerSeat;
  }

  @override
  Future<void> setCurrentSpeaker(int? seatNumber) async {
    if (seatNumber != null) {
      _notifier.setSpeaking(seatNumber);
    }
  }

  @override
  Future<int> getCurrentRound() async {
    return _notifier.state.currentRound;
  }

  @override
  Future<void> setCurrentRound(int round) async {
    _notifier.setRound(round);
  }

  @override
  Future<void> setGameEnded(bool ended) async {
    _notifier.setGameEnded(ended);
  }

  @override
  Future<void> setWinner(GameResult result) async {
    _notifier.setWinner(result == GameResult.redWin ? 'red' : 'black');
  }

  @override
  Future<void> clearAllGameData() async {
    _notifier.resetState();
    await _localSource.clearCurrentGameState();
  }

  @override
  Future<void> addKill({
    required int seatNumber,
    required String phase,
    required String killType,
  }) async {
    _notifier.addPendingKill(seatNumber, phase, killType);
  }

  @override
  Future<void> addBestMove(List<int> threeSeats) async {
    _notifier.addPendingBestMove(threeSeats);
  }
  @override
  Future<void> saveBestMove(List<int> threeSeats) async {
  _notifier.addPendingBestMove(threeSeats);
}
}