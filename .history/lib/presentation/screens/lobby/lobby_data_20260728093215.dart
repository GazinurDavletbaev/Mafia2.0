// lib/presentation/screens/lobby/lobby_data.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/user_provider.dart';
import '../../../domain/rules/game_history.dart';
import '../../state/game_state.dart';

class GameData {
  String tournamentName;
  String stageName;
  int tableNumber;
  int gameNumber;
  DateTime date;
  String judgeName;
  List<String> playerNames;
  GameState gameState;
  GameHistory gameHistory;

  GameData({
    this.tournamentName = 'РЕЙТИНГ',
    this.stageName = '',
    this.tableNumber = 1,
    this.gameNumber = 1,
    DateTime? date,
    this.judgeName = '',
    this.playerNames = const [],
    GameState? gameState,
    GameHistory? gameHistory,
  })  : date = date ?? DateTime.now(),
        gameState = gameState ?? GameState.initial(),
        gameHistory = gameHistory ?? GameHistory();
}

class LobbyData {
  static String getCurrentStage() {
    const months = [
      'ЯНВАРЬ', 'ФЕВРАЛЬ', 'МАРТ', 'АПРЕЛЬ', 'МАЙ', 'ИЮНЬ',
      'ИЮЛЬ', 'АВГУСТ', 'СЕНТЯБРЬ', 'ОКТЯБРЬ', 'НОЯБРЬ', 'ДЕКАБРЬ'
    ];
    return months[DateTime.now().month - 1];
  }

  static String getJudgeName(WidgetRef ref) {
    final user = ref.watch(userProvider).value;
    return user?['username'] ?? 'Судья';
  }

  static GameData createInitial(WidgetRef ref) {
    return GameData(
      judgeName: getJudgeName(ref),
      tournamentName: 'РЕЙТИНГ',
      stageName: getCurrentStage(),
    );
  }
}