import 'package:mafia_help/presentation/state/game_state.dart';

class VoteController {
  final List<int> candidateSeats;
  final Map<int, int> _votes = {};
  int _currentIndex = 0;
  bool _isVisible = true;

  VoteController(this.candidateSeats);

  // Геттеры
  int get currentSeat => candidateSeats[_currentIndex];
  int? get currentVotes => _votes[currentSeat];
  int get currentIndex => _currentIndex;
  int get totalCandidates => candidateSeats.length;
  bool get isComplete => _votes.length == candidateSeats.length;
  bool get isVisible => _isVisible;
  Map<int, int> get results => Map.unmodifiable(_votes);
  List<int> get remainingCandidates {
    return candidateSeats.where((seat) => !_votes.containsKey(seat)).toList();
  }

  // Действия
  void setVotes(int count) {
    if (count < 0 || count > 10) return;
    _votes[currentSeat] = count;
  }

  void nextCandidate() {
    if (_currentIndex + 1 < candidateSeats.length) {
      _currentIndex++;
    }
  }

  void previousCandidate() {
    if (_currentIndex > 0) {
      _currentIndex--;
    }
  }

  void show() {
    _isVisible = true;
  }

  void hide() {
    _isVisible = false;
  }

  void toggleVisibility() {
    _isVisible = !_isVisible;
  }

  void reset() {
    _votes.clear();
    _currentIndex = 0;
  }

  // Статический метод для определения результата голосования
  static VoteResult determineResult(
    Map<int, int> votes,
    int aliveCount, {
    bool isRevote = false,
    int previousTiedCount = 0,
  }) {
    if (votes.isEmpty) {
      return VoteResult.noCandidates();
    }

    final maxVotes = votes.values.reduce((a, b) => a > b ? a : b);
    final winners = votes.entries
        .where((e) => e.value == maxVotes)
        .map((e) => e.key)
        .toList();

    if (winners.length == 1) {
      print('1 $votes $previousTiedCount');
      return VoteResult.winner(winners.first, maxVotes);
    } else if (isRevote && winners.length < previousTiedCount) {
      print('2 $votes $previousTiedCount $winners.length');

      return VoteResult.tieBreak(winners, maxVotes);
    } else if (isRevote && winners.length >= previousTiedCount) {
      print('3 $votes $previousTiedCount $winners.length');

      return VoteResult.eliminationVote(winners, maxVotes);
    } else {
      print('4 $votes $previousTiedCount $winners.length');

      return VoteResult.tieBreak(winners, maxVotes);
    }
  }
}

class VoteResult {
  final VoteResultType type;
  final List<int> seats;
  final int? winnerSeat;
  final int votesCount;

  VoteResult({
    required this.type,
    required this.seats,
    this.winnerSeat,
    required this.votesCount,
  });

  factory VoteResult.winner(int seat, int votes) {
    return VoteResult(
      type: VoteResultType.winner,
      seats: [seat],
      winnerSeat: seat,
      votesCount: votes,
    );
  }

  factory VoteResult.tieBreak(List<int> seats, int votes) {
    return VoteResult(
      type: VoteResultType.tieBreak,
      seats: seats,
      winnerSeat: null,
      votesCount: votes,
    );
  }

  factory VoteResult.eliminationVote(List<int> seats, int votes) {
    return VoteResult(
      type: VoteResultType.eliminationVote,
      seats: seats,
      winnerSeat: null,
      votesCount: votes,
    );
  }

  factory VoteResult.noCandidates() {
    return VoteResult(
      type: VoteResultType.noCandidates,
      seats: [],
      winnerSeat: null,
      votesCount: 0,
    );
  }
}

enum VoteResultType { winner, tieBreak, eliminationVote, noCandidates }
