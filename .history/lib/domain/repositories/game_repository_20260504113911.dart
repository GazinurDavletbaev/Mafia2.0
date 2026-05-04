import 'package:mafia_help/data/local/models/best_move.dart';
import 'package:mafia_help/data/local/models/game.dart';
import 'package:mafia_help/data/local/models/kill.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/player.dart';
import 'package:mafia_help/data/local/models/vote.dart';
import 'package:mafia_help/domain/helpers/game_end_helper.dart';
import 'package:mafia_help/presentation/state/game_state.dart';

abstract class GameRepository {
  // ========== Game State (текущая игра) ==========
  Future<GameState?> loadCurrentGameState();
  Future<void> saveCurrentGameState();
  Future<void> clearCurrentGameState();
  
  // ========== Завершённые игры ==========
  Future<void> saveCompletedGame(GameState finalState);
  Future<List<Game>> getAllCompletedGames();
  
  // ========== Работа с GameState через Notifier ==========
  Future<Player?> getPlayerBySeat(int seatNumber);
  Future<List<Player>> getAllPlayers();
  Future<List<Player>> getAlivePlayers();
  Future<void> updatePlayerFouls(int seatNumber, int fouls);
  Future<void> setPlayerAlive(int seatNumber, bool isAlive);
  Future<void> updatePlayer(Player player);
  
  // ========== Nominations ==========
  Future<List<int>> getCurrentNominations();
  Future<void> setNominations(List<int> seats);
  
  // ========== Votes ==========
  Future<Map<int, int>> getCurrentVotes();
  Future<void> addVote({required int round, required int targetSeat, required int voteCount});
  Future<void> clearVotes();
  
  // ========== Best Move ==========
  Future<List<int>> getPartialBestMove();
  Future<void> setPartialBestMove(List<int> digits);
  Future<void> clearPartialBestMove();
  
  // ========== Phase ==========
  Future<Phase> getCurrentPhase();
  Future<void> setCurrentPhase(Phase phase);
  Future<int> getCurrentSubPhaseIndex();
  Future<void> setCurrentSubPhaseIndex(int index);
  Future<int> getCurrentDay();
  Future<void> setCurrentDay(int day);
  
  // ========== Speaking ==========
  Future<int?> getCurrentSpeaker();
  Future<void> setCurrentSpeaker(int? seatNumber);
  
  // ========== Round ==========
  Future<int> getCurrentRound();
  Future<void> setCurrentRound(int round);
  
  // ========== Game End ==========
  Future<void> setGameEnded(bool ended);
  Future<void> setWinner(GameResult result);
  
  // ========== Reset ==========
  Future<void> clearAllGameData();
  
  // ========== Pending данные (для истории) ==========
  Future<void> addKill({required int seatNumber, required String phase, required String killType});
  Future<void> addBestMove(List<int> threeSeats);
}