import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/providers.dart';
import 'package:mafia_help/data/local/models/sub_phase.dart';
import 'package:mafia_help/presentation/viewmodel/game_viewmodel.dart';

import '../state/game_state.dart';

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
                _position.dx.clamp(0, MediaQuery.of(context).size.width - 280),
                _position.dy.clamp(0, MediaQuery.of(context).size.height - 280),
              );
            });
          }
        },
        onPanEnd: (_) => setState(() => _isDragging = false),
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ряд 1: 10 9 8 7
              Row(
                children: [
                  _calcButton(10),
                  _calcButton(9),
                  _calcButton(8),
                  _calcButton(7),
                ],
              ),
              const SizedBox(height: 8),
              // Ряд 2: 6 5 4 3
              Row(
                children: [
                  _calcButton(6),
                  _calcButton(5),
                  _calcButton(4),
                  _calcButton(3),
                ],
              ),
              const SizedBox(height: 8),
              // Ряд 3: 2 1 0 ⚔️
              Row(
                children: [
                  _calcButton(2),
                  _calcButton(1),
                  _calcButton(0),
                  _battleButton(),
                ],
              ),
              const SizedBox(height: 12),
              // Ряд 4: навигация
              Row(
                children: [
                  _navButton(Icons.arrow_back_ios, 'Назад', () => _vm.onPhaseBack()),
                  _navButton(Icons.minimize, 'Свернуть', _minimizeWindow),
                  _navButton(Icons.arrow_forward_ios, 'Вперёд', () => _vm.onPhaseForward()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _calcButton(int n) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: () => _onNumberTap(n),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade800,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            n.toString(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _battleButton() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: () => _onNumberTap(-1),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade800,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Icon(Icons.crisis_alert, size: 24),
        ),
      ),
    );
  }

  Widget _navButton(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade800,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _minimizeWindow() {
    // сворачивание окна для Desktop
  }
}