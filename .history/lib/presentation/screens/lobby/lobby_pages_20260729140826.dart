// lib/presentation/screens/lobby/lobby_pages.dart
import 'package:flutter/material.dart';
import '../club/club_screen.dart';
import '../game/game_screen.dart';
import '../game/game_settings_screen.dart';
import '../game/seat_setup_screen.dart';
import '../game/game_protocol_screen.dart';
import 'lobby_data.dart';

class LobbyPages {
  static List<Widget> getPages({
    required GameData gameData,
    required Function(GameData) onSettingsChanged,
    required VoidCallback onNewGame,
    required Function(GameData) onNamesChanged,
    required Function(GameData) onGameStateChanged,
    required Function(int) onSwitchToTab,
  }) {
    return [
      const ClubScreen(),

      SeatSetupScreen(
        initialData: gameData,
        onNamesChanged: onNamesChanged,
      ),
      GameScreen(
        initialData: gameData,
        onGameStateChanged: onGameStateChanged,
        onSwitchToTab: onSwitchToTab,
      ),
      GameProtocolScreen(
        gameHistory: gameData.gameHistory,
        gameState: gameData.gameState,
      ),
    ];
  }
}