import 'package:mafia_help/data/local/models/game.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mafia_help/data/local/sources/game_local_source.dart';
import 'package:mafia_help/domain/helpers/game_end_helper.dart';
import 'package:mafia_help/domain/repositories/game_repository.dart';
import 'package:mafia_help/presentation/state/game_state.dart';

import '../../presentation/state/game_state_extentions.dart';
import '../local/models/sub_phase.dart';

class GameRepositoryImpl implements GameRepository {
  final GameLocalSource _localSource;

  GameRepositoryImpl({
    required GameLocalSource localSource,
  }) : _localSource = localSource;

  @override
  Future<GameState?> loadCurrentGameState() async {
    return _localSource.loadCurrentGameState();
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
  
  @override
  Future<void> addBestMove(List<int> threeSeats) {
    // TODO: implement addBestMove
    throw UnimplementedError();
  }
  
  @override
  Future<void> addKill({required int seatNumber, required String phase, required String killType}) {
    // TODO: implement addKill
    throw UnimplementedError();
  }
  
  @override
  Future<void> addVote({required int round, required int targetSeat, required int voteCount}) {
    // TODO: implement addVote
    throw UnimplementedError();
  }
  
  @override
  Future<void> clearAllGameData() {
    // TODO: implement clearAllGameData
    throw UnimplementedError();
  }
  
  @override
  Future<void> clearPartialBestMove() {
    // TODO: implement clearPartialBestMove
    throw UnimplementedError();
  }
  
  @override
  Future<void> clearVotes() {
    // TODO: implement clearVotes
    throw UnimplementedError();
  }
  
  @override
  Future<List<PlayerModel>> getAlivePlayers() {
    // TODO: implement getAlivePlayers
    throw UnimplementedError();
  }
  
  @override
  Future<List<PlayerModel>> getAllPlayers() {
    // TODO: implement getAllPlayers
    throw UnimplementedError();
  }
  
  @override
  Future<int> getCurrentDay() {
    // TODO: implement getCurrentDay
    throw UnimplementedError();
  }
  
  @override
  Future<List<int>> getCurrentNominations() {
    // TODO: implement getCurrentNominations
    throw UnimplementedError();
  }
  
  @override
  Future<Phase> getCurrentPhase() {
    // TODO: implement getCurrentPhase
    throw UnimplementedError();
  }
  
  @override
  Future<int> getCurrentRound() {
    // TODO: implement getCurrentRound
    throw UnimplementedError();
  }
  
  @override
  Future<int?> getCurrentSpeaker() {
    // TODO: implement getCurrentSpeaker
    throw UnimplementedError();
  }
  
  @override
  Future<SubPhase> getCurrentSubPhase() {
    // TODO: implement getCurrentSubPhase
    throw UnimplementedError();
  }
  
  @override
  Future<int> getCurrentSubPhaseIndex() {
    // TODO: implement getCurrentSubPhaseIndex
    throw UnimplementedError();
  }
  
  @override
  Future<Map<int, int>> getCurrentVotes() {
    // TODO: implement getCurrentVotes
    throw UnimplementedError();
  }
  
  @override
  Future<List<int>> getPartialBestMove() {
    // TODO: implement getPartialBestMove
    throw UnimplementedError();
  }
  
  @override
  Future<void> saveBestMove(List<int> threeSeats) {
    // TODO: implement saveBestMove
    throw UnimplementedError();
  }
  
  @override
  Future<void> setCurrentDay(int day) {
    // TODO: implement setCurrentDay
    throw UnimplementedError();
  }
  
  @override
  Future<void> setCurrentPhase(Phase phase) {
    // TODO: implement setCurrentPhase
    throw UnimplementedError();
  }
  
  @override
  Future<void> setCurrentRound(int round) {
    // TODO: implement setCurrentRound
    throw UnimplementedError();
  }
  
  @override
  Future<void> setCurrentSpeaker(int? seatNumber) {
    // TODO: implement setCurrentSpeaker
    throw UnimplementedError();
  }
  
  @override
  Future<void> setCurrentSubPhase(SubPhase subPhase) {
    // TODO: implement setCurrentSubPhase
    throw UnimplementedError();
  }
  
  @override
  Future<void> setCurrentSubPhaseIndex(int index) {
    // TODO: implement setCurrentSubPhaseIndex
    throw UnimplementedError();
  }
  
  @override
  Future<void> setGameEnded(bool ended) {
    // TODO: implement setGameEnded
    throw UnimplementedError();
  }
  
  @override
  Future<void> setNominations(List<int> seats) {
    // TODO: implement setNominations
    throw UnimplementedError();
  }
  
  @override
  Future<void> setPartialBestMove(List<int> digits) {
    // TODO: implement setPartialBestMove
    throw UnimplementedError();
  }
  
  @override
  Future<void> setWinner(GameResult result) {
    // TODO: implement setWinner
    throw UnimplementedError();
  }
  
  @override
  Future<void> updatePlayer(PlayerModel player) {
    // TODO: implement updatePlayer
    throw UnimplementedError();
  }

  // ========== НИЖЕ ВСЕ МЕТОДЫ УДАЛИТЬ ==========
  // Они больше не нужны, так как usecase работают напрямую с GameState
  // Через getCurrentGameState() и saveCurrentGameState()
}