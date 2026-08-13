import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/presentation/screens/game/saved_protocols_screen.dart';
import 'package:mafia_help/presentation/widgets/protocol/protocol_header.dart';
import 'package:mafia_help/presentation/widgets/protocol/protocol_players_table.dart';
import 'package:mafia_help/presentation/widgets/protocol/protocol_info_row.dart';
import 'package:mafia_help/presentation/widgets/protocol/protocol_voting_table.dart';
import 'package:mafia_help/presentation/widgets/protocol/protocol_notes.dart';
import 'package:mafia_help/presentation/widgets/protocol/protocol_save_logic.dart';
import 'package:mdi_plus/mdi_plus.dart';
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
    final primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // 🔥 ОСНОВНОЙ КОНТЕНТ (без AppBar)
          ListView(
            padding: const EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
              bottom: 100,
            ),
            children: [
              ProtocolHeader(gameState: widget.gameState),
              const SizedBox(height: 2),
              ProtocolPlayersTable(
                gameState: widget.gameState,
                bonusPoints: _saveLogic.bonusPoints, // 🔥 ДОБАВИТЬ

                onRemovedRuleChanged: _saveLogic.updateRemovedRule,
                onBonusChanged: _saveLogic.updateBonus,
                onNoteAdded: _saveLogic.addRemovedNote,
                onBonusNoteAdded: _saveLogic.addBonusNote,
              ),
              const SizedBox(height: 2),
              ProtocolInfoRow(gameState: widget.gameState),
              const SizedBox(height: 2),
              ProtocolVotingTable(gameState: widget.gameState),
              const SizedBox(height: 2),
              ProtocolNotes(
                noteControllers: _saveLogic.noteControllers,
                protestCommentController: _saveLogic.protestCommentController,
              ),
            ],
          ),
          // 🔥 ПЛАВАЮЩИЕ КНОПКИ (СНИЗУ СПРАВА)
          // 🔥 ПЛАВАЮЩИЕ КНОПКИ (СНИЗУ СПРАВА)
Positioned(
  bottom: 24,
  right: 20,
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // 🔥 КНОПКА "СОХРАНИТЬ НА СЕРВЕР"
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: primaryColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _saveLogic.saveProtocol(context),
            borderRadius: BorderRadius.circular(50),
            child: Icon(
              Mdi.cloudUpload,
              color: isDark ? Colors.white : Colors.black87,
              size: 24,
            ),
          ),
        ),
      ),
      const SizedBox(height: 12),
      
      // 🔥 КНОПКА "СОХРАНИТЬ ЛОКАЛЬНО"
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: primaryColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _saveLogic.saveLocalProtocol(context),
            borderRadius: BorderRadius.circular(50),
            child: Icon(
              Mdi.contentSave,
              color: isDark ? Colors.white : Colors.black87,
              size: 24,
            ),
          ),
        ),
      ),
      const SizedBox(height: 12),
      
      // 🔥 КНОПКА "ПАПКА"
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: primaryColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SavedProtocolsScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(50),
            child: Icon(
              Mdi.folderOpen,
              color: isDark ? Colors.white : Colors.black87,
              size: 24,
            ),
          ),
        ),
      ),
    ],
  ),
),
        ],
      ),
    );
  }
}
