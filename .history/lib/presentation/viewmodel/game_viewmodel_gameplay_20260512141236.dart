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
  final newState = await usecase(_vm.state, goForward: false);
  _vm.state = newState;
}

Future<void> onPhaseForward() async {
  AppLogger.d('GameplayActions.onPhaseForward() called');
  final usecase = _ref.read(changePhaseUsecaseProvider);
  final newState = await usecase(_vm.state, goForward: true);
  _vm.state = newState;
}

  // ========== Речи ==========

  Future<void> nextSpeaker() async {
    AppLogger.d('nextSpeaker() called, currentSpeaker=${_vm.state.currentSpeakerSeat}');
    
    if (_vm.state.currentSubPhase != SubPhase.speeches) {
      AppLogger.d('  not in speeches phase, exiting');
      return;
    }

    final allAlive = _vm.state.players
        .where((p) => p.isAlive)
        .map((p) => p.seatNumber)
        .toList()
      ..sort();

    if (allAlive.isEmpty) {
      AppLogger.d('  no alive players, exiting');
      return;
    }

    final startSeat = _vm.state.dayStarterSeat ?? _vm.state.currentSpeakerSeat ?? allAlive.first;
    final startIndex = allAlive.indexOf(startSeat);

    final orderedSeats = <int>[];
    for (int i = 0; i < allAlive.length; i++) {
      orderedSeats.add(allAlive[(startIndex + i) % allAlive.length]);
    }

    final currentIndex = orderedSeats.indexOf(_vm.state.currentSpeakerSeat ?? 0);
    
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
    AppLogger.d('previousSpeaker() called, currentSpeaker=${_vm.state.currentSpeakerSeat}');
    
    if (_vm.state.currentSubPhase != SubPhase.speeches) {
      AppLogger.d('  not in speeches phase, exiting');
      return;
    }

    final allAlive = _vm.state.players
        .where((p) => p.isAlive)
        .map((p) => p.seatNumber)
        .toList()
      ..sort();

    if (allAlive.isEmpty) {
      AppLogger.d('  no alive players, exiting');
      return;
    }

    final startSeat = _vm.state.dayStarterSeat ?? _vm.state.currentSpeakerSeat ?? allAlive.first;
    final startIndex = allAlive.indexOf(startSeat);

    final orderedSeats = <int>[];
    for (int i = 0; i < allAlive.length; i++) {
      orderedSeats.add(allAlive[(startIndex + i) % allAlive.length]);
    }

    final currentIndex = orderedSeats.indexOf(_vm.state.currentSpeakerSeat ?? 0);
    
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
  }

  Future<void> dealRoles() async {
    AppLogger.d('dealRoles() called');
    final usecase = _ref.read(dealRolesUsecaseProvider);
    final newState = await usecase();
    _vm.state = newState;
  }

  // ========== Действия с игроками ==========

  Future<void> onPlayerTap(int seatNumber) async {
    AppLogger.d('onPlayerTap: seat=$seatNumber, currentSpearker=${_vm.state.currentSpeakerSeat}');

    if (_vm.state.currentSubPhase == SubPhase.roleDistribution) {
      toggleRoleCard(seatNumber);
      return;
    }

    AppLogger.d('  adding foul for seat $seatNumber');
    final usecase = _ref.read(addFoulUsecaseProvider);
    final newState = await usecase(seatNumber);
    _vm.state = newState;
  }

  void toggleRoleCard(int seatNumber) {
    if (_vm.state.showingRoleForSeat == seatNumber) {
      _vm.state = _vm.state.copyWith(showingRoleForSeat: null);
    } else {
      _vm.state = _vm.state.copyWith(showingRoleForSeat: seatNumber);
    }
  }

  void closeRoleCard() {
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
  }

  Future<void> _revivePlayer(int seatNumber) async {
    AppLogger.d('_revivePlayer: seat=$seatNumber');
    final usecase = _ref.read(revivePlayerUsecaseProvider);
    final newState = await usecase(seatNumber);
    _vm.state = newState;
  }

  Future<void> _nominatePlayer(int seatNumber) async {
    AppLogger.d('_nominatePlayer: seat=$seatNumber');
    final usecase = _ref.read(nominatePlayerUsecaseProvider);
    final newState = await usecase(seatNumber);
    _vm.state = newState;
  }

  Future<void> _removeNomination(int seatNumber) async {
    AppLogger.d('_removeNomination: seat=$seatNumber');
    final usecase = _ref.read(removeNominationUsecaseProvider);
    final newState = await usecase(seatNumber);
    _vm.state = newState;
  }

  // ========== Голосование ==========

  Future<void> onVote(int seat, int votes) async {
    AppLogger.d('onVote: seat=$seat, votes=$votes');
    final usecase = _ref.read(votingUsecaseProvider);
    _vm.state = await usecase(targetSeat: seat, votesCount: votes);
  }

  Future<void> onRevote() async {
    AppLogger.d('onRevote called');
    final usecase = _ref.read(revoteUsecaseProvider);
    _vm.state = await usecase();
  }

  Future<void> onNextTieCandidate() async {
    AppLogger.d('onNextTieCandidate called');
    final usecase = _ref.read(tieBreakUsecaseProvider);
    _vm.state = await usecase.nextCandidate();
  }

  Future<void> onFinishTieBreak() async {
    AppLogger.d('onFinishTieBreak called');
    final usecase = _ref.read(tieBreakUsecaseProvider);
    _vm.state = await usecase.finishTieBreak();
  }

  Future<void> onEliminationVote(int votes) async {
    AppLogger.d('onEliminationVote: votes=$votes');
    final usecase = _ref.read(eliminationVoteUsecaseProvider);
    _vm.state = await usecase.addVotes(votes);
  }

  Future<void> onCheckEliminationResult() async {
    AppLogger.d('onCheckEliminationResult called');
    final usecase = _ref.read(eliminationVoteUsecaseProvider);
    _vm.state = await usecase.checkResult();
  }

  // ========== Сброс ==========

  Future<void> onResetGame() async {
    AppLogger.d('onResetGame called');
    final usecase = _ref.read(resetGameUsecaseProvider);
    final newState = await usecase();
    _vm.state = newState;
  }

  // ========== Вспомогательные ==========

  String currentPhaseString() {
    switch (_vm.state.currentPhase) {
      case Phase.night:
        return 'night';
      case Phase.day:
        return 'day';
    }
  }
}