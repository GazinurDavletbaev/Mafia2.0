import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/presentation/screens/game/saved_protocols_screen.dart';
import 'package:mafia_help/presentation/widgets/protocol/protocol_header.dart';
import 'package:mafia_help/presentation/widgets/protocol/protocol_players_table.dart';
import 'package:mafia_help/presentation/widgets/protocol/protocol_info_row.dart';
import 'package:mafia_help/presentation/widgets/protocol/protocol_voting_table.dart';
import 'package:mafia_help/presentation/widgets/protocol/protocol_notes.dart';
import 'package:mafia_help/presentation/widgets/protocol/protocol_save_logic.dart';
import '../../../domain/rules/game_history.dart';
import '../../state/game_state.dart';

class GameProtocolScreen extends ConsumerStatefulWidget {
  final GameHistory gameHistory;
  final GameState gameState;

  const GameProtocolScreen({
    super.key,
    required this.gameHistory,
    required this.gameState,
  });

  @override
  ConsumerState<GameProtocolScreen> createState() => _GameProtocolScreenState();
}

class _GameProtocolScreenState extends ConsumerState<GameProtocolScreen> {
  late ProtocolSaveLogic _saveLogic;

  @override
  void initState() {
    super.initState();
    _saveLogic = ProtocolSaveLogic(
      gameState: widget.gameState,
      ref: ref,
    );
  }

  @override
  void dispose() {
    _saveLogic.dispose();
    super.dispose();
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
          IconButton(
            icon: Icon(
              Icons.folder_open,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SavedProtocolsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.save,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () => _saveLogic.saveProtocol(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ProtocolHeader(gameState: widget.gameState),
          const SizedBox(height: 16),
          ProtocolPlayersTable(
            gameState: widget.gameState,
            onRemovedRuleChanged: _saveLogic.updateRemovedRule,
            onBonusChanged: _saveLogic.updateBonus,
            onNoteAdded: _saveLogic.addRemovedNote,
            onBonusNoteAdded: _saveLogic.addBonusNote,
          ),
          const SizedBox(height: 16),
          ProtocolInfoRow(gameState: widget.gameState),
          const SizedBox(height: 16),
          ProtocolVotingTable(gameState: widget.gameState),
          const SizedBox(height: 16),
          ProtocolNotes(
            noteControllers: _saveLogic.noteControllers,
            protestCommentController: _saveLogic.protestCommentController,
          ),
        ],
      ),
    );
  }
}