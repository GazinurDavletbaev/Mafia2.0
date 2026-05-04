import 'package:mafia_help/data/local/models/best_move_model.dart';
import 'package:mafia_help/data/local/models/game_model.dart';
import 'package:mafia_help/data/local/models/kill_model.dart';
import 'package:mafia_help/data/local/models/phase_model.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mafia_help/data/local/models/vote_model.dart';
import 'package:mafia_help/domain/helpers/game_end_helper.dart';
import 'package:mafia_help/data/local/models/best_move.dart';
import 'package:mafia_help/data/local/models/game.dart';
import 'package:mafia_help/data/local/models/kill.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/player.dart';
import 'package:mafia_help/data/local/models/vote.dart';

abstract class GameRepository {
  // Game
  Future<GameModel?> getCurrentGame();
  Future<void> saveGame(GameModel game);
  Future<void> setGameEnded(bool ended);
  Future<void> setWinner(GameResult result);
  
  // Players
  Future<PlayerModel?> getPlayerBySeat(int seatNumber);
  Future<List<PlayerModel>> getAllPlayers();
  Future<List<PlayerModel>> getAlivePlayers();
  Future<void> updatePlayerFouls(int seatNumber, int fouls);
  Future<void> setPlayerAlive(int seatNumber, bool isAlive);
  Future<void> updatePlayer(PlayerModel player);
  
  // Nominations (для голосования)
  Future<List<int>> getCurrentNominations();
  Future<void> setNominations(List<int> seats);
  
  // Votes
  Future<void> addVote({required int round, required int targetSeat, required int voteCount});
  Future<void> clearVotes();
  Future<Map<int, int>> getCurrentVotes();
  
  // Best Move
  Future<List<int>> getPartialBestMove();
  Future<void> setPartialBestMove(List<int> digits);
  Future<void> clearPartialBestMove();
  Future<void> saveBestMove(List<int> threeSeats);
  Future<List<BestMoveModel>> getBestMovesForGame();
  
  // Kills
  Future<void> addKill({required int seatNumber, required String phase, required String killType});
  Future<List<KillModel>> getKillsForGame();
  
  // Phase
  Future<Phase> getCurrentPhase();
  Future<void> setCurrentPhase(Phase phase);
  Future<int> getCurrentSubPhaseIndex();
  Future<void> setCurrentSubPhaseIndex(int index);
  Future<int> getCurrentDay();
  Future<void> setCurrentDay(int day);
  
  // Speaking
  Future<int?> getCurrentSpeaker();
  Future<void> setCurrentSpeaker(int? seatNumber);
  
  // Reset
  Future<void> clearAllGameData();
}