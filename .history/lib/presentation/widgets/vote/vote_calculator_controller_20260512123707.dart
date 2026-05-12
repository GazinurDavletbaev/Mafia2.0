class VoteCalculatorController {
  final List<int> candidateSeats;
  final Map<int, int> votes;
  int currentIndex;
  bool isVisible;

  VoteCalculatorController({
    required this.candidateSeats,
    this.votes = const {},
    this.currentIndex = 0,
    this.isVisible = true,
  });

  int get currentSeat => candidateSeats[currentIndex];
  int get currentVotes => votes[currentSeat] ?? 0;
  
  void setVotes(int seat, int count) {
    votes[seat] = count;
  }
  
  void nextCandidate() {
    if (currentIndex + 1 < candidateSeats.length) {
      currentIndex++;
    }
  }
  
  void previousCandidate() {
    if (currentIndex > 0) {
      currentIndex--;
    }
  }
  
  void toggleVisibility() {
    isVisible = !isVisible;
  }
  
  bool get isComplete {
    return votes.keys.length == candidateSeats.length;
  }
  
  Map<int, int> get results => Map.unmodifiable(votes);
}