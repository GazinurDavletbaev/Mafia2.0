import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/providers.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mafia_help/presentation/state/vote_day.dart';
import '../../core/logger/app_logger.dart';
import '../../data/local/models/phase.dart';
import '../../data/local/models/sub_phase.dart';
import '../state/game_state.dart';
import 'game_viewmodel.dart';

class PlayerActions {
  final GameViewModel _vm;
  final Ref _ref;

  PlayerActions(this._vm, this._ref);

  Future<void> onPlayerTap(int seatNumber) async {
    AppLogger.d('onPlayerTap: seat=$seatNumber');

    if (_vm.state.currentSubPhase == SubPhase.roleDistribution) {
      toggleRoleCard(seatNumber);
      return;
    }

    final usecase = _ref.read(addFoulUsecaseProvider);
    final (newPlayers, winner) = usecase.execute(_vm.state.players, seatNumber);

    final oldPlayer =
        _vm.state.players.firstWhere((p) => p.seatNumber == seatNumber);
    final newPlayer = newPlayers.firstWhere((p) => p.seatNumber == seatNumber);
    final hasDied = oldPlayer.isAlive && !newPlayer.isAlive;
    final gotThirdFoul = oldPlayer.fouls == 2 && newPlayer.fouls == 3;
    final isSpeaking = _vm.state.currentSpeakerSeat == seatNumber;

    print('=== FOUL UPDATE ===');
    print('old: fouls=${oldPlayer.fouls}, isAlive=${oldPlayer.isAlive}');
    print('new: fouls=${newPlayer.fouls}, isAlive=${newPlayer.isAlive}');
    if (hasDied) {
      _vm.state = _vm.state.copyWith(players: newPlayers);
      await _killPlayer(seatNumber);
      return;
    }

    if (gotThirdFoul && isSpeaking) {
      // Меняем флаг, таймер не трогаем
      final updatedPlayer = newPlayer.copyWith(gotThirdFoulDuringSpeech: true);
      final updatedPlayers = List<PlayerModel>.from(newPlayers);
      final index =
          updatedPlayers.indexWhere((p) => p.seatNumber == seatNumber);
      updatedPlayers[index] = updatedPlayer;
      _vm.state = _vm.state.copyWith(players: updatedPlayers);
      return;
    }

    // Обновляем состояние, если игрок не умер и не получил 3-й фол во время речи
    _vm.state = _vm.state.copyWith(players: newPlayers);

    // Если игрок получил 3-й фол НЕ во время речи — флаг не меняется
    // Он будет изменён в processNextSpeaker при старте следующей речи

    if (winner != null) {
      _vm.state = _vm.state.copyWith(
        isGameEnded: true,
        winner: winner ? 'red' : 'black',
      );
    }
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

    // ✅ Находим игрока
    final existingPlayer =
        _vm.state.players.firstWhere((p) => p.seatNumber == seatNumber);
    if (!existingPlayer.isAlive && existingPlayer.fouls == 4) {
      AppLogger.d('_killPlayer: игрок уже мёртв с 4 фолами, проверяем победу');

      final newPlayers = _vm.state.players;
      final blackAlive =
          newPlayers.where((p) => p.isAlive && p.team == 'black').length;
      final redAlive =
          newPlayers.where((p) => p.isAlive && p.team == 'red').length;
      final totalAlive = blackAlive + redAlive;

      String? winner;
      if (blackAlive == 0) {
        winner = 'red';
      } else if (redAlive <= blackAlive || totalAlive < 3) {
        winner = 'black';
      }

      if (winner != null) {
        _vm.state = _vm.state.copyWith(
          isGameEnded: true,
          winner: winner,
        );
      }
      return;
    }

    // ✅ Добавляем игрока в список удалённых
    final newRemoved = List<PlayerModel>.from(_vm.state.removedPlayers);
    if (!newRemoved.any((p) => p.seatNumber == seatNumber)) {
      newRemoved.add(existingPlayer);
    }

// ✅ Добавляем удалённого игрока в voteHistory
  final day = _vm.state.currentDay;
  final existingDay = _vm.state.voteHistory[day];
  final updatedDay = (existingDay ?? VoteDay(rounds: [])).copyWith(
    result: [seatNumber],
    eliminated: false,
  );

  final newVoteHistory = Map<int, VoteDay>.from(_vm.state.voteHistory);
  newVoteHistory[day] = updatedDay;

    final usecase = _ref.read(killPlayerUsecaseProvider);
    final (newPlayers, winner) = usecase.execute(_vm.state.players, seatNumber);
    final newNominatedSeats =
        _vm.state.nominatedSeats.where((seat) => seat != seatNumber).toList();

    // Проверяем, находимся ли мы в голосовании
    final isInVoting = _vm.state.isVotingActive ||
        _vm.state.currentSubPhase == SubPhase.voting ||
        _vm.state.currentSubPhase == SubPhase.revote ||
        _vm.state.currentSubPhase == SubPhase.eliminationVote;

    GameState newState;

    if (isInVoting) {
      final aliveCount = newPlayers.where((p) => p.isAlive).length;
      newState = _vm.state.copyWith(
        players: newPlayers,
        removedPlayers: newRemoved, // ← добавляем
        currentPhase: Phase.night,
        currentSubPhase: SubPhase.mafiaShoot,
        currentDay: _vm.state.currentDay + 1,
        nominatedSeats: [],
        votes: {},
        isVotingActive: false,
        voteController: null,
        isVotingDay: true,
        isBestMove: aliveCount >= 9,
      );
    } else {
      newState = _vm.state.copyWith(
        players: newPlayers,
        removedPlayers: newRemoved, // ← добавляем
        nominatedSeats: newNominatedSeats,
        isVotingDay: false,
      );
    }

    if (winner != null) {
      newState = newState.copyWith(
        isGameEnded: true,
        winner: winner ? 'red' : 'black',
      );
    }

    _vm.state = newState;
  }

