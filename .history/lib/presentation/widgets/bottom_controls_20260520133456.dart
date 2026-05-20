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
    // Если показываем калькулятор
    if (showCalculator) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Верхний ряд: 10 8 6 4 2 0
            Row(
              children: [
                _buildCalculatorButton(10),
                const SizedBox(width: 8),
                _buildCalculatorButton(8),
                const SizedBox(width: 8),
                _buildCalculatorButton(6),
                const SizedBox(width: 8),
                _buildCalculatorButton(4),
                const SizedBox(width: 8),
                _buildCalculatorButton(2),
                const SizedBox(width: 8),
                _buildCalculatorButton(0),
              ],
            ),
            const SizedBox(height: 8),
            // Нижний ряд: 9 7 5 3 1 ❤️
            Row(
              children: [
                _buildCalculatorButton(9),
                const SizedBox(width: 8),
                _buildCalculatorButton(7),
                const SizedBox(width: 8),
                _buildCalculatorButton(5),
                const SizedBox(width: 8),
                _buildCalculatorButton(3),
                const SizedBox(width: 8),
                _buildCalculatorButton(1),
                const SizedBox(width: 8),
                _buildHeartButton(),
              ],
            ),
          ],
        ),
      );
    }

    // Обычные кнопки навигации
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: PhaseNavButton(icon: Icons.arrow_back_ios, onTap: onBack),
          ),
          const SizedBox(width: 20),
          const MinimizeButton(),
          const SizedBox(width: 20),
          Expanded(
            child: PhaseNavButton(icon: Icons.arrow_forward_ios, onTap: onForward),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorButton(int number) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: ElevatedButton(
          onPressed: () => onCalculatorTap(number),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade800,
            foregroundColor: Colors.white,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            number.toString(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildHeartButton() {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: ElevatedButton(
          onPressed: () => onCalculatorTap(-1),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade800,
            foregroundColor: Colors.white,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Icon(Icons.favorite, size: 24),
        ),
      ),
    );
  }
}