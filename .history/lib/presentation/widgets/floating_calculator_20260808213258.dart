import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/providers.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import 'package:mafia_help/presentation/viewmodel/game_viewmodel.dart';
import 'package:mafia_help/presentation/widgets/pie_menu_dialog.dart';
import 'package:mdi_plus/mdi_plus.dart';

import '../state/game_state.dart';

class FloatingCalculator extends ConsumerStatefulWidget {
  const FloatingCalculator({super.key});

  @override
  ConsumerState<FloatingCalculator> createState() => _FloatingCalculatorState();
}

class _FloatingCalculatorState extends ConsumerState<FloatingCalculator> {
  Offset _position = const Offset(130, 450);
  bool _isDragging = false;
  bool _isMinimized = false;

  static const double _digitsHeight = 220;

  GameViewModel get _vm => ref.read(gameViewModelProvider.notifier);
  GameState get _state => ref.read(gameViewModelProvider);

  void _onNumberTap(int value) {
    if (_state.currentSubPhase == SubPhase.eliminationVote) {
      _vm.submitVote(value);
      return;
    }

    if (_state.isVotingActive) {
      final controller = _vm.getVoteController();
      if (controller != null) {
        final aliveCount = _state.players.where((p) => p.isAlive).length;
        final currentTotal = controller.totalVotes;
        final remaining = aliveCount - currentTotal;

        if (value == remaining) {
          final remainingCandidates = controller.remainingCandidates;
          print('Осталось 0 голосов');
          print('Осталось кандидатов: ${remainingCandidates.length}');
          print('Номера кандидатов: $remainingCandidates');
          _vm.submitVote(value);

          for (var seat in remainingCandidates) {
            _vm.submitVote(0);
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
          _vm.submitVote(value);
          controller.nextCandidate();
          final newTotal = controller.totalVotes;
          final newRemaining = aliveCount - newTotal;
          if (newRemaining > 0) {
            _vm.submitVote(newRemaining);
          }
          return;
        }

        _vm.submitVote(value);
      }
    } else if (_state.currentSubPhase == SubPhase.bestMove) {
      _vm.submitBestMoveNumber(value);
    } else if (_state.currentSubPhase == SubPhase.mafiaShoot ||
        _state.currentSubPhase == SubPhase.donCheck ||
        _state.currentSubPhase == SubPhase.sheriffCheck) {
      _vm.submitNightAction(value);
    } else {
      _vm.onPlayerTap(value);
    }
  }

  void _onNumberLongPress(int value) {
    if (!_state.isVotingActive &&
        _state.currentSubPhase != SubPhase.mafiaShoot &&
        _state.currentSubPhase != SubPhase.donCheck &&
        _state.currentSubPhase != SubPhase.sheriffCheck) {
      PieMenuDialog.show(context, value, _vm);
    }
  }

  void _toggleMinimize() {
    setState(() {
      if (_isMinimized) {
        _position = Offset(_position.dx, _position.dy - _digitsHeight + 44);
      } else {
        _position = Offset(_position.dx, _position.dy + _digitsHeight - 44);
      }
      _isMinimized = !_isMinimized;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxTop = screenHeight - (_isMinimized ? 60 : 280);

    return Positioned(
      left: _position.dx.clamp(0, screenWidth - 150),
      top: _position.dy.clamp(0, maxTop),
      child: GestureDetector(
        onPanStart: (_) => setState(() => _isDragging = true),
        onPanUpdate: (details) {
          if (_isDragging) {
            setState(() {
              _position += details.delta;
              _position = Offset(
                _position.dx.clamp(0, screenWidth - 150),
                _position.dy.clamp(0, maxTop),
              );
            });
          }
        },
        onPanEnd: (_) => setState(() => _isDragging = false),
        child: Container(
          width: 140,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: _isMinimized
                    ? const SizedBox.shrink()
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              _buildKey('10', 10, context),
                              _buildKey('9', 9, context),
                              _buildKey('8', 8, context),
                            ],
                          ),
                          Row(
                            children: [
                              _buildKey('7', 7, context),
                              _buildKey('6', 6, context),
                              _buildKey('5', 5, context),
                            ],
                          ),
                          Row(
                            children: [
                              _buildKey('4', 4, context),
                              _buildKey('3', 3, context),
                              _buildKey('2', 2, context),
                            ],
                          ),
                          Row(
                            children: [
                              _buildKey('1', 1, context),
                              _buildKey('0', 0, context),
                              _buildKeyIcon(Mdi.target, -1, context), // 🔥 ИКОНКА ПРОМАХ
                            ],
                          ),
                        ],
                      ),
              ),
              Row(
                children: [
                  _buildNavKey(Mdi.arrowLeft, () => _vm.onPhaseBack(), context),
                  _buildNavKey(
                      _isMinimized ? Mdi.calculator : Mdi.calculator,
                      _toggleMinimize,
                      context),
                  _buildNavKey(Mdi.arrowRight, () => _vm.onPhaseForward(), context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKey(String text, int value, BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800.withOpacity(0.7) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onNumberTap(value),
            onLongPress: () => _onNumberLongPress(value),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              alignment: Alignment.center,
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 18,
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

  // 🔥 НОВЫЙ МЕТОД ДЛЯ ИКОНКИ
  Widget _buildKeyIcon(IconData icon, int value, BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800.withOpacity(0.7) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onNumberTap(value),
            onLongPress: () => _onNumberLongPress(value),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: isDark ? Colors.white : Colors.black87,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavKey(IconData icon, VoidCallback onTap, BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.grey.shade800.withOpacity(0.7)
              : Colors.grey.shade200.withOpacity(0.7),
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
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: isDark ? Colors.white : Colors.black87,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}