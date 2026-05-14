// lib/domain/usecases/elimination_vote_usecase.dart

import '../../data/local/models/sub_phase.dart';
import '../rules/voting_rules.dart';

class EliminationVoteUsecase {
  final VotingRules _votingRules;
  
  EliminationVoteUsecase({required VotingRules votingRules})
      : _votingRules = votingRules;
  
  /// Добавить голос за выбывание кандидата
  (Map<int, int>, bool) addVote({
    required Map<int, int> eliminationVotes,
    required int candidateSeat,
    required int votesCount,
  }) {
    final newVotes = Map<int, int>.from(eliminationVotes);
    newVotes[candidateSeat] = votesCount;
    return (newVotes, true);
  }
  
  /// Проверить результат eliminationVote
  (List<int>, SubPhase) checkResult({
    required Map<int, int> eliminationVotes,
    required int totalAlive,
    required List<int> candidates,
  }) {
    final eliminated = <int>[];
    
    for (final candidate in candidates) {
      final votesFor = eliminationVotes[candidate] ?? 0;
      if (_votingRules.isEliminated(votesFor, totalAlive)) {
        eliminated.add(candidate);
      }
    }
    
    if (eliminated.isNotEmpty) {
      // Выбывшие получают finalWord
      return (eliminated, SubPhase.finalWord);
    }
    
    // Никто не выбыл → ночь
return ([], NightPhase.mafiaShoot);
  }
}