import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/repository_provider.dart';
import 'package:mafia_help/domain/usecases/add_foul_usecase.dart';
import 'package:mafia_help/domain/usecases/deal_roles_usecase.dart';
import 'package:mafia_help/domain/usecases/kill_player_usecase.dart';
import 'package:mafia_help/domain/usecases/nominate_player_usecase.dart';
import 'package:mafia_help/domain/usecases/remove_nomination_usecase.dart';
import 'package:mafia_help/domain/usecases/reset_game_usecase.dart';
import 'package:mafia_help/domain/usecases/revive_player_usecase.dart';

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
  return RevivePlayerUsecase(playerRules: ref.watch(playerRulesProvider));
});

final nominatePlayerUsecaseProvider = Provider<NominatePlayerUsecase>((ref) {
  return NominatePlayerUsecase();
});

final removeNominationUsecaseProvider = Provider<RemoveNominationUsecase>((
  ref,
) {
  return RemoveNominationUsecase();
});

final addVoteUsecaseProvider = Provider<AddVoteUsecase>((ref) {
  return AddVoteUsecase();
});

final setCurrentSpeakerUsecaseProvider = Provider<SetCurrentSpeakerUsecase>((
  ref,
) {
  return SetCurrentSpeakerUsecase();
});


final resetGameUsecaseProvider = Provider<ResetGameUsecase>((ref) {
  final repository = ref.read(gameRepositoryProvider);
  return ResetGameUsecase(repository: repository);
});

final dealRolesUsecaseProvider = Provider<DealRolesUsecase>((ref) {
  return DealRolesUsecase();
});

final revoteUsecaseProvider = Provider<RevoteUsecase>((ref) {
  return RevoteUsecase(votingRules: ref.watch(votingRulesProvider));
});

final tieBreakUsecaseProvider = Provider<TieBreakUsecase>((ref) {
  return TieBreakUsecase();
});

final eliminationVoteUsecaseProvider = Provider<EliminationVoteUsecase>((ref) {
  return EliminationVoteUsecase(votingRules: ref.watch(votingRulesProvider));
});
