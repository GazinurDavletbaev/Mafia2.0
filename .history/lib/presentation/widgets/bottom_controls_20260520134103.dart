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
        if (showCalculator) _buildCalculator() else const MinimizeButton(),
        
        // Кнопка ВПЕРЁД
        PhaseNavButton(icon: Icons.arrow_forward_ios, onTap: onForward),
      ],
    ),
  );
}

  Widget _buildCalculator() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCalculatorButton(10),
              const SizedBox(width: 6),
              _buildCalculatorButton(8),
              const SizedBox(width: 6),
              _buildCalculatorButton(6),
              const SizedBox(width: 6),
              _buildCalculatorButton(4),
              const SizedBox(width: 6),
              _buildCalculatorButton(2),
              const SizedBox(width: 6),
              _buildCalculatorButton(0),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCalculatorButton(9),
              const SizedBox(width: 6),
              _buildCalculatorButton(7),
              const SizedBox(width: 6),
              _buildCalculatorButton(5),
              const SizedBox(width: 6),
              _buildCalculatorButton(3),
              const SizedBox(width: 6),
              _buildCalculatorButton(1),
              const SizedBox(width: 6),
              _buildHeartButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorButton(int number) {
    return SizedBox(
      width: 40,
      height: 40,
      child: ElevatedButton(
        onPressed: () => onCalculatorTap(number),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade800,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          number.toString(),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildHeartButton() {
    return SizedBox(
      width: 40,
      height: 40,
      child: ElevatedButton(
        onPressed: () => onCalculatorTap(-1),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade800,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Icon(Icons.favorite, size: 20),
      ),
    );
  }
}