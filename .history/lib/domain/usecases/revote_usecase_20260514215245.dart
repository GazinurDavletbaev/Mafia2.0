// lib/domain/usecases/revote_usecase.dart

import '../rules/voting_rules.dart';
import '../../data/local/models/sub_phase.dart';

class RevoteUsecase {
  final VotingRules _votingRules;
  
  RevoteUsecase({required VotingRules votingRules})
      : _votingRules = votingRules;
  
  (SubPhase, int?, List<int>) execute({
    required Map<int, int> voteCounts,
    required List<int> candidates,
    required int totalAlive,
    required bool tieBreakDone,
    required List<int>? lastTieBreakLeaders,
  }) {
    final leaders = _votingRules.findLeaders(voteCounts);
    
    // Победитель один
    if (leaders.length == 1) {
      return (SubPhase.finalWord, leaders.first, []);
    }
    
    // Несколько лидеров
    final needsTieBreak = _votingRules.needsTieBreak(
      currentLeaders: leaders,
      previousLeaders: lastTieBreakLeaders,
      tieBreakDone: tieBreakDone,
    );
    
    if (needsTieBreak) {
      return (SubPhase.tieBreak, null, leaders);
    }
    
    // Перестрелка уже была → eliminationVote
    return (SubPhase.eliminationVote, null, leaders);
  }
}