import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/providers.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import '../../core/logger/app_logger.dart';
import '../../data/local/models/sub_phase.dart';
import 'game_viewmodel.dart';

class GameplayActions {
  final GameViewModel _vm;
  final Ref _ref;

  GameplayActions(this._vm, this._ref);

  // ========== Фазы ==========

  Future<void> onPhaseBack() async {
    AppLogger.d('GameplayActions.onPhaseBack() called');
    final usecase = _ref.read(changePhaseUsecaseProvider);
    final newState = await usecase(goForward: false);
    _vm.state = newState;
    AppLogger.d(
      'onPhaseBack completed, newPhase=${_vm.state.currentPhase}, newSubPhase=${_vm.state.currentSubPhase}',
    );
  }

  Future<void> onPhaseForward() async {
    AppLogger.d(
      'GameplayActions.onPhaseForward() called, subPhase=${_vm.state.currentSubPhase}',
    );
    final usecase = _ref.read(changePhaseUsecaseProvider);
    final newState = await usecase(goForward: true);
    _vm.state = newState;
    AppLogger.d(
      'onPhaseForward completed, newPhase=${_vm.state.currentPhase}, newSubPhase=${_vm.state.currentSubPhase}, speaker=${_vm.state.currentSpeakerSeat}',
    );
  }

  // ========== Речи ==========

  Future<void> nextSpeaker() async {
    AppLogger.d(
      'nextSpeaker() called, currentSpeaker=${_vm.state.currentSpeakerSeat}, subPhase=${_vm.state.currentSubPhase}',
    );

    if (_vm.state.currentSubPhase != SubPhase.speeches) {
      AppLogger.d('  not in speeches phase, exiting');
      return;
    }

    final allAlive =
        _vm.state.players
            .where((p) => p.isAlive)
            .map((p) => p.seatNumber)
            .toList()
          ..sort();

    AppLogger.d('  allAlive = $allAlive');

    if (allAlive.isEmpty) {
      AppLogger.d('  no alive players, exiting');
      return;
    }

    final startSeat =
        _vm.state.dayStarterSeat ??
        _vm.state.currentSpeakerSeat ??
        allAlive.first;
    final startIndex = allAlive.indexOf(startSeat);

    final orderedSeats = <int>[];
    for (int i = 0; i < allAlive.length; i++) {
      orderedSeats.add(allAlive[(startIndex + i) % allAlive.length]);
    }

    AppLogger.d('  orderedSeats = $orderedSeats');

    final currentIndex = orderedSeats.indexOf(
      _vm.state.currentSpeakerSeat ?? 0,
    );
    AppLogger.d('  currentIndex = $currentIndex');

    if (currentIndex != -1 && currentIndex + 1 < orderedSeats.length) {
      final nextSeat = orderedSeats[currentIndex + 1];
      AppLogger.d('  next speaker: seat $nextSeat');
      _vm.state = _vm.state.copyWith(currentSpeakerSeat: nextSeat);
    } else {
      AppLogger.d('  circle completed → moving to voting');
      await onPhaseForward();
    }
  }

  Future<void> previousSpeaker() async {
    AppLogger.d(
      'previousSpeaker() called, currentSpeaker=${_vm.state.currentSpeakerSeat}, subPhase=${_vm.state.currentSubPhase}',
    );

    if (_vm.state.currentSubPhase != SubPhase.speeches) {
      AppLogger.d('  not in speeches phase, exiting');
      return;
    }

    final allAlive =
        _vm.state.players
            .where((p) => p.isAlive)
            .map((p) => p.seatNumber)
            .toList()
          ..sort();

    AppLogger.d('  allAlive = $allAlive');

    if (allAlive.isEmpty) {
      AppLogger.d('  no alive players, exiting');
      return;
    }

    final startSeat =
        _vm.state.dayStarterSeat ??
        _vm.state.currentSpeakerSeat ??
        allAlive.first;
    final startIndex = allAlive.indexOf(startSeat);

    final orderedSeats = <int>[];
    for (int i = 0; i < allAlive.length; i++) {
      orderedSeats.add(allAlive[(startIndex + i) % allAlive.length]);
    }

    AppLogger.d('  orderedSeats = $orderedSeats');

    final currentIndex = orderedSeats.indexOf(
      _vm.state.currentSpeakerSeat ?? 0,
    );
    AppLogger.d('  currentIndex = $currentIndex');

    if (currentIndex > 0) {
      final prevSeat = orderedSeats[currentIndex - 1];
      AppLogger.d('  previous speaker: seat $prevSeat');
      _vm.state = _vm.state.copyWith(currentSpeakerSeat: prevSeat);
    } else {
      AppLogger.d('  already at first speaker, cannot go back');
    }
  }