  Future<void> _revivePlayer(int seatNumber) async {
    AppLogger.d('_revivePlayer: seat=$seatNumber');
    final usecase = _ref.read(revivePlayerUsecaseProvider);
    final newPlayers = usecase.execute(_vm.state.players, seatNumber);

    _vm.state = _vm.state.copyWith(
      players: newPlayers,
    );
  }

  Future<void> _nominatePlayer(int seatNumber) async {
    AppLogger.d('_nominatePlayer: seat=$seatNumber');
    final usecase = _ref.read(nominatePlayerUsecaseProvider);
    final (newPlayers, newNominatedSeats) = usecase.execute(
      _vm.state.players,
      _vm.state.nominatedSeats,
      seatNumber,
    );

    _vm.state = _vm.state.copyWith(
      players: newPlayers,
      nominatedSeats: newNominatedSeats,
    );
  }

  Future<void> _removeNomination(int seatNumber) async {
    AppLogger.d('_removeNomination: seat=$seatNumber');
    final usecase = _ref.read(removeNominationUsecaseProvider);
    final newNominatedSeats = usecase.execute(
      _vm.state.nominatedSeats,
      seatNumber,
    );

    _vm.state = _vm.state.copyWith(nominatedSeats: newNominatedSeats);
  }

  Future<void> onNominatePlayer(int seatNumber) async {
    if (_vm.state.currentPhase == Phase.night) return;
    await _nominatePlayer(seatNumber);
  }

  Future<void> onRemoveNomination(int seatNumber) async {
    await _removeNomination(seatNumber);
  }

  Future<void> onKillPlayer(int seatNumber) async {
    await _killPlayer(seatNumber);
  }

  Future<void> onRevivePlayer(int seatNumber) async {
    await _revivePlayer(seatNumber);
  }
}
