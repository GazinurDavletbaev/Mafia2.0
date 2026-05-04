class GameStateNotifier extends StateNotifier<GameState> {
  GameStateNotifier() : super(GameState.initial());

  void setGameState(GameState newState) {
    state = newState;
  }

  void setSpeaking(int seatNumber) {
    state = state.setCurrentSpeaker(seatNumber);
  }

  void setSubPhaseIndex(int index) {
    state = state.copyWith(currentSubPhaseIndex: index);
  }

  void setDay(int day) {
    state = state.copyWith(currentDay: day);
  }

  void updatePlayerInState(PlayerModel player) {
    state = state.updatePlayer(player);
  }

  void updateFoulsInState(int seatNumber, int fouls) {
    state = state.updateFouls(seatNumber, fouls);
  }

  void updateAliveInState(int seatNumber, bool isAlive) {
    state = state.setPlayerAlive(seatNumber, isAlive);
  }

  void updateNominationsInState(List<int> seats) {
    state = state.copyWith(nominatedSeats: seats);
  }

  void updateVotesInState(Map<int, int> votes) {
    state = state.copyWith(votes: votes);
  }

  void updatePartialBestMoveInState(List<int> digits) {
    state = state.copyWith(partialBestMove: digits);
  }

  void resetState() {
    state = GameState.initial();
  }
}