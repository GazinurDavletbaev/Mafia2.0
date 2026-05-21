import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/providers.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import 'package:mafia_help/presentation/viewmodel/game_viewmodel.dart';
import 'package:mafia_help/presentation/widgets/pie_menu_dialog.dart';

import '../state/game_state.dart';

class FloatingCalculator extends ConsumerStatefulWidget {
  final String gameId;

  const FloatingCalculator({super.key, required this.gameId});

  @override
  ConsumerState<FloatingCalculator> createState() => _FloatingCalculatorState();
}

class _FloatingCalculatorState extends ConsumerState<FloatingCalculator> {
  Offset _position = const Offset(150, 450);
  bool _isDragging = false;
  bool _isMinimized = false;

  static const double _width = 150;
  static const double _height = 280; // Фиксированная высота всегда

  GameViewModel get _vm =>
      ref.read(gameViewModelFamily(widget.gameId).notifier);
  GameState get _state => ref.read(gameViewModelFamily(widget.gameId));

  void _onNumberTap(int value) {
    if (_state.isVotingActive) {
      _vm.submitVote(value);
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
      _isMinimized = !_isMinimized;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanStart: (_) => setState(() => _isDragging = true),
        onPanUpdate: (details) {
          if (_isDragging) {
            setState(() {
              _position += details.delta;
              _position = Offset(
                _position.dx.clamp(0, MediaQuery.of(context).size.width - _width),
                _position.dy.clamp(0, MediaQuery.of(context).size.height - _height),
              );
            });
          }
        },
        onPanEnd: (_) => setState(() => _isDragging = false),
        child: Container(
          width: _width,
          height: _height, // Высота не меняется
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Цифровые ряды (просто невидимы, но занимают место)
              Opacity(
                opacity: _isMinimized ? 0 : 1,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ряд 1: 10 9 8
                    Row(
                      children: [
                        _buildKey('10', 10),
                        _buildKey('9', 9),
                        _buildKey('8', 8),
                      ],
                    ),
                    // Ряд 2: 7 6 5
                    Row(
                      children: [
                        _buildKey('7', 7),
                        _buildKey('6', 6),
                        _buildKey('5', 5),
                      ],
                    ),
                    // Ряд 3: 4 3 2
                    Row(
                      children: [
                        _buildKey('4', 4),
                        _buildKey('3', 3),
                        _buildKey('2', 2),
                      ],
                    ),
                    // Ряд 4: 1 0 ⚔️
                    Row(
                      children: [
                        _buildKey('1', 1),
                        _buildKey('0', 0),
                        _buildKey('⚔️', -1),
                      ],
                    ),
                    const Divider(height: 1, color: Colors.grey),
                  ],
                ),
              ),
              // Панель навигации (всегда внизу через Spacer)
              const Spacer(),
              Row(
                children: [
                  _buildNavKey('←', () => _vm.onPhaseBack()),
                  _buildNavKey(_isMinimized ? '□' : '■', _toggleMinimize),
                  _buildNavKey('→', () => _vm.onPhaseForward()),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKey(String text, int value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade700, width: 1),
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavKey(String text, VoidCallback onTap) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade700, width: 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              alignment: Alignment.center,
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}