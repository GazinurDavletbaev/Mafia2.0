class VoteDay {
  final List<Map<int, int>> rounds;  // ← вместо vote и revote
  final bool eliminated;
  final int eliminationVotes;
  final List<int> result;

  VoteDay({
    required this.rounds,
    this.eliminated = false,
    this.eliminationVotes = 0,
    this.result = const [],
  });

  factory VoteDay.initial() {
    return VoteDay(
      rounds: [],
      eliminated: false,
      eliminationVotes: 0,
      result: [],
    );
  }

  VoteDay addRound(Map<int, int> round) {
    return copyWith(
      rounds: [...rounds, round],
    );
  }

  VoteDay copyWith({
    List<Map<int, int>>? rounds,
    bool? eliminated,
    int? eliminationVotes,
    List<int>? result,
  }) {
    return VoteDay(
      rounds: rounds ?? this.rounds,
      eliminated: eliminated ?? this.eliminated,
      eliminationVotes: eliminationVotes ?? this.eliminationVotes,
      result: result ?? this.result,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rounds': rounds,
      'eliminated': eliminated,
      'eliminationVotes': eliminationVotes,
      'result': result,
    };
  }

  factory VoteDay.fromJson(Map<String, dynamic> json) {
    return VoteDay(
      rounds: List<Map<int, int>>.from(json['rounds'] ?? []),
      eliminated: json['eliminated'] ?? false,
      eliminationVotes: json['eliminationVotes'] ?? 0,
      result: List<int>.from(json['result'] ?? []),
    );
  }
}