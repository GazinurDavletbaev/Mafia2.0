import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/data/local/models/phase_model.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/data/local/models/phase.dart';
final gameStateProvider = StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  return GameStateNotifier();
});

class GameStateNotifier extends StateNotifier<GameState> {
  GameStateNotifier() : super(GameState.initial());

  // ========== Полная замена состояния ==========
  void setGameState(GameState newState) {
    state = newState;
  }

  // ========== Основные сеттеры ==========
  
  void setPhase(Phase phase) {
    state = state.copyWith(currentPhase: phase);
  }

  void setSubPhaseIndex(int index) {
    state = state.copyWith(currentSubPhaseIndex: index);
  }

  void setDay(int day) {
    state = state.copyWith(currentDay: day);
  }

  void setRound(int round) {
    state = state.copyWith(currentRound: round);
  }

  void setSpeaking(int seatNumber) {
    state = state.copyWith(currentSpeakerSeat: seatNumber);
  }

  void setGameEnded(bool ended) {
    state = state.copyWith(isGameEnded: ended);
  }

  void setWinner(String winner) {
    state = state.copyWith(winner: winner, isGameEnded: true);
  }

  // ========== Обновление игроков ==========
  
  void updatePlayerInState(PlayerModel player) {
    state = state.updatePlayer(player);
  }

  void updateFoulsInState(int seatNumber, int fouls) {
    state = state.updateFouls(seatNumber, fouls);
  }

  void updateAliveInState(int seatNumber, bool isAlive) {
    state = state.setPlayerAlive(seatNumber, isAlive);
  }

  // ========== Голосование ==========
  
  void updateNominationsInState(List<int> seats) {
    state = state.copyWith(nominatedSeats: seats);
  }

  void updateVotesInState(Map<int, int> votes) {
    state = state.copyWith(votes: votes);
  }

  // ========== Лучший ход ==========
  
  void updatePartialBestMoveInState(List<int> digits) {
    state = state.copyWith(partialBestMove: digits);
  }

  // ========== Pending данные (для истории) ==========
  
  void addPendingKill(int seatNumber, String phase, String killType) {
    state = state.addPendingKill(seatNumber, phase, killType);
  }

  void addPendingBestMove(List<int> threeSeats) {
    state = state.addPendingBestMove(threeSeats);
  }

  void addPendingVote(dynamic vote) {
    // Реализовать при необходимости
  }

  void addPendingLog(dynamic log) {
    // Реализовать при необходимости
  }

  // ========== Сброс ==========
  
  void resetState() {
    state = GameState.initial();
  }
}