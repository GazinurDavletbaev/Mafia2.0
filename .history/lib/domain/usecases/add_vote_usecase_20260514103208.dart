// lib/domain/usecases/add_vote_usecase.dart

class AddVoteUsecase {
  AddVoteUsecase();
  
  Map<int, int> execute(
    Map<int, int> currentVotes,
    int candidateSeat,
    int votesCount,
  ) {
    final newVotes = Map<int, int>.from(currentVotes);
    newVotes[candidateSeat] = votesCount;
    return newVotes;
  }
}