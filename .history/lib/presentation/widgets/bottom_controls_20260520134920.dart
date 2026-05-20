import 'package:flutter/material.dart';
import 'minimize_button.dart';
import 'phase_nav_button.dart';

class BottomControls extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onForward;
  final bool showCalculator;
  final void Function(int) onCalculatorTap;

  const BottomControls({
    super.key,
    required this.onBack,
    required this.onForward,
    this.showCalculator = false,
    required this.onCalculatorTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Кнопка НАЗАД
          PhaseNavButton(icon: Icons.arrow_back_ios, onTap: onBack),

          // По центру: либо калькулятор, либо кнопка СВЕРНУТЬ
          showCalculator ? _buildCalculator(context) : const MinimizeButton(),

          // Кнопка ВПЕРЁД
          PhaseNavButton(icon: Icons.arrow_forward_ios, onTap: onForward),
        ],
      ),
    );
  }

  Widget _buildCalculator(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _buildCalculatorButton(10, context),
            _buildCalculatorButton(9, context),
            _buildCalculatorButton(8, context),
            _buildCalculatorButton(7, context),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            _buildCalculatorButton(6, context),
            _buildCalculatorButton(5, context),
            _buildCalculatorButton(4, context),
            _buildCalculatorButton(3, context),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            _buildCalculatorButton(2, context),
            _buildCalculatorButton(1, context),
            _buildCalculatorButton(0, context),
            _buildBattleButton(context),
          ],
        ),
      ],
    );
  }

  Widget _buildCalculatorButton(int number, BuildContext context) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: ElevatedButton(
            onPressed: () => onCalculatorTap(number),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade800,
              foregroundColor: Colors.white,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              number.toString(),
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.035,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBattleButton(BuildContext context) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: ElevatedButton(
            onPressed: () => onCalculatorTap(-1),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade800,
              foregroundColor: Colors.white,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Icon(Icons.crisis_alert, size: 20),
          ),
        ),
      ),
    );
  }
}
