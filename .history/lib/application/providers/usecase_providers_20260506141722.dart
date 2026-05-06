import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/repository_provider.dart';
import 'package:mafia_help/domain/usecases/add_foul_usecase.dart';
import 'package:mafia_help/domain/usecases/add_vote_usecase.dart';
import 'package:mafia_help/domain/usecases/change_phase_usecase.dart';
import 'package:mafia_help/domain/usecases/check_game_end_usecase.dart';
import 'package:mafia_help/domain/usecases/clear_votes_usecase.dart';
import 'package:mafia_help/domain/usecases/deal_roles_usecase.dart';
import 'package:mafia_help/domain/usecases/end_game_usecase.dart';
import 'package:mafia_help/domain/usecases/get_speech_order_usecase.dart';
import 'package:mafia_help/domain/usecases/kill_player_usecase.dart';
import 'package:mafia_help/domain/usecases/nominate_player_usecase.dart';
import 'package:mafia_help/domain/usecases/remove_nomination_usecase.dart';
import 'package:mafia_help/domain/usecases/reset_game_usecase.dart';
import 'package:mafia_help/domain/usecases/revive_player_usecase.dart';
import 'package:mafia_help/domain/usecases/set_current_speaker_usecase.dart';

final addFoulUsecaseProvider = Provider<AddFoulUsecase>((ref) {
  final repository = ref.read(gameRepositoryProvider);
  return AddFoulUsecase(repository: repository);
});

final killPlayerUsecaseProvider = Provider<KillPlayerUsecase>((ref) {
  final repository = ref.read(gameRepositoryProvider);
  return KillPlayerUsecase(repository: repository);
});

final revivePlayerUsecaseProvider = Provider<RevivePlayerUsecase>((ref) {
  final repository = ref.read(gameRepositoryProvider);
  return RevivePlayerUsecase(repository: repository);
});

final nominatePlayerUsecaseProvider = Provider<NominatePlayerUsecase>((ref) {
  final repository = ref.read(gameRepositoryProvider);
  return NominatePlayerUsecase(repository: repository);
});

final removeNominationUsecaseProvider = Provider<RemoveNominationUsecase>((ref) {
  final repository = ref.read(gameRepositoryProvider);
  return RemoveNominationUsecase(repository: repository);
});

final addVoteUsecaseProvider = Provider<AddVoteUsecase>((ref) {
  final repository = ref.read(gameRepositoryProvider);
  return AddVoteUsecase(repository: repository);
});

final clearVotesUsecaseProvider = Provider<ClearVotesUsecase>((ref) {
  final repository = ref.read(gameRepositoryProvider);
  return ClearVotesUsecase(repository: repository);
});

final changePhaseUsecaseProvider = Provider<ChangePhaseUsecase>((ref) {
  final repository = ref.read(gameRepositoryProvider);
  return ChangePhaseUsecase(repository: repository);
});

final checkGameEndUsecaseProvider = Provider<CheckGameEndUsecase>((ref) {
  final repository = ref.read(gameRepositoryProvider);
  return CheckGameEndUsecase(repository: repository);
});

final endGameUsecaseProvider = Provider<EndGameUsecase>((ref) {
  final repository = ref.read(gameRepositoryProvider);
  return EndGameUsecase(repository: repository);
});

final resetGameUsecaseProvider = Provider<ResetGameUsecase>((ref) {
  final repository = ref.read(gameRepositoryProvider);
  return ResetGameUsecase(repository: repository);
});

final dealRolesUsecaseProvider = Provider<DealRolesUsecase>((ref) {
  final repository = ref.read(gameRepositoryProvider);
  return DealRolesUsecase(repository: repository);
});

final setCurrentSpeakerUsecaseProvider = Provider<SetCurrentSpeakerUsecase>((ref) {
  final repository = ref.read(gameRepositoryProvider);
  return SetCurrentSpeakerUsecase(repository: repository);
});

final getSpeechOrderUsecaseProvider = Provider<GetSpeechOrderUsecase>((ref) {
  final repository = ref.read(gameRepositoryProvider);
  return GetSpeechOrderUsecase(repository: repository);
});