  Future<void> setCurrentSpeaker(int? seatNumber) async {
    AppLogger.d('setCurrentSpeaker() called, seat=$seatNumber');
    final usecase = _ref.read(setCurrentSpeakerUsecaseProvider);
    final newState = await usecase(seatNumber);
    _vm.state = newState;
    AppLogger.d(
      'setCurrentSpeaker completed, new speaker=${_vm.state.currentSpeakerSeat}',
    );
  }

  Future<void> dealRoles() async {
    AppLogger.d('dealRoles() called');
    final usecase = _ref.read(dealRolesUsecaseProvider);
    final newState = await usecase();
    _vm.state = newState;
    AppLogger.d('dealRoles completed');
  }

  // ========== Действия с игроками ==========

  Future<void> onPlayerTap(int seatNumber) async {
    AppLogger.d(
      'onPlayerTap: START seat=$seatNumber, currentSpeaker=${_vm.state.currentSpeakerSeat}, currentSubPhase=${_vm.state.currentSubPhase}',
    );

    if (_vm.state.currentSubPhase == SubPhase.roleDistribution) {
      AppLogger.d('  roleDistribution phase → toggling role card');
      toggleRoleCard(seatNumber);
      return;
    }

    AppLogger.d('  adding foul for seat $seatNumber');
    final usecase = _ref.read(addFoulUsecaseProvider);
    final newState = await usecase(seatNumber);
    _vm.state = newState;

    AppLogger.d(
      'onPlayerTap: AFTER foul, currentSpeaker=${_vm.state.currentSpeakerSeat}',
    );

    await _vm.onCheckGameEnd();
    AppLogger.d(
      'onPlayerTap: AFTER onCheckGameEnd, currentSpeaker=${_vm.state.currentSpeakerSeat}',
    );
  }

  void toggleRoleCard(int seatNumber) {
    AppLogger.d(
      'toggleRoleCard: seat=$seatNumber, current showing=${_vm.state.showingRoleForSeat}',
    );
    if (_vm.state.showingRoleForSeat == seatNumber) {
      _vm.state = _vm.state.copyWith(showingRoleForSeat: null);
      AppLogger.d('  role card closed');
    } else {
      _vm.state = _vm.state.copyWith(showingRoleForSeat: seatNumber);
      AppLogger.d('  role card opened for seat $seatNumber');
    }
  }

  void closeRoleCard() {
    AppLogger.d('closeRoleCard called');
    _vm.state = _vm.state.copyWith(showingRoleForSeat: null);
  }

  Future<void> onPlayerLongPress(int seatNumber, int actionType) async {
    AppLogger.d('onPlayerLongPress: seat=$seatNumber, actionType=$actionType');
    switch (actionType) {
      case 0:
        await _killPlayer(seatNumber);
        break;
      case 1:
        await _revivePlayer(seatNumber);
        break;
      case 2:
        await _nominatePlayer(seatNumber);
        break;
      case 3:
        await _removeNomination(seatNumber);
        break;
      default:
        AppLogger.d('  unknown actionType: $actionType');
    }
    await _vm.onCheckGameEnd();
  }

