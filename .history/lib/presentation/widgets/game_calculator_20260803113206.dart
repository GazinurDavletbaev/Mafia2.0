import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/providers.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import 'package:mafia_help/presentation/viewmodel/game_viewmodel.dart';
import 'package:mafia_help/presentation/widgets/pie_menu_dialog.dart';

class GameCalculator extends ConsumerWidget {
  const GameCalculator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final vm = ref.read(gameViewModelProvider.notifier);
    final state = ref.read(gameViewModelProvider);

    // 🔥 ПОКАЗЫВАТЬ КАЛЬКУЛЯТОР ТОЛЬКО В ОПРЕДЕЛЁННЫХ СЛУЧАЯХ
    final bool showCalculator = state.isVotingActive ||
        state.currentSubPhase == SubPhase.eliminationVote ||
        state.currentSubPhase == SubPhase.bestMove ||
        state.currentSubPhase == SubPhase.mafiaShoot ||
        state.currentSubPhase == SubPhase.donCheck ||
        state.currentSubPhase == SubPhase.sheriffCheck;

    if (!showCalculator) {
      return const SizedBox.shrink();
    }

    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔥 10, 9, 8
          Row(
            children: [
              _buildKey(context, '10', 10, vm, state),
              _buildKey(context, '9', 9, vm, state),
              _buildKey(context, '8', 8, vm, state),
            ],
          ),
          // 🔥 7, 6, 5
          Row(
            children: [
              _buildKey(context, '7', 7, vm, state),
              _buildKey(context, '6', 6, vm, state),
              _buildKey(context, '5', 5, vm, state),
            ],
          ),
          // 🔥 4, 3, 2
          Row(
            children: [
              _buildKey(context, '4', 4, vm, state),
              _buildKey(context, '3', 3, vm, state),
              _buildKey(context, '2', 2, vm, state),
            ],
          ),
          // 🔥 1, 0, ⚔️
          Row(
            children: [
              _buildKey(context, '1', 1, vm, state),
              _buildKey(context, '0', 0, vm, state),
              _buildKey(context, '⚔️', -1, vm, state),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(
    BuildContext context,
    String text,
    int value,
    GameViewModel vm,
    GameState state,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    void onTap() {
      _onNumberTap(context, value, vm, state);
    }

    void onLongPress() {
      if (!state.isVotingActive &&
          state.currentSubPhase != SubPhase.mafiaShoot &&
          state.currentSubPhase != SubPhase.donCheck &&
          state.currentSubPhase != SubPhase.sheriffCheck) {
        PieMenuDialog.show(context, value, vm);
      }
    }

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              alignment: Alignment.center,
              child: Text(
                text,
                style: TextStyle(
                  fontSize: text.length > 2 ? 14 : 18,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onNumberTap(BuildContext context, int value, GameViewModel vm, GameState state) {
    if (state.currentSubPhase == SubPhase.eliminationVote) {
      vm.submitVote(value);
      return;
    }

    if (state.isVotingActive) {
      final controller = vm.getVoteController();
      if (controller != null) {
        final aliveCount = state.players.where((p) => p.isAlive).length;
        final currentTotal = controller.totalVotes;
        final remaining = aliveCount - currentTotal;

        if (value == remaining) {
          final remainingCandidates = controller.remainingCandidates;
          vm.submitVote(value);
          for (var seat in remainingCandidates) {
            vm.submitVote(0);
          }
          return;
        }

        if (value > remaining) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Осталось только $remaining голосов'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }

        if (controller.currentIndex == controller.totalCandidates - 2) {
          vm.submitVote(value);
          controller.nextCandidate();
          final newTotal = controller.totalVotes;
          final newRemaining = aliveCount - newTotal;
          if (newRemaining > 0) {
            vm.submitVote(newRemaining);
          }
          return;
        }

        vm.submitVote(value);
      }
    } else if (state.currentSubPhase == SubPhase.bestMove) {
      vm.submitBestMoveNumber(value);
    } else if (state.currentSubPhase == SubPhase.mafiaShoot ||
        state.currentSubPhase == SubPhase.donCheck ||
        state.currentSubPhase == SubPhase.sheriffCheck) {
      vm.submitNightAction(value);
    } else {
      vm.onPlayerTap(value);
    }
  }
}