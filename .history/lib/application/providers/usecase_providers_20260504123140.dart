import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/game_state_provider.dart';
import 'package:mafia_help/application/providers/repository_provider.dart';
import 'package:mafia_help/domain/usecases/add_best_move_usecase.dart';
import 'package:mafia_help/domain/usecases/add_foul_usecase.dart';
import 'package:mafia_help/domain/usecases/add_vote_usecase.dart';
import 'package:mafia_help/domain/usecases/change_phase_usecase.dart';
import 'package:mafia_help/domain/usecases/check_game_end_usecase.dart';
import 'package:mafia_help/domain/usecases/clear_votes_usecase.dart';
import 'package:mafia_help/domain/usecases/commit_best_move_usecase.dart';
import 'package:mafia_help/domain/usecases/end_game_usecase.dart';
import 'package:mafia_help/domain/usecases/get_speech_order_usecase.dart';
import 'package:mafia_help/domain/usecases/kill_player_usecase.dart';
import 'package:mafia_help/domain/usecases/nominate_player_usecase.dart';
import 'package:mafia_help/domain/usecases/pop_best_move_usecase.dart';
import 'package:mafia_help/domain/usecases/remove_nomination_usecase.dart';
import 'package:mafia_help/domain/usecases/reset_game_usecase.dart';
import 'package:mafia_help/domain/usecases/revive_player_usecase.dart';
import 'package:mafia_help/domain/usecases/set_current_speaker_usecase.dart';
import 'package:mafia_help/domain/usecases/add_best_move_usecase.dart';
import 'package:mafia_help/domain/usecases/pop_best_move_usecase.dart';

// ========== UseCase провайдеры ==========

final addFoulUsecaseProvider = Provider<AddFoulUsecase>((ref) {
  final repository = ref.read(gameRepositoryProvider);
  final notifier = ref.read(gameStateProvider.notifier);
  return AddFoulUsecase(
    repository: repository,
    notifier: notifier,
  );
});

final killPlayerUsecaseProvider = Provider<KillPlayerUsecase>((ref) {
  final repository = ref.read(gameRepositoryProvider);
  final notifier = ref.read(gameStateProvider.notifier);
  return KillPlayerUsecase(
    repository: repository,
    notifier: notifier,
  );
});

final revivePlayerUsecaseProvider = Provider<RevivePlayerUsecase>((ref) {
  final repository = ref.read(gameRepositoryProvider);
  final notifier = ref.read(gameStateProvider.notifier);
  return RevivePlayerUsecase(
    repository: repository,
    notifier: notifier,
  );
});

final nominatePlayerUsecaseProvider = Provider<NominatePlayerUsecase>((ref) {
  final repository = ref.read(gameRepositoryProvider);
  final notifier = ref.read(gameStateProvider.notifier);
  return NominatePlayerUsecase(
    repository: repository,
    notifier: notifier,
  );
});

final removeNominationUsecaseProvider = Provider<RemoveNominationUsecase>((ref) {
  final repository = ref.read(gameRepositoryProvider);
  final notifier = ref.read(gameStateProvider.notifier);
  return RemoveNominationUsecase(
    repository: repository,
    notifier: notifier,
  );
});

final addVoteUsecaseProvider = Provider<AddVoteUsecase>((ref) {
  final repository = ref.read(gameRepositoryProvider);
  final notifier = ref.read(gameStateProvider.notifier);
  return AddVoteUsecase(
    repository: repository,
    notifier: notifier,
  );
});

final clearVotesUsecaseProvider = Provider<ClearVotesUsecase>((ref) {
  final repository = ref.read(gameRepositoryProvider);
  final notifier = ref.read(gameStateProvider.notifier);
  return ClearVotesUsecase(
    repository: repository,
    notifier: notifier,
  );
});

final addBestMoveUsecaseProvider = Provider<AddBestMoveUsecase>((ref) {
  final repository = ref.read(gameRepositoryProvider);
  final notifier = ref.read(gameStateProvider.notifier);
  return AddBestMoveUsecase(
    repository: repository,
    notifier: notifier,
  );
});

final popBestMoveUsecaseProvider = Provider<PopBestMoveUsecase>((ref) {
  final repository = ref.read(gameRepositoryProvider);
  final notifier = ref.read(gameStateProvider.notifier);
  return PopBestMoveUsecase(
    repository: repository,
    notifier: notifier,
  );
});

final commitBestMoveUsecaseProvider = Provider<CommitBestMoveUsecase>((ref) {
  final repository = ref.read(gameRepositoryProvider);
  final notifier = ref.read(gameStateProvider.notifier);
  return CommitBestMoveUsecase(
    repository: repository,
    notifier: notifier,
  );
});

final changePhaseUsecaseProvider = Provider<ChangePhaseUsecase>((ref) {
  final repository = ref.read(gameRepositoryProvider);
  final notifier = ref.read(gameStateProvider.notifier);
  return ChangePhaseUsecase(
    repository: repository,
    notifier: notifier,
  );
});

final checkGameEndUsecaseProvider = Provider<CheckGameEndUsecase>((ref) {
  final repository = ref.read(gameRepositoryProvider);
  return CheckGameEndUsecase(
    repository: repository,
  );
});

final endGameUsecaseProvider = Provider<EndGameUsecase>((ref) {
  final repository = ref.read(gameRepositoryProvider);
  final notifier = ref.read(gameStateProvider.notifier);
  return EndGameUsecase(
    repository: repository,
    notifier: notifier,
  );
});

final resetGameUsecaseProvider = Provider<ResetGameUsecase>((ref) {
  final repository = ref.read(gameRepositoryProvider);
  final notifier = ref.read(gameStateProvider.notifier);
  return ResetGameUsecase(
    repository: repository,
    notifier: notifier,
  );
});

final getSpeechOrderUsecaseProvider = Provider<GetSpeechOrderUsecase>((ref) {
  final repository = ref.read(gameRepositoryProvider);
  return GetSpeechOrderUsecase(
    repository: repository,
  );
});

final setCurrentSpeakerUsecaseProvider = Provider<SetCurrentSpeakerUsecase>((ref) {
  final repository = ref.read(gameRepositoryProvider);
  final notifier = ref.read(gameStateProvider.notifier);
  return SetCurrentSpeakerUsecase(
    repository: repository,
    notifier: notifier,
  );
});