import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/game_provider.dart';
import 'package:mafia_help/application/providers/notification_provider.dart';
import 'package:mafia_help/application/providers/club_provider.dart';
import 'package:mafia_help/application/providers/user_provider.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/presentation/viewmodel/game_viewmodel.dart';
import 'package:mafia_help/presentation/widgets/app_bottom_nav.dart';
import 'lobby_data.dart';
import 'lobby_pages.dart';

class LobbyScreen extends ConsumerStatefulWidget {
  const LobbyScreen({super.key});

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  int _selectedIndex = 0;
  GameData _gameData = GameData();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initGameData();
      ref.read(savedGameIdProvider.notifier).state = null;
      ref.invalidate(userProvider);
      ref.invalidate(clubProvider);
      ref.invalidate(pendingRequestsProvider);
    });
  }

  void _initGameData() {
    setState(() {
      _gameData = LobbyData.createInitial(ref);
    });
  }

  void _updateGameData(GameData newData) {
    setState(() {
      _gameData = newData;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    ref.listen<GameState>(gameViewModelProvider, (previous, next) {
      if (_selectedIndex == 2 || _selectedIndex == 3) {
        final vm = ref.read(gameViewModelProvider.notifier);
        _updateGameData(
          GameData(
            tournamentName: _gameData.tournamentName,
            stageName: _gameData.stageName,
            tableNumber: _gameData.tableNumber,
            gameNumber: _gameData.gameNumber,
            date: _gameData.date,
            judgeName: _gameData.judgeName,
            playerNames: _gameData.playerNames,
            gameState: next,
            gameHistory: vm.getHistory(),
          ),
        );
      }
    });

    final pages = LobbyPages.getPages(
      gameData: _gameData,
      onSettingsChanged: _updateGameData,
      onNewGame: _onNewGame,
      onNamesChanged: _updateGameData,
      onGameStateChanged: _updateGameData,
      onSwitchToTab: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: pages[_selectedIndex],
            ),
            Positioned(
              bottom: 3,
              left: 0,
              right: 0,
              child: AppBottomNav(
                currentIndex: _selectedIndex,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                  ref.invalidate(pendingRequestsProvider);
                },
                phase: _gameData.gameState.currentPhase,
                currentDay: _gameData.gameState.currentDay,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onNewGame() {
    ref.read(savedGameIdProvider.notifier).state = null;
    final vm = ref.read(gameViewModelProvider.notifier);
    vm.resetGame();

    final newGameData = GameData(
      judgeName: LobbyData.getJudgeName(ref),
      tournamentName: 'РЕЙТИНГ',
      stageName: LobbyData.getCurrentStage(),
    );
    _updateGameData(newGameData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('🔄 Новая игра создана!'),
        backgroundColor: Theme.of(context).primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}