import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/state/game_state.dart';
import 'package:mafia_help/models/player_model.dart';

// Провайдер состояния игры
final gameStateProvider = StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  return GameStateNotifier();
});

class GameStateNotifier extends StateNotifier<GameState> {
  GameStateNotifier() : super(GameState.initial());

  // Полностью заменить состояние
  void setGameState(GameState newState) {
    state = newState;
  }

  // Обновить игрока
  void updatePlayer(PlayerModel player) {
    state = state.updatePlayer(player);
  }

  // Обновить фолы (циклически 0→1→2→3→4→0)
  void addFoul(int seatNumber) {
    final player = state.getPlayerBySeat(seatNumber);
    if (player == null) return;
    
    int newFouls = player.fouls + 1;
    if (newFouls > 4) newFouls = 0;
    
    state = state.updateFouls(seatNumber, newFouls);
  }

  // Убить/воскресить игрока
  void setAlive(int seatNumber, bool isAlive) {
    state = state.setPlayerAlive(seatNumber, isAlive);
  }

  // Установить текущего говорящего
  void setSpeaking(int seatNumber) {
    state = state.setCurrentSpeaker(seatNumber);
  }

  // Добавить кандидата на голосование
  void addNomination(int seatNumber) {
    if (!state.nominatedSeats.contains(seatNumber)) {
      state = state.copyWith(
        nominatedSeats: [...state.nominatedSeats, seatNumber],
      );
    }
  }

  // Удалить кандидата
  void removeNomination(int seatNumber) {
    state = state.copyWith(
      nominatedSeats: state.nominatedSeats.where((s) => s != seatNumber).toList(),
    );
  }

  // Установить голоса за кандидата
  void setVotes(int seatNumber, int votesCount) {
    final newVotes = Map<int, int>.from(state.votes);
    newVotes[seatNumber] = votesCount;
    state = state.copyWith(votes: newVotes);
  }

  // Очистить голоса
  void clearVotes() {
    state = state.copyWith(votes: {});
  }

  // Добавить цифру в лучший ход
  void addBestMoveDigit(int digit) {
    if (state.partialBestMove.length >= 3) return;
    state = state.copyWith(
      partialBestMove: [...state.partialBestMove, digit],
    );
  }

  // Удалить последнюю цифру лучшего хода
  void popBestMoveDigit() {
    if (state.partialBestMove.isEmpty) return;
    final newList = List<int>.from(state.partialBestMove);
    newList.removeLast();
    state = state.copyWith(partialBestMove: newList);
  }

  // Сохранить лучший ход (при вызове с 3 цифрами)
  void commitBestMove() {
    if (state.partialBestMove.length != 3) return;
    // TODO: сохранить в Hive
    state = state.copyWith(partialBestMove: []);
  }

  // Сменить подфазу
  void setSubPhaseIndex(int index) {
    state = state.copyWith(currentSubPhaseIndex: index);
  }

  // Сменить день
  void setDay(int day) {
    state = state.copyWith(currentDay: day);
  }

  // Сбросить для новой игры
  void reset() {
    state = GameState.initial();
  }
}