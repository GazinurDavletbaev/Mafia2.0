import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/providers.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import '../../core/logger/app_logger.dart';
import '../../data/local/models/sub_phase.dart';
import '../state/game_state.dart';

class GameplayActions {
  final GameViewModel _vm;
  final Ref _ref;

  GameplayActions(this._vm, this._ref);

  // ========== Фазы ==========

  Future<void> onPhaseBack() async {
    final usecase = _ref.read(changePhaseUsecaseProvider);
    final newState = await usecase(goForward: false);
    _vm.state = newState;
  }

  Future<void> onPhaseForward() async {
    AppLogger.d('onPhaseForward called BEFORE: subPhase=${_vm.state.currentSubPhase}');
    final usecase = _ref.read(changePhaseUsecaseProvider);
    final newState = await usecase(goForward: true);
    _vm.state = newState;
    AppLogger.d('onPhaseForward AFTER: subPhase=${_vm.state.currentSubPhase}');
  }

  // ========== Речи ==========

  Future<void> nextSpeaker() async {
    if (_vm.state.currentSubPhase != SubPhase.speeches) return;
    
    final aliveSeats = _vm.state.players
        .where((p) => p.isAlive)
        .map((p) => p.seatNumber)
        .toList()
      ..sort();
    
    final currentIndex = aliveSeats.indexOf(_vm.state.currentSpeakerSeat ?? 0);
    
    if (currentIndex != -1 && currentIndex + 1 < aliveSeats.length) {
      final nextSeat = aliveSeats[currentIndex + 1];
      _vm.state = _vm.state.copyWith(currentSpeakerSeat: nextSeat);
    } else {
      await onPhaseForward();
    }
  }

  Future<void> previousSpeaker() async {
    if (_vm.state.currentSubPhase != SubPhase.speeches) return;
    
    final aliveSeats = _vm.state.players
        .where((p) => p.isAlive)
        .map((p) => p.seatNumber)
        .toList()
      ..sort();
    
    final currentIndex = aliveSeats.indexOf(_vm.state.currentSpeakerSeat ?? 0);
    
    if (currentIndex > 0) {
      final prevSeat = aliveSeats[currentIndex - 1];
      _vm.state = _vm.state.copyWith(currentSpeakerSeat: prevSeat);
    }
  }

  Future<void> setCurrentSpeaker(int? seatNumber) async {
    final usecase = _ref.read(setCurrentSpeakerUsecaseProvider);
    final newState = await usecase(seatNumber);
    _vm.state = newState;
  }

  Future<void> dealRoles() async {
    final usecase = _ref.read(dealRolesUsecaseProvider);
    final newState = await usecase();
    _vm.state = newState;
  }

  // ========== Действия с игроками ==========

  Future<void> onPlayerTap(int seatNumber) async {
    AppLogger.d('onPlayerTap: seat=$seatNumber, currentSubPhase=${_vm.state.currentSubPhase}');

    if (_vm.state.currentSubPhase == SubPhase.roleDistribution) {
      toggleRoleCard(seatNumber);
      return;
    }
    
    final usecase = _ref.read(addFoulUsecaseProvider);
    final newState = await usecase(seatNumber);
    _vm.state = newState;
    await _vm.onCheckGameEnd();
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
    switch (actionType) {
      case 0: await _killPlayer(seatNumber); break;
      case 1: await _revivePlayer(seatNumber); break;
      case 2: await _nominatePlayer(seatNumber); break;
      case 3: await _removeNomination(seatNumber); break;
    }
    await _vm.onCheckGameEnd();
  }

  Future<void> _killPlayer(int seatNumber) async {
    final usecase = _ref.read(killPlayerUsecaseProvider);
    final newState = await usecase(
      seatNumber: seatNumber,
      phase: currentPhaseString(),
      killType: 'manual',
    );
    _vm.state = newState;
  }

  Future<void> _revivePlayer(int seatNumber) async {
    final usecase = _ref.read(revivePlayerUsecaseProvider);
    final newState = await usecase(seatNumber);
    _vm.state = newState;
  }

  Future<void> _nominatePlayer(int seatNumber) async {
    final usecase = _ref.read(nominatePlayerUsecaseProvider);
    final newState = await usecase(seatNumber);
    _vm.state = newState;
  }

  Future<void> _removeNomination(int seatNumber) async {
    final usecase = _ref.read(removeNominationUsecaseProvider);
    final newState = await usecase(seatNumber);
    _vm.state = newState;
  }

  // ========== Голосование ==========

  Future<void> onVote(int seat, int votes) async {
    final usecase = _ref.read(votingUsecaseProvider);
    _vm.state = await usecase(targetSeat: seat, votesCount: votes);
  }

  Future<void> onRevote() async {
    final usecase = _ref.read(revoteUsecaseProvider);
    _vm.state = await usecase();
  }

  Future<void> onNextTieCandidate() async {
    final usecase = _ref.read(tieBreakUsecaseProvider);
    _vm.state = await usecase.nextCandidate();
  }

  Future<void> onFinishTieBreak() async {
    final usecase = _ref.read(tieBreakUsecaseProvider);
    _vm.state = await usecase.finishTieBreak();
  }

  Future<void> onEliminationVote(int votes) async {
    final usecase = _ref.read(eliminationVoteUsecaseProvider);
    _vm.state = await usecase.addVotes(votes);
  }

  Future<void> onCheckEliminationResult() async {
    final usecase = _ref.read(eliminationVoteUsecaseProvider);
    _vm.state = await usecase.checkResult();
  }

  // ========== Сброс ==========

  Future<void> onResetGame() async {
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
      case Phase.voting:
        return 'voting';
      default:
        return 'night';
    }
  }
}