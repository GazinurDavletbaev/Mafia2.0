import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/providers.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import 'package:mafia_help/presentation/viewmodel/game_viewmodel.dart';

class FloatingCalculator extends ConsumerStatefulWidget {
  final String gameId;

  const FloatingCalculator({super.key, required this.gameId});

  @override
  ConsumerState<FloatingCalculator> createState() => _FloatingCalculatorState();
}

class _FloatingCalculatorState extends ConsumerState<FloatingCalculator> {
  Offset _position = const Offset(20, 100);
  bool _isDragging = false;

  GameViewModel get _vm => ref.read(gameViewModelFamily(widget.gameId).notifier);
  GameState get _state => ref.read(gameViewModelFamily(widget.gameId));

  void _onNumberTap(int value) {
    if (_state.isVotingActive) {
      _vm.submitVote(value);
    } else if (_state.currentSubPhase == SubPhase.mafiaShoot ||
        _state.currentSubPhase == SubPhase.donCheck ||
        _state.currentSubPhase == SubPhase.sheriffCheck) {
      _vm.submitNightAction(value);
    }
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
                _position.dx.clamp(0, MediaQuery.of(context).size.width - 240),
                _position.dy.clamp(0, MediaQuery.of(context).size.height - 320),
              );
            });
          }
        },
        onPanEnd: (_) => setState(() => _isDragging = false),
        child: Container(
          width: 240,
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(16),
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
              // Ряд 1
              Row(
                children: [
                  _buildKey('10', () => _onNumberTap(10)),
                  _buildKey('9', () => _onNumberTap(9)),
                  _buildKey('8', () => _onNumberTap(8)),
                  _buildKey('7', () => _onNumberTap(7)),
                ],
              ),
              // Ряд 2
              Row(
                children: [
                  _buildKey('6', () => _onNumberTap(6)),
                  _buildKey('5', () => _onNumberTap(5)),
                  _buildKey('4', () => _onNumberTap(4)),
                  _buildKey('3', () => _onNumberTap(3)),
                ],
              ),
              // Ряд 3
              Row(
                children: [
                  _buildKey('2', () => _onNumberTap(2)),
                  _buildKey('1', () => _onNumberTap(1)),
                  _buildKey('0', () => _onNumberTap(0)),
                  _buildKey('⚔️', () => _onNumberTap(-1)),
                ],
              ),
              // Разделитель
              const Divider(height: 1, color: Colors.grey),
              // Ряд навигации
              Row(
                children: [
                  _buildNavKey('←', () => _vm.onPhaseBack()),
                  _buildNavKey('■', _minimizeWindow),
                  _buildNavKey('→', () => _vm.onPhaseForward()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKey(String text, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavKey(String text, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
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
    );
  }

  void _minimizeWindow() {
    // сворачивание
  }
}