// lib/presentation/screens/game/game_protocol_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/presentation/screens/game/saved_protocols_screen.dart';
import 'package:mafia_help/presentation/widgets/protocol/protocol_header.dart';
import 'package:mafia_help/presentation/widgets/protocol/protocol_players_table.dart';
import 'package:mafia_help/presentation/widgets/protocol/protocol_info_row.dart';
import 'package:mafia_help/presentation/widgets/protocol/protocol_voting_table.dart';
import 'package:mafia_help/presentation/widgets/protocol/protocol_notes.dart';
import 'package:mafia_help/presentation/widgets/protocol/protocol_save_logic.dart';
import 'package:mafia_help/presentation/widgets/tutorial/tutorial_manager.dart'; // ← ДОБАВИТЬ
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
  bool _tutorialsShown = false;

  // 🔑 КЛЮЧИ ДЛЯ ПОДСКАЗОК
  final Map<String, GlobalKey> _tutorialKeys = {
    'protocol_ball': GlobalKey(),
    'protocol_penalty': GlobalKey(),
    'protocol_server': GlobalKey(),
    'protocol_local': GlobalKey(),
    'protocol_file': GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    _saveLogic = ProtocolSaveLogic(
      gameState: widget.gameState,
      ref: ref,
    );

    // 🔥 ПОКАЗЫВАЕМ ПОДСКАЗКИ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showTutorials();
    });
  }

  void _showTutorials() {
    if (_tutorialsShown) return;
    if (!mounted) return;

    _tutorialsShown = true;

    TutorialManager.startTutorials(
      context: context,
      screen: 'protocol',
      ref: ref,
      keys: _tutorialKeys,
      onAllCompleted: () {
        print('🎉 Подсказки протокола показаны!');
      },
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
    final ball = _tutorialKeys['protocol_ball'];
    final penalty = _tutorialKeys['protocol_penalty'];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // 🔥 ОСНОВНОЙ КОНТЕНТ
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
                tutorialkeyball: ball,
                tutorialkeypenalty: penalty,
                gameState: widget.gameState,
                bonusPoints: _saveLogic.bonusPoints,
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
          // 🔥 ПЛАВАЮЩИЕ КНОПКИ
          Positioned(
            bottom: 24,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔥 1. СОХРАНИТЬ НА СЕРВЕР
                _buildFloatingButton(
                  key: _tutorialKeys['protocol_server'], // ← ПРИВЯЗКА
                  icon: Mdi.cloudUpload,
                  onTap: () => _saveLogic.saveProtocol(context),
                  isDark: isDark,
                  primaryColor: primaryColor,
                  tooltip: 'Сохранить на сервер',
                ),
                const SizedBox(height: 12),
                // 🔥 2. СОХРАНИТЬ ЛОКАЛЬНО
                _buildFloatingButton(
                  key: _tutorialKeys['protocol_local'], // ← ПРИВЯЗКА
                  icon: Mdi.contentSavePlus,
                  onTap: () => _saveLogic.saveLocalProtocol(context),
                  isDark: isDark,
                  primaryColor: primaryColor,
                  tooltip: 'Сохранить локально',
                ),

                const SizedBox(height: 12),
                // 🔥 4. ПАПКА
                _buildFloatingButton(
                  key: _tutorialKeys['protocol_file'], // ← ПРИВЯЗКА
                  icon: Mdi.folderOpen,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SavedProtocolsScreen(),
                      ),
                    );
                  },
                  isDark: isDark,
                  primaryColor: primaryColor,
                  tooltip: 'Сохранённые игры',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton({
    Key? key, // ← ДОБАВИТЬ ПАРАМЕТР KEY
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    required Color primaryColor,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        key: key, // ← ПРИВЯЗКА КЛЮЧА
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
            onTap: onTap,
            borderRadius: BorderRadius.circular(50),
            child: Icon(
              icon,
              color: isDark ? Colors.white : Colors.black87,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
