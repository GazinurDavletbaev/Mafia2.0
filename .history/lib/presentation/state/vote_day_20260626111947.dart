class VoteDay {
  final Map<int, int> vote; // игрок → голоса (основное голосование)
  final Map<int, int>? revote; // игрок → голоса (переголосование)
  final bool eliminated; // true = ушли, false = никто не ушёл
  final int eliminationVotes; // голоса за подъём
  final List<int> result; // кто ушёл (список игроков)

  VoteDay({
    required this.vote,
    this.revote,
    this.eliminated = false,
    this.eliminationVotes = 0,
    this.result = const [],
  });

  VoteDay copyWith({
    Map<int, int>? vote,
    Map<int, int>? revote,
    bool? eliminated,
    int? eliminationVotes,
    List<int>? result,
  }) {
    return VoteDay(
      vote: vote ?? this.vote,
      revote: revote ?? this.revote,
      eliminated: eliminated ?? this.eliminated,
      eliminationVotes: eliminationVotes ?? this.eliminationVotes,
      result: result ?? this.result,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    final voteMap = <String, int>{};
    vote.forEach((k, v) => voteMap[k.toString()] = v);
    data['vote'] = voteMap;

    if (revote != null && revote!.isNotEmpty) {
      final revoteMap = <String, int>{};
      revote!.forEach((k, v) => revoteMap[k.toString()] = v);
      data['revote'] = revoteMap;
    }

    data['eliminated'] = eliminated;
    data['eliminationVotes'] = eliminationVotes;
    data['result'] = result;

    return data;
  }

  factory VoteDay.fromJson(Map<String, dynamic> json) {
    final vote = <int, int>{};
    (json['vote'] as Map<String, dynamic>).forEach((k, v) {
      vote[int.parse(k)] = v;
    });

    Map<int, int>? revote;
    if (json['revote'] != null) {
      revote = {};
      (json['revote'] as Map<String, dynamic>).forEach((k, v) {
        revote![int.parse(k)] = v;
      });
    }

    return VoteDay(
      vote: vote,
      revote: revote,
      eliminated: json['eliminated'] ?? false,
      eliminationVotes: json['eliminationVotes'] ?? 0,
      result: List<int>.from(json['result'] ?? []),
    );
  }
}
