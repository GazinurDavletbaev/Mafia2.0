import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/repository_provider.dart';
import 'package:mafia_help/domain/usecases/add_foul_usecase.dart';
import 'package:mafia_help/domain/usecases/add_vote_usecase.dart';
import 'package:mafia_help/domain/usecases/change_phase_usecase.dart';
import 'package:mafia_help/domain/usecases/check_game_end_usecase.dart';
import 'package:mafia_help/domain/usecases/deal_roles_usecase.dart';
import 'package:mafia_help/domain/usecases/end_game_usecase.dart';
import 'package:mafia_help/domain/usecases/kill_player_usecase.dart';
import 'package:mafia_help/domain/usecases/nominate_player_usecase.dart';
import 'package:mafia_help/domain/usecases/remove_nomination_usecase.dart';
import 'package:mafia_help/domain/usecases/reset_game_usecase.dart';
import 'package:mafia_help/domain/usecases/revive_player_usecase.dart';
import 'package:mafia_help/domain/usecases/set_current_speaker_usecase.dart';

import '../../domain/usecases/elimination_vote_usecase.dart';
import '../../domain/usecases/revote_usecase.dart';
import '../../domain/usecases/tie_break_usecase.dart';
import 'rules_providers.dart';

final addFoulUsecaseProvider = Provider<AddFoulUsecase>((ref) {
  return AddFoulUsecase(
    playerRules: ref.watch(playerRulesProvider),
    winRules: ref.watch(winRulesProvider),
  );
});

final killPlayerUsecaseProvider = Provider<KillPlayerUsecase>((ref) {
  return KillPlayerUsecase(
    playerRules: ref.watch(playerRulesProvider),
    winRules: ref.watch(winRulesProvider),
  );
});

final revivePlayerUsecaseProvider = Provider<RevivePlayerUsecase>((ref) {
  return RevivePlayerUsecase(
    playerRules: ref.watch(playerRulesProvider),
  );
});

final nominatePlayerUsecaseProvider = Provider<NominatePlayerUsecase>((ref) {
  return NominatePlayerUsecase();
});

final removeNominationUsecaseProvider = Provider<RemoveNominationUsecase>((ref) {
  return RemoveNominationUsecase();
});

final addVoteUsecaseProvider = Provider<AddVoteUsecase>((ref) {
  return AddVoteUsecase();
});

final setCurrentSpeakerUsecaseProvider = Provider<SetCurrentSpeakerUsecase>((ref) {
  return SetCurrentSpeakerUsecase();
});

final nominatePlayerUsecaseProvider = Provider<NominatePlayerUsecase>((ref) {
  return NominatePlayerUsecase();
});

final removeNominationUsecaseProvider = Provider<RemoveNominationUsecase>((ref) {
  return RemoveNominationUsecase();
});

final addVoteUsecaseProvider = Provider<AddVoteUsecase>((ref) {
  return AddVoteUsecase();
});

final changePhaseUsecaseProvider = Provider<ChangePhaseUsecase>((ref) {
  final repository = ref.read(gameRepositoryProvider);
  return ChangePhaseUsecase(repository: repository);
});

final setCurrentSpeakerUsecaseProvider = Provider<SetCurrentSpeakerUsecase>((ref) {
  return SetCurrentSpeakerUsecase();
});

final resetGameUsecaseProvider = Provider<ResetGameUsecase>((ref) {
  final repository = ref.read(gameRepositoryProvider);
  return ResetGameUsecase(repository: repository);
});

final endGameUsecaseProvider = Provider<EndGameUsecase>((ref) {
  final repository = ref.read(gameRepositoryProvider);
  return EndGameUsecase(repository: repository);
});

final dealRolesUsecaseProvider = Provider<DealRolesUsecase>((ref) {
  return DealRolesUsecase();
});

final checkGameEndUsecaseProvider = Provider<CheckGameEndUsecase>((ref) {
  final repository = ref.read(gameRepositoryProvider);
  return CheckGameEndUsecase(repository: repository);
});
final revoteUsecaseProvider = Provider<RevoteUsecase>((ref) {
  return RevoteUsecase();
});

final tieBreakUsecaseProvider = Provider<TieBreakUsecase>((ref) {
  return TieBreakUsecase();
});

final eliminationVoteUsecaseProvider = Provider<EliminationVoteUsecase>((ref) {
  return EliminationVoteUsecase();
});