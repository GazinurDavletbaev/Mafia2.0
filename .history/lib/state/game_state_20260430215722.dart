import 'package:mafia_help/models/player_model.dart';

class GameState {
  final List<PlayerModel> players;           // все 10 игроков
  final int currentDay;                       // 1, 2, 3...
  final int currentSubPhaseIndex;             // индекс в списке подфаз текущей основной фазы
  final int firstSpeakerSeat;                 // кто начинает речь в текущем дне
  final List<int> nominatedSeats;             // выставленные кандидаты (в порядке выставления)
  final Map<int, int> votes;                  // seatNumber -> количество голосов (временное для текущего голосования)
  final List<int> revoteCandidates;           // кандидаты на переголосование (если равный счёт)
  final List<int> partialBestMove;            // 0–3 цифры, введённые для лучшего хода
  final bool isGameOver;
  final String? winnerTeam;                   // 'red' или 'black', если isGameOver = true
  final int lastDayFirstSpeakerSeat;  // ← ДОБАВИТЬ ЭТУ СТРОКУ

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

  });

  // Начальное состояние для новой игры
  factory GameState.initial() {
    // Создаём 10 игроков с заглушками (данные будут заполнены при раздаче ролей)
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
        lastDayFirstSpeakerSeat: 0,  // 0 = нет предыдущего дня

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
  
    );
  }

  // Копирование с изменением полей
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

  // Обновление игрока
  GameState updatePlayer(PlayerModel updatedPlayer) {
    final newPlayers = List<PlayerModel>.from(players);
    final index = newPlayers.indexWhere((p) => p.seatNumber == updatedPlayer.seatNumber);
    if (index != -1) {
      newPlayers[index] = updatedPlayer;
    }
    return copyWith(players: newPlayers);
  }
}