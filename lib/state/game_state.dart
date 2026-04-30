import 'package:mafia_help/models/player_model.dart';

class GameState {
  final List<PlayerModel> players;
  final int currentDay;
  final int currentSubPhaseIndex;
  final int firstSpeakerSeat;
  final List<int> nominatedSeats;
  final Map<int, int> votes;
  final List<int> revoteCandidates;
  final List<int> partialBestMove;
  final bool isGameOver;
  final String? winnerTeam;
  final int lastDayFirstSpeakerSeat;  // ← добавить если ещё нет
  final List<int> currentSpeechesOrder; // ← НОВОЕ: порядок выступлений в текущем дне
  final int currentSpeakerIndex;        // ← НОВОЕ: индекс текущего выступающего

  const GameState({
    required this.players,
    required this.currentDay,
    required this.currentSubPhaseIndex,
    required this.firstSpeakerSeat,
    required this.nominatedSeats,
    required this.votes,
    required this.revoteCandidates,
    required this.partialBestMove,
    required this.isGameOver,
    required this.winnerTeam,
    required this.lastDayFirstSpeakerSeat,
    required this.currentSpeechesOrder,
    required this.currentSpeakerIndex,
  });

  factory GameState.initial() {
    final players = List.generate(10, (index) {
      final seat = index + 1;
      return PlayerModel(
        seatNumber: seat,
        name: 'Игрок $seat',
        team: 'unknown',
        role: 'unknown',
        isAlive: true,
        fouls: 0,
        isSpeaking: false,
      );
    });

    return GameState(
      players: players,
      currentDay: 1,
      currentSubPhaseIndex: 0,
      firstSpeakerSeat: 1,
      nominatedSeats: [],
      votes: {},
      revoteCandidates: [],
      partialBestMove: [],
      isGameOver: false,
      winnerTeam: null,
      lastDayFirstSpeakerSeat: 0,
      currentSpeechesOrder: [],
      currentSpeakerIndex: 0,
    );
  }

  GameState copyWith({
    List<PlayerModel>? players,
    int? currentDay,
    int? currentSubPhaseIndex,
    int? firstSpeakerSeat,
    List<int>? nominatedSeats,
    Map<int, int>? votes,
    List<int>? revoteCandidates,
    List<int>? partialBestMove,
    bool? isGameOver,
    String? winnerTeam,
    int? lastDayFirstSpeakerSeat,
    List<int>? currentSpeechesOrder,
    int? currentSpeakerIndex,
  }) {
    return GameState(
      players: players ?? this.players,
      currentDay: currentDay ?? this.currentDay,
      currentSubPhaseIndex: currentSubPhaseIndex ?? this.currentSubPhaseIndex,
      firstSpeakerSeat: firstSpeakerSeat ?? this.firstSpeakerSeat,
      nominatedSeats: nominatedSeats ?? this.nominatedSeats,
      votes: votes ?? this.votes,
      revoteCandidates: revoteCandidates ?? this.revoteCandidates,
      partialBestMove: partialBestMove ?? this.partialBestMove,
      isGameOver: isGameOver ?? this.isGameOver,
      winnerTeam: winnerTeam ?? this.winnerTeam,
      lastDayFirstSpeakerSeat: lastDayFirstSpeakerSeat ?? this.lastDayFirstSpeakerSeat,
      currentSpeechesOrder: currentSpeechesOrder ?? this.currentSpeechesOrder,
      currentSpeakerIndex: currentSpeakerIndex ?? this.currentSpeakerIndex,
    );
  }

  // Вспомогательные геттеры
  List<PlayerModel> get alivePlayers =>
      players.where((p) => p.isAlive).toList();

  List<PlayerModel> get redAlivePlayers =>
      alivePlayers.where((p) => p.team == 'red').toList();

  List<PlayerModel> get blackAlivePlayers =>
      alivePlayers.where((p) => p.team == 'black').toList();

  int get totalAlive => alivePlayers.length;
  int get redAlive => redAlivePlayers.length;
  int get blackAlive => blackAlivePlayers.length;

  PlayerModel? getPlayerBySeat(int seatNumber) {
    try {
      return players.firstWhere((p) => p.seatNumber == seatNumber);
    } catch (e) {
      return null;
    }
  }

  GameState updatePlayer(PlayerModel updatedPlayer) {
    final newPlayers = List<PlayerModel>.from(players);
    final index = newPlayers.indexWhere((p) => p.seatNumber == updatedPlayer.seatNumber);
    if (index != -1) {
      newPlayers[index] = updatedPlayer;
    }
    return copyWith(players: newPlayers);
  }

  GameState setPlayerAlive(int seatNumber, bool isAlive, {int? newFouls}) {
    final player = getPlayerBySeat(seatNumber);
    if (player == null) return this;
    
    final updatedPlayer = player.copyWith(
      isAlive: isAlive,
      fouls: newFouls ?? player.fouls,
    );
    
    return updatePlayer(updatedPlayer);
  }

  // НОВОЕ: обновление фолов
  GameState updateFouls(int seatNumber, int newFouls) {
    final player = getPlayerBySeat(seatNumber);
    if (player == null) return this;
    
    final newIsAlive = newFouls < 4;
    final updatedPlayer = player.copyWith(
      fouls: newFouls,
      isAlive: newIsAlive,
    );
    
    return updatePlayer(updatedPlayer);
  }

  // НОВОЕ: назначить текущего говорящего
  GameState setCurrentSpeaker(int seatNumber) {
    // Сначала убираем isSpeaking у всех
    final newPlayers = players.map((p) => p.copyWith(isSpeaking: false)).toList();
    
    // Затем включаем у нужного
    final index = newPlayers.indexWhere((p) => p.seatNumber == seatNumber);
    if (index != -1) {
      newPlayers[index] = newPlayers[index].copyWith(isSpeaking: true);
    }
    
    return copyWith(players: newPlayers);
  }
}