  Future<void> _killPlayer(int seatNumber) async {
    AppLogger.d('_killPlayer: seat=$seatNumber');
    final usecase = _ref.read(killPlayerUsecaseProvider);
    final newState = await usecase(
      seatNumber: seatNumber,
      phase: currentPhaseString(),
      killType: 'manual',
    );
    _vm.state = newState;
    AppLogger.d('_killPlayer completed');
  }

  Future<void> _revivePlayer(int seatNumber) async {
    AppLogger.d('_revivePlayer: seat=$seatNumber');
    final usecase = _ref.read(revivePlayerUsecaseProvider);
    final newState = await usecase(seatNumber);
    _vm.state = newState;
    AppLogger.d('_revivePlayer completed');
  }

  Future<void> _nominatePlayer(int seatNumber) async {
    AppLogger.d('_nominatePlayer: seat=$seatNumber');
    final usecase = _ref.read(nominatePlayerUsecaseProvider);
    final newState = await usecase(seatNumber);
    _vm.state = newState;
    AppLogger.d('_nominatePlayer completed');
  }

  Future<void> _removeNomination(int seatNumber) async {
    AppLogger.d('_removeNomination: seat=$seatNumber');
    final usecase = _ref.read(removeNominationUsecaseProvider);
    final newState = await usecase(seatNumber);
    _vm.state = newState;
    AppLogger.d('_removeNomination completed');
  }

  // ========== Голосование ==========

  Future<void> onVote(int seat, int votes) async {
    AppLogger.d('onVote: seat=$seat, votes=$votes');
    final usecase = _ref.read(votingUsecaseProvider);
    _vm.state = await usecase(targetSeat: seat, votesCount: votes);
    AppLogger.d('onVote completed, current votes=${_vm.state.votes}');
  }

  Future<void> onRevote() async {
    AppLogger.d('onRevote called');
    final usecase = _ref.read(revoteUsecaseProvider);
    _vm.state = await usecase();
    AppLogger.d('onRevote completed, subPhase=${_vm.state.currentSubPhase}');
  }

  Future<void> onNextTieCandidate() async {
    AppLogger.d('onNextTieCandidate called');
    final usecase = _ref.read(tieBreakUsecaseProvider);
    _vm.state = await usecase.nextCandidate();
    AppLogger.d(
      'onNextTieCandidate completed, currentTieIndex=${_vm.state.currentTieIndex}',
    );
  }

  Future<void> onFinishTieBreak() async {
    AppLogger.d('onFinishTieBreak called');
    final usecase = _ref.read(tieBreakUsecaseProvider);
    _vm.state = await usecase.finishTieBreak();
    AppLogger.d('onFinishTieBreak completed');
  }

  Future<void> onEliminationVote(int votes) async {
    AppLogger.d('onEliminationVote: votes=$votes');
    final usecase = _ref.read(eliminationVoteUsecaseProvider);
    _vm.state = await usecase.addVotes(votes);
    AppLogger.d('onEliminationVote completed');
  }

  Future<void> onCheckEliminationResult() async {
    AppLogger.d('onCheckEliminationResult called');
    final usecase = _ref.read(eliminationVoteUsecaseProvider);
    _vm.state = await usecase.checkResult();
    AppLogger.d(
      'onCheckEliminationResult completed, subPhase=${_vm.state.currentSubPhase}',
    );
  }

  // ========== Сброс ==========

  Future<void> onResetGame() async {
    AppLogger.d('onResetGame called');
    final usecase = _ref.read(resetGameUsecaseProvider);
    final newState = await usecase();
    _vm.state = newState;
    AppLogger.d('onResetGame completed');
  }

  // ========== Вспомогательные ==========

  String currentPhaseString() {
    final phase = _vm.state.currentPhase;
    switch (phase) {
      case Phase.night:
        return 'night';
      case Phase.day:
        return 'day';
    }
  }
}
