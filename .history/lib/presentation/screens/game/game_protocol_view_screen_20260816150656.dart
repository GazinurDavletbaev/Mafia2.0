// lib/presentation/screens/game/game_protocol_view_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/data/local/models/phase.dart';
import 'package:mafia_help/data/local/models/player_model.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/presentation/state/vote_day.dart';
import 'package:mafia_help/presentation/widgets/protocol/protocol_header.dart';
import 'package:mafia_help/presentation/widgets/protocol/protocol_info_row.dart';
import 'package:mafia_help/presentation/widgets/protocol/protocol_notes.dart';
import 'package:mafia_help/presentation/widgets/protocol/protocol_players_table.dart';
import 'package:mafia_help/presentation/widgets/protocol/protocol_voting_table.dart';
import 'package:mafia_help/services/club_service.dart';

class GameProtocolViewScreen extends ConsumerStatefulWidget {
  final int? gameId;
  final Map<String, dynamic>? gameData;

  const GameProtocolViewScreen({
    super.key,
    this.gameId,
    this.gameData,
  });

  @override
  ConsumerState<GameProtocolViewScreen> createState() =>
      _GameProtocolViewScreenState();
}

class _GameProtocolViewScreenState
    extends ConsumerState<GameProtocolViewScreen> {
  GameState? _gameState;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    if (widget.gameData != null) {
      _gameState = _convertToGameState(widget.gameData!);
      _isLoading = false;
    } else if (widget.gameId != null) {
      _loadGame();
    } else {
      _error = 'Нет данных для отображения';
      _isLoading = false;
    }
  }

  GameState _convertToGameState(Map<String, dynamic> data) {
    // 🔥 КОНВЕРТИРУЕМ JSON В GameState
    final players = (data['players'] as List? ?? []).map((p) {
      return PlayerModel(
        id: 'player_${p['seat']}',
        seatNumber: p['seat'] ?? 0,
        name: p['name'] ?? '',
        role: p['role'] ?? 'unknown',
        team: _getTeamByRole(p['role']),
        isAlive: true,
        fouls: p['fouls'] ?? 0,
        techFouls: 0,
        isSpeaking: false,
        gameId: '',
        hasSkippedSpeech: false,
        gotThirdFoulDuringSpeech: false,
        avatarUrl: '',
      );
    }).toList();

    // 🔥 ПАРСИМ BEST_MOVE
    List<int> bestMove = [];
    if (data['best_move'] != null && data['best_move'].toString().isNotEmpty) {
      try {
        final parts = data['best_move'].toString().split(',');
        bestMove = parts.map((e) => int.tryParse(e.trim()) ?? 0).toList();
      } catch (_) {
        bestMove = [];
      }
    }

    // 🔥 ПАРСИМ НОЧНЫЕ ДЕЙСТВИЯ
    List<int> nightActions = [];
    final nightData = data['night_actions'] as List? ?? [];
    for (final night in nightData) {
      final kill = night['kill'] ?? 0;
      final don = night['don'] ?? 0;
      final sheriff = night['sheriff'] ?? 0;
      nightActions.addAll([kill, don, sheriff]);
    }

    // 🔥 ПАРСИМ VOTE_HISTORY
    final Map<int, VoteDay> voteHistory = {};
    final voteHistoryData = data['vote_history'] as Map<String, dynamic>? ?? {};

    for (final entry in voteHistoryData.entries) {
      final day = int.parse(entry.key);
      final dayData = entry.value as Map<String, dynamic>;

      final rounds = (dayData['rounds'] as List? ?? []).map((round) {
        final Map<int, int> parsedRound = {};
        (round as Map<String, dynamic>).forEach((key, value) {
          parsedRound[int.parse(key)] = value as int;
        });
        return parsedRound;
      }).toList();

      final result =
          (dayData['result'] as List? ?? []).map((e) => e as int).toList();
      final eliminationVotes = dayData['eliminationVotes'] ?? 0;

      voteHistory[day] = VoteDay(
        rounds: rounds,
        eliminated: dayData['eliminated'] ?? false,
        eliminationVotes: eliminationVotes,
        result: result,
      );
    }

    return GameState(
      game: null,
      players: players,
      currentPhase: Phase.day,
      currentSubPhase: SubPhase.finalWord,
      currentSubPhaseIndex: 0,
      currentDay: 0,
      currentSpeakerSeat: null,
      nominatedSeats: [],
      removedPlayers: [],
      votes: {},
      partialBestMove: bestMove,
      isGameEnded: true,
      winner: data['winner'],
      currentRound: 1,
      showingRoleForSeat: null,
      hasKillInLastNight: false,
      eliminationVotes: 0,
      tiedSeats: const [],
      currentTieIndex: 0,
      dayStarterSeat: null,
      voteController: null,
      isVotingActive: false,
      nightActions: nightActions,
      phaseHistory: [],
      speechHistory: [],
      voteHistory: voteHistory,
      isBestMove: false,
      isVotingDay: true,
      currentSpeakerTimer: null,
      tableNumber: data['table'],
      gameNumber: data['game'],
      gameDate: data['date'] != null ? DateTime.parse(data['date']) : null,
      judgeName: data['judge'],
      tournamentName: data['tournament'],
      stageName: data['stage'],
      ppkPlayerSeat: null,
    );
  }

  String _getTeamByRole(String? role) {
    switch (role) {
      case 'don':
      case 'mafia':
        return 'black';
      case 'sheriff':
      case 'citizen':
        return 'red';
      default:
        return 'unknown';
    }
  }

  Future<void> _loadGame() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await ClubService.getGame(widget.gameId!);

    if (result['success']) {
      setState(() {
        _gameState = _convertToGameState(result['data']);
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = result['error'] ?? 'Ошибка загрузки';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Протокол игры'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        actions: [
          if (widget.gameId != null)
            IconButton(
              icon: Icon(Icons.refresh,
                  color: isDark ? Colors.white : Colors.black87),
              onPressed: _loadGame,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (widget.gameId != null) ...[
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadGame,
                          child: const Text('Повторить'),
                        ),
                      ],
                    ],
                  ),
                )
              : _gameState == null
                  ? const Center(child: Text('Нет данных'))
                  : _buildProtocolContent(),
    );
  }

  Widget _buildProtocolContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ProtocolHeader(gameState: _gameState!),
          const SizedBox(height: 16),
          ProtocolPlayersTable(
            gameState: _gameState!,
            bonusPoints: List.generate(10, (_) => 0.0),
            onRemovedRuleChanged: (_, __) {},
            onBonusChanged: (_, __) {},
            onNoteAdded: (_, __) {},
            onBonusNoteAdded: (_, __) {},
          ),
          const SizedBox(height: 16),
          ProtocolInfoRow(gameState: _gameState!),
          const SizedBox(height: 16),
          ProtocolVotingTable(gameState: _gameState!),
          const SizedBox(height: 16),
          ProtocolNotes(
            noteControllers: List.generate(10, (_) => TextEditingController()),
            protestCommentController: TextEditingController(),
          ),
        ],
      ),
    );
  }
